!> Método de Euler explícito de paso fijo:
!>
!>     u_{k+1} = u_k + h * F(t_k, u_k),     t_k = k*h
!>
!> En este bloque el solver usa directamente el módulo del modelo: es
!> sencillo, pero el solver "conoce" el modelo. En el bloque 04 se separan
!> ambos mediante una interfaz abstracta y punteros a procedimiento.
module solver_euler
    use, intrinsic :: iso_fortran_env, only: real64
    use modelo_lienard, only: campo_lienard
    implicit none
    private

    public :: integrar_euler

contains

    !> Integra desde t = 0 con n_pasos pasos de tamaño h.
    !> A la salida, t(k) es el instante k-ésimo y u(:, k) el estado en t(k),
    !> para k = 0, 1, ..., n_pasos. Cada columna de u es un estado completo:
    !> Fortran guarda las matrices por columnas, así que u(:, k) es contiguo.
    subroutine integrar_euler(u0, p, h, n_pasos, t, u)
        real(real64), intent(in) :: u0(:)          !< estado inicial
        real(real64), intent(in) :: p(:)           !< parámetros del modelo
        real(real64), intent(in) :: h              !< tamaño de paso
        integer, intent(in) :: n_pasos             !< número de pasos
        real(real64), allocatable, intent(out) :: t(:), u(:, :)
        integer :: k

        ! Los índices empiezan donde queramos: aquí en 0, como en las fórmulas.
        allocate(t(0:n_pasos), u(size(u0), 0:n_pasos))

        t(0) = 0.0_real64
        u(:, 0) = u0
        do k = 1, n_pasos
            u(:, k) = u(:, k-1) + h * campo_lienard(t(k-1), u(:, k-1), p)
            t(k) = k * h        ! mejor que t = t + h: no acumula redondeo
        end do
    end subroutine integrar_euler

end module solver_euler
