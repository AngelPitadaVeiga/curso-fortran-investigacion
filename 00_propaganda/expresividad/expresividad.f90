!> Expresividad: operaciones típicas con arrays escritas con la sintaxis de
!> arrays de Fortran. Compárese con expresividad.cpp, que hace lo mismo.
!>
!>   gfortran -O3 expresividad.f90 -o expresividad_f
program expresividad
    use, intrinsic :: iso_fortran_env, only: real64
    implicit none
    integer, parameter :: n = 5
    real(real64) :: a(n), b(n), c(n), u(n), lap(n), x(n), y(n), mat(n, n)
    integer :: i, j

    a = [(real(i, real64) - 3.0_real64, i = 1, n)]        ! -2 -1 0 1 2
    b = 1.0_real64
    u = a**2
    x = 1.0_real64
    mat = reshape([((real(i + j, real64), i = 1, n), j = 1, n)], [n, n])

    ! 1. Combinación lineal de vectores
    c = a + 2.0_real64 * b

    ! 2. Norma euclídea
    print '(a, f10.4)', 'norma(a)        = ', norm2(a)

    ! 3. Operación condicional elemento a elemento
    where (a > 0.0_real64)
        b = sqrt(a)
    elsewhere
        b = 0.0_real64
    end where

    ! 4. Diferencias finitas (laplaciano 1D) en los nodos interiores
    lap = 0.0_real64
    lap(2:n-1) = u(1:n-2) - 2.0_real64 * u(2:n-1) + u(3:n)

    ! 5. Producto matriz-vector y sumas por columnas
    y = matmul(mat, x)

    ! 6. Máximo y su posición
    print '(a, 5f8.3)', 'c               = ', c
    print '(a, 5f8.3)', 'b               = ', b
    print '(a, 5f8.3)', 'lap             = ', lap
    print '(a, 5f8.3)', 'mat*x           = ', y
    print '(a, 5f8.3)', 'sumas columnas  = ', sum(mat, dim=1)
    print '(a, f8.3, a, i0)', 'max(c)          = ', maxval(c), '  en i = ', maxloc(c, dim=1)
end program expresividad
