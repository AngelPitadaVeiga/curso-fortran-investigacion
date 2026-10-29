!> Bloque 06: Euler para Van der Pol, organizado en módulos y con archivo de entrada.
!>
!> Uso:   euler              (lee entrada.nml)
!>        euler otro.nml     (lee el archivo indicado)
program euler
    use, intrinsic :: iso_fortran_env, only: real64
    use metodo_euler, only: integrar_euler
    implicit none

    ! Parámetros que se leen del namelist (con valores por defecto).
    real(real64) :: mu = 1.0_real64
    real(real64) :: h = 0.01_real64
    real(real64) :: t_final = 30.0_real64
    real(real64) :: x0 = 0.5_real64
    real(real64) :: y0 = 0.0_real64
    character(len=256) :: archivo_salida = "resultados/euler.dat"
    namelist /parametros/ mu, h, t_final, x0, y0, archivo_salida

    character(len=256) :: archivo_entrada
    real(real64), allocatable :: u(:, :)
    integer :: n_pasos, k, unidad, estado

    ! 1) Leer los parámetros: del archivo que se pase como argumento, o de entrada.nml.
    archivo_entrada = "entrada.nml"
    if (command_argument_count() >= 1) call get_command_argument(1, archivo_entrada)

    open(newunit=unidad, file=archivo_entrada, status="old", action="read", iostat=estado)
    if (estado /= 0) then
        print '(a)', 'Error: no puedo abrir ' // trim(archivo_entrada)
        stop 1
    end if
    read(unidad, nml=parametros)
    close(unidad)
    print '(a)', 'Parametros leidos de ' // trim(archivo_entrada)

    ! 2) Integrar.
    n_pasos = nint(t_final / h)
    call integrar_euler([x0, y0], mu, h, n_pasos, u)
    print '(a, i0, a, 2es14.6)', 'Pasos: ', n_pasos, '   estado final (x, y) = ', u(:, n_pasos)

    ! 3) Escribir  t  x  y  en columnas.
    open(newunit=unidad, file=archivo_salida, status="replace", action="write", iostat=estado)
    if (estado /= 0) then
        print '(a)', 'Error: no puedo crear ' // trim(archivo_salida) // ' (existe la carpeta?)'
        stop 1
    end if
    write(unidad, '(a, es12.5, a, es12.5)') '# Van der Pol - Euler explicito.  mu = ', mu, '  h = ', h
    write(unidad, '(a)') '#           t                       x                       y'
    do k = 0, n_pasos
        write(unidad, '(3es24.16)') k * h, u(:, k)
    end do
    close(unidad)
    print '(a)', 'Resultados escritos en ' // trim(archivo_salida)
end program euler
