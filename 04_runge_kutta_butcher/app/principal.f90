!> Bloque 04: Runge-Kutta general definido por un tablero de Butcher.
!>
!> Uso:   rk_butcher                              (lee entrada.nml)
!>        rk_butcher otro.nml                     (otro archivo de entrada)
!>        rk_butcher otro.nml tableros/rk4.txt    (además, cambia el tablero)
!>
!> Escribe  t  x  y  en <prefijo_salida><nombre del tablero>.dat y dibuja
!> la solución con gnuplot.
program rk_butcher
    use, intrinsic :: iso_fortran_env, only: real64, int64
    use modelo_lienard, only: campo_lienard, jacobiano_lienard
    use tablero_butcher, only: tablero, leer_tablero
    use solver_rk, only: problema_edo, opciones_newton, integrar_rk
    use sistema, only: crear_carpeta_de, llamar_gnuplot
    implicit none

    ! Parámetros del namelist (con valores por defecto).
    character(len=256) :: tablero_archivo = "tableros/rk4.txt"
    real(real64) :: mu = 1.0_real64
    real(real64) :: h = 0.01_real64
    real(real64) :: t_final = 30.0_real64
    real(real64) :: x0 = 0.5_real64
    real(real64) :: y0 = 0.0_real64
    real(real64) :: tol_newton = 1.0e-10_real64
    integer :: max_iter_newton = 20
    character(len=256) :: prefijo_salida = "resultados/"
    integer :: paso_escritura = 1
    namelist /parametros/ tablero_archivo, mu, h, t_final, x0, y0, tol_newton, &
                          max_iter_newton, prefijo_salida, paso_escritura

    type(tablero) :: tab
    type(problema_edo) :: prob
    type(opciones_newton) :: opc
    real(real64), allocatable :: t(:), u(:, :)
    character(len=:), allocatable :: archivo_salida
    integer :: n_pasos, n_hechos
    integer(int64) :: inicio, fin, ticks_por_segundo
    real(real64) :: iter_media

    call leer_entrada()

    call leer_tablero(trim(tablero_archivo), tab)
    if (tab%explicito) then
        print '(a, i0, a, i0, a)', 'Metodo: ' // tab%nombre // ' (explicito, s = ', tab%s, &
                                   ', orden ', tab%orden, ')'
    else
        print '(a, i0, a, i0, a)', 'Metodo: ' // tab%nombre // ' (implicito, s = ', tab%s, &
                                   ', orden ', tab%orden, ')'
    end if

    ! El problema: punteros al campo y al jacobiano del modelo de Liénard.
    ! El solver solo ve "un campo vectorial con esta interfaz".
    prob%campo => campo_lienard
    prob%jacobiano => jacobiano_lienard
    prob%p = [mu]                    ! asignación con reserva automática

    opc%tolerancia = tol_newton
    opc%max_iter = max_iter_newton

    n_pasos = nint(t_final / h)
    print '(a, es10.3, a, es10.3, a, i0)', 'mu = ', mu, '   h = ', h, '   pasos = ', n_pasos

    call system_clock(inicio, ticks_por_segundo)
    call integrar_rk(tab, prob, [x0, y0], h, n_pasos, opc, t, u, n_hechos, iter_media)
    call system_clock(fin)
    print '(a, f8.3, a)', 'Tiempo de integracion: ', real(fin - inicio, real64) / ticks_por_segundo, ' s'
    if (.not. tab%explicito) print '(a, f6.2)', 'Iteraciones de Newton por paso (media): ', iter_media

    archivo_salida = trim(prefijo_salida) // nombre_base(trim(tablero_archivo)) // ".dat"
    call escribir_resultados()
    if (n_hechos == n_pasos) then
        print '(a, 2es14.6)', 'Estado final (x, y) = ', u(:, n_pasos)
    end if

    call llamar_gnuplot("graficar.gp", "archivo='" // archivo_salida // "'; titulo='" // tab%nombre // "'")

contains

    !> Lee el namelist; un segundo argumento opcional sustituye al tablero.
    subroutine leer_entrada()
        character(len=256) :: archivo_entrada, mensaje
        integer :: unidad, estado

        archivo_entrada = "entrada.nml"
        if (command_argument_count() >= 1) call get_command_argument(1, archivo_entrada)

        open(newunit=unidad, file=archivo_entrada, status="old", action="read", &
             iostat=estado, iomsg=mensaje)
        if (estado /= 0) then
            print '(a)', 'Error: no puedo abrir ' // trim(archivo_entrada) // ': ' // trim(mensaje)
            stop 1
        end if
        read(unidad, nml=parametros, iostat=estado, iomsg=mensaje)
        if (estado /= 0) then
            print '(a)', 'Error leyendo el namelist &parametros: ' // trim(mensaje)
            stop 1
        end if
        close(unidad)
        print '(a)', 'Parametros leidos de ' // trim(archivo_entrada)

        if (command_argument_count() >= 2) call get_command_argument(2, tablero_archivo)
    end subroutine leer_entrada

    !> "tableros/rk4.txt" -> "rk4"
    pure function nombre_base(ruta) result(base)
        character(len=*), intent(in) :: ruta
        character(len=:), allocatable :: base
        integer :: i, j
        i = max(index(ruta, "/", back=.true.), index(ruta, "\", back=.true.))
        j = index(ruta, ".", back=.true.)
        if (j <= i) j = len(ruta) + 1
        base = ruta(i+1:j-1)
    end function nombre_base

    !> Escribe un estado de cada `paso_escritura` (para no generar archivos
    !> enormes en integraciones largas) y, siempre, los 200 últimos pasos
    !> calculados: si el método explota, se ve cómo lo hace.
    subroutine escribir_resultados()
        integer :: unidad, k

        call crear_carpeta_de(archivo_salida)
        open(newunit=unidad, file=archivo_salida, status="replace", action="write")
        write(unidad, '(a)') '# Lienard (Van der Pol) - ' // tab%nombre
        write(unidad, '(a, es12.5, a, es12.5, a, 2es12.5)') &
            '# mu = ', mu, '  h = ', h, '  (x0, y0) = ', x0, y0
        write(unidad, '(a)') '#           t                       x                       y'
        do k = 0, n_hechos
            if (mod(k, paso_escritura) == 0 .or. k > n_hechos - 200) then
                write(unidad, '(3es24.16)') t(k), u(1, k), u(2, k)
            end if
        end do
        close(unidad)
        print '(a)', 'Resultados escritos en ' // archivo_salida
    end subroutine escribir_resultados

end program rk_butcher
