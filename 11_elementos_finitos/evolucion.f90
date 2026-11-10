!> Un paso de tiempo para la ecuación de reacción-difusión
!>
!>     u_t = d u_xx + r u (1 - u)
!>
!> Con elementos finitos queda un sistema de EDO,  M u' = -d K u + M g(u),
!> con g(u) = r u (1 - u), y le aplicamos Euler como en la unidad 05.
module evolucion
    use tridiagonal, only: producto, resolver
    implicit none
    private
    public :: paso_explicito, paso_implicito

contains

    function reaccion(u, r) result(g)
        double precision, intent(in) :: u(:), r
        double precision :: g(size(u))
        g = r * u * (1 - u)
    end function reaccion

    !> Euler explícito:  M u_nuevo = M (u + dt g(u)) - dt d K u
    !> Hay que resolver un sistema con M, pero M es muy buena y no pasa nada.
    subroutine paso_explicito(u, dt, d, r, m_dia, m_fuera, k_dia, k_fuera)
        double precision, intent(inout) :: u(:)
        double precision, intent(in) :: dt, d, r
        double precision, intent(in) :: m_dia(:), m_fuera(:), k_dia(:), k_fuera(:)
        double precision :: b(size(u))

        b = producto(m_dia, m_fuera, u + dt * reaccion(u, r)) &
            - dt * d * producto(k_dia, k_fuera, u)
        call resolver(m_dia, m_fuera, b, u)
    end subroutine paso_explicito

    !> Difusión implícita y reacción explícita:
    !>     (M + dt d K) u_nuevo = M (u + dt g(u))
    !> La matriz A = M + dt d K es siempre la misma: se ensambla fuera, una vez.
    subroutine paso_implicito(u, dt, r, m_dia, m_fuera, a_dia, a_fuera)
        double precision, intent(inout) :: u(:)
        double precision, intent(in) :: dt, r
        double precision, intent(in) :: m_dia(:), m_fuera(:), a_dia(:), a_fuera(:)
        double precision :: b(size(u))

        b = producto(m_dia, m_fuera, u + dt * reaccion(u, r))
        call resolver(a_dia, a_fuera, b, u)
    end subroutine paso_implicito

end module evolucion
