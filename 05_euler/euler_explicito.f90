!> Euler explícito para el oscilador de Van der Pol, todo en un archivo.
!>
!>     x' = y
!>     y' = -mu*(x**2 - 1)*y - x
!>
!> Método:  u_{k+1} = u_k + h*F(u_k),  con u = (x, y).
!>
!> Se integra durante mucho tiempo (3000, unos 450 periodos) y se escribe un punto
!> cada 0.1 de tiempo, sea cual sea h.
!>
!>     gfortran euler_explicito.f90 -o euler_explicito
!>     ./euler_explicito
program euler_explicito
    implicit none

    ! Parámetros del problema. Para cambiarlos hay que recompilar
    ! (en la unidad 07 se leerán de un archivo de entrada).
    double precision, parameter :: mu = 1.0d0
    double precision, parameter :: h = 0.01d0
    double precision, parameter :: t_final = 3000.0d0
    double precision, parameter :: dt_escritura = 0.1d0
    double precision, parameter :: x0 = 0.5d0, y0 = 0.0d0

    double precision :: u(2)             ! estado actual (x, y)
    integer :: k, n_pasos, paso_escritura, unidad

    n_pasos = nint(t_final / h)          ! nint: entero más próximo
    paso_escritura = max(1, nint(dt_escritura / h))
    u = [x0, y0]

    open(newunit=unidad, file="euler_explicito.dat", status="replace", action="write")
    write(unidad, '(a)') '#           t                       x                       y'
    write(unidad, '(3es24.16)') 0.0d0, u
    do k = 1, n_pasos
        u = u + h * campo(u)             ! un paso de Euler, con arrays
        if (mod(k, paso_escritura) == 0) write(unidad, '(3es24.16)') k * h, u
        if (maxval(abs(u)) > 1.0d6) then
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
        double precision, intent(in) :: u(2)
        double precision :: du(2)
        du(1) = u(2)
        du(2) = -mu * (u(1)**2 - 1) * u(2) - u(1)
    end function campo

end program euler_explicito
