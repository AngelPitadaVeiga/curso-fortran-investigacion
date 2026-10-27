!> Utilidades para hablar con el sistema operativo: crear carpetas,
!> comprobar si existe un programa y llamar a gnuplot.
!>
!> execute_command_line (Fortran 2008) ejecuta una orden en el intérprete
!> del sistema: cmd.exe en Windows (también desde MSYS2) y sh en Linux/macOS.
!> Como la sintaxis de ambos difiere, se detecta el sistema con la variable
!> de entorno OS, que en Windows vale "Windows_NT".
module sistema
    implicit none
    private

    public :: es_windows, crear_carpeta_de, existe_comando, llamar_gnuplot

contains

    !> .true. si el programa se ejecuta en Windows.
    function es_windows() result(si)
        logical :: si
        character(len=32) :: valor
        integer :: estado
        call get_environment_variable("OS", valor, status=estado)
        si = (estado == 0 .and. valor == "Windows_NT")
    end function es_windows

    !> Crea (si no existe) la carpeta que contiene el archivo `ruta`.
    !> Ejemplo: crear_carpeta_de("resultados/euler.dat") crea "resultados".
    subroutine crear_carpeta_de(ruta)
        character(len=*), intent(in) :: ruta
        character(len=:), allocatable :: carpeta
        integer :: i, estado, estado_cmd

        i = index(ruta, "/", back=.true.)
        if (i == 0) i = index(ruta, "\", back=.true.)
        if (i <= 1) return              ! el archivo está en la carpeta actual
        carpeta = ruta(1:i-1)

        if (es_windows()) then
            carpeta = barras_windows(carpeta)
            call execute_command_line('if not exist "' // carpeta // '" mkdir "' // carpeta // '"', &
                                      exitstat=estado, cmdstat=estado_cmd)
        else
            call execute_command_line('mkdir -p "' // carpeta // '"', exitstat=estado, cmdstat=estado_cmd)
        end if
        if (estado_cmd /= 0 .or. estado /= 0) then
            print '(a)', 'Aviso: no se pudo crear la carpeta ' // carpeta
        end if
    end subroutine crear_carpeta_de

    !> .true. si `nombre` es un programa accesible en el PATH.
    function existe_comando(nombre) result(existe)
        character(len=*), intent(in) :: nombre
        logical :: existe
        integer :: estado, estado_cmd

        if (es_windows()) then
            call execute_command_line('where ' // nombre // ' >nul 2>nul', &
                                      exitstat=estado, cmdstat=estado_cmd)
        else
            call execute_command_line('command -v ' // nombre // ' >/dev/null 2>&1', &
                                      exitstat=estado, cmdstat=estado_cmd)
        end if
        existe = (estado_cmd == 0 .and. estado == 0)
    end function existe_comando

    !> Ejecuta `gnuplot -e "<variables>" <script>`.
    !> Si gnuplot no está instalado o el script no existe, avisa y sigue:
    !> los datos ya están escritos y se pueden dibujar más tarde.
    subroutine llamar_gnuplot(script, variables)
        character(len=*), intent(in) :: script      !< archivo .gp
        character(len=*), intent(in) :: variables   !< p. ej.  archivo='a.dat'; salida='a.png'
        logical :: hay_script
        integer :: estado, estado_cmd

        inquire(file=script, exist=hay_script)
        if (.not. hay_script) then
            print '(a)', 'Aviso: no encuentro el script ' // script // &
                         ' (ejecuta el programa desde la carpeta del bloque). No se dibuja.'
            return
        end if
        if (.not. existe_comando("gnuplot")) then
            print '(a)', 'Aviso: gnuplot no esta instalado o no esta en el PATH. ' // &
                         'Los datos estan escritos; no se genera la figura.'
            return
        end if

        call execute_command_line('gnuplot -e "' // variables // '" ' // script, &
                                  exitstat=estado, cmdstat=estado_cmd)
        if (estado_cmd /= 0 .or. estado /= 0) then
            print '(a)', 'Aviso: gnuplot termino con error al ejecutar ' // script
        end if
    end subroutine llamar_gnuplot

    !> Cambia "/" por "\" (cmd.exe no acepta "/" en las rutas de mkdir).
    pure function barras_windows(ruta) result(r)
        character(len=*), intent(in) :: ruta
        character(len=len(ruta)) :: r
        integer :: i
        r = ruta
        do i = 1, len(r)
            if (r(i:i) == "/") r(i:i) = "\"
        end do
    end function barras_windows

end module sistema
