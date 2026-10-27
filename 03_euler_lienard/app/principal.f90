!> Bloque 03: ecuación de Liénard (Van der Pol) con Euler explícito.
!>
!> Uso:   euler                  (lee entrada.nml)
!>        euler otro.nml         (lee el archivo indicado)
!>
!> Escribe las columnas  t  x  y  en el archivo de salida y llama a gnuplot
!> para dibujar x(t) y la órbita en el plano (x, y).
program euler
    use, intrinsic :: iso_fortran_env, only: real64
    use solver_euler, only: integrar_euler
    use sistema, only: crear_carpeta_de, llamar_gnuplot
    implicit none

    ! Parámetros del namelist (con valores por defecto).
    real(real64) :: mu = 1.0_real64
    real(real64) :: h = 0.01_real64
    real(real64) :: t_final = 30.0_real64
    real(real64) :: x0 = 0.5_real64
    real(real64) :: y0 = 0.0_real64
    character(len=256) :: archivo_salida = "resultados/euler.dat"
    namelist /parametros/ mu, h, t_final, x0, y0, archivo_salida

    character(len=256) :: archivo_entrada
    real(real64), allocatable :: t(:), u(:, :)
    integer :: n_pasos

    call leer_entrada()

    n_pasos = nint(t_final / h)
    print '(a, es10.3, a, es10.3, a, i0)', 'mu = ', mu, '   h = ', h, '   pasos = ', n_pasos

    call integrar_euler([x0, y0], [mu], h, n_pasos, t, u)

    call escribir_resultados()
    print '(a, 2es14.6)', 'Estado final (x, y) = ', u(:, n_pasos)

    call llamar_gnuplot("graficar.gp", "archivo='" // trim(archivo_salida) // "'")

contains

    !> Lee el namelist del archivo pasado como argumento (o entrada.nml).
    subroutine leer_entrada()
        integer :: unidad, estado
        character(len=256) :: mensaje

        if (command_argument_count() >= 1) then
            call get_command_argument(1, archivo_entrada)
        else
            archivo_entrada = "entrada.nml"
        end if

        open(newunit=unidad, file=archivo_entrada, status="old", action="read", &
             iostat=estado, iomsg=mensaje)
        if (estado /= 0) then
            print '(a)', 'Error: no puedo abrir ' // trim(archivo_entrada) // ': ' // trim(mensaje)
            stop 1
        end if
        read(unidad, nml=parametros, iostat=estado, iomsg=mensaje)
        if (estado /= 0) then
            print '(a)', 'Error leyendo el namelist &parametros: ' // trim(mensaje)
            stop 1
        end if
        close(unidad)
        print '(a)', 'Parametros leidos de ' // trim(archivo_entrada)
    end subroutine leer_entrada

    !> Escribe t, x, y en columnas, con una cabecera comentada con '#'.
    subroutine escribir_resultados()
        integer :: unidad, k

        call crear_carpeta_de(trim(archivo_salida))
        open(newunit=unidad, file=archivo_salida, status="replace", action="write")
        write(unidad, '(a)') '# Lienard (Van der Pol) - Euler explicito'
        write(unidad, '(a, es12.5, a, es12.5, a, 2es12.5)') &
            '# mu = ', mu, '  h = ', h, '  (x0, y0) = ', x0, y0
        write(unidad, '(a)') '#           t                       x                       y'
        do k = 0, n_pasos
            write(unidad, '(3es24.16)') t(k), u(1, k), u(2, k)
        end do
        close(unidad)
        print '(a)', 'Resultados escritos en ' // trim(archivo_salida)
    end subroutine escribir_resultados

end program euler
