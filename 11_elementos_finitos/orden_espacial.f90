!> Orden de convergencia en el espacio, como en la unidad 09 pero para elementos finitos.
!>
!> Se resuelve  u - u_xx = f  en [0, 1], con u_x = 0 en los extremos y
!> f = (1 + pi**2) cos(pi x), cuya solución exacta es u = cos(pi x). Se hace con
!> una malla uniforme y con otra estirada, duplicando el número de elementos.
!> Con elementos lineales el error debe dividirse por 4 cada vez: orden 2.
!>
!>     ./orden_espacial
program orden_espacial
    use malla, only: crear_malla
    use ensamblaje, only: ensamblar
    use tridiagonal, only: producto, resolver
    implicit none

    double precision, parameter :: pi = acos(-1.0d0)
    integer, parameter :: n_mallas = 6
    double precision, parameter :: estiramientos(2) = [1.0d0, 1.5d0]

    double precision, allocatable :: x(:), u(:), b(:)
    double precision, allocatable :: m_dia(:), m_fuera(:), k_dia(:), k_fuera(:)
    double precision :: error(n_mallas), orden
    integer :: i, j, n_elementos
    logical :: todo_bien

    todo_bien = .true.
    do i = 1, size(estiramientos)
        print '(a, f4.1)', 'Estiramiento de la malla: ', estiramientos(i)
        print '(a)', '  elementos     error maximo     orden'
        do j = 1, n_mallas
            n_elementos = 10 * 2**(j - 1)
            call crear_malla(1.0d0, n_elementos, estiramientos(i), x)
            call ensamblar(x, m_dia, m_fuera, k_dia, k_fuera)

            ! (M + K) u = M f
            allocate(u(size(x)), b(size(x)))
            b = producto(m_dia, m_fuera, (1 + pi**2) * cos(pi * x))
            call resolver(m_dia + k_dia, m_fuera + k_fuera, b, u)
            error(j) = maxval(abs(u - cos(pi * x)))
            deallocate(u, b)

            if (j == 1) then
                print '(i11, es17.4)', n_elementos, error(j)
            else
                orden = log(error(j-1) / error(j)) / log(2.0d0)
                print '(i11, es17.4, f10.2)', n_elementos, error(j), orden
            end if
        end do
        if (abs(orden - 2) > 0.3d0) todo_bien = .false.
    end do

    if (.not. todo_bien) then
        print '(a)', 'FALLA: el orden no es 2.'
        stop 1
    end if
    print '(a)', 'OK: orden 2.'
end program orden_espacial
