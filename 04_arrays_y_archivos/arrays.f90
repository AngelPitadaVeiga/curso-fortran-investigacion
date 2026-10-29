!> Arrays en Fortran: operaciones sin bucles, cortes, matrices y arrays dinámicos.
!>
!>     gfortran arrays.f90 -o arrays
!>     ./arrays
program arrays
    use, intrinsic :: iso_fortran_env, only: real64
    implicit none
    real(real64) :: v(5), w(5)              ! tamaño fijo; índices 1..5
    real(real64) :: a(2, 3)                 ! matriz de 2 filas y 3 columnas
    real(real64), allocatable :: x(:)       ! tamaño decidido al ejecutar
    integer :: i, n

    ! Constructor [...] y operaciones elemento a elemento, sin bucles.
    v = [1.0_real64, 2.0_real64, 3.0_real64, 4.0_real64, 5.0_real64]
    w = 2 * v + 1
    print '(a, 5f6.1)', 'v        =', v
    print '(a, 5f6.1)', '2*v + 1  =', w
    print '(a, 5f6.1)', 'v * w    =', v * w            ! elemento a elemento
    print '(a, 5f6.1)', 'sqrt(v)  =', sqrt(v)          ! las intrínsecas también
    print '(a, f6.1)',  'dot_product(v, w) =', dot_product(v, w)
    print '(a, f6.1, a, f6.1, a, i0)', 'sum(v) =', sum(v), '   maxval(v) =', maxval(v), &
                                       '   size(v) = ', size(v)

    ! Cortes: inicio:fin:paso (el fin se incluye).
    print *
    print '(a, 3f6.1)', 'v(2:4)    =', v(2:4)
    print '(a, 3f6.1)', 'v(1:5:2)  =', v(1:5:2)
    print '(a, 5f6.1)', 'v(5:1:-1) =', v(5:1:-1)

    ! Matrices. reshape rellena POR COLUMNAS: así se guardan en memoria.
    a = reshape([1, 2, 3, 4, 5, 6], [2, 3])
    print *
    print '(a)', 'a ='
    do i = 1, 2
        print '(3f6.1)', a(i, :)                       ! fila i
    end do
    print '(a, 2f6.1)', 'a(:, 2) (columna 2) =', a(:, 2)
    print '(a, 2f6.1)', 'matmul(a, [1, 1, 1]) =', matmul(a, [1.0_real64, 1.0_real64, 1.0_real64])
    print '(a, 2i3)',   'shape(a) =', shape(a)

    ! Arrays dinámicos, con el primer índice que queramos.
    n = 4
    allocate(x(0:n))
    x = [(real(i, real64) / n, i = 0, n)]              ! "do implícito": 0, 0.25, ..., 1
    print *
    print '(a, 5f6.2)', 'x(0:n) =', x
    print '(a, i0, a, i0)', 'lbound(x) = ', lbound(x, 1), '   ubound(x) = ', ubound(x, 1)
    ! No hace falta deallocate: x se libera sola al terminar.
end program arrays
