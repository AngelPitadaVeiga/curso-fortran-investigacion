!> Reacción-difusión en 1D con elementos finitos lineales:
!>
!>     u_t = d u_xx + r u (1 - u),   en [0, longitud],   con u_x = 0 en los extremos.
!>
!> Con r = 0 es la ecuación del calor, y con r > 0 la de Fisher-KPP, que tiene
!> frentes que avanzan. Las condiciones de contorno de flujo nulo son las naturales
!> en elementos finitos: no hay que hacer nada para imponerlas.
!>
!>     ./fem calor.nml
!>     ./fem fisher.nml
program fem
    use malla, only: crear_malla
    use ensamblaje, only: ensamblar
    use evolucion, only: paso_explicito, paso_implicito
    implicit none

    double precision, parameter :: pi = acos(-1.0d0)

    double precision :: longitud = 1.0d0
    integer :: n_elementos = 50
    double precision :: estiramiento = 1.0d0       ! 1 = malla uniforme
    double precision :: d = 0.1d0                  ! difusión
    double precision :: r = 0.0d0                  ! reacción
    double precision :: dt = 0.01d0
    double precision :: t_final = 1.0d0
    character(len=20) :: metodo = 'implicito'      ! 'implicito' o 'explicito'
    character(len=20) :: condicion = 'coseno'      ! 'coseno' o 'escalon'
    integer :: n_guardados = 10                    ! cuántos instantes se escriben
    character(len=100) :: archivo_salida = 'resultados/solucion.dat'
    namelist /parametros/ longitud, n_elementos, estiramiento, d, r, dt, t_final, &
                          metodo, condicion, n_guardados, archivo_salida

    character(len=100) :: archivo_entrada
    double precision, allocatable :: x(:), u(:), guardado(:, :), a_dia(:), a_fuera(:)
    double precision, allocatable :: m_dia(:), m_fuera(:), k_dia(:), k_fuera(:)
    double precision :: tiempos(0:100)
    integer :: n, i, k, n_pasos, cada, n_hechos, unidad, estado

    ! 1) Parámetros.
    archivo_entrada = 'calor.nml'
    if (command_argument_count() >= 1) call get_command_argument(1, archivo_entrada)
    open(newunit=unidad, file=archivo_entrada, status='old', action='read', iostat=estado)
    if (estado /= 0) then
        print '(a)', 'No puedo abrir ' // trim(archivo_entrada)
        stop 1
    end if
    read(unidad, nml=parametros)
    close(unidad)

    ! 2) Malla, matrices y condición inicial.
    call crear_malla(longitud, n_elementos, estiramiento, x)
    call ensamblar(x, m_dia, m_fuera, k_dia, k_fuera)
    n = size(x)
    allocate(u(n))
    select case (condicion)
    case ('coseno')
        u = cos(pi * x / longitud)
    case ('escalon')
        u = 0
        where (x < 0.1d0 * longitud) u = 1
    case default
        print '(a)', 'Condicion inicial desconocida: ' // trim(condicion)
        stop 1
    end select

    ! La matriz del paso implícito, A = M + dt d K, siempre es la misma.
    a_dia = m_dia + dt * d * k_dia
    a_fuera = m_fuera + dt * d * k_fuera

    ! 3) Avanzar en el tiempo, guardando n_guardados + 1 instantes.
    n_pasos = nint(t_final / dt)
    cada = max(1, n_pasos / n_guardados)
    allocate(guardado(n, 0:n_guardados))
    guardado(:, 0) = u
    tiempos(0) = 0
    n_hechos = 0

    print '(a, i0, a, a, a, es9.2, a, i0, a)', 'Elementos: ', n_elementos, '   metodo: ', trim(metodo), &
                                              '   dt =', dt, '   pasos: ', n_pasos
    do k = 1, n_pasos
        select case (metodo)
        case ('implicito')
            call paso_implicito(u, dt, r, m_dia, m_fuera, a_dia, a_fuera)
        case ('explicito')
            call paso_explicito(u, dt, d, r, m_dia, m_fuera, k_dia, k_fuera)
        case default
            print '(a)', 'Metodo desconocido: ' // trim(metodo)
            stop 1
        end select

        if (.not. (maxval(abs(u)) < 1.0d10)) then
            print '(a, es9.2)', 'La solucion ha explotado en t =', k * dt
            exit
        end if
        if (mod(k, cada) == 0 .and. n_hechos < n_guardados) then
            n_hechos = n_hechos + 1
            guardado(:, n_hechos) = u
            tiempos(n_hechos) = k * dt
        end if
    end do

    ! 4) Si conocemos la solución exacta, comparamos.
    if (r == 0 .and. condicion == 'coseno' .and. maxval(abs(u)) < 1.0d10) then
        print '(a, es10.2)', 'Error maximo en los nodos en t_final: ', &
            maxval(abs(u - exp(-d * (pi / longitud)**2 * t_final) * cos(pi * x / longitud)))
    end if

    ! 5) Escribir: la primera línea tiene los tiempos, y luego una fila por nodo
    !    con  x  u(t_0)  u(t_1) ...
    open(newunit=unidad, file=archivo_salida, status='replace', action='write', iostat=estado)
    if (estado /= 0) then
        print '(a)', 'No puedo crear ' // trim(archivo_salida) // ' (existe la carpeta?)'
        stop 1
    end if
    write(unidad, '(a, *(es12.4))') '# tiempos:', tiempos(0:n_hechos)
    do i = 1, n
        write(unidad, '(*(es16.8))') x(i), guardado(i, 0:n_hechos)
    end do
    close(unidad)
    print '(a)', 'Resultados en ' // trim(archivo_salida)
end program fem
