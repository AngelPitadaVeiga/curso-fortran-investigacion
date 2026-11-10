!> El programa principal: lee los parámetros, llama al integrador y escribe el resultado.
!>
!>     ./euler                   (lee entrada.nml)
!>     ./euler otro.nml
program euler
    use integrador, only: integrar_euler
    implicit none

    double precision :: mu = 1.0d0
    double precision :: h = 0.01d0
    double precision :: t_final = 30.0d0
    double precision :: x0 = 0.5d0, y0 = 0.0d0
    character(len=100) :: archivo_salida = 'euler.dat'
    namelist /parametros/ mu, h, t_final, x0, y0, archivo_salida

    character(len=100) :: archivo_entrada
    double precision, allocatable :: u(:, :)
    integer :: k, n_pasos, unidad, estado

    ! Leer los parámetros.
    archivo_entrada = 'entrada.nml'
    if (command_argument_count() >= 1) call get_command_argument(1, archivo_entrada)
    open(newunit=unidad, file=archivo_entrada, status='old', action='read', iostat=estado)
    if (estado /= 0) then
        print '(a)', 'No puedo abrir ' // trim(archivo_entrada)
        stop 1
    end if
    read(unidad, nml=parametros)
    close(unidad)

    ! Integrar.
    n_pasos = nint(t_final / h)
    call integrar_euler([x0, y0], mu, h, n_pasos, u)
    print '(a, i0, a, 2es14.6)', 'Pasos: ', n_pasos, '   estado final (x, y) = ', u(:, n_pasos)

    ! Escribir  t  x  y  en columnas.
    open(newunit=unidad, file=archivo_salida, status='replace', action='write')
    write(unidad, '(a)') '#           t                       x                       y'
    do k = 0, n_pasos
        write(unidad, '(3es24.16)') k * h, u(:, k)
    end do
    close(unidad)
    print '(a)', 'Resultados en ' // trim(archivo_salida)
end program euler
