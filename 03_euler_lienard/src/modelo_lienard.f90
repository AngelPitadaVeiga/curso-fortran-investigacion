!> Modelo de Liénard en forma de sistema de primer orden:
!>
!>     x' = y
!>     y' = -f(x)*y - g(x)
!>
!> Por defecto es el oscilador de Van der Pol: f(x) = mu*(x**2 - 1), g(x) = x.
!>
!> Para cambiar el modelo basta con editar las funciones f y g (y sus
!> derivadas df y dg, que usa el jacobiano). Este módulo lo reutilizan
!> también los bloques 04 y 05: el modelo se define en un único sitio.
!>
!> Convenio de parámetros: p(1) = mu. Se pasa un vector p(:) (y no un
!> escalar mu) para que la interfaz sirva para cualquier modelo con
!> cualquier número de parámetros; así lo exige el solver del bloque 04.
module modelo_lienard
    use, intrinsic :: iso_fortran_env, only: real64
    implicit none
    private

    public :: f, g, campo_lienard, jacobiano_lienard

contains

    !> Coeficiente de amortiguamiento f(x).
    pure function f(x, p) result(fx)
        real(real64), intent(in) :: x, p(:)
        real(real64) :: fx
        fx = p(1) * (x**2 - 1.0_real64)
    end function f

    !> Derivada f'(x) (para el jacobiano).
    pure function df(x, p) result(dfx)
        real(real64), intent(in) :: x, p(:)
        real(real64) :: dfx
        dfx = 2.0_real64 * p(1) * x
    end function df

    !> Fuerza restauradora g(x).
    pure function g(x, p) result(gx)
        real(real64), intent(in) :: x, p(:)
        real(real64) :: gx
        gx = x
    end function g

    !> Derivada g'(x) (para el jacobiano).
    pure function dg(x, p) result(dgx)
        real(real64), intent(in) :: x, p(:)
        real(real64) :: dgx
        dgx = 1.0_real64
    end function dg

    !> Campo vectorial F(t, u) con u = (x, y).
    !> El argumento t no se usa (sistema autónomo), pero se mantiene para
    !> que la interfaz sea la de una EDO general u' = F(t, u).
    pure function campo_lienard(t, u, p) result(du)
        real(real64), intent(in) :: t, u(:), p(:)
        real(real64) :: du(size(u))
        associate (x => u(1), y => u(2))
            du(1) = y
            du(2) = -f(x, p) * y - g(x, p)
        end associate
    end function campo_lienard

    !> Jacobiano analítico dF/du (matriz 2x2). Lo usa el método de Newton
    !> de los Runge-Kutta implícitos del bloque 04.
    !>
    !>     | 0                     1     |
    !>     | -f'(x)*y - g'(x)     -f(x)  |
    pure function jacobiano_lienard(t, u, p) result(jac)
        real(real64), intent(in) :: t, u(:), p(:)
        real(real64) :: jac(size(u), size(u))
        associate (x => u(1), y => u(2))
            jac(1, 1) = 0.0_real64
            jac(1, 2) = 1.0_real64
            jac(2, 1) = -df(x, p) * y - dg(x, p)
            jac(2, 2) = -f(x, p)
        end associate
    end function jacobiano_lienard

end module modelo_lienard
