!> El modelo: el campo vectorial de Van der Pol, u = (x, y),
!>
!>     x' = y
!>     y' = -mu*(x**2 - 1)*y - x
module modelo
    implicit none
    private                 ! todo es privado...
    public :: campo         ! ...salvo lo que se exporta aquí

contains

    function campo(u, mu) result(du)
        double precision, intent(in) :: u(2), mu
        double precision :: du(2)
        du(1) = u(2)
        du(2) = -mu * (u(1)**2 - 1) * u(2) - u(1)
    end function campo

end module modelo
