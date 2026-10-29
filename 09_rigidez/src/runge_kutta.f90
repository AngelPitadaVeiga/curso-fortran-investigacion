!> Runge-Kutta de paso fijo, explícito o implícito, definido por un tablero
!> de Butcher. Es el módulo del bloque 07 con dos añadidos:
!>
!>   - métodos implícitos: las etapas se obtienen resolviendo un sistema
!>     no lineal con el método de Newton (paso_implicito);
!>   - integrar_rk se detiene si la solución explota (Inf o NaN) o si
!>     Newton no converge, y lo dice con el argumento opcional n_hechos.
module runge_kutta
    use, intrinsic :: iso_fortran_env, only: real64
    use, intrinsic :: ieee_arithmetic, only: ieee_is_finite
    use modelo, only: campo, jacobiano
    use tablero_butcher, only: tablero, es_explicito
    use algebra_lineal, only: resolver_sistema
    implicit none
    private
    public :: paso_rk, integrar_rk

    ! Parámetros de Newton (constantes del módulo, no variables globales).
    real(real64), parameter :: tol_newton = 1.0e-10_real64
    integer, parameter :: max_iter_newton = 20

contains

    !> Un paso explícito (igual que en el bloque 07).
    pure function paso_rk(tab, u, mu, h) result(u_nuevo)
        type(tablero), intent(in) :: tab
        real(real64), intent(in) :: u(2), mu, h
        real(real64) :: u_nuevo(2)
        real(real64) :: k(2, tab%s)
        integer :: i

        do i = 1, tab%s
            k(:, i) = campo(u + h * matmul(k(:, 1:i-1), tab%a(i, 1:i-1)), mu)
        end do
        u_nuevo = u + h * matmul(k, tab%b)
    end function paso_rk

    !> Un paso implícito. Las incógnitas son z_i = u_i - u (una columna de
    !> z por etapa), que cumplen
    !>
    !>     G(z) = z_i - h * sum_j a_ij F(u + z_j) = 0,   i = 1, ..., s.
    !>
    !> Newton: resolver G'(z) dz = -G(z) y hacer z = z + dz. G'(z) es una
    !> matriz de 2s x 2s formada por bloques 2x2:  delta_ij I - h a_ij J(u + z_j).
    subroutine paso_implicito(tab, u, mu, h, u_nuevo, convergido)
        type(tablero), intent(in) :: tab
        real(real64), intent(in) :: u(2), mu, h
        real(real64), intent(out) :: u_nuevo(2)
        logical, intent(out) :: convergido
        real(real64) :: z(2, tab%s), fz(2, tab%s), g(2, tab%s)
        real(real64) :: m(2*tab%s, 2*tab%s), dz(2*tab%s), jac(2, 2)
        integer :: i, j, iter
        logical :: singular

        z = 0                                   ! estimación inicial: u_i = u
        convergido = .false.
        do iter = 1, max_iter_newton
            do j = 1, tab%s
                fz(:, j) = campo(u + z(:, j), mu)
            end do
            g = z - h * matmul(fz, transpose(tab%a))

            ! Matriz de Newton, bloque a bloque.
            do j = 1, tab%s
                jac = jacobiano(u + z(:, j), mu)
                do i = 1, tab%s
                    m(2*i-1:2*i, 2*j-1:2*j) = -h * tab%a(i, j) * jac
                end do
                m(2*j-1, 2*j-1) = m(2*j-1, 2*j-1) + 1
                m(2*j, 2*j) = m(2*j, 2*j) + 1
            end do

            ! reshape ve la matriz g(2, s) como un vector de 2s componentes
            ! (columna tras columna, el orden de la memoria) y viceversa.
            call resolver_sistema(m, reshape(-g, [2*tab%s]), dz, singular)
            if (singular) return
            z = z + reshape(dz, [2, tab%s])

            if (maxval(abs(dz)) <= tol_newton * (1 + maxval(abs(u)))) then
                convergido = .true.
                exit
            end if
        end do
        if (.not. convergido) return

        if (all(abs(tab%b - tab%a(tab%s, :)) < 1.0e-14_real64)) then
            ! Rígidamente preciso (b = última fila de A, como Radau IIA):
            ! u_nuevo = u + z_s, sin volver a evaluar F, que en problemas
            ! rígidos amplificaría el pequeño error de Newton.
            u_nuevo = u + z(:, tab%s)
        else
            do j = 1, tab%s
                fz(:, j) = campo(u + z(:, j), mu)
            end do
            u_nuevo = u + h * matmul(fz, tab%b)
        end if
    end subroutine paso_implicito

    !> Integra n_pasos pasos de tamaño h desde u0: u(:, k) es el estado en
    !> t = k*h. Si la solución explota o Newton no converge, se detiene y
    !> lo avisa; n_hechos (opcional) devuelve el número de pasos completados.
    subroutine integrar_rk(tab, u0, mu, h, n_pasos, u, n_hechos)
        type(tablero), intent(in) :: tab
        real(real64), intent(in) :: u0(2), mu, h
        integer, intent(in) :: n_pasos
        real(real64), allocatable, intent(out) :: u(:, :)
        integer, intent(out), optional :: n_hechos
        integer :: k
        logical :: explicito, convergido

        explicito = es_explicito(tab)
        allocate(u(2, 0:n_pasos))
        u(:, 0) = u0
        if (present(n_hechos)) n_hechos = n_pasos

        do k = 1, n_pasos
            if (explicito) then
                u(:, k) = paso_rk(tab, u(:, k-1), mu, h)
            else
                call paso_implicito(tab, u(:, k-1), mu, h, u(:, k), convergido)
                if (.not. convergido) then
                    print '(a, es10.3, a)', 'Newton no converge en t = ', (k-1) * h, &
                                            '. Prueba con un paso menor.'
                    if (present(n_hechos)) n_hechos = k - 1
                    return
                end if
            end if
            if (.not. all(ieee_is_finite(u(:, k)))) then
                print '(a, es10.3, a)', 'La solucion ha explotado (Inf o NaN) en t = ', k * h, '.'
                if (present(n_hechos)) n_hechos = k - 1
                return
            end if
        end do
    end subroutine integrar_rk

end module runge_kutta
