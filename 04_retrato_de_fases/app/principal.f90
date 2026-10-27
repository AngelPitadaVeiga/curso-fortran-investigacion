!> Bloque 04: retratos de fases de la ecuación de Liénard (Van der Pol)
!> para varios valores de mu.
!>
!> Uso:   retrato              (lee entrada.nml)
!>        retrato otro.nml
!>
!> Para cada mu escribe en la carpeta de resultados:
!>   campo_<i>.dat         campo de vectores normalizado
!>   trayectorias_<i>.dat  trayectorias desde una rejilla de condiciones iniciales
!>   ciclo_<i>.dat         ciclo límite (tras descartar el transitorio)
!>   nulclinas_<i>.dat     nulclinas
!> y genera un script de gnuplot con una figura de varios paneles.
program retrato
    use, intrinsic :: iso_fortran_env, only: real64
    use modelo_lienard, only: campo_lienard, jacobiano_lienard
    use tablero_butcher, only: tablero, leer_tablero
    use solver_rk, only: problema_edo, opciones_newton
    use retrato_fases, only: caja_plano, ciclo_limite, escribir_campo, escribir_trayectorias, &
                             escribir_nulclinas
    use sistema, only: crear_carpeta_de, llamar_gnuplot
    implicit none

    integer, parameter :: max_mus = 10
    real(real64) :: mus(max_mus) = -1.0_real64        ! -1 = hueco sin usar
    character(len=256) :: tablero_archivo = "../03_runge_kutta_butcher/tableros/rk4.txt"
    real(real64) :: h = 0.01_real64
    real(real64) :: t_transitorio = 100.0_real64
    real(real64) :: t_ciclo = 20.0_real64
    real(real64) :: t_trayectoria = 10.0_real64
    real(real64) :: margen = 1.6_real64
    integer :: n_flechas = 21
    integer :: n_condiciones = 5
    character(len=256) :: carpeta = "resultados/"
    namelist /parametros/ mus, tablero_archivo, h, t_transitorio, t_ciclo, t_trayectoria, &
                       margen, n_flechas, n_condiciones, carpeta

    type(tablero) :: tab
    type(problema_edo) :: prob
    type(opciones_newton) :: opc
    type(caja_plano), allocatable :: cajas(:)
    real(real64), allocatable :: lista_mus(:)
    integer :: i, unidad

    call leer_entrada()
    call leer_tablero(trim(tablero_archivo), tab)
    print '(a)', 'Metodo: ' // tab%nombre

    lista_mus = pack(mus, mus >= 0.0_real64)
    allocate(cajas(size(lista_mus)))

    prob%campo => campo_lienard
    prob%jacobiano => jacobiano_lienard
    call crear_carpeta_de(trim(carpeta) // "x")

    do i = 1, size(lista_mus)
        print '(a, f8.3)', 'Calculando mu = ', lista_mus(i)
        prob%p = [lista_mus(i)]
        call ciclo_limite(tab, prob, opc, [2.0_real64, 0.0_real64], h, t_transitorio, t_ciclo, &
                          margen, archivo("ciclo", i), cajas(i))
        call escribir_campo(archivo("campo", i), prob, cajas(i), n_flechas)
        call escribir_trayectorias(archivo("trayectorias", i), tab, prob, opc, cajas(i), &
                                   n_condiciones, h, t_trayectoria)
        call escribir_nulclinas(archivo("nulclinas", i), prob%p, cajas(i), 400)
    end do
    print '(a)', 'Datos escritos en ' // trim(carpeta)

    ! Lista de valores de mu (la usa graficar.jl para los títulos).
    open(newunit=unidad, file=trim(carpeta) // "mus.dat", status="replace", action="write")
    write(unidad, '(a)') '# Valores de mu: el panel k corresponde a los archivos *_k.dat'
    write(unidad, '(es16.8)') lista_mus
    close(unidad)

    call escribir_script()
    call llamar_gnuplot(trim(carpeta) // "retrato.gp", "carpeta='" // trim(carpeta) // "'")

contains

    subroutine leer_entrada()
        character(len=256) :: nombre, mensaje
        integer :: u, estado
        nombre = "entrada.nml"
        if (command_argument_count() >= 1) call get_command_argument(1, nombre)
        open(newunit=u, file=nombre, status="old", action="read", iostat=estado, iomsg=mensaje)
        if (estado /= 0) then
            print '(a)', 'Error: no puedo abrir ' // trim(nombre) // ': ' // trim(mensaje)
            stop 1
        end if
        read(u, nml=parametros, iostat=estado, iomsg=mensaje)
        if (estado /= 0) then
            print '(a)', 'Error leyendo el namelist &parametros: ' // trim(mensaje)
            stop 1
        end if
        close(u)
        print '(a)', 'Parametros leidos de ' // trim(nombre)
    end subroutine leer_entrada

    !> "campo", 2  ->  "resultados/campo_2.dat"
    function archivo(tipo, i) result(nombre)
        character(len=*), intent(in) :: tipo
        integer, intent(in) :: i
        character(len=:), allocatable :: nombre
        character(len=12) :: num
        write(num, '(i0)') i
        nombre = trim(carpeta) // tipo // "_" // trim(num) // ".dat"
    end function archivo

    !> Script de gnuplot con un panel por cada mu. Se genera desde Fortran
    !> porque el número de paneles y los rangos dependen de los datos.
    subroutine escribir_script()
        integer :: u, j
        character(len=:), allocatable :: d
        character(len=8) :: valor

        open(newunit=u, file=trim(carpeta) // "retrato.gp", status="replace", action="write")
        write(u, '(a)') '# Script generado por el programa retrato (bloque 04).'
        write(u, '(a)') '# Uso, desde la carpeta del bloque:  gnuplot ' // trim(carpeta) // 'retrato.gp'
        write(u, '(a)') 'if (!exists("carpeta")) carpeta = "' // trim(carpeta) // '"'
        write(u, '(a)') 'if (strstrt(GPVAL_TERMINALS, "pngcairo") > 0) {'
        write(u, '(a, i0, a)') '    set terminal pngcairo size ', 520 * size(lista_mus), &
                               ',560 enhanced font "Arial,11"'
        write(u, '(a)') '} else {'
        write(u, '(a, i0, a)') '    set terminal png size ', 520 * size(lista_mus), ',560 font "Arial,11"'
        write(u, '(a)') '}'
        write(u, '(a)') 'set output carpeta . "retrato.png"'
        write(u, '(a, i0, a)') 'set multiplot layout 1,', size(lista_mus), &
                               ' title "Retratos de fases de la ecuacion de Lienard: x'' = y,  y'' = -f(x) y - g(x)"'
        write(u, '(a)') 'set xlabel "x"'
        write(u, '(a)') 'set ylabel "y"'
        write(u, '(a)') 'set key bottom right font ",9" opaque'
        do j = 1, size(lista_mus)
            d = 'carpeta . "'
            write(valor, '(f8.2)') lista_mus(j)          ! f0.2 escribiría ".10"
            write(u, '(a)') 'set title "mu = ' // trim(adjustl(valor)) // '"'
            write(u, '(a, 4(es12.4, a))') 'set xrange [', cajas(j)%x_min, ':', cajas(j)%x_max, &
                                          ']; set yrange [', cajas(j)%y_min, ':', cajas(j)%y_max, ']'
            write(u, '(a)') 'plot ' // d // nombre_corto("campo", j) // &
                '" using 1:2:3:4 with vectors head size 0.08,20 filled lc rgb "#9e9e9e" notitle, \'
            write(u, '(a)') '     ' // d // nombre_corto("trayectorias", j) // &
                '" using 1:2 with lines lw 0.8 lc rgb "#6baed6" title "trayectorias", \'
            write(u, '(a)') '     ' // d // nombre_corto("nulclinas", j) // &
                '" index 0 using 1:2 with lines dt 2 lw 2 lc rgb "#ff7f0e" title "x'' = 0", \'
            write(u, '(a)') '     ' // d // nombre_corto("nulclinas", j) // &
                '" index 1 using 1:2 with lines dt 2 lw 2 lc rgb "#2ca02c" title "y'' = 0", \'
            write(u, '(a)') '     ' // d // nombre_corto("ciclo", j) // &
                '" using 1:2 with lines lw 3 lc rgb "#d62728" title "ciclo limite"'
        end do
        write(u, '(a)') 'unset multiplot'
        write(u, '(a)') 'print "Figura escrita en " . carpeta . "retrato.png"'
        close(u)
    end subroutine escribir_script

    !> "campo", 2 -> "campo_2.dat" (sin la carpeta)
    function nombre_corto(tipo, i) result(nombre)
        character(len=*), intent(in) :: tipo
        integer, intent(in) :: i
        character(len=:), allocatable :: nombre
        character(len=12) :: num
        write(num, '(i0)') i
        nombre = tipo // "_" // trim(num) // ".dat"
    end function nombre_corto

end program retrato
