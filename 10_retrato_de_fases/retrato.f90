!> Retrato de fases de Van der Pol: ciclo límite, campo de direcciones y
!> trayectorias desde una rejilla de condiciones iniciales.
!>
!>     ./retrato                 (lee entrada.nml)
!>     ./retrato otro.nml
!>
!> Escribe en resultados/:
!>   ciclo.dat          el ciclo límite (tras descartar un transitorio)
!>   campo.dat          campo de direcciones en una rejilla:  x  y  dx  dy
!>   trayectorias.dat   todas las trayectorias, una detrás de otra
!>   parametros.dat     mu, tamaño de la caja y número de trayectorias
program retrato
    use modelo, only: campo
    use runge_kutta, only: integrar
    implicit none

    double precision :: mu = 1.0d0
    double precision :: h = 0.001d0
    double precision :: t_transitorio = 100.0d0   ! se integra y se descarta
    double precision :: t_ciclo = 20.0d0          ! tramo que se guarda como ciclo
    double precision :: t_trayectoria = 10.0d0    ! duración de cada trayectoria
    integer :: n_flechas = 51                     ! rejilla de flechas: n_flechas x n_flechas
    integer :: n_condiciones = 15                 ! rejilla de condiciones iniciales
    integer :: paso_escritura = 10                ! se escribe un punto de cada 10
    namelist /parametros/ mu, h, t_transitorio, t_ciclo, t_trayectoria, &
                          n_flechas, n_condiciones, paso_escritura

    character(len=100) :: archivo_entrada
    double precision, allocatable :: u(:, :)
    double precision :: u_inicio(2), x_max, y_max, x, y, d(2)
    integer :: i, j, unidad, estado, n_hechos

    archivo_entrada = 'entrada.nml'
    if (command_argument_count() >= 1) call get_command_argument(1, archivo_entrada)
    open(newunit=unidad, file=archivo_entrada, status='old', action='read', iostat=estado)
    if (estado /= 0) then
        print '(a)', 'No puedo abrir ' // trim(archivo_entrada)
        stop 1
    end if
    read(unidad, nml=parametros)
    close(unidad)
    print '(a, f7.3)', 'Retrato de fases para mu =', mu

    ! 1) El ciclo límite: integramos un transitorio desde (2, 0), nos quedamos con
    !    el estado final y seguimos desde ahí. u_inicio es una copia: no se puede
    !    pasar u(:, n) directamente, porque integrar vuelve a reservar u.
    call integrar('rk4', [2.0d0, 0.0d0], mu, h, nint(t_transitorio / h), u, n_hechos)
    u_inicio = u(:, n_hechos)
    call integrar('rk4', u_inicio, mu, h, nint(t_ciclo / h), u, n_hechos)

    open(newunit=unidad, file='resultados/ciclo.dat', status='replace', action='write')
    write(unidad, '(a)') '#  x  y  (ciclo limite)'
    write(unidad, '(2es16.8)') u(:, ::paso_escritura)      ! una columna de u por línea
    close(unidad)

    ! La caja del dibujo: la del ciclo, un poco más grande.
    x_max = 1.6d0 * maxval(abs(u(1, :)))
    y_max = 1.6d0 * maxval(abs(u(2, :)))

    ! 2) Campo de direcciones: flechas de la misma longitud, porque solo
    !    importa la dirección.
    open(newunit=unidad, file='resultados/campo.dat', status='replace', action='write')
    write(unidad, '(a)') '#  x  y  dx  dy  (campo de direcciones)'
    do j = 1, n_flechas
        do i = 1, n_flechas
            x = x_max * (2 * (i - 0.5d0) / n_flechas - 1)
            y = y_max * (2 * (j - 0.5d0) / n_flechas - 1)
            d = campo([x, y], mu) / [x_max, y_max]      ! en los ejes del dibujo
            if (norm2(d) > 0) d = d / norm2(d)           ! en el equilibrio, d = 0
            d = 1.4d0 / n_flechas * d * [x_max, y_max]
            write(unidad, '(4es16.8)') x, y, d
        end do
    end do
    close(unidad)

    ! 3) Trayectorias desde una rejilla de condiciones iniciales. Todas tienen
    !    el mismo número de puntos, y graficar.py las separa.
    open(newunit=unidad, file='resultados/trayectorias.dat', status='replace', action='write')
    write(unidad, '(a)') '#  x  y  (trayectorias, una detras de otra)'
    do j = 1, n_condiciones
        do i = 1, n_condiciones
            x = x_max * (2 * (i - 0.5d0) / n_condiciones - 1)
            y = y_max * (2 * (j - 0.5d0) / n_condiciones - 1)
            call integrar('rk4', [x, y], mu, h, nint(t_trayectoria / h), u, n_hechos)
            write(unidad, '(2es16.8)') u(:, ::paso_escritura)
        end do
    end do
    close(unidad)

    ! 4) Datos para el dibujo.
    open(newunit=unidad, file='resultados/parametros.dat', status='replace', action='write')
    write(unidad, '(a)') '#  mu  x_max  y_max  n_trayectorias'
    write(unidad, '(3es16.8, i8)') mu, x_max, y_max, n_condiciones**2
    close(unidad)

    print '(a)', 'Datos escritos en resultados/'
end program retrato
