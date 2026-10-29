!> Escribe una tabla  x  sin(x)  cos(x)  en tabla.dat, lista para gnuplot.
!>
!>     gfortran tabla.f90 -o tabla
!>     ./tabla
!>     gnuplot graficar.gp          (genera tabla.png)
program tabla
    use, intrinsic :: iso_fortran_env, only: real64
    implicit none
    integer, parameter :: n = 200
    real(real64), parameter :: pi = acos(-1.0_real64)
    real(real64) :: x(0:n)
    integer :: i, unidad

    x = [(2 * pi * i / n, i = 0, n)]       ! n + 1 puntos en [0, 2 pi]

    ! newunit: Fortran elige un número de unidad libre y lo guarda en "unidad".
    open(newunit=unidad, file="tabla.dat", status="replace", action="write")
    write(unidad, '(a)') '#          x              sin(x)              cos(x)'
    do i = 0, n
        write(unidad, '(3es20.10)') x(i), sin(x(i)), cos(x(i))
    end do
    close(unidad)

    print '(a, i0, a)', 'Escritas ', n + 1, ' filas en tabla.dat'
end program tabla
