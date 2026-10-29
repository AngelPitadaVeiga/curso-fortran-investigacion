!> Orden de convergencia observado de uno o varios Runge-Kutta.
!>
!> Uso:   convergencia tableros/heun.txt tableros/rk4.txt ...
!>
!> Van der Pol con mu = 1 desde (2, 0) hasta t = 1, con pasos h = 0.1, 0.05,
!> ..., 0.1/32. El error en t = 1 se mide frente a una referencia (RK4 con
!> h = 1e-4) y el orden observado es log2(error(h) / error(h/2)) con los dos
!> pasos más finos cuyo error supera 1e-11 (por debajo domina el redondeo).
!>
!> Escribe resultados/convergencia.dat y termina con código 1 si algún
!> orden observado se desvía más de 0.3 del teórico (así lo usa la
!> integración continua).
program convergencia
    use, intrinsic :: iso_fortran_env, only: real64
    use tablero_butcher, only: tablero, leer_tablero
    use runge_kutta, only: integrar_rk
    implicit none

    real(real64), parameter :: mu = 1.0_real64, t_final = 1.0_real64
    real(real64), parameter :: u0(2) = [2.0_real64, 0.0_real64]
    integer, parameter :: n_h = 6
    real(real64), parameter :: error_minimo = 1.0e-11_real64
    real(real64), parameter :: tolerancia_orden = 0.3_real64

    type(tablero) :: tab
    character(len=256) :: archivo
    real(real64), allocatable :: u(:, :)
    real(real64) :: u_ref(2), h(n_h), error(n_h), orden
    integer :: i, j, n_pasos, unidad
    logical :: todo_bien

    if (command_argument_count() == 0) then
        print '(a)', 'Uso: convergencia tablero1.txt [tablero2.txt ...]'
        stop 1
    end if

    ! Solución de referencia.
    call leer_tablero('tableros/rk4.txt', tab)
    n_pasos = nint(t_final / 1.0e-4_real64)
    call integrar_rk(tab, u0, mu, t_final / n_pasos, n_pasos, u)
    u_ref = u(:, n_pasos)

    h = [(0.1_real64 / 2**(j - 1), j = 1, n_h)]
    todo_bien = .true.
    open(newunit=unidad, file='resultados/convergencia.dat', status='replace', action='write')
    print '(a)', '                   metodo   orden teorico   orden observado'

    do i = 1, command_argument_count()
        call get_command_argument(i, archivo)
        call leer_tablero(trim(archivo), tab)

        do j = 1, n_h
            n_pasos = nint(t_final / h(j))
            call integrar_rk(tab, u0, mu, h(j), n_pasos, u)
            error(j) = maxval(abs(u(:, n_pasos) - u_ref))
        end do

        ! Pareja de pasos más fina con error por encima del redondeo.
        orden = 0
        do j = n_h, 2, -1
            if (error(j) > error_minimo) then
                orden = log(error(j-1) / error(j)) / log(2.0_real64)
                exit
            end if
        end do

        ! Un bloque por método, separados por dos líneas en blanco (index de gnuplot).
        ! La primera línea del bloque da el título de la curva.
        if (i > 1) write(unidad, '(/)')
        write(unidad, '(a)') '"h" "' // tab%nombre // '"'
        do j = 1, n_h
            write(unidad, '(2es16.8)') h(j), error(j)
        end do

        if (abs(orden - tab%orden) <= tolerancia_orden) then
            print '(a25, i10, f18.2, a)', tab%nombre, tab%orden, orden, '   OK'
        else
            print '(a25, i10, f18.2, a)', tab%nombre, tab%orden, orden, '   FALLA'
            todo_bien = .false.
        end if
    end do
    close(unidad)
    print '(a)', 'Errores escritos en resultados/convergencia.dat'

    if (.not. todo_bien) stop 1
end program convergencia
