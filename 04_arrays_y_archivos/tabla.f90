!> Escribe una tabla  x  sin(x)  cos(x)  en tabla.dat.
!> La dibujaremos en la unidad 06.
!>
!>     gfortran tabla.f90 -o tabla
!>     ./tabla
program tabla
    implicit none
    integer, parameter :: n = 200
    double precision, parameter :: pi = acos(-1.0d0)
    double precision :: x(0:n)
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
