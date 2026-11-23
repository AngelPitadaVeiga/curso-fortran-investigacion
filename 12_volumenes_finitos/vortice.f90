!> El vórtice isentrópico: una solución exacta de las ecuaciones de Euler.
!>
!> Es un remolino centrado inicialmente en (5, 5) que la corriente de fondo, de velocidad
!> (1, 1), arrastra sin deformarlo. En el centro la densidad y la presión son mínimas.
!> El dominio es el cuadrado [0, 10] x [0, 10] con condiciones periódicas, de modo que en
!> t = 10 el vórtice vuelve a su posición inicial.
!>
!> beta es la intensidad: la velocidad de giro máxima vale beta / (2 pi), a distancia 1
!> del centro.
module vortice
    use gas, only: gamma
    implicit none
    private
    public :: lado, vortice_exacto

    double precision, parameter :: lado = 10.0d0
    double precision, parameter :: pi = acos(-1.0d0)
    double precision, parameter :: u0 = 1.0d0, v0 = 1.0d0     ! corriente de fondo

contains

    !> Variables primitivas (rho, u, v, p) de la solución exacta en (x, y) y en el tiempo t.
    function vortice_exacto(x, y, t, beta) result(w)
        double precision, intent(in) :: x, y, t, beta
        double precision :: w(4), rx, ry, r2, temperatura

        ! Vector desde el centro, que en el tiempo t está en (5 + u0 t, 5 + v0 t). Se toma
        ! la copia periódica más cercana del centro.
        rx = x - (lado / 2 + u0 * t)
        ry = y - (lado / 2 + v0 * t)
        rx = rx - lado * nint(rx / lado)
        ry = ry - lado * nint(ry / lado)
        r2 = rx**2 + ry**2

        temperatura = 1 - (gamma - 1) * beta**2 / (8 * gamma * pi**2) * exp(1 - r2)
        w(1) = temperatura**(1 / (gamma - 1))
        w(2) = u0 - beta / (2 * pi) * exp((1 - r2) / 2) * ry
        w(3) = v0 + beta / (2 * pi) * exp((1 - r2) / 2) * rx
        w(4) = w(1) * temperatura
    end function vortice_exacto

end module vortice
