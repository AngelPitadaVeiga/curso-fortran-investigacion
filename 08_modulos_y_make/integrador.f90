!> El método: Euler explícito de paso fijo,  u_{k+1} = u_k + h*F(u_k).
module integrador
    use modelo, only: campo
    implicit none
    private
    public :: integrar_euler

contains

    !> Da n_pasos pasos de tamaño h desde u0. A la salida, u(:, k) es el
    !> estado en el paso k, para k = 0, ..., n_pasos.
    subroutine integrar_euler(u0, mu, h, n_pasos, u)
        double precision, intent(in) :: u0(2), mu, h
        integer, intent(in) :: n_pasos
        double precision, allocatable, intent(out) :: u(:, :)
        integer :: k

        allocate(u(2, 0:n_pasos))
        u(:, 0) = u0
        do k = 1, n_pasos
            u(:, k) = u(:, k-1) + h * campo(u(:, k-1), mu)
        end do
    end subroutine integrar_euler

end module integrador
