!> Vibraciones: M u'' + K u = 0, con M diagonal (un vector m) y K la matriz de rigidez.
!>
!> Para integrar en el tiempo se guardan el desplazamiento u, la velocidad v y la
!> aceleración a = -K u / m. Hay dos métodos, que vienen de las unidades 05 y 09:
!>
!>   explícito  (velocidad Verlet): barato, pero solo es estable si dt < 2 / omega_max.
!>   implícito  (Newmark, aceleración media): resuelve un sistema en cada paso, pero es
!>              estable con cualquier dt. Es la regla del trapecio de la unidad 09
!>              aplicada al sistema de primer orden  u' = v,  M v' = -K u.
module dinamica
    use algebra, only: resolver
    implicit none
    private
    public :: autovalor_maximo, paso_explicito, paso_implicito, energia

contains

    !> Mayor autovalor de M^-1 K, por el método de la potencia: se multiplica
    !> una y otra vez un vector cualquiera, y acaba alineado con el autovector
    !> de mayor autovalor. omega_max es su raíz cuadrada.
    function autovalor_maximo(k, m) result(lambda)
        double precision, intent(in) :: k(:, :), m(:)
        double precision :: lambda, x(size(m)), y(size(m))
        integer :: i, iteracion

        x = [(sin(dble(i)**2), i = 1, size(m))]          ! un vector sin ninguna estructura
        x = x / norm2(x)
        lambda = 0
        do iteracion = 1, 400
            y = matmul(k, x) / m
            lambda = norm2(y)
            x = y / lambda
        end do
    end function autovalor_maximo

    !> Un paso explícito. Con estas tres líneas se actualiza (u, v, a).
    subroutine paso_explicito(u, v, a, dt, k, m)
        double precision, intent(inout) :: u(:), v(:), a(:)
        double precision, intent(in) :: dt, k(:, :), m(:)
        double precision :: a_nueva(size(u))

        u = u + dt * v + dt**2 / 2 * a
        a_nueva = -matmul(k, u) / m
        v = v + dt / 2 * (a + a_nueva)
        a = a_nueva
    end subroutine paso_explicito

    !> Un paso implícito. l es el factor de Cholesky de (diag(m) + dt**2/4 * K),
    !> que no cambia, así que se calcula una sola vez fuera del bucle.
    subroutine paso_implicito(u, v, a, dt, k, l)
        double precision, intent(inout) :: u(:), v(:), a(:)
        double precision, intent(in) :: dt, k(:, :), l(:, :)
        double precision :: u_previsto(size(u))

        u_previsto = u + dt * v + dt**2 / 4 * a
        v = v + dt / 2 * a
        call resolver(l, -matmul(k, u_previsto), a)       ! aceleración nueva
        u = u_previsto + dt**2 / 4 * a
        v = v + dt / 2 * a
    end subroutine paso_implicito

    !> Energía total: cinética más elástica. En un sistema sin rozamiento debería
    !> conservarse, y por eso es una buena forma de vigilar al integrador.
    function energia(u, v, k, m) result(e)
        double precision, intent(in) :: u(:), v(:), k(:, :), m(:)
        double precision :: e
        e = 0.5d0 * sum(m * v**2) + 0.5d0 * dot_product(u, matmul(k, u))
    end function energia

end module dinamica
