!> Las ecuaciones de Euler de un gas ideal en 2D, escritas como leyes de conservación:
!>
!>     q_t + f(q)_x + g(q)_y = 0,      q = (rho, rho u, rho v, E)
!>
!> con la densidad rho, la velocidad (u, v), la energía total por unidad de volumen E y
!> la presión p = (gamma - 1) (E - rho (u**2 + v**2) / 2).
!>
!> Este módulo tiene lo que depende del gas: el paso de las variables conservadas q a las
!> primitivas w = (rho, u, v, p) y al revés, el flujo y la velocidad de las ondas.
module gas
    implicit none
    private
    public :: gamma, conservadas, primitivas, flujo, velocidad_ondas

    double precision, parameter :: gamma = 1.4d0      ! aire

contains

    !> De w = (rho, u, v, p) a q = (rho, rho u, rho v, E).
    function conservadas(w) result(q)
        double precision, intent(in) :: w(4)
        double precision :: q(4)
        q(1) = w(1)
        q(2) = w(1) * w(2)
        q(3) = w(1) * w(3)
        q(4) = w(4) / (gamma - 1) + 0.5d0 * w(1) * (w(2)**2 + w(3)**2)
    end function conservadas

    !> De q = (rho, rho u, rho v, E) a w = (rho, u, v, p).
    function primitivas(q) result(w)
        double precision, intent(in) :: q(4)
        double precision :: w(4)
        w(1) = q(1)
        w(2) = q(2) / q(1)
        w(3) = q(3) / q(1)
        w(4) = (gamma - 1) * (q(4) - 0.5d0 * q(1) * (w(2)**2 + w(3)**2))
    end function primitivas

    !> Flujo a través de una cara perpendicular al eje x (dir = 1) o al eje y (dir = 2).
    function flujo(w, dir) result(f)
        double precision, intent(in) :: w(4)
        integer, intent(in) :: dir
        double precision :: f(4), vn
        vn = w(1 + dir)                         ! velocidad normal a la cara: u o v
        f = vn * conservadas(w)                 ! lo que arrastra la corriente
        f(1 + dir) = f(1 + dir) + w(4)          ! más la presión, en la cantidad de movimiento
        f(4) = f(4) + vn * w(4)                 ! y su trabajo, en la energía
    end function flujo

    !> La mayor velocidad a la que viaja la información en la dirección dir: |vn| + c,
    !> con c = sqrt(gamma p / rho) la velocidad del sonido.
    function velocidad_ondas(w, dir) result(s)
        double precision, intent(in) :: w(4)
        integer, intent(in) :: dir
        double precision :: s
        s = abs(w(1 + dir)) + sqrt(gamma * w(4) / w(1))
    end function velocidad_ondas

end module gas
