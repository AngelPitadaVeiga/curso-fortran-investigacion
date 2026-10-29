!> Euler explícito para el oscilador de Van der Pol, todo en un archivo.
!>
!>     x' = y
!>     y' = -mu*(x**2 - 1)*y - x
!>
!> Método:  u_{k+1} = u_k + h*F(u_k),  con u = (x, y).
!>
!>     gfortran euler.f90 -o euler
!>     ./euler
!>     gnuplot graficar.gp          (genera euler.png)
program euler
    use, intrinsic :: iso_fortran_env, only: real64
    implicit none

    ! Parámetros del problema. Para cambiarlos hay que recompilar
    ! (en el bloque 06 se leerán de un archivo de entrada).
    real(real64), parameter :: mu = 1.0_real64
    real(real64), parameter :: h = 0.01_real64
    real(real64), parameter :: t_final = 30.0_real64
    real(real64), parameter :: x0 = 0.5_real64, y0 = 0.0_real64

    real(real64) :: u(2)                ! estado actual (x, y)
    integer :: k, n_pasos, unidad

    n_pasos = nint(t_final / h)         ! nint: entero más próximo
    u = [x0, y0]

    open(newunit=unidad, file="euler.dat", status="replace", action="write")
    write(unidad, '(a)') '#           t                       x                       y'
    write(unidad, '(3es24.16)') 0.0_real64, u
    do k = 1, n_pasos
        u = u + h * campo(u)            ! un paso de Euler, con arrays
        write(unidad, '(3es24.16)') k * h, u
    end do
    close(unidad)

    print '(a, i0, a)', 'Hechos ', n_pasos, ' pasos. Resultados en euler.dat'
    print '(a, 2es14.6)', 'Estado final (x, y) = ', u

contains

    !> Campo vectorial de Van der Pol: devuelve F(u) = (x', y').
    !> Una función puede devolver un array. intent(in): solo se lee u.
    function campo(u) result(du)
        real(real64), intent(in) :: u(2)
        real(real64) :: du(2)
        du(1) = u(2)
        du(2) = -mu * (u(1)**2 - 1) * u(2) - u(1)
    end function campo

end program euler
