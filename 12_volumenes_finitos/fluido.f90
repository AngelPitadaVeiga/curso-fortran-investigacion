!> Un vórtice arrastrado por un gas, resuelto con volúmenes finitos.
!>
!> Parte del vórtice isentrópico (módulo vortice), avanza en el tiempo hasta t_final y
!> compara con la solución exacta. Escribe en resultados/:
!>
!>     <nombre>_campo.dat      x, y, rho, u, v, p y la densidad exacta en cada celda, en t_final
!>     <nombre>_historia.dat   t, densidad mínima y error de la densidad, en cada paso
!>
!>     ./fluido vortice.nml
program fluido
    use gas, only: conservadas, primitivas
    use volumenes, only: paso_rk2, paso_maximo
    use vortice, only: lado, vortice_exacto
    implicit none

    ! Parámetros, con sus valores por defecto.
    integer :: n = 100                          ! celdas en cada dirección
    double precision :: t_final = 10.0d0        ! en t = 10 el vórtice ha dado una vuelta
    double precision :: cfl = 0.5d0             ! fracción del paso máximo estable
    double precision :: beta = 5.0d0            ! intensidad del vórtice
    character(len=20) :: esquema = 'muscl'      ! 'primer_orden' o 'muscl'
    character(len=50) :: nombre = 'muscl'       ! prefijo de los archivos de salida
    namelist /parametros/ n, t_final, cfl, beta, esquema, nombre

    double precision, allocatable :: q(:, :, :)
    double precision :: dx, dt, t, w(4), w_exacta(4), rho_min, error
    integer :: i, j, paso, unidad, historia, estado
    character(len=100) :: archivo_entrada

    ! 1) Parámetros.
    archivo_entrada = 'vortice.nml'
    if (command_argument_count() >= 1) call get_command_argument(1, archivo_entrada)
    open(newunit=unidad, file=archivo_entrada, status='old', action='read', iostat=estado)
    if (estado /= 0) then
        print '(a)', 'No puedo abrir ' // trim(archivo_entrada)
        stop 1
    end if
    read(unidad, nml=parametros)
    close(unidad)
    if (esquema /= 'primer_orden' .and. esquema /= 'muscl') then
        print '(a)', 'Esquema desconocido: ' // trim(esquema)
        stop 1
    end if

    ! 2) Malla y condición inicial, también en las celdas fantasma. La celda i ocupa
    !    [(i - 1) dx, i dx], y su centro está en (i - 1/2) dx.
    dx = lado / n
    allocate(q(4, -1:n+2, -1:n+2))
    do j = -1, n + 2
        do i = -1, n + 2
            q(:, i, j) = conservadas(vortice_exacto((i - 0.5d0) * dx, (j - 0.5d0) * dx, 0.0d0, beta))
        end do
    end do

    ! 3) Avance en el tiempo. El último paso se acorta para terminar justo en t_final.
    open(newunit=historia, file='resultados/' // trim(nombre) // '_historia.dat', &
         status='replace', action='write', iostat=estado)
    if (estado /= 0) then
        print '(a)', 'No puedo escribir en resultados/ (existe la carpeta?)'
        stop 1
    end if
    write(historia, '(a)') '#  t  densidad_minima  error_densidad'
    t = 0
    paso = 0
    call medir(rho_min, error)
    write(historia, '(3es16.8)') t, rho_min, error
    do while (t < t_final - 1.0d-12)
        dt = min(paso_maximo(q, dx, cfl), t_final - t)
        call paso_rk2(q, dx, dt, esquema)
        t = t + dt
        paso = paso + 1
        call medir(rho_min, error)
        write(historia, '(3es16.8)') t, rho_min, error
        ! Escrito así también detecta NaN.
        if (.not. (rho_min > 0)) then
            print '(a, i0, a, es10.3)', 'La solucion ha explotado en el paso ', paso, ', t =', t
            stop 1
        end if
    end do
    close(historia)

    ! 4) Resumen y campo final.
    w = vortice_exacto(lado / 2, lado / 2, 0.0d0, beta)
    print '(a, a, a, i0, a, i0)', 'Esquema: ', trim(esquema), '   celdas: ', n, ' x ', n
    print '(a, i0, a, f6.2)', 'Pasos: ', paso, '   t final =', t
    print '(a, f8.4, a, f8.4)', 'Densidad minima:', rho_min, '   exacta:', w(1)
    print '(a, es10.3)', 'Error de la densidad (norma L1):', error

    open(newunit=unidad, file='resultados/' // trim(nombre) // '_campo.dat', &
         status='replace', action='write')
    write(unidad, '(a, i0)') '#  x  y  rho  u  v  p  rho_exacta    n = ', n
    do j = 1, n
        do i = 1, n
            w = primitivas(q(:, i, j))
            w_exacta = vortice_exacto((i - 0.5d0) * dx, (j - 0.5d0) * dx, t, beta)
            write(unidad, '(7es16.8)') (i - 0.5d0) * dx, (j - 0.5d0) * dx, w, w_exacta(1)
        end do
    end do
    close(unidad)
    print '(a)', 'Resultados en resultados/' // trim(nombre) // '_*.dat'

contains

    !> Densidad mínima y error en norma L1: la media de |rho - rho_exacta| en el dominio.
    subroutine medir(rho_min, error)
        double precision, intent(out) :: rho_min, error
        double precision :: w_exacta(4)
        integer :: i, j
        rho_min = minval(q(1, 1:n, 1:n))
        error = 0
        do j = 1, n
            do i = 1, n
                w_exacta = vortice_exacto((i - 0.5d0) * dx, (j - 0.5d0) * dx, t, beta)
                error = error + abs(q(1, i, j) - w_exacta(1))
            end do
        end do
        error = error / n**2
    end subroutine medir

end program fluido
