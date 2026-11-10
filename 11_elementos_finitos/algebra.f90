!> Un resolutor de sistemas lineales A x = b para matrices simétricas definidas
!> positivas (como la de rigidez), con la factorización de Cholesky: A = L L'.
!>
!> No es el más rápido (la matriz es llena y casi todo son ceros), pero cabe en
!> veinte líneas y se lee de arriba abajo. Para mallas grandes se usarían matrices
!> dispersas, o LAPACK (dpotrf y dpotrs hacen exactamente esto).
module algebra
    implicit none
    private
    public :: factorizar, resolver

contains

    !> Sustituye a por su factor L, en el triángulo inferior.
    subroutine factorizar(a)
        double precision, intent(inout) :: a(:, :)
        integer :: j, n

        n = size(a, 1)
        do j = 1, n
            a(j, j) = sqrt(a(j, j) - dot_product(a(j, 1:j-1), a(j, 1:j-1)))
            a(j+1:n, j) = (a(j+1:n, j) - matmul(a(j+1:n, 1:j-1), a(j, 1:j-1))) / a(j, j)
        end do
    end subroutine factorizar

    !> Resuelve L L' x = b, con l ya factorizada: primero hacia delante y luego hacia atrás.
    subroutine resolver(l, b, x)
        double precision, intent(in) :: l(:, :), b(:)
        double precision, intent(out) :: x(:)
        integer :: i, n

        n = size(b)
        x = b
        do i = 1, n
            x(i) = x(i) / l(i, i)
            x(i+1:n) = x(i+1:n) - l(i+1:n, i) * x(i)
        end do
        do i = n, 1, -1
            x(i) = (x(i) - dot_product(l(i+1:n, i), x(i+1:n))) / l(i, i)
        end do
    end subroutine resolver

end module algebra
