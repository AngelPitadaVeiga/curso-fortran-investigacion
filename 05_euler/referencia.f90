!> Solución de referencia para Van der Pol, con el mismo tiempo final y la misma
!> condición inicial que los dos Euler, para poder compararlos.
!>
!> Usa el método de Runge-Kutta clásico de orden 4 (RK4) con h = 0.001. No hace
!> falta entenderlo ahora: lo veremos en la unidad 09. Basta saber que con ese paso
!> es muchísimo más preciso que Euler con el mismo paso.
!>
!>     gfortran referencia.f90 -o referencia
!>     ./referencia
program referencia
    implicit none

    double precision, parameter :: mu = 1.0d0
    double precision, parameter :: h = 0.001d0
    double precision, parameter :: t_final = 3000.0d0
    double precision, parameter :: dt_escritura = 0.1d0
    double precision, parameter :: x0 = 0.5d0, y0 = 0.0d0

    double precision :: u(2), k1(2), k2(2), k3(2), k4(2)
    integer :: k, n_pasos, paso_escritura, unidad

    n_pasos = nint(t_final / h)
    paso_escritura = nint(dt_escritura / h)
    u = [x0, y0]

    open(newunit=unidad, file="referencia.dat", status="replace", action="write")
    write(unidad, '(a)') '#           t                       x                       y'
    write(unidad, '(3es24.16)') 0.0d0, u
    do k = 1, n_pasos
        k1 = campo(u)
        k2 = campo(u + h / 2 * k1)
        k3 = campo(u + h / 2 * k2)
        k4 = campo(u + h * k3)
        u = u + h / 6 * (k1 + 2 * k2 + 2 * k3 + k4)
        if (mod(k, paso_escritura) == 0) write(unidad, '(3es24.16)') k * h, u
    end do
    close(unidad)

    print '(a, i0, a)', 'Referencia (RK4): ', n_pasos, ' pasos. Resultados en referencia.dat'
    print '(a, 2es14.6)', 'Estado final (x, y) = ', u

contains

    function campo(u) result(du)
        double precision, intent(in) :: u(2)
        double precision :: du(2)
        du(1) = u(2)
        du(2) = -mu * (u(1)**2 - 1) * u(2) - u(1)
    end function campo

end program referencia
