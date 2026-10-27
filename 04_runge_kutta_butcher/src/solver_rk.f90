!> Runge-Kutta general de paso fijo definido por un tablero de Butcher.
!>
!> El solver NO conoce el modelo: recibe el campo vectorial F(t, u) y su
!> jacobiano mediante punteros a procedimiento con una interfaz abstracta.
!> Cualquier función con esa forma (la de Liénard, Lorenz, ...) sirve.
!>
!> - Si A es estrictamente triangular inferior (método explícito), las
!>   etapas se calculan una tras otra.
!> - Si no (método implícito), se resuelve el sistema no lineal de las
!>   etapas, de dimensión n*s, con el método de Newton.
module solver_rk
    use, intrinsic :: iso_fortran_env, only: real64
    use, intrinsic :: ieee_arithmetic, only: ieee_is_finite
    use tablero_butcher, only: tablero
    use algebra_lineal, only: resolver_sistema
    implicit none
    private

    public :: campo_vectorial, jacobiano_campo, problema_edo, opciones_newton
    public :: paso_rk, integrar_rk

    !> Interfaces abstractas: describen la "forma" de una función sin
    !> implementarla, como un tipo de función en C++ (std::function) o una
    !> firma de método en Julia.
    abstract interface
        pure function campo_vectorial(t, u, p) result(du)
            import :: real64
            real(real64), intent(in) :: t, u(:), p(:)
            real(real64) :: du(size(u))
        end function campo_vectorial

        pure function jacobiano_campo(t, u, p) result(jac)
            import :: real64
            real(real64), intent(in) :: t, u(:), p(:)
            real(real64) :: jac(size(u), size(u))
        end function jacobiano_campo
    end interface

    !> El problema u' = F(t, u; p): punteros al campo y al jacobiano, y los
    !> parámetros p. `nopass` indica que el procedimiento no recibe el
    !> objeto como primer argumento (no es un "método").
    type :: problema_edo
        procedure(campo_vectorial), pointer, nopass :: campo => null()
        procedure(jacobiano_campo), pointer, nopass :: jacobiano => null()
        real(real64), allocatable :: p(:)
    end type problema_edo

    !> Parámetros del método de Newton (solo para métodos implícitos).
    type :: opciones_newton
        real(real64) :: tolerancia = 1.0e-10_real64
        integer :: max_iter = 20
    end type opciones_newton

