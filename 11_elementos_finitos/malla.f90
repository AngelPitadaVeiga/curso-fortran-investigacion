!> La malla: un rectángulo [0, lx] x [0, ly] dividido en triángulos.
!>
!> Primero se reparten los nodos en una rejilla de (nx+1) x (ny+1) puntos, numerados
!> fila a fila. Después cada casilla se corta por una diagonal en dos triángulos:
!>
!>     n3 ---- n4         triángulos:  (n1, n2, n4)  y  (n1, n4, n3)
!>      |    / |
!>      |  /   |          Los vértices van en sentido antihorario.
!>     n1 ---- n2
module malla
    implicit none
    private
    public :: crear_malla

contains

    !> x(:, i) son las coordenadas del nodo i, y tri(:, e), los tres nodos del triángulo e.
    subroutine crear_malla(lx, ly, nx, ny, x, tri)
        double precision, intent(in) :: lx, ly
        integer, intent(in) :: nx, ny
        double precision, allocatable, intent(out) :: x(:, :)
        integer, allocatable, intent(out) :: tri(:, :)
        integer :: i, j, n1, n2, n3, n4, e

        allocate(x(2, (nx + 1) * (ny + 1)), tri(3, 2 * nx * ny))

        do j = 0, ny
            do i = 0, nx
                x(:, j * (nx + 1) + i + 1) = [lx * i / nx, ly * j / ny]
            end do
        end do

        e = 0
        do j = 0, ny - 1
            do i = 0, nx - 1
                n1 = j * (nx + 1) + i + 1
                n2 = n1 + 1
                n3 = n1 + nx + 1
                n4 = n3 + 1
                e = e + 1
                tri(:, e) = [n1, n2, n4]
                e = e + 1
                tri(:, e) = [n1, n4, n3]
            end do
        end do
    end subroutine crear_malla

end module malla
