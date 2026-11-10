!> La malla: los nodos x(1), ..., x(n) de un intervalo [0, longitud].
!> Los elementos son los trozos entre nodos consecutivos: el elemento e va
!> de x(e) a x(e+1), así que hay n - 1 elementos.
module malla
    implicit none
    private
    public :: crear_malla

contains

    !> Con estiramiento = 1 los nodos están igualmente espaciados. Con un valor
    !> mayor que 1 se juntan cerca de x = 0, y los elementos de ese lado son más pequeños.
    subroutine crear_malla(longitud, n_elementos, estiramiento, x)
        double precision, intent(in) :: longitud, estiramiento
        integer, intent(in) :: n_elementos
        double precision, allocatable, intent(out) :: x(:)
        integer :: i

        allocate(x(n_elementos + 1))
        do i = 1, n_elementos + 1
            x(i) = longitud * (dble(i - 1) / n_elementos)**estiramiento
        end do
    end subroutine crear_malla

end module malla