contains

    !> Un paso de Runge-Kutta: de u(t) a u_nuevo ~ u(t + h).
    !> `iter` es el número de iteraciones de Newton (0 si es explícito) y
    !> `exito` es .false. si Newton no converge.
    pure subroutine paso_rk(tab, prob, t, u, h, opc, u_nuevo, iter, exito)
        type(tablero), intent(in) :: tab
        type(problema_edo), intent(in) :: prob
        real(real64), intent(in) :: t, u(:), h
        type(opciones_newton), intent(in) :: opc
        real(real64), intent(out) :: u_nuevo(size(u))
        integer, intent(out) :: iter
        logical, intent(out) :: exito
        real(real64) :: k(size(u), tab%s)     ! k(:, i) = etapa i (columnas contiguas)
        integer :: i

        iter = 0
        exito = .true.
        if (tab%explicito) then
            do i = 1, tab%s
                ! k_i = F(t + c_i h, u + h * sum_{j<i} a_ij k_j)
                k(:, i) = prob%campo(t + tab%c(i) * h, &
                                     u + h * matmul(k(:, 1:i-1), tab%a(i, 1:i-1)), prob%p)
            end do
            u_nuevo = u + h * matmul(k, tab%b)
        else
            call paso_implicito(tab, prob, t, u, h, opc, u_nuevo, iter, exito)
        end if
    end subroutine paso_rk

    !> Paso implícito. Incógnitas z_i = h * sum_j a_ij F(t + c_j h, u + z_j),
    !> i = 1..s, guardadas como columnas de z(n, s). Newton para
    !>
    !>     G(z) = z - h * F(z) * A^T = 0,   con F(z)(:, j) = F(t + c_j h, u + z(:, j)).
    !>
    !> El jacobiano de G tiene bloques n x n:  delta_ij * I - h * a_ij * J_j,
    !> con J_j el jacobiano del campo en la etapa j.
    pure subroutine paso_implicito(tab, prob, t, u, h, opc, u_nuevo, iter, exito)
        type(tablero), intent(in) :: tab
        type(problema_edo), intent(in) :: prob
        real(real64), intent(in) :: t, u(:), h
        type(opciones_newton), intent(in) :: opc
        real(real64), intent(out) :: u_nuevo(size(u))
        integer, intent(out) :: iter
        logical, intent(out) :: exito
        integer :: n, s, i, j, fi, ci
        real(real64) :: z(size(u), tab%s), fz(size(u), tab%s), g(size(u), tab%s), dz(size(u), tab%s)
        real(real64) :: jac(size(u), size(u), tab%s)
        real(real64) :: m(size(u)*tab%s, size(u)*tab%s), dz_vec(size(u)*tab%s)
        logical :: singular

        n = size(u)
        s = tab%s
        z = 0.0_real64           ! estimación inicial: etapas = estado actual
        exito = .false.

        do iter = 1, opc%max_iter
            do j = 1, s
                fz(:, j) = prob%campo(t + tab%c(j) * h, u + z(:, j), prob%p)
                jac(:, :, j) = prob%jacobiano(t + tab%c(j) * h, u + z(:, j), prob%p)
            end do
            g = z - h * matmul(fz, transpose(tab%a))

            ! Matriz de Newton (n*s x n*s) por bloques.
            do j = 1, s
                ci = (j - 1) * n
                do i = 1, s
                    fi = (i - 1) * n
                    m(fi+1:fi+n, ci+1:ci+n) = -h * tab%a(i, j) * jac(:, :, j)
                end do
                m(ci+1:ci+n, ci+1:ci+n) = m(ci+1:ci+n, ci+1:ci+n) + identidad(n)
            end do

            ! reshape: la matriz z(n, s) se ve como un vector de n*s
            ! componentes, columna tras columna (el orden de la memoria).
            call resolver_sistema(m, reshape(-g, [n*s]), dz_vec, singular)
            if (singular) return
            dz = reshape(dz_vec, [n, s])
            z = z + dz

            if (maxval(abs(dz)) <= opc%tolerancia * (1.0_real64 + maxval(abs(u)))) then
                exito = .true.
                exit
            end if
        end do
        if (.not. exito) return

        if (tab%rigidamente_preciso) then
            ! b = última fila de A, luego u_nuevo = u + z_s. Evita volver a
            ! evaluar F, que en problemas rígidos amplifica el error de Newton.
            u_nuevo = u + z(:, s)
        else
            do j = 1, s
                fz(:, j) = prob%campo(t + tab%c(j) * h, u + z(:, j), prob%p)
            end do
            u_nuevo = u + h * matmul(fz, tab%b)
        end if
    end subroutine paso_implicito

    pure function identidad(n) result(id)
        integer, intent(in) :: n
        real(real64) :: id(n, n)
        integer :: i
        id = 0.0_real64
        do i = 1, n
            id(i, i) = 1.0_real64
        end do
    end function identidad

    !> Integra desde t = 0 con n_pasos pasos de tamaño h.
    !> A la salida, u(:, k) es el estado en t(k) = k*h, k = 0..n_hechos.
    !> Si la solución deja de ser finita (el método "explota") o Newton no
    !> converge, se avisa y se devuelven los pasos hechos hasta entonces
    !> (n_hechos < n_pasos). El argumento opcional iter_media devuelve el
    !> número medio de iteraciones de Newton por paso (0 si es explícito).
    subroutine integrar_rk(tab, prob, u0, h, n_pasos, opc, t, u, n_hechos, iter_media)
        type(tablero), intent(in) :: tab
        type(problema_edo), intent(in) :: prob
        real(real64), intent(in) :: u0(:), h
        integer, intent(in) :: n_pasos
        type(opciones_newton), intent(in) :: opc
        real(real64), allocatable, intent(out) :: t(:), u(:, :)
        integer, intent(out) :: n_hechos
        real(real64), intent(out), optional :: iter_media
        integer :: k, iter, iter_total
        logical :: exito

        if (.not. associated(prob%campo)) then
            print '(a)', 'Error: el problema no tiene campo vectorial asociado.'
            stop 1
        end if
        if (.not. tab%explicito .and. .not. associated(prob%jacobiano)) then
            print '(a)', 'Error: el metodo ' // tab%nombre // ' es implicito y necesita el jacobiano.'
            stop 1
        end if

        allocate(t(0:n_pasos), u(size(u0), 0:n_pasos))
        t(0) = 0.0_real64
        u(:, 0) = u0
        iter_total = 0
        n_hechos = n_pasos

        do k = 1, n_pasos
            call paso_rk(tab, prob, t(k-1), u(:, k-1), h, opc, u(:, k), iter, exito)
            t(k) = k * h
            iter_total = iter_total + iter
            if (.not. exito) then
                print '(a, es12.4, a, i0, a)', 'Error: Newton no converge en t = ', t(k-1), &
                      ' tras ', opc%max_iter, ' iteraciones.'
                print '(a)', '       Prueba con un paso h menor o aumenta max_iter_newton.'
                n_hechos = k - 1
                exit
            end if
            if (.not. all(ieee_is_finite(u(:, k)))) then
                print '(a, es12.4, a)', 'La solucion ha explotado (Inf o NaN) en t = ', t(k), &
                      '. Se detiene la integracion.'
                n_hechos = k - 1
                exit
            end if
        end do

        if (present(iter_media)) iter_media = real(iter_total, real64) / max(n_hechos, 1)
    end subroutine integrar_rk

end module solver_rk
