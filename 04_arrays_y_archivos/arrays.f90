!> Arrays en Fortran: operaciones sin bucles, cortes y matrices.
!>
!>     gfortran arrays.f90 -o arrays
!>     ./arrays
program arrays
    implicit none
    double precision :: v(5), w(5)      ! tamaño fijo; índices 1..5
    double precision :: a(2, 3)         ! matriz de 2 filas y 3 columnas
    double precision, allocatable :: x(:)
    integer :: i, n

    ! El constructor [...] y las operaciones elemento a elemento, sin bucles.
    v = [1.0d0, 2.0d0, 3.0d0, 4.0d0, 5.0d0]
    w = 2 * v + 1
    print '(a, 5f6.1)', 'v        =', v
    print '(a, 5f6.1)', '2*v + 1  =', w
    print '(a, 5f6.1)', 'v * w    =', v * w            ! elemento a elemento
    print '(a, 5f6.1)', 'sqrt(v)  =', sqrt(v)          ! las funciones también
    print '(a, f6.1)',  'dot_product(v, w) =', dot_product(v, w)
    print '(a, f6.1, a, f6.1, a, i0)', 'sum(v) =', sum(v), '   maxval(v) =', maxval(v), &
                                       '   size(v) = ', size(v)

    ! Cortes: inicio:fin:paso (el fin se incluye).
    print *
    print '(a, 3f6.1)', 'v(2:4)    =', v(2:4)
    print '(a, 3f6.1)', 'v(1:5:2)  =', v(1:5:2)
    print '(a, 5f6.1)', 'v(5:1:-1) =', v(5:1:-1)

    ! Matrices. reshape rellena POR COLUMNAS, que es como se guardan en memoria.
    a = reshape([1, 2, 3, 4, 5, 6], [2, 3])
    print *
    print '(a)', 'a ='
    do i = 1, 2
        print '(3f6.1)', a(i, :)                       ! fila i
    end do
    print '(a, 2f6.1)', 'a(:, 2) (columna 2) =', a(:, 2)
    print '(a, 2f6.1)', 'matmul(a, [1, 1, 1]) =', matmul(a, [1.0d0, 1.0d0, 1.0d0])
    print '(a, 2i3)',   'shape(a) =', shape(a)

    ! Un vector con el primer índice que queramos (más sobre allocate en matrices.f90).
    n = 4
    allocate(x(0:n))
    x = [(dble(i) / n, i = 0, n)]                      ! 0, 0.25, ..., 1
    print *
    print '(a, 5f6.2)', 'x(0:n) =', x
    print '(a, i0, a, i0)', 'lbound(x) = ', lbound(x, 1), '   ubound(x) = ', ubound(x, 1)
end program arrays
