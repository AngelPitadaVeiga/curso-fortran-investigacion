!> Van der Pol con el método que se elija en el archivo de entrada.
!>
!>     ./rk                  (lee entrada.nml)
!>     ./rk otro.nml
program rk
    use runge_kutta, only: integrar
    implicit none

    character(len=20) :: metodo = 'rk4'
    double precision :: mu = 1.0d0
    double precision :: h = 0.01d0
    double precision :: t_final = 30.0d0
    double precision :: x0 = 0.5d0, y0 = 0.0d0
    integer :: paso_escritura = 1            ! se escribe un paso de cada paso_escritura
    character(len=100) :: archivo_salida = 'resultados/rk.dat'
    namelist /parametros/ metodo, mu, h, t_final, x0, y0, paso_escritura, archivo_salida

    character(len=100) :: archivo_entrada
    double precision, allocatable :: u(:, :)
    integer :: k, n_pasos, n_hechos, unidad, estado

    archivo_entrada = 'entrada.nml'
    if (command_argument_count() >= 1) call get_command_argument(1, archivo_entrada)
    open(newunit=unidad, file=archivo_entrada, status='old', action='read', iostat=estado)
    if (estado /= 0) then
        print '(a)', 'No puedo abrir ' // trim(archivo_entrada)
        stop 1
    end if
    read(unidad, nml=parametros)
    close(unidad)

    n_pasos = nint(t_final / h)
    print '(a, f7.1, a, es9.2, a, i0)', 'Metodo: ' // trim(metodo) // '   mu =', mu, '   h =', h, &
                                        '   pasos = ', n_pasos
    call integrar(trim(metodo), [x0, y0], mu, h, n_pasos, u, n_hechos)
    print '(a, i0, a, 2es14.6)', 'Pasos hechos: ', n_hechos, '   estado final (x, y) = ', u(:, n_hechos)

    open(newunit=unidad, file=archivo_salida, status='replace', action='write', iostat=estado)
    if (estado /= 0) then
        print '(a)', 'No puedo crear ' // trim(archivo_salida) // ' (existe la carpeta?)'
        stop 1
    end if
    write(unidad, '(a)') '#           t                       x                       y'
    do k = 0, n_hechos
        if (mod(k, paso_escritura) == 0 .or. k == n_hechos) write(unidad, '(3es24.16)') k * h, u(:, k)
    end do
    close(unidad)
    print '(a)', 'Resultados en ' // trim(archivo_salida)
end program rk
