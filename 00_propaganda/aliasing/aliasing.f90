!> Aliasing en Fortran: la misma actualización de partículas que aliasing.cpp.
!>
!> Compilar y ver qué bucles vectoriza el compilador:
!>   gfortran -O3 -march=native -fopt-info-vec-optimized aliasing.f90 -o aliasing_f
!>
!> El estándar de Fortran prohíbe llamar a un procedimiento con argumentos
!> que se solapen si alguno de ellos se modifica. Por tanto el compilador
!> puede suponer, sin comprobarlo, que x, y, vx, vy, fx, fy y m no se
!> solapan: es lo que en C++ hay que prometer con __restrict__.
module particulas
    use, intrinsic :: iso_fortran_env, only: real64
    implicit none
    private
    public :: avanzar, avanzar_forma_explicita

contains

    !> Euler simpléctico para N partículas en el plano: v += dt*F/m, x += dt*v.
    !> Arrays de forma asumida x(:): el estilo moderno habitual.
    subroutine avanzar(x, y, vx, vy, fx, fy, m, dt)
        real(real64), intent(inout) :: x(:), y(:), vx(:), vy(:)
        real(real64), intent(in) :: fx(:), fy(:), m(:), dt
        integer :: i
        do i = 1, size(x)
            vx(i) = vx(i) + dt * fx(i) / m(i)
            vy(i) = vy(i) + dt * fy(i) / m(i)
            x(i) = x(i) + dt * vx(i)
            y(i) = y(i) + dt * vy(i)
        end do
    end subroutine avanzar

    !> Lo mismo con arrays de forma explícita x(n), como en FORTRAN 77:
    !> el compilador sabe además que son contiguos.
    subroutine avanzar_forma_explicita(n, x, y, vx, vy, fx, fy, m, dt)
        integer, intent(in) :: n
        real(real64), intent(inout) :: x(n), y(n), vx(n), vy(n)
        real(real64), intent(in) :: fx(n), fy(n), m(n), dt
        integer :: i
        do i = 1, n
            vx(i) = vx(i) + dt * fx(i) / m(i)
            vy(i) = vy(i) + dt * fy(i) / m(i)
            x(i) = x(i) + dt * vx(i)
            y(i) = y(i) + dt * vy(i)
        end do
    end subroutine avanzar_forma_explicita

end module particulas


program aliasing
    use, intrinsic :: iso_fortran_env, only: real64, int64
    use particulas, only: avanzar, avanzar_forma_explicita
    implicit none
    integer, parameter :: n = 1000, repeticiones = 250000
    real(real64), parameter :: dt = 1.0e-6_real64
    real(real64), dimension(n) :: x, y, vx, vy, fx, fy, m
    integer(int64) :: t0, t1, ticks
    integer :: r, variante

    do variante = 1, 2
        x = 0.0_real64;  y = 0.0_real64
        vx = 1.0_real64; vy = 0.0_real64
        fx = 0.0_real64; fy = -1.0_real64
        m = 2.0_real64

        call system_clock(t0, ticks)
        do r = 1, repeticiones
            if (variante == 1) then
                call avanzar(x, y, vx, vy, fx, fy, m, dt)
            else
                call avanzar_forma_explicita(n, x, y, vx, vy, fx, fy, m, dt)
            end if
        end do
        call system_clock(t1)

        if (variante == 1) then
            print '(a, f6.3, a)', 'Fortran, x(:):        ', real(t1 - t0, real64) / ticks, ' s'
        else
            print '(a, f6.3, a)', 'Fortran, x(n):        ', real(t1 - t0, real64) / ticks, ' s'
        end if
    end do
    print '(a, f9.6, a, f9.6, a)', '(control: x = ', x(1), ', y = ', y(1), ')'
end program aliasing
