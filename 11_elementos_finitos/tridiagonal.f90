!> Matrices tridiagonales simétricas. Se guardan en dos vectores:
!>
!>     dia(i)    es el elemento (i, i)
!>     fuera(i)  es el elemento (i, i+1), que es igual al (i+1, i)
!>
!> Con elementos finitos lineales en una dimensión, las matrices salen así.
module tridiagonal
    implicit none
    private
    public :: producto, resolver

contains

    !> Producto de la matriz por un vector:  w = A v.
    function producto(dia, fuera, v) result(w)
        double precision, intent(in) :: dia(:), fuera(:), v(:)
        double precision :: w(size(v))
        integer :: n

        n = size(v)
        w = dia * v
        w(1:n-1) = w(1:n-1) + fuera * v(2:n)
        w(2:n) = w(2:n) + fuera * v(1:n-1)
    end function producto

    !> Resuelve A x = b con el algoritmo de Thomas: eliminación gaussiana
    !> aprovechando que casi todo son ceros. Cuesta O(n) en vez de O(n**3).
    subroutine resolver(dia, fuera, b, x)
        double precision, intent(in) :: dia(:), fuera(:), b(:)
        double precision, intent(out) :: x(:)
        double precision :: d(size(dia)), w
        integer :: i, n

        n = size(dia)
        d = dia
        x = b

        ! Hacia delante: se elimina la subdiagonal.
        do i = 2, n
            w = fuera(i-1) / d(i-1)
            d(i) = d(i) - w * fuera(i-1)
            x(i) = x(i) - w * x(i-1)
        end do

        ! Hacia atrás: se despeja de abajo arriba.
        x(n) = x(n) / d(n)
        do i = n - 1, 1, -1
            x(i) = (x(i) - fuera(i) * x(i+1)) / d(i)
        end do
    end subroutine resolver

end module tridiagonal
