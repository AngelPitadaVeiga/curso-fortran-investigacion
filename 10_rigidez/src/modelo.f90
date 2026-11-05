!> Modelo de Liénard como sistema de primer orden, u = (x, y):
!>
!>     x' = y
!>     y' = -f(x)*y - g(x)
!>
!> Por defecto, Van der Pol: f(x) = mu*(x**2 - 1), g(x) = x.
!> Es el modelo de la unidad 08 más su jacobiano, que necesitan los métodos
!> implícitos. Si cambias f o g, cambia también sus derivadas df y dg.
module modelo
    use iso_fortran_env, only: real64
    implicit none
    private
    public :: campo, jacobiano

contains

    pure function f(x, mu) result(fx)
        real(real64), intent(in) :: x, mu
        real(real64) :: fx
        fx = mu * (x**2 - 1)
    end function f

    pure function df(x, mu) result(dfx)
        real(real64), intent(in) :: x, mu
        real(real64) :: dfx
        dfx = 2 * mu * x
    end function df

    pure function g(x) result(gx)
        real(real64), intent(in) :: x
        real(real64) :: gx
        gx = x
    end function g

    pure function dg(x) result(dgx)
        real(real64), intent(in) :: x
        real(real64) :: dgx
        dgx = 1 + 0 * x          ! (0*x: evita el aviso de argumento sin usar)
    end function dg

    !> Campo vectorial F(u) = (x', y').
    pure function campo(u, mu) result(du)
        real(real64), intent(in) :: u(2), mu
        real(real64) :: du(2)
        du(1) = u(2)
        du(2) = -f(u(1), mu) * u(2) - g(u(1))
    end function campo

    !> Jacobiano dF/du:
    !>     | 0                    1     |
    !>     | -f'(x)*y - g'(x)    -f(x)  |
    pure function jacobiano(u, mu) result(jac)
        real(real64), intent(in) :: u(2), mu
        real(real64) :: jac(2, 2)
        jac(1, 1) = 0
        jac(1, 2) = 1
        jac(2, 1) = -df(u(1), mu) * u(2) - dg(u(1))
        jac(2, 2) = -f(u(1), mu)
    end function jacobiano

end module modelo
