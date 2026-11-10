!> El modelo: el campo vectorial de Van der Pol, u = (x, y),
!>
!>     x' = y
!>     y' = -mu*(x**2 - 1)*y - x
!>
!> y su jacobiano, que solo necesita el Euler implícito.
module modelo
    implicit none
    private
    public :: campo, jacobiano

contains

    function campo(u, mu) result(du)
        double precision, intent(in) :: u(2), mu
        double precision :: du(2)
        du(1) = u(2)
        du(2) = -mu * (u(1)**2 - 1) * u(2) - u(1)
    end function campo

    !> Matriz 2x2 con j(i, k) = dF_i / du_k.
    function jacobiano(u, mu) result(j)
        double precision, intent(in) :: u(2), mu
        double precision :: j(2, 2)
        j(1, 1) = 0
        j(1, 2) = 1
        j(2, 1) = -2 * mu * u(1) * u(2) - 1
        j(2, 2) = -mu * (u(1)**2 - 1)
    end function jacobiano

end module modelo
