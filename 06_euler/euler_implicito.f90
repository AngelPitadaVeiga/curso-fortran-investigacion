!> Euler implícito para el oscilador de Van der Pol, todo en un archivo.
!>
!> Método:  u_{k+1} = u_k + h*F(u_{k+1}).  La incógnita aparece a los dos lados:
!> en cada paso hay que resolver un sistema no lineal, aquí con Newton.
!>
!>     gfortran euler_implicito.f90 -o euler_implicito
!>     ./euler_implicito
program euler_implicito
    use iso_fortran_env, only: real64
    implicit none

    real(real64), parameter :: mu = 1.0_real64
    real(real64), parameter :: h = 0.01_real64
    real(real64), parameter :: t_final = 30.0_real64
    real(real64), parameter :: x0 = 0.5_real64, y0 = 0.0_real64

    real(real64) :: u(2)                ! estado actual (x, y)
    integer :: k, n_pasos, unidad, iteraciones

    n_pasos = nint(t_final / h)
    u = [x0, y0]

    open(newunit=unidad, file="euler_implicito.dat", status="replace", action="write")
    write(unidad, '(a)') '#           t                       x                       y'
    write(unidad, '(3es24.16)') 0.0_real64, u
    do k = 1, n_pasos
        call paso_euler_implicito(u, h, iteraciones)
        write(unidad, '(3es24.16)') k * h, u
    end do
    close(unidad)

    print '(a, i0, a)', 'Euler implicito: ', n_pasos, ' pasos. Resultados en euler_implicito.dat'
    print '(a, 2es14.6)', 'Estado final (x, y) = ', u
    print '(a, i0)', 'Iteraciones de Newton en el ultimo paso: ', iteraciones

contains

    !> Campo vectorial de Van der Pol: devuelve F(u) = (x', y').
    function campo(u) result(du)
        real(real64), intent(in) :: u(2)
        real(real64) :: du(2)
        du(1) = u(2)
        du(2) = -mu * (u(1)**2 - 1) * u(2) - u(1)
    end function campo

    !> Un paso de Euler implícito. Resuelve G(z) = z - u - h*F(z) = 0 con Newton:
    !> la matriz del sistema es M = I - h*J(z), con J el jacobiano de F.
    subroutine paso_euler_implicito(u, h, iteraciones)
        real(real64), intent(inout) :: u(2)     ! entra u_k y sale u_{k+1}
        real(real64), intent(in) :: h           ! solo se lee
        integer, intent(out) :: iteraciones     ! solo se escribe

        real(real64), parameter :: tolerancia = 1.0e-12_real64
        integer, parameter :: max_iteraciones = 20
        real(real64) :: z(2), g(2), dz(2), m11, m12, m21, m22, det

        z = u                                   ! estimación inicial
        do iteraciones = 1, max_iteraciones
            g = z - u - h * campo(z)
            m11 = 1
            m12 = -h
            m21 = h * (2 * mu * z(1) * z(2) + 1)
            m22 = 1 + h * mu * (z(1)**2 - 1)

            ! M*dz = -g, un sistema 2x2: regla de Cramer.
            det = m11 * m22 - m12 * m21
            dz(1) = (-g(1) * m22 + g(2) * m12) / det
            dz(2) = (-g(2) * m11 + g(1) * m21) / det
            z = z + dz
            if (maxval(abs(dz)) <= tolerancia) exit
        end do
        u = z
    end subroutine paso_euler_implicito

end program euler_implicito
