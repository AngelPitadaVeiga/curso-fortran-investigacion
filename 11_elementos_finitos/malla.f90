!> Las mallas de triángulos.
!>
!> leer_malla lee una malla de un archivo, como las que escribe generar_malla.py (o,
!> en un código de verdad, un mallador como Gmsh).
!>
!> crear_malla divide un rectángulo [0, lx] x [0, ly] en triángulos, sin archivo. Primero se reparten los nodos en una rejilla de (nx+1) x (ny+1) puntos, numerados
!> fila a fila. Después cada casilla se corta por una diagonal en dos triángulos:
!>
!>     n3 ---- n4         triángulos:  (n1, n2, n4)  y  (n1, n4, n3)
!>      |    / |
!>      |  /   |          Los vértices van en sentido antihorario.
!>     n1 ---- n2
module malla
    implicit none
    private
    public :: crear_malla, leer_malla

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

    !> Lee el archivo de malla. Además de los nodos y los triángulos, para cada nodo dice
    !> si está empotrado (fijo) y qué fracción de la carga total soporta (peso).
    subroutine leer_malla(archivo, x, tri, fijo, peso)
        character(len=*), intent(in) :: archivo
        double precision, allocatable, intent(out) :: x(:, :), peso(:)
        integer, allocatable, intent(out) :: tri(:, :)
        logical, allocatable, intent(out) :: fijo(:)
        integer :: i, n, m, unidad, estado, empotrado

        open(newunit=unidad, file=archivo, status='old', action='read', iostat=estado)
        if (estado /= 0) then
            print '(a)', 'No puedo abrir la malla ' // trim(archivo) // ' (python generar_malla.py)'
            stop 1
        end if
        read(unidad, *)                     ! la línea de comentario
        read(unidad, *) n, m
        allocate(x(2, n), peso(n), fijo(n), tri(3, m))
        do i = 1, n
            read(unidad, *) x(1, i), x(2, i), empotrado, peso(i)
            fijo(i) = (empotrado == 1)
        end do
        do i = 1, m
            read(unidad, *) tri(:, i)
        end do
        close(unidad)
    end subroutine leer_malla

end module malla
