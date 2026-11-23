!> Un gas en 2D resuelto con volúmenes finitos.
!>
!> Parte de uno de los casos del módulo casos (el vórtice isentrópico o la inestabilidad
!> de Kelvin-Helmholtz) y avanza en el tiempo hasta t_final. Escribe en resultados/:
!>
!>     <nombre>_campo.dat      x, y, rho, u, v, p y la densidad exacta en cada celda, en t_final
!>                             (la exacta solo en el vórtice; en el otro caso, la inicial)
!>     <nombre>_historia.dat   en cada paso: t, densidad mínima, error de la densidad (solo
!>                             en el vórtice) y energía cinética del movimiento vertical
!>     <nombre>_0000.bin, ...  si dt_escritura > 0, la densidad y la vorticidad cada
!>                             dt_escritura, para hacer una película (pelicula.py)
!>
!>     ./fluido vortice.nml
program fluido
    use gas, only: conservadas, primitivas
    use volumenes, only: paso_rk2, paso_maximo
    use casos, only: lado, vortice_exacto, kelvin_helmholtz
    implicit none

    ! Parámetros, con sus valores por defecto.
    character(len=20) :: caso = 'vortice'       ! 'vortice' o 'kelvin_helmholtz'
    integer :: n = 100                          ! celdas en cada dirección
    double precision :: t_final = 10.0d0        ! en t = 10 el vórtice ha dado una vuelta
    double precision :: cfl = 0.5d0             ! fracción del paso máximo estable
    double precision :: beta = 5.0d0            ! intensidad del vórtice
    character(len=20) :: esquema = 'muscl'      ! 'primer_orden' o 'muscl'
    character(len=50) :: nombre = 'muscl'       ! prefijo de los archivos de salida
    double precision :: dt_escritura = 0        ! cada cuánto se guarda una instantánea (0: nunca)
    namelist /parametros/ caso, n, t_final, cfl, beta, esquema, nombre, dt_escritura

    double precision, allocatable :: q(:, :, :)
    double precision :: dx, dt, t, t_escritura, w(4), w_exacta(4), rho_min, error, energia_v
    integer :: i, j, paso, unidad, historia, estado, instantanea
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
    if (caso /= 'vortice' .and. caso /= 'kelvin_helmholtz') then
        print '(a)', 'Caso desconocido: ' // trim(caso)
        stop 1
    end if

    ! 2) Malla y condición inicial, también en las celdas fantasma. La celda i ocupa
    !    [(i - 1) dx, i dx], y su centro está en (i - 1/2) dx.
    dx = lado / n
    allocate(q(4, -1:n+2, -1:n+2))
    do j = -1, n + 2
        do i = -1, n + 2
            q(:, i, j) = conservadas(estado_inicial((i - 0.5d0) * dx, (j - 0.5d0) * dx))
        end do
    end do

    ! 3) Avance en el tiempo. El último paso se acorta para terminar justo en t_final, y
    !    los pasos también se acortan para pasar justo por los instantes que se guardan.
    open(newunit=historia, file='resultados/' // trim(nombre) // '_historia.dat', &
         status='replace', action='write', iostat=estado)
    if (estado /= 0) then
        print '(a)', 'No puedo escribir en resultados/ (existe la carpeta?)'
        stop 1
    end if
    write(historia, '(a)') '#  t  densidad_minima  error_densidad  energia_vertical'
    t = 0
    paso = 0
    instantanea = 0
    t_escritura = 0
    call medir(rho_min, error, energia_v)
    write(historia, '(4es16.8)') t, rho_min, error, energia_v
    if (dt_escritura > 0) call guardar_instantanea()
    do while (t < t_final - 1.0d-12)
        dt = min(paso_maximo(q, dx, cfl), t_final - t)
        if (dt_escritura > 0) dt = min(dt, t_escritura - t)
        call paso_rk2(q, dx, dt, esquema)
        t = t + dt
        paso = paso + 1
        call medir(rho_min, error, energia_v)
        write(historia, '(4es16.8)') t, rho_min, error, energia_v
        ! Escrito así también detecta NaN.
        if (.not. (rho_min > 0)) then
            print '(a, i0, a, es10.3)', 'La solucion ha explotado en el paso ', paso, ', t =', t
            stop 1
        end if
        if (dt_escritura > 0 .and. t >= t_escritura - 1.0d-12) call guardar_instantanea()
    end do
    close(historia)

    ! 4) Resumen y campo final.
    print '(a, a, a, a, a, i0, a, i0)', 'Caso: ', trim(caso), '   esquema: ', trim(esquema), &
                                        '   celdas: ', n, ' x ', n
    print '(a, i0, a, f6.2)', 'Pasos: ', paso, '   t final =', t
    if (caso == 'vortice') then
        w = vortice_exacto(lado / 2, lado / 2, 0.0d0, beta)
        print '(a, f8.4, a, f8.4)', 'Densidad minima:', rho_min, '   exacta:', w(1)
        print '(a, es10.3)', 'Error de la densidad (norma L1):', error
    end if
    if (instantanea > 0) print '(a, i0, a)', 'Instantaneas guardadas: ', instantanea, &
                                             ' (python pelicula.py ' // trim(nombre) // ')'

    open(newunit=unidad, file='resultados/' // trim(nombre) // '_campo.dat', &
         status='replace', action='write')
    write(unidad, '(a, i0)') '#  x  y  rho  u  v  p  rho_exacta    n = ', n
    do j = 1, n
        do i = 1, n
            w = primitivas(q(:, i, j))
            w_exacta = estado_inicial((i - 0.5d0) * dx, (j - 0.5d0) * dx)
            if (caso == 'vortice') w_exacta = vortice_exacto((i - 0.5d0) * dx, (j - 0.5d0) * dx, t, beta)
            write(unidad, '(7es16.8)') (i - 0.5d0) * dx, (j - 0.5d0) * dx, w, w_exacta(1)
        end do
    end do
    close(unidad)
    print '(a)', 'Resultados en resultados/' // trim(nombre) // '_*'

