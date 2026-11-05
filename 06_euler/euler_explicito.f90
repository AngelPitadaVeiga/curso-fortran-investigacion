!> Euler explícito para el oscilador de Van der Pol, todo en un archivo.
!>
!>     x' = y
!>     y' = -mu*(x**2 - 1)*y - x
!>
!> Método:  u_{k+1} = u_k + h*F(u_k),  con u = (x, y).
!>
!>     gfortran euler_explicito.f90 -o euler_explicito
!>     ./euler_explicito
program euler_explicito
    use iso_fortran_env, only: real64
    implicit none

    ! Parámetros del problema. Para cambiarlos hay que recompilar
    ! (en la unidad 07 se leerán de un archivo de entrada).
    real(real64), parameter :: mu = 1.0_real64
    real(real64), parameter :: h = 0.01_real64
    real(real64), parameter :: t_final = 30.0_real64
    real(real64), parameter :: x0 = 0.5_real64, y0 = 0.0_real64

    real(real64) :: u(2)                ! estado actual (x, y)
    integer :: k, n_pasos, unidad

    n_pasos = nint(t_final / h)         ! nint: entero más próximo
    u = [x0, y0]

    open(newunit=unidad, file="euler_explicito.dat", status="replace", action="write")
    write(unidad, '(a)') '#           t                       x                       y'
    write(unidad, '(3es24.16)') 0.0_real64, u
    do k = 1, n_pasos
        u = u + h * campo(u)            ! un paso de Euler, con arrays
        write(unidad, '(3es24.16)') k * h, u
        if (maxval(abs(u)) > 1.0e6_real64) then
            print '(a, f7.2)', 'La solucion ha explotado en t =', k * h
            exit
        end if
    end do
    close(unidad)

    print '(a, i0, a)', 'Euler explicito: ', n_pasos, ' pasos. Resultados en euler_explicito.dat'
    print '(a, 2es14.6)', 'Estado final (x, y) = ', u

contains

    !> Campo vectorial de Van der Pol: devuelve F(u) = (x', y').
    function campo(u) result(du)
        real(real64), intent(in) :: u(2)
        real(real64) :: du(2)
        du(1) = u(2)
        du(2) = -mu * (u(1)**2 - 1) * u(2) - u(1)
    end function campo

end program euler_explicito
