!> Orden de convergencia en el espacio, como en la unidad 09 pero con elementos finitos.
!>
!> Se parte de un desplazamiento inventado en el cuadrado [0, 1] x [0, 1],
!>
!>     ux = sin(pi x) sin(pi y),     uy = 0,
!>
!> que vale 0 en todo el borde. Si se sustituye en las ecuaciones de la elasticidad,
!> sale la fuerza (por unidad de volumen) que lo produciría:
!>
!>     fx = (lambda + 3 mu) pi**2 sin(pi x) sin(pi y),    fy = -(lambda + mu) pi**2 cos(pi x) cos(pi y)
!>
!> Se resuelve con mallas cada vez más finas y se mide el error máximo en los nodos.
!> Con triángulos lineales debe dividirse por 4 al duplicar las casillas: orden 2.
!>
!>     ./orden_espacial
program orden_espacial
    use malla, only: crear_malla
    use elasticidad, only: ensamblar
    use algebra, only: factorizar, resolver
    implicit none

    double precision, parameter :: pi = acos(-1.0d0)
    double precision, parameter :: e_young = 1.0d0, nu = 0.3d0, rho = 1.0d0
    integer, parameter :: n_mallas = 4

    double precision :: lambda, mu, error(n_mallas), orden
    double precision, allocatable :: x(:, :), k(:, :), m(:), f(:), u(:), kl(:, :), ul(:)
    integer, allocatable :: tri(:, :), libres(:)
    logical, allocatable :: fijo(:)
    double precision :: tol
    integer :: i, j, n, nx

    ! Constantes de Lamé de tensión plana.
    lambda = e_young * nu / (1 - nu**2)
    mu = e_young / (2 * (1 + nu))

    print '(a)', '  casillas     error maximo     orden'
    do j = 1, n_mallas
        nx = 4 * 2**(j - 1)
        call crear_malla(1.0d0, 1.0d0, nx, nx, x, tri)
        call ensamblar(x, tri, e_young, nu, rho, k, m)
        n = size(x, 2)

        ! Fuerza en cada nodo: la fuerza por unidad de volumen por el "volumen" del nodo
        ! (con rho = 1, la masa concentrada es justo ese volumen).
        allocate(f(2 * n), fijo(2 * n), u(2 * n))
        f = 0
        tol = 1.0d-9
        do i = 1, n
            f(2*i - 1) = m(2*i - 1) * (lambda + 3 * mu) * pi**2 * sin(pi * x(1, i)) * sin(pi * x(2, i))
            f(2*i) = -m(2*i) * (lambda + mu) * pi**2 * cos(pi * x(1, i)) * cos(pi * x(2, i))
            ! Los nodos del borde tienen desplazamiento nulo.
            fijo(2*i - 1:2*i) = (x(1, i) < tol .or. x(1, i) > 1 - tol .or. &
                                 x(2, i) < tol .or. x(2, i) > 1 - tol)
        end do
        libres = pack([(i, i = 1, 2 * n)], .not. fijo)

        kl = k(libres, libres)
        allocate(ul(size(libres)))
        call factorizar(kl)
        call resolver(kl, f(libres), ul)
        u = 0
        u(libres) = ul

        ! Error frente al desplazamiento exacto, nodo a nodo.
        error(j) = 0
        do i = 1, n
            error(j) = max(error(j), abs(u(2*i - 1) - sin(pi * x(1, i)) * sin(pi * x(2, i))), abs(u(2*i)))
        end do

        if (j == 1) then
            print '(i10, es17.4)', nx, error(j)
        else
            orden = log(error(j-1) / error(j)) / log(2.0d0)
            print '(i10, es17.4, f10.2)', nx, error(j), orden
        end if
        deallocate(f, fijo, u, ul)
    end do

    if (abs(orden - 2) > 0.3d0) then
        print '(a)', 'FALLA: el orden no es 2.'
        stop 1
    end if
    print '(a)', 'OK: orden 2.'
end program orden_espacial
