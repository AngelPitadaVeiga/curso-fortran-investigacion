!> Euler explícito para Van der Pol, igual que en la unidad 05, pero leyendo
!> los parámetros de un archivo de entrada: cambiarlos ya no obliga a recompilar.
!>
!>     gfortran euler.f90 -o euler
!>     ./euler                   (lee entrada.nml)
!>     ./euler otro.nml          (lee el archivo que se indique)
program euler
    implicit none

    ! Estos son los valores por defecto. El archivo de entrada puede cambiarlos.
    double precision :: mu = 1.0d0
    double precision :: h = 0.01d0
    double precision :: t_final = 30.0d0
    double precision :: x0 = 0.5d0, y0 = 0.0d0
    character(len=100) :: archivo_salida = 'euler.dat'

    ! Un namelist es una lista de variables que se pueden leer de golpe.
    namelist /parametros/ mu, h, t_final, x0, y0, archivo_salida

    character(len=100) :: archivo_entrada
    double precision :: u(2)
    integer :: k, n_pasos, unidad, estado

    ! 1) Leer los parámetros. Si hay un argumento en la línea de órdenes,
    !    es el nombre del archivo; si no, usamos entrada.nml.
    archivo_entrada = 'entrada.nml'
    if (command_argument_count() >= 1) call get_command_argument(1, archivo_entrada)

    open(newunit=unidad, file=archivo_entrada, status='old', action='read', iostat=estado)
    if (estado /= 0) then
        print '(a)', 'No puedo abrir ' // trim(archivo_entrada)
        stop 1
    end if
    read(unidad, nml=parametros)
    close(unidad)
    print '(a)', 'Parametros leidos de ' // trim(archivo_entrada)
    print '(a, es9.2, a, es9.2, a, f8.2)', '   mu =', mu, '   h =', h, '   t_final =', t_final

    ! 2) Integrar y escribir, como siempre.
    n_pasos = nint(t_final / h)
    u = [x0, y0]
    open(newunit=unidad, file=archivo_salida, status='replace', action='write')
    write(unidad, '(a)') '#           t                       x                       y'
    write(unidad, '(3es24.16)') 0.0d0, u
    do k = 1, n_pasos
        u = u + h * campo(u)
        write(unidad, '(3es24.16)') k * h, u
        if (maxval(abs(u)) > 1.0d6) then
            print '(a, f7.2)', 'La solucion ha explotado en t =', k * h
            exit
        end if
    end do
    close(unidad)

    print '(a)', 'Resultados en ' // trim(archivo_salida)
    print '(a, 2es14.6)', 'Estado final (x, y) = ', u

contains

    function campo(u) result(du)
        double precision, intent(in) :: u(2)
        double precision :: du(2)
        du(1) = u(2)
        du(2) = -mu * (u(1)**2 - 1) * u(2) - u(1)
    end function campo

end program euler
