!> Unidad 10: Van der Pol rígido con un Runge-Kutta explícito o implícito.
!>
!> Uso:   rigidez                                   (lee entrada.nml)
!>        rigidez entrada.nml tableros/rk4.txt resultados/rk4.dat
!>               (el 2.º y el 3.º argumento sustituyen al tablero y a la salida)
program rigidez
    use iso_fortran_env, only: real64, int64
    use tablero_butcher, only: tablero, leer_tablero
    use runge_kutta, only: integrar_rk
    implicit none

    character(len=256) :: tablero_archivo = "tableros/radau_iia3.txt"
    real(real64) :: mu = 1000.0_real64
    real(real64) :: h = 0.002_real64
    real(real64) :: t_final = 3000.0_real64
    real(real64) :: x0 = 2.0_real64
    real(real64) :: y0 = 0.0_real64
    character(len=256) :: archivo_salida = "resultados/radau.dat"
    integer :: paso_escritura = 100
    namelist /parametros/ tablero_archivo, mu, h, t_final, x0, y0, archivo_salida, paso_escritura

    character(len=256) :: archivo_entrada
    type(tablero) :: tab
    real(real64), allocatable :: u(:, :)
    integer :: n_pasos, n_hechos, k, unidad, estado
    integer(int64) :: inicio, fin, ticks_por_segundo

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
    if (command_argument_count() >= 3) call get_command_argument(3, archivo_salida)

    call leer_tablero(trim(tablero_archivo), tab)
    n_pasos = nint(t_final / h)
    print '(a, f7.1, a, es9.2, a, i0)', 'Metodo: ' // tab%nombre // '   mu =', mu, &
                                        '   h = ', h, '   pasos = ', n_pasos

    ! system_clock: cronómetro de pared (ticks y ticks por segundo).
    call system_clock(inicio, ticks_por_segundo)
    call integrar_rk(tab, [x0, y0], mu, h, n_pasos, u, n_hechos)
    call system_clock(fin)
    print '(a, i0, a, f6.2, a)', 'Pasos completados: ', n_hechos, '   tiempo:', &
                                 real(fin - inicio, real64) / ticks_por_segundo, ' s'

    ! Se escribe un paso de cada paso_escritura. Si la integración se ha
    ! detenido antes de tiempo, se escriben todos (para ver cómo explota).
    open(newunit=unidad, file=archivo_salida, status="replace", action="write", iostat=estado)
    if (estado /= 0) then
        print '(a)', 'Error: no puedo crear ' // trim(archivo_salida) // ' (existe la carpeta?)'
        stop 1
    end if
    write(unidad, '(a, es12.5, a, es12.5)') '# Van der Pol - ' // tab%nombre // '.  mu = ', mu, '  h = ', h
    write(unidad, '(a)') '#           t                       x                       y'
    do k = 0, n_hechos
        if (mod(k, paso_escritura) == 0 .or. n_hechos < n_pasos) then
            write(unidad, '(3es24.16)') k * h, u(:, k)
        end if
    end do
    close(unidad)
    print '(a)', 'Resultados escritos en ' // trim(archivo_salida)
end program rigidez
