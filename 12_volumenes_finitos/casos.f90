!> Las condiciones iniciales, en el cuadrado [0, 10] x [0, 10] con condiciones periódicas.
!>
!> vortice_exacto: el vórtice isentrópico, una solución exacta de las ecuaciones de Euler.
!>     Es un remolino centrado inicialmente en (5, 5) que la corriente de fondo, de
!>     velocidad (1, 1), arrastra sin deformarlo. En el centro la densidad y la presión son
!>     mínimas, y en t = 10 vuelve a su posición inicial. beta es la intensidad: la
!>     velocidad de giro máxima vale beta / (2 pi), a distancia 1 del centro.
!>
!> kelvin_helmholtz: una franja de gas denso (rho = 2) que se mueve hacia la derecha entre
!>     dos capas de gas ligero (rho = 1) que se mueven hacia la izquierda. Una pequeña
!>     perturbación de la velocidad vertical hace que las dos superficies de separación se
!>     enrollen en vórtices, que después se unen de dos en dos. No tiene solución exacta.
module casos
    use gas, only: gamma
    implicit none
    private
    public :: lado, vortice_exacto, kelvin_helmholtz

    double precision, parameter :: lado = 10.0d0
    double precision, parameter :: pi = acos(-1.0d0)

contains

    !> Variables primitivas (rho, u, v, p) del vórtice exacto en (x, y) y en el tiempo t.
    function vortice_exacto(x, y, t, beta) result(w)
        double precision, intent(in) :: x, y, t, beta
        double precision, parameter :: u0 = 1.0d0, v0 = 1.0d0     ! corriente de fondo
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

    !> Variables primitivas (rho, u, v, p) del estado inicial de Kelvin-Helmholtz en (x, y).
    function kelvin_helmholtz(x, y) result(w)
        double precision, intent(in) :: x, y
        double precision, parameter :: y1 = 2.5d0, y2 = 7.5d0   ! las dos superficies
        double precision, parameter :: a = 0.1d0                ! su espesor
        double precision, parameter :: amplitud = 0.05d0        ! la perturbación
        double precision :: w(4), franja

        ! franja vale 1 entre y1 e y2 y 0 fuera, con una transición suave de espesor a.
        franja = (tanh((y - y1) / a) - tanh((y - y2) / a)) / 2
        w(1) = 1 + franja
        w(2) = -0.5d0 + franja
        ! Cuatro ondas a lo largo de x, más otra de la mitad de amplitud y doble longitud,
        ! concentradas cerca de las superficies. La segunda hace que los vórtices se unan
        ! de dos en dos.
        w(3) = amplitud * (sin(8 * pi * x / lado) + 0.5d0 * sin(4 * pi * x / lado)) &
               * (exp(-((y - y1) / 0.5d0)**2) + exp(-((y - y2) / 0.5d0)**2))
        w(4) = 2.5d0
    end function kelvin_helmholtz

end module casos
