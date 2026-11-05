!> Método de Euler explícito de paso fijo:  u_{k+1} = u_k + h*F(u_k).
module metodo_euler
    use iso_fortran_env, only: real64
    use modelo, only: campo
    implicit none
    private
    public :: integrar_euler

contains

    !> Integra n_pasos pasos de tamaño h desde u0.
    !> A la salida, u(:, k) es el estado en t = k*h, para k = 0, ..., n_pasos:
    !> cada columna es un estado (las columnas son contiguas en memoria).
    subroutine integrar_euler(u0, mu, h, n_pasos, u)
        real(real64), intent(in) :: u0(2), mu, h
        integer, intent(in) :: n_pasos
        real(real64), allocatable, intent(out) :: u(:, :)
        integer :: k

        allocate(u(2, 0:n_pasos))
        u(:, 0) = u0
        do k = 1, n_pasos
            u(:, k) = u(:, k-1) + h * campo(u(:, k-1), mu)
        end do
    end subroutine integrar_euler

end module metodo_euler
