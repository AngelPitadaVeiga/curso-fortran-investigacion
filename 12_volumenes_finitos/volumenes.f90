!> Volúmenes finitos en una malla de n x n celdas cuadradas de lado dx, periódica.
!>
!> q(:, i, j) es la media de las variables conservadas en la celda (i, j). A cada lado hay
!> dos filas de celdas fantasma (índices -1, 0 y n+1, n+2) que copian las del lado
!> opuesto; así las celdas del borde se tratan igual que las demás.
!>
!> Cada celda cambia según lo que entra y sale por sus cuatro caras:
!>
!>     dq_ij/dt = -(F_{i+1/2,j} - F_{i-1/2,j}) / dx - (G_{i,j+1/2} - G_{i,j-1/2}) / dx
!>
!> El flujo en una cara se calcula con dos estados, uno a cada lado (flujo de Rusanov).
!> Con esquema = 'primer_orden', esos estados son las medias de las dos celdas. Con
!> esquema = 'muscl', se reconstruye una recta en cada celda, con la pendiente limitada
!> (minmod) para que no aparezcan oscilaciones; el método es entonces de orden 2.
module volumenes
    use gas, only: conservadas, primitivas, flujo, velocidad_ondas
    implicit none
    private
    public :: paso_rk2, paso_maximo

contains

    !> Un paso de tiempo con el método de Heun (Runge-Kutta de orden 2, unidad 09),
    !> aplicado a dq/dt = R(q).
    subroutine paso_rk2(q, dx, dt, esquema)
        double precision, intent(inout) :: q(:, -1:, -1:)
        double precision, intent(in) :: dx, dt
        character(len=*), intent(in) :: esquema
        double precision :: q1(size(q, 1), -1:size(q, 2) - 2, -1:size(q, 3) - 2)
        integer :: n

        n = size(q, 2) - 4
        call periodicas(q)
        q1 = q
        q1(:, 1:n, 1:n) = q(:, 1:n, 1:n) + dt * residuo(q, dx, esquema)
        call periodicas(q1)
        q(:, 1:n, 1:n) = 0.5d0 * (q(:, 1:n, 1:n) + q1(:, 1:n, 1:n) + dt * residuo(q1, dx, esquema))
    end subroutine paso_rk2

    !> Paso de tiempo estable: dt (sx + sy) / dx <= cfl en todas las celdas.
    function paso_maximo(q, dx, cfl) result(dt)
        double precision, intent(in) :: q(:, -1:, -1:), dx, cfl
        double precision :: dt, w(4), s
        integer :: i, j, n

        n = size(q, 2) - 4
        s = 0
        do j = 1, n
            do i = 1, n
                w = primitivas(q(:, i, j))
                s = max(s, velocidad_ondas(w, 1) + velocidad_ondas(w, 2))
            end do
        end do
        dt = cfl * dx / s
    end function paso_maximo

    !> Rellena las celdas fantasma con las del lado opuesto.
    subroutine periodicas(q)
        double precision, intent(inout) :: q(:, -1:, -1:)
        integer :: n
        n = size(q, 2) - 4
        q(:, -1:0, :) = q(:, n-1:n, :)
        q(:, n+1:n+2, :) = q(:, 1:2, :)
        q(:, :, -1:0) = q(:, :, n-1:n)
        q(:, :, n+1:n+2) = q(:, :, 1:2)
    end subroutine periodicas

    !> R(q): lo que entra menos lo que sale de cada celda, dividido por su área.
    function residuo(q, dx, esquema) result(r)
        double precision, intent(in) :: q(:, -1:, -1:), dx
        character(len=*), intent(in) :: esquema
        double precision :: r(4, size(q, 2) - 4, size(q, 3) - 4)
        double precision :: w(4, -1:size(q, 2) - 2, -1:size(q, 3) - 2), f(4)
        integer :: i, j, n

        n = size(q, 2) - 4
        do j = -1, n + 2
            do i = -1, n + 2
                w(:, i, j) = primitivas(q(:, i, j))
            end do
        end do

        r = 0
        ! Caras verticales, entre las celdas (i, j) e (i+1, j). Lo que sale de una entra
        ! en la otra: por eso se conserva exactamente la masa, la cantidad de movimiento
        ! y la energía.
        do j = 1, n
            do i = 0, n
                f = flujo_cara(w(:, i-1, j), w(:, i, j), w(:, i+1, j), w(:, i+2, j), 1, esquema)
                if (i >= 1) r(:, i, j) = r(:, i, j) - f / dx
                if (i < n) r(:, i+1, j) = r(:, i+1, j) + f / dx
            end do
        end do
        ! Caras horizontales, entre las celdas (i, j) e (i, j+1).
        do j = 0, n
            do i = 1, n
                f = flujo_cara(w(:, i, j-1), w(:, i, j), w(:, i, j+1), w(:, i, j+2), 2, esquema)
                if (j >= 1) r(:, i, j) = r(:, i, j) - f / dx
                if (j < n) r(:, i, j+1) = r(:, i, j+1) + f / dx
            end do
        end do
    end function residuo

    !> Flujo de Rusanov en la cara entre las celdas b y c, con a, b, c, d consecutivas
    !> en la dirección dir. w_izq y w_der son los estados a cada lado de la cara.
    function flujo_cara(wa, wb, wc, wd, dir, esquema) result(f)
        double precision, intent(in) :: wa(4), wb(4), wc(4), wd(4)
        integer, intent(in) :: dir
        character(len=*), intent(in) :: esquema
        double precision :: f(4), w_izq(4), w_der(4), s

        select case (esquema)
        case ('primer_orden')
            w_izq = wb
            w_der = wc
        case ('muscl')
            w_izq = wb + 0.5d0 * minmod(wb - wa, wc - wb)
            w_der = wc - 0.5d0 * minmod(wc - wb, wd - wc)
        case default
            print '(a)', 'Esquema desconocido: ' // esquema
            stop 1
        end select

        ! Media de los dos flujos, más una difusión proporcional a la onda más rápida.
        s = max(velocidad_ondas(w_izq, dir), velocidad_ondas(w_der, dir))
        f = 0.5d0 * (flujo(w_izq, dir) + flujo(w_der, dir)) &
            - 0.5d0 * s * (conservadas(w_der) - conservadas(w_izq))
    end function flujo_cara

    !> La pendiente de menor valor absoluto, o cero si tienen distinto signo (un extremo).
    !> elemental: se aplica componente a componente cuando recibe arrays.
    elemental function minmod(a, b) result(m)
        double precision, intent(in) :: a, b
        double precision :: m
        if (a * b <= 0) then
            m = 0
        else
            m = sign(min(abs(a), abs(b)), a)
        end if
    end function minmod

end module volumenes
