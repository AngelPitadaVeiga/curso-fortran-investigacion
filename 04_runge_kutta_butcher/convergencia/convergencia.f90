!> Test de convergencia de los tableros de Butcher.
!>
!> Para cada tablero integra el mismo problema con los pasos
!> h, h/2, h/4, ..., calcula el error en t_final frente a una solución de
!> referencia muy precisa y estima el orden observado p con un ajuste por
!> mínimos cuadrados de  log(error) = p*log(h) + cte  (con los 3 pasos más
!> finos cuyo error no está dominado por el redondeo).
!>
!> Si algún orden observado se aleja del teórico más de `tolerancia_orden`,
!> el programa termina con código de error (lo usa la integración continua).
!>
!> Uso:   convergencia_rk [convergencia/convergencia.nml]
program test_convergencia
    use, intrinsic :: iso_fortran_env, only: real64
    use modelo_lienard, only: campo_lienard, jacobiano_lienard
    use tablero_butcher, only: tablero, leer_tablero
    use solver_rk, only: problema_edo, opciones_newton, integrar_rk
    use sistema, only: crear_carpeta_de, llamar_gnuplot
    implicit none

    integer, parameter :: max_tableros = 20
    character(len=256) :: tableros(max_tableros) = ""
    character(len=256) :: tablero_referencia = "tableros/rk4.txt"
    real(real64) :: h_referencia = 1.0e-4_real64
    real(real64) :: mu = 1.0_real64
    real(real64) :: t_final = 2.0_real64
    real(real64) :: x0 = 2.0_real64
    real(real64) :: y0 = 0.0_real64
    real(real64) :: h_inicial = 0.1_real64
    integer :: n_pasos_h = 5
    real(real64) :: error_minimo = 1.0e-12_real64
    real(real64) :: tolerancia_orden = 0.3_real64
    real(real64) :: tol_newton = 1.0e-13_real64
    integer :: max_iter_newton = 50
    character(len=256) :: archivo_salida = "resultados/convergencia.dat"
    namelist /convergencia/ tableros, tablero_referencia, h_referencia, mu, t_final, x0, y0, &
                            h_inicial, n_pasos_h, error_minimo, tolerancia_orden, &
                            tol_newton, max_iter_newton, archivo_salida

    type(tablero) :: tab
    type(problema_edo) :: prob
    type(opciones_newton) :: opc
    real(real64) :: u_ref(2), p_obs
    real(real64), allocatable :: h(:), errores(:)
    character(len=64) :: nombres(max_tableros)
    integer :: ordenes(max_tableros)
    real(real64) :: constantes(max_tableros)   ! C de la recta teórica C*h**p
    integer :: n_tab, i, k, unidad, n_fallos
    logical :: ok

    call leer_entrada()

    prob%campo => campo_lienard
    prob%jacobiano => jacobiano_lienard
    prob%p = [mu]
    opc%tolerancia = tol_newton
    opc%max_iter = max_iter_newton

    ! Solución de referencia
    u_ref = solucion_final(trim(tablero_referencia), h_referencia)
    print '(a, 2es24.16)', 'Referencia en t_final: ', u_ref

    h = [(h_inicial / 2.0_real64**k, k = 0, n_pasos_h - 1)]
    allocate(errores(n_pasos_h))

    call crear_carpeta_de(trim(archivo_salida))
    open(newunit=unidad, file=archivo_salida, status="replace", action="write")
    write(unidad, '(a)') '# Test de convergencia: error en t_final frente a h'
    write(unidad, '(a, es10.3, a, es10.3)') '# mu = ', mu, '   t_final = ', t_final

    ! Solo las entradas no vacías de la lista (puede haber huecos).
    tableros = [pack(tableros, tableros /= ""), spread(repeat(" ", 256), 1, count(tableros == ""))]
    n_tab = count(tableros /= "")
    n_fallos = 0
    print '(/, a)', '  Tablero                       orden teorico   orden observado'
    print '(a)',    '  ------------------------------------------------------------'
    do i = 1, n_tab
        call leer_tablero(trim(tableros(i)), tab)
        nombres(i) = tab%nombre
        ordenes(i) = tab%orden
        do k = 1, n_pasos_h
            errores(k) = maxval(abs(solucion_final(trim(tableros(i)), h(k)) - u_ref))
        end do

        ! Bloque de datos de este tablero (separados por dos líneas en blanco
        ! para que gnuplot los distinga con "index").
        write(unidad, '(a)') '# ' // tab%nombre
        write(unidad, '(a)') '#        h                   error'
        do k = 1, n_pasos_h
            write(unidad, '(2es20.10)') h(k), errores(k)
        end do
        write(unidad, '(/)')

        p_obs = orden_observado(h, errores, error_minimo)
        constantes(i) = constante_teorica(h, errores, error_minimo, tab%orden)
        ok = abs(p_obs - tab%orden) <= tolerancia_orden
        if (.not. ok) n_fallos = n_fallos + 1
        print '(2x, a30, i8, f18.2, 4x, a)', tab%nombre, tab%orden, p_obs, merge('OK   ', 'FALLO', ok)
    end do
    close(unidad)
    print '(/, a)', 'Datos escritos en ' // trim(archivo_salida)

    call escribir_script_gnuplot()
    call llamar_gnuplot(script_gnuplot(), "archivo='" // trim(archivo_salida) // "'")

    if (n_fallos > 0) then
        print '(a, i0, a)', 'ERROR: ', n_fallos, ' tablero(s) con orden observado distinto del teorico.'
        stop 1
    end if
    print '(a)', 'Todos los ordenes observados coinciden con los teoricos.'

contains

    subroutine leer_entrada()
        character(len=256) :: archivo, mensaje
        integer :: u, estado
        archivo = "convergencia/convergencia.nml"
        if (command_argument_count() >= 1) call get_command_argument(1, archivo)
        open(newunit=u, file=archivo, status="old", action="read", iostat=estado, iomsg=mensaje)
        if (estado /= 0) then
            print '(a)', 'Error: no puedo abrir ' // trim(archivo) // ': ' // trim(mensaje)
            stop 1
        end if
        read(u, nml=convergencia, iostat=estado, iomsg=mensaje)
        if (estado /= 0) then
            print '(a)', 'Error leyendo el namelist &convergencia: ' // trim(mensaje)
            stop 1
        end if
        close(u)
    end subroutine leer_entrada

    !> Integra con el tablero y el paso dados y devuelve u(t_final).
    function solucion_final(archivo_tablero, paso) result(u_fin)
        character(len=*), intent(in) :: archivo_tablero
        real(real64), intent(in) :: paso
        real(real64) :: u_fin(2)
        type(tablero) :: tb
        real(real64), allocatable :: t(:), u(:, :)
        integer :: n, n_hechos

        call leer_tablero(archivo_tablero, tb)
        n = nint(t_final / paso)
        call integrar_rk(tb, prob, [x0, y0], paso, n, opc, t, u, n_hechos)
        if (n_hechos /= n) then
            print '(a)', 'Error: la integracion con ' // tb%nombre // ' no ha terminado.'
            stop 1
        end if
        u_fin = u(:, n)
    end function solucion_final

    !> Pendiente del ajuste por mínimos cuadrados de log(e) frente a log(h)
    !> con los 3 pasos más pequeños cuyo error supera e_min. Se descartan:
    !>  - los errores menores que e_min, dominados por el redondeo;
    !>  - los pasos grandes, que pueden no estar aún en el régimen
    !>    asintótico error ~ C*h**p (le pasa, por ejemplo, al RK3 de Kutta).
    pure function orden_observado(h, e, e_min) result(p)
        real(real64), intent(in) :: h(:), e(:), e_min
        real(real64) :: p
        integer, parameter :: n_ajuste = 3
        logical :: usar(size(h))
        real(real64) :: lx(size(h)), ly(size(h)), mx, my
        integer :: m, k

        ! Los n_ajuste errores válidos con menor h (h está en orden decreciente).
        usar = .false.
        m = 0
        do k = size(h), 1, -1
            if (e(k) > e_min .and. m < n_ajuste) then
                usar(k) = .true.
                m = m + 1
            end if
        end do
        if (m < 2) then
            p = 0.0_real64           ! no se puede estimar: se marcará como FALLO
            return
        end if
        lx = log(h)
        ly = log(max(e, tiny(1.0_real64)))
        mx = sum(lx, mask=usar) / m
        my = sum(ly, mask=usar) / m
        p = sum((lx - mx) * (ly - my), mask=usar) / sum((lx - mx)**2, mask=usar)
    end function orden_observado

    !> C tal que C*h**p pasa por el error del menor h que está por encima
    !> de e_min (el punto más cercano al régimen asintótico).
    pure function constante_teorica(h, e, e_min, p) result(c)
        real(real64), intent(in) :: h(:), e(:), e_min
        integer, intent(in) :: p
        real(real64) :: c
        integer :: k
        c = e(1) / h(1)**p
        do k = 1, size(h)
            if (e(k) > e_min) c = e(k) / h(k)**p
        end do
    end function constante_teorica

    function script_gnuplot() result(nombre)
        character(len=:), allocatable :: nombre
        nombre = trim(archivo_salida(1:len_trim(archivo_salida)-4)) // ".gp"
    end function script_gnuplot

    !> Genera un script de gnuplot a medida: una curva por tablero y, en el
    !> mismo color y a trazos, la recta de pendiente teórica C*h**p.
    subroutine escribir_script_gnuplot()
        integer :: u, j
        character(len=16) :: color(7) = [character(len=16) :: '#1f77b4', '#ff7f0e', '#2ca02c', &
                                         '#d62728', '#9467bd', '#8c564b', '#e377c2']
        character(len=32) :: c

        open(newunit=u, file=script_gnuplot(), status="replace", action="write")
        write(u, '(a)') '# Script generado por convergencia_rk. Uso: gnuplot ' // script_gnuplot()
        write(u, '(a)') 'if (!exists("archivo")) archivo = "' // trim(archivo_salida) // '"'
        write(u, '(a)') 'salida = archivo[1:strlen(archivo)-4] . ".png"'
        write(u, '(a)') 'if (strstrt(GPVAL_TERMINALS, "pngcairo") > 0) {'
        write(u, '(a)') '    set terminal pngcairo size 900,700 enhanced font "Arial,11"'
        write(u, '(a)') '} else {'
        write(u, '(a)') '    set terminal png size 900,700 font "Arial,11"'
        write(u, '(a)') '}'
        write(u, '(a)') 'set output salida'
        write(u, '(a)') 'set logscale xy'
        write(u, '(a)') 'set format y "10^{%L}"'
        write(u, '(a)') 'set format x "10^{%L}"'
        write(u, '(a, es12.4, a, es12.4, a)') 'set xrange [', h(size(h)) / 1.5_real64, ':', &
                                              h(1) * 1.5_real64, ']'
        write(u, '(a)') 'set xlabel "h"'
        write(u, '(a)') 'set ylabel "error en t_{final}"'
        write(u, '(a)') 'set title "Convergencia de los tableros de Butcher\n' // &
                        '(a trazos: pendiente teorica, desplazada)"'
        write(u, '(a)') 'set grid'
        write(u, '(a)') 'set key bottom right font ",10"'
        write(u, '(a, es12.4)') 'emin = ', error_minimo
        write(u, '(a)', advance='no') 'plot '
        do j = 1, n_tab
            c = color(mod(j - 1, size(color)) + 1)
            ! Datos (línea continua) y recta teórica C*h**p (a trazos), evaluada
            ! en los mismos h: en escala log-log es una recta de pendiente p.
            ! Se desplaza hacia abajo (factor 0.1) para que no tape los datos.
            write(u, '(a, i0, a, i0, a)', advance='no') 'archivo index ', j - 1, &
                ' using 1:2 with linespoints lw 2 pt 7 lc rgb "' // trim(c) // &
                '" title "' // trim(nombres(j)) // ' (p = ', ordenes(j), ')", '
            write(u, '(a, i0, a, es14.6, a, i0, a)', advance='no') 'archivo index ', j - 1, &
                ' using 1:(', 0.1_real64 * constantes(j), '*$1**', ordenes(j), ') with lines dt 2 lw 1.5 lc rgb "' // &
                trim(c) // '" notitle'
            if (j < n_tab) write(u, '(a)', advance='no') ', '
        end do
        write(u, '(a)') ''
        close(u)
    end subroutine escribir_script_gnuplot

end program test_convergencia
