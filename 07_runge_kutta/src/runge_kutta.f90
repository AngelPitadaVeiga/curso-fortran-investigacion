!> Runge-Kutta explícito de paso fijo, definido por un tablero de Butcher:
!>
!>     k_i     = F(u_n + h * sum_{j<i} a_ij k_j),   i = 1, ..., s
!>     u_{n+1} = u_n + h * sum_i b_i k_i
module runge_kutta
    use, intrinsic :: iso_fortran_env, only: real64
    use modelo, only: campo
    use tablero_butcher, only: tablero, es_explicito
    implicit none
    private
    public :: paso_rk, integrar_rk

contains

    !> Un paso: de u(t) a u(t + h).
    pure function paso_rk(tab, u, mu, h) result(u_nuevo)
        type(tablero), intent(in) :: tab
        real(real64), intent(in) :: u(2), mu, h
        real(real64) :: u_nuevo(2)
        real(real64) :: k(2, tab%s)          ! k(:, i) = etapa i
        integer :: i

        do i = 1, tab%s
            ! matmul(k(:, 1:i-1), a(i, 1:i-1)) = sum_{j<i} a_ij k_j  (vacío si i = 1)
            k(:, i) = campo(u + h * matmul(k(:, 1:i-1), tab%a(i, 1:i-1)), mu)
        end do
        u_nuevo = u + h * matmul(k, tab%b)
    end function paso_rk

    !> Integra n_pasos pasos de tamaño h desde u0.
    !> A la salida, u(:, k) es el estado en t = k*h, k = 0, ..., n_pasos.
    subroutine integrar_rk(tab, u0, mu, h, n_pasos, u)
        type(tablero), intent(in) :: tab
        real(real64), intent(in) :: u0(2), mu, h
        integer, intent(in) :: n_pasos
        real(real64), allocatable, intent(out) :: u(:, :)
        integer :: k

        if (.not. es_explicito(tab)) then
            print '(a)', 'Error: ' // tab%nombre // ' es implicito (vease el bloque 09).'
            stop 1
        end if

        allocate(u(2, 0:n_pasos))
        u(:, 0) = u0
        do k = 1, n_pasos
            u(:, k) = paso_rk(tab, u(:, k-1), mu, h)
        end do
    end subroutine integrar_rk

end module runge_kutta
