!> Métodos de un paso para u' = F(u): Euler, Heun, RK4, Euler implícito y trapecio.
!>
!> Cada método es una función que recibe el estado u_k y devuelve u_{k+1}.
!> integrar elige cuál se usa según el nombre. No es lo más rápido (el nombre
!> se comprueba en cada paso), pero se lee muy bien.
module runge_kutta
    use modelo, only: campo, jacobiano
    implicit none
    private
    public :: integrar

contains

    !> Da n_pasos pasos de tamaño h con el método indicado: 'euler', 'heun', 'rk4',
    !> 'euler_implicito' o 'trapecio'. A la salida, u(:, k) es el estado en el paso k.
    !> Si la solución explota, se detiene y n_hechos dice cuántos pasos se dieron.
    subroutine integrar(metodo, u0, mu, h, n_pasos, u, n_hechos)
        character(len=*), intent(in) :: metodo
        double precision, intent(in) :: u0(2), mu, h
        integer, intent(in) :: n_pasos
        double precision, allocatable, intent(out) :: u(:, :)
        integer, intent(out) :: n_hechos
        integer :: k

        allocate(u(2, 0:n_pasos))
        u(:, 0) = u0
        n_hechos = n_pasos
        do k = 1, n_pasos
            select case (metodo)
            case ('euler')
                u(:, k) = paso_euler(u(:, k-1), mu, h)
            case ('heun')
                u(:, k) = paso_heun(u(:, k-1), mu, h)
            case ('rk4')
                u(:, k) = paso_rk4(u(:, k-1), mu, h)
            case ('euler_implicito')
                u(:, k) = paso_implicito(u(:, k-1), mu, h, 1.0d0)
            case ('trapecio')
                u(:, k) = paso_implicito(u(:, k-1), mu, h, 0.5d0)
            case default
                print '(a)', 'Metodo desconocido: ' // metodo
                stop 1
            end select

            ! La condición está escrita así para que también detecte NaN.
            if (.not. (maxval(abs(u(:, k))) < 1.0d10)) then
                print '(a, i0, a, es9.2)', 'La solucion ha explotado en el paso ', k, ', t =', k * h
                n_hechos = k
                exit
            end if
        end do
    end subroutine integrar

    ! u_{k+1} = u_k + h F(u_k)
    function paso_euler(u, mu, h) result(u_nuevo)
        double precision, intent(in) :: u(2), mu, h
        double precision :: u_nuevo(2)
        u_nuevo = u + h * campo(u, mu)
    end function paso_euler

    ! Heun: se promedia la pendiente del principio y la del final del paso.
    function paso_heun(u, mu, h) result(u_nuevo)
        double precision, intent(in) :: u(2), mu, h
        double precision :: u_nuevo(2), k1(2), k2(2)
        k1 = campo(u, mu)
        k2 = campo(u + h * k1, mu)
        u_nuevo = u + h / 2 * (k1 + k2)
    end function paso_heun

    ! Runge-Kutta clásico de orden 4.
    function paso_rk4(u, mu, h) result(u_nuevo)
        double precision, intent(in) :: u(2), mu, h
        double precision :: u_nuevo(2), k1(2), k2(2), k3(2), k4(2)
        k1 = campo(u, mu)
        k2 = campo(u + h / 2 * k1, mu)
        k3 = campo(u + h / 2 * k2, mu)
        k4 = campo(u + h * k3, mu)
        u_nuevo = u + h / 6 * (k1 + 2 * k2 + 2 * k3 + k4)
    end function paso_rk4

    ! Método implícito con un parámetro theta:
    !     u_{k+1} = u_k + h * ( theta F(u_{k+1}) + (1 - theta) F(u_k) )
    ! Con theta = 1 es Euler implícito, y con theta = 1/2, la regla del trapecio
    ! (la versión implícita de Heun). Se resuelve con Newton, como en la unidad 05.
    function paso_implicito(u, mu, h, theta) result(u_nuevo)
        double precision, intent(in) :: u(2), mu, h, theta
        double precision :: u_nuevo(2)

        double precision, parameter :: tolerancia = 1.0d-12
        integer, parameter :: max_iteraciones = 20
        double precision :: z(2), g(2), dz(2), m(2, 2), det, conocido(2)
        integer :: iter

        conocido = u + h * (1 - theta) * campo(u, mu)
        z = u
        do iter = 1, max_iteraciones
            g = z - conocido - h * theta * campo(z, mu)
            m = -h * theta * jacobiano(z, mu)   ! M = I - h*theta*J
            m(1, 1) = m(1, 1) + 1
            m(2, 2) = m(2, 2) + 1

            ! M*dz = -g: sistema 2x2, regla de Cramer.
            det = m(1, 1) * m(2, 2) - m(1, 2) * m(2, 1)
            dz(1) = (-g(1) * m(2, 2) + g(2) * m(1, 2)) / det
            dz(2) = (-g(2) * m(1, 1) + g(1) * m(2, 1)) / det
            z = z + dz
            if (maxval(abs(dz)) <= tolerancia) exit
        end do
        u_nuevo = z
    end function paso_implicito

end module runge_kutta