contains

    !> El estado inicial del caso elegido, en primitivas.
    function estado_inicial(x, y) result(w)
        double precision, intent(in) :: x, y
        double precision :: w(4)
        if (caso == 'vortice') then
            w = vortice_exacto(x, y, 0.0d0, beta)
        else
            w = kelvin_helmholtz(x, y)
        end if
    end function estado_inicial

    !> Densidad mínima, error en norma L1 (la media de |rho - rho_exacta|, solo en el
    !> vórtice) y energía cinética media del movimiento vertical, rho v**2 / 2.
    subroutine medir(rho_min, error, energia_v)
        double precision, intent(out) :: rho_min, error, energia_v
        double precision :: w_exacta(4)
        integer :: i, j
        rho_min = minval(q(1, 1:n, 1:n))
        energia_v = sum(q(3, 1:n, 1:n)**2 / q(1, 1:n, 1:n)) / (2 * n**2)
        error = 0
        if (caso /= 'vortice') return
        do j = 1, n
            do i = 1, n
                w_exacta = vortice_exacto((i - 0.5d0) * dx, (j - 0.5d0) * dx, t, beta)
                error = error + abs(q(1, i, j) - w_exacta(1))
            end do
        end do
        error = error / n**2
    end subroutine medir

    !> Escribe la densidad y la vorticidad en resultados/<nombre>_0000.bin, _0001.bin, ...
    !> en binario (access='stream'): los números tal como están en memoria, sin formato.
    !> Se guardan en simple precisión (real), que basta para dibujar y ocupa la mitad.
    !> La lista de instantes y sus tiempos va a <nombre>_instantaneas.dat.
    subroutine guardar_instantanea()
        real :: rho(n, n), vorticidad(n, n)
        double precision :: u(-1:n+2, -1:n+2), v(-1:n+2, -1:n+2)
        character(len=100) :: archivo
        integer :: i, j, unidad

        u = q(2, :, :) / q(1, :, :)
        v = q(3, :, :) / q(1, :, :)
        ! Las celdas fantasma no están al día hasta el siguiente paso: se copian aquí.
        u(0, :) = u(n, :); u(n+1, :) = u(1, :); u(:, 0) = u(:, n); u(:, n+1) = u(:, 1)
        v(0, :) = v(n, :); v(n+1, :) = v(1, :); v(:, 0) = v(:, n); v(:, n+1) = v(:, 1)
        do j = 1, n
            do i = 1, n
                rho(i, j) = real(q(1, i, j))
                ! Vorticidad: dv/dx - du/dy, con diferencias centradas.
                vorticidad(i, j) = real((v(i+1, j) - v(i-1, j) - u(i, j+1) + u(i, j-1)) / (2 * dx))
            end do
        end do

        write(archivo, '(a, a, a, i4.4, a)') 'resultados/', trim(nombre), '_', instantanea, '.bin'
        open(newunit=unidad, file=archivo, access='stream', form='unformatted', status='replace')
        write(unidad) rho, vorticidad
        close(unidad)

        if (instantanea == 0) then
            open(newunit=unidad, file='resultados/' // trim(nombre) // '_instantaneas.dat', &
                 status='replace', action='write')
            write(unidad, '(a, i0)') '#  instantanea  t     n = ', n
        else
            open(newunit=unidad, file='resultados/' // trim(nombre) // '_instantaneas.dat', &
                 status='old', position='append', action='write')
        end if
        write(unidad, '(i6, es16.8)') instantanea, t
        close(unidad)

        instantanea = instantanea + 1
        t_escritura = t_escritura + dt_escritura
    end subroutine guardar_instantanea

end program fluido
