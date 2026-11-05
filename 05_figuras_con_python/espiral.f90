!> Escribe una espiral en espiral.dat para practicar las figuras:
!>
!>     x(t) = exp(-t/10) cos(t),   y(t) = exp(-t/10) sin(t)
!>
!>     gfortran espiral.f90 -o espiral
!>     ./espiral
program espiral
    use iso_fortran_env, only: real64
    implicit none
    integer, parameter :: n = 1000
    real(real64), parameter :: t_final = 40.0_real64
    real(real64) :: t
    integer :: k, unidad

    open(newunit=unidad, file="espiral.dat", status="replace", action="write")
    write(unidad, '(a)') '#           t                       x                       y'
    do k = 0, n
        t = k * t_final / n
        write(unidad, '(3es24.16)') t, exp(-t / 10) * cos(t), exp(-t / 10) * sin(t)
    end do
    close(unidad)

    print '(a, i0, a)', 'Escritas ', n + 1, ' filas en espiral.dat'
end program espiral
