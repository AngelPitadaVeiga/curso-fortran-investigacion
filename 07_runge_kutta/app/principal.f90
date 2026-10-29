!> Bloque 07: Van der Pol con cualquier Runge-Kutta explícito.
!>
!> Uso:   rk                              (lee entrada.nml)
!>        rk otro.nml                     (otro archivo de entrada)
!>        rk entrada.nml tableros/heun.txt     (además, otro tablero)
program rk
    use, intrinsic :: iso_fortran_env, only: real64
    use tablero_butcher, only: tablero, leer_tablero
    use runge_kutta, only: integrar_rk
    implicit none

    character(len=256) :: tablero_archivo = "tableros/rk4.txt"
    real(real64) :: mu = 1.0_real64
    real(real64) :: h = 0.01_real64
    real(real64) :: t_final = 30.0_real64
    real(real64) :: x0 = 0.5_real64
    real(real64) :: y0 = 0.0_real64
    character(len=256) :: archivo_salida = "resultados/rk.dat"
    namelist /parametros/ tablero_archivo, mu, h, t_final, x0, y0, archivo_salida

    character(len=256) :: archivo_entrada
    type(tablero) :: tab
    real(real64), allocatable :: u(:, :)
    integer :: n_pasos, k, unidad, estado

    ! 1) Entrada. Un segundo argumento, si lo hay, sustituye al tablero del namelist.
    archivo_entrada = "entrada.nml"
    if (command_argument_count() >= 1) call get_command_argument(1, archivo_entrada)
    open(newunit=unidad, file=archivo_entrada, status="old", action="read", iostat=estado)
    if (estado /= 0) then
        print '(a)', 'Error: no puedo abrir ' // trim(archivo_entrada)
        stop 1
    end if
    read(unidad, nml=parametros)
    close(unidad)
    if (command_argument_count() >= 2) call get_command_argument(2, tablero_archivo)

    call leer_tablero(trim(tablero_archivo), tab)
    print '(a, i0, a, i0, a)', 'Metodo: ' // tab%nombre // ' (s = ', tab%s, ', orden ', tab%orden, ')'

    ! 2) Integrar.
    n_pasos = nint(t_final / h)
    call integrar_rk(tab, [x0, y0], mu, h, n_pasos, u)
    print '(a, i0, a, 2es14.6)', 'Pasos: ', n_pasos, '   estado final (x, y) = ', u(:, n_pasos)

    ! 3) Escribir.
    open(newunit=unidad, file=archivo_salida, status="replace", action="write", iostat=estado)
    if (estado /= 0) then
        print '(a)', 'Error: no puedo crear ' // trim(archivo_salida) // ' (existe la carpeta?)'
        stop 1
    end if
    write(unidad, '(a, es12.5, a, es12.5)') '# Van der Pol - ' // tab%nombre // '.  mu = ', mu, '  h = ', h
    write(unidad, '(a)') '#           t                       x                       y'
    do k = 0, n_pasos
        write(unidad, '(3es24.16)') k * h, u(:, k)
    end do
    close(unidad)
    print '(a)', 'Resultados escritos en ' // trim(archivo_salida)
end program rk
