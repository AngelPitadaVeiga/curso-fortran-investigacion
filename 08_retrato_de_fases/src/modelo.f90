!> Modelo de Liénard como sistema de primer orden, u = (x, y):
!>
!>     x' = y
!>     y' = -f(x)*y - g(x)
!>
!> Por defecto, Van der Pol: f(x) = mu*(x**2 - 1), g(x) = x.
!> Para cambiar de modelo basta con editar f y g.
module modelo
    use, intrinsic :: iso_fortran_env, only: real64
    implicit none
    private                 ! todo es privado...
    public :: campo         ! ...salvo lo que se exporta explícitamente

contains

    !> Amortiguamiento f(x).
    pure function f(x, mu) result(fx)
        real(real64), intent(in) :: x, mu
        real(real64) :: fx
        fx = mu * (x**2 - 1)
    end function f

    !> Fuerza restauradora g(x).
    pure function g(x) result(gx)
        real(real64), intent(in) :: x
        real(real64) :: gx
        gx = x
    end function g

    !> Campo vectorial F(u) = (x', y').
    pure function campo(u, mu) result(du)
        real(real64), intent(in) :: u(2), mu
        real(real64) :: du(2)
        du(1) = u(2)
        du(2) = -f(u(1), mu) * u(2) - g(u(1))
    end function campo

end module modelo
