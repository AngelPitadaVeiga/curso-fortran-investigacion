!> Cálculos para el retrato de fases de un sistema plano u' = F(u):
!> campo de vectores normalizado, trayectorias, ciclo límite y nulclinas.
!>
!> Cada subrutina escribe un archivo de datos en columnas, listo para
!> gnuplot (o Julia, Python...). Las curvas distintas se separan con una
!> línea en blanco: gnuplot no las une al dibujar "with lines".
module retrato_fases
    use, intrinsic :: iso_fortran_env, only: real64
    use modelo_lienard, only: f, g
    use tablero_butcher, only: tablero
    use solver_rk, only: problema_edo, opciones_newton, integrar_rk
    implicit none
    private

    public :: caja_plano, ciclo_limite, escribir_campo, escribir_trayectorias, escribir_nulclinas

    !> Rectángulo [x_min, x_max] x [y_min, y_max] del plano de fases.
    type :: caja_plano
        real(real64) :: x_min, x_max, y_min, y_max
    end type caja_plano

contains

    !> Integra desde u0 durante t_transitorio (y lo descarta) y luego
    !> durante t_ciclo, que se escribe en `archivo`: si hay un ciclo límite
    !> atractor, lo que queda es (casi exactamente) el ciclo. Devuelve la
    !> caja que lo contiene, ampliada en un factor `margen`.
    subroutine ciclo_limite(tab, prob, opc, u0, h, t_transitorio, t_ciclo, margen, archivo, caja)
        type(tablero), intent(in) :: tab
        type(problema_edo), intent(in) :: prob
        type(opciones_newton), intent(in) :: opc
        real(real64), intent(in) :: u0(2), h, t_transitorio, t_ciclo, margen
        character(len=*), intent(in) :: archivo
        type(caja_plano), intent(out) :: caja
        real(real64), allocatable :: t(:), u(:, :)
        real(real64) :: cx, cy, rx, ry
        integer :: n_hechos, unidad, k

        ! 1) Transitorio: solo interesa el estado final.
        call integrar_rk(tab, prob, u0, h, nint(t_transitorio / h), opc, t, u, n_hechos)
        call comprobar(n_hechos, size(t) - 1, "el transitorio")

        ! 2) Ciclo: se parte del estado final del transitorio.
        call integrar_rk(tab, prob, u(:, n_hechos), h, nint(t_ciclo / h), opc, t, u, n_hechos)
        call comprobar(n_hechos, size(t) - 1, "el ciclo limite")

        open(newunit=unidad, file=archivo, status="replace", action="write")
        write(unidad, '(a)') '# Ciclo limite (tras descartar el transitorio):  x  y'
        do k = 0, n_hechos
            write(unidad, '(2es16.8)') u(1, k), u(2, k)
        end do
        close(unidad)

        ! Caja centrada en el ciclo y ampliada.
        cx = 0.5_real64 * (maxval(u(1, :)) + minval(u(1, :)))
        cy = 0.5_real64 * (maxval(u(2, :)) + minval(u(2, :)))
        rx = 0.5_real64 * margen * (maxval(u(1, :)) - minval(u(1, :)))
        ry = 0.5_real64 * margen * (maxval(u(2, :)) - minval(u(2, :)))
        caja = caja_plano(cx - rx, cx + rx, cy - ry, cy + ry)
    end subroutine ciclo_limite

    !> Campo de vectores normalizado en una rejilla n x n: columnas x y dx dy.
    !> Todas las flechas tienen la misma longitud (solo importa la dirección).
    !> La normalización se hace en coordenadas relativas a la caja, para que
    !> las flechas se vean igual de largas aunque los ejes tengan escalas distintas.
    subroutine escribir_campo(archivo, prob, caja, n)
        character(len=*), intent(in) :: archivo
        type(problema_edo), intent(in) :: prob
        type(caja_plano), intent(in) :: caja
        integer, intent(in) :: n
        real(real64) :: lx, ly, x, y, du(2), d(2), norma
        integer :: unidad, i, j

        lx = caja%x_max - caja%x_min
        ly = caja%y_max - caja%y_min
        open(newunit=unidad, file=archivo, status="replace", action="write")
        write(unidad, '(a)') '# Campo de vectores normalizado:  x  y  dx  dy'
        do j = 1, n
            do i = 1, n
                x = caja%x_min + lx * (i - 0.5_real64) / n
                y = caja%y_min + ly * (j - 0.5_real64) / n
                du = prob%campo(0.0_real64, [x, y], prob%p)
                d = [du(1) / lx, du(2) / ly]
                norma = norm2(d)
                if (norma > 0.0_real64) d = d / norma
                ! Longitud: 70 % de la separación de la rejilla.
                write(unidad, '(4es16.8)') x, y, 0.7_real64 * lx / n * d(1), 0.7_real64 * ly / n * d(2)
            end do
        end do
        close(unidad)
    end subroutine escribir_campo

    !> Trayectorias desde una rejilla n_ci x n_ci de condiciones iniciales,
    !> integradas durante t_tray. Columnas x y, separadas por líneas en blanco.
    subroutine escribir_trayectorias(archivo, tab, prob, opc, caja, n_ci, h, t_tray)
        character(len=*), intent(in) :: archivo
        type(tablero), intent(in) :: tab
        type(problema_edo), intent(in) :: prob
        type(opciones_newton), intent(in) :: opc
        type(caja_plano), intent(in) :: caja
        integer, intent(in) :: n_ci
        real(real64), intent(in) :: h, t_tray
        real(real64), allocatable :: t(:), u(:, :)
        real(real64) :: x0, y0
        integer :: unidad, i, j, k, n_hechos

        open(newunit=unidad, file=archivo, status="replace", action="write")
        write(unidad, '(a)') '# Trayectorias desde una rejilla de condiciones iniciales:  x  y'
        do j = 1, n_ci
            do i = 1, n_ci
                x0 = caja%x_min + (caja%x_max - caja%x_min) * (i - 0.5_real64) / n_ci
                y0 = caja%y_min + (caja%y_max - caja%y_min) * (j - 0.5_real64) / n_ci
                call integrar_rk(tab, prob, [x0, y0], h, nint(t_tray / h), opc, t, u, n_hechos)
                do k = 0, n_hechos
                    write(unidad, '(2es16.8)') u(1, k), u(2, k)
                end do
                write(unidad, '(a)') ''          ! fin de esta trayectoria
            end do
        end do
        close(unidad)
    end subroutine escribir_trayectorias

    !> Nulclinas del sistema de Liénard:
    !>   x' = 0  ->  y = 0
    !>   y' = 0  ->  y = -g(x)/f(x)   (donde f(x) /= 0)
    !> La segunda se corta (línea en blanco) donde se sale de la caja, por
    !> ejemplo cerca de las asíntotas verticales en las que f(x) = 0.
    subroutine escribir_nulclinas(archivo, p, caja, n)
        character(len=*), intent(in) :: archivo
        real(real64), intent(in) :: p(:)
        type(caja_plano), intent(in) :: caja
        integer, intent(in) :: n
        real(real64) :: x, y, fx, alto
        integer :: unidad, i
        logical :: dentro, antes_dentro

        alto = caja%y_max - caja%y_min
        open(newunit=unidad, file=archivo, status="replace", action="write")
        write(unidad, '(a)') "# Nulclina x' = 0:  y = 0"
        write(unidad, '(2es16.8)') caja%x_min, 0.0_real64
        write(unidad, '(2es16.8)') caja%x_max, 0.0_real64
        write(unidad, '(/)')                     ! dos líneas en blanco: nuevo bloque (index 1)
        write(unidad, '(a)') "# Nulclina y' = 0:  y = -g(x)/f(x)"
        antes_dentro = .false.
        do i = 0, n
            x = caja%x_min + (caja%x_max - caja%x_min) * i / n
            fx = f(x, p)
            dentro = abs(fx) > tiny(1.0_real64)
            if (dentro) then
                y = -g(x, p) / fx
                ! Se deja salir un poco de la caja para que la curva llegue al borde.
                dentro = y > caja%y_min - alto .and. y < caja%y_max + alto
            end if
            if (dentro) then
                write(unidad, '(2es16.8)') x, y
            else if (antes_dentro) then
                write(unidad, '(a)') ''          ! corta la curva
            end if
            antes_dentro = dentro
        end do
        close(unidad)
    end subroutine escribir_nulclinas

    subroutine comprobar(n_hechos, n_pedidos, que)
        integer, intent(in) :: n_hechos, n_pedidos
        character(len=*), intent(in) :: que
        if (n_hechos /= n_pedidos) then
            print '(a)', 'Error: la integracion de ' // que // ' no ha terminado.'
            stop 1
        end if
    end subroutine comprobar

end module retrato_fases
