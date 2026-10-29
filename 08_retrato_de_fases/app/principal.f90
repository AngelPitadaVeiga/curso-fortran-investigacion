!> Bloque 08: retrato de fases de Van der Pol.
!>
!> Uso:   retrato              (lee entrada.nml)
!>        retrato otro.nml
!>
!> Escribe en resultados/:
!>   ciclo.dat          el ciclo límite (tras descartar un transitorio)
!>   campo.dat          campo de direcciones en una rejilla:  x  y  dx  dy
!>   trayectorias.dat   trayectorias desde una rejilla de condiciones iniciales
!>   parametros.gp      mu y el tamaño de la caja, para graficar.gp
program retrato
    use, intrinsic :: iso_fortran_env, only: real64
    use modelo, only: campo
    use tablero_butcher, only: tablero, leer_tablero
    use runge_kutta, only: integrar_rk
    implicit none

    real(real64) :: mu = 1.0_real64
    character(len=256) :: tablero_archivo = "../07_runge_kutta/tableros/rk4.txt"
    real(real64) :: h = 0.001_real64
    real(real64) :: t_transitorio = 100.0_real64
    real(real64) :: t_ciclo = 20.0_real64
    real(real64) :: t_trayectoria = 10.0_real64
    real(real64) :: margen = 1.6_real64
    integer :: n_flechas = 51
    integer :: n_condiciones = 15
    integer :: paso_escritura = 10
    namelist /parametros/ mu, tablero_archivo, h, t_transitorio, t_ciclo, t_trayectoria, &
                          margen, n_flechas, n_condiciones, paso_escritura

    character(len=256) :: archivo_entrada
    type(tablero) :: tab
    real(real64), allocatable :: u(:, :)
    real(real64) :: u_inicio(2), x_max, y_max, x, y, d(2)
    integer :: i, j, unidad, estado

    archivo_entrada = "entrada.nml"
    if (command_argument_count() >= 1) call get_command_argument(1, archivo_entrada)
    open(newunit=unidad, file=archivo_entrada, status="old", action="read", iostat=estado)
    if (estado /= 0) then
        print '(a)', 'Error: no puedo abrir ' // trim(archivo_entrada)
        stop 1
    end if
    read(unidad, nml=parametros)
    close(unidad)
    call leer_tablero(trim(tablero_archivo), tab)
    print '(a, f7.3, a)', 'Retrato de fases para mu =', mu, ' con ' // tab%nombre

    ! 1) Ciclo límite: se integra un transitorio desde (2, 0), se descarta y
    !    se guarda el tramo siguiente. u_inicio es una copia: pasar u(:, n)
    !    directamente no vale, porque integrar_rk vuelve a reservar u.
    call integrar_rk(tab, [2.0_real64, 0.0_real64], mu, h, nint(t_transitorio / h), u)
    u_inicio = u(:, ubound(u, 2))
    call integrar_rk(tab, u_inicio, mu, h, nint(t_ciclo / h), u)

    open(newunit=unidad, file="resultados/ciclo.dat", status="replace", action="write")
    write(unidad, '(a)') '#  x  y  (ciclo limite)'
    write(unidad, '(2es16.8)') u(:, ::paso_escritura)      ! una columna de u por línea
    close(unidad)

    ! La caja del dibujo: la del ciclo, ampliada.
    x_max = margen * maxval(abs(u(1, :)))
    y_max = margen * maxval(abs(u(2, :)))

    ! 2) Campo de direcciones: flechas de la misma longitud, solo importa la
    !    dirección. Se normaliza con la escala de cada eje para que se vean
    !    igual de largas aunque x e y tengan rangos distintos.
    open(newunit=unidad, file="resultados/campo.dat", status="replace", action="write")
    write(unidad, '(a)') '#  x  y  dx  dy  (campo de direcciones)'
    do j = 1, n_flechas
        do i = 1, n_flechas
            x = x_max * (2 * (i - 0.5_real64) / n_flechas - 1)
            y = y_max * (2 * (j - 0.5_real64) / n_flechas - 1)
            d = campo([x, y], mu) / [x_max, y_max]
            if (norm2(d) > 0) d = d / norm2(d)                  ! en el equilibrio, d = 0
            d = 1.4_real64 / n_flechas * d * [x_max, y_max]    ! 70 % de la separación
            write(unidad, '(4es16.8)') x, y, d
        end do
    end do
    close(unidad)

    ! 3) Trayectorias desde una rejilla de condiciones iniciales. Una línea
    !    en blanco entre trayectorias: gnuplot no las une.
    open(newunit=unidad, file="resultados/trayectorias.dat", status="replace", action="write")
    write(unidad, '(a)') '#  x  y  (trayectorias, separadas por lineas en blanco)'
    do j = 1, n_condiciones
        do i = 1, n_condiciones
            x = x_max * (2 * (i - 0.5_real64) / n_condiciones - 1)
            y = y_max * (2 * (j - 0.5_real64) / n_condiciones - 1)
            call integrar_rk(tab, [x, y], mu, h, nint(t_trayectoria / h), u)
            write(unidad, '(2es16.8)') u(:, ::paso_escritura)
            write(unidad, '(a)') ''
        end do
    end do
    close(unidad)

    ! 4) Parámetros para el script de gnuplot.
    open(newunit=unidad, file="resultados/parametros.gp", status="replace", action="write")
    write(unidad, '(a, es16.8)') 'mu = ', mu
    write(unidad, '(a, es16.8)') 'x_max = ', x_max
    write(unidad, '(a, es16.8)') 'y_max = ', y_max
    close(unidad)

    print '(a)', 'Datos escritos en resultados/'
end program retrato
