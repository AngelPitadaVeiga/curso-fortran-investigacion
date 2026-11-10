!> Orden de convergencia observado de cada método.
!>
!> Se integra hasta t = 1 con pasos h = 0.1, 0.05, 0.025, 0.0125 y se mide el
!> error frente a una referencia (RK4 con h = 1e-4). Si un método es de orden p,
!> al dividir h entre 2 el error se divide por 2**p, así que
!>
!>     orden = log2( error(h) / error(h/2) )
!>
!> Escribe resultados/orden.dat (h y un error por método) y termina con
!> código 1 si algún orden se desvía más de 0.3 del teórico.
!>
!>     ./orden
program orden
    use runge_kutta, only: integrar
    implicit none

    integer, parameter :: n_metodos = 5, n_h = 4
    character(len=20), parameter :: metodos(n_metodos) = &
        [character(len=20) :: 'euler', 'heun', 'rk4', 'euler_implicito', 'trapecio']
    integer, parameter :: ordenes_teoricos(n_metodos) = [1, 2, 4, 1, 2]
    double precision, parameter :: mu = 1.0d0, u0(2) = [2.0d0, 0.0d0]

    double precision, allocatable :: u(:, :)
    double precision :: h(n_h), error(n_h, n_metodos), u_ref(2), orden_obs
    character(len=200) :: linea
    integer :: i, j, n_pasos, n_hechos, unidad
    logical :: todo_bien

    ! Solución de referencia: RK4 con un paso muy pequeño.
    call integrar('rk4', u0, mu, 1.0d-4, 10000, u, n_hechos)
    u_ref = u(:, 10000)

    h = [(0.1d0 / 2**(j - 1), j = 1, n_h)]
    do i = 1, n_metodos
        do j = 1, n_h
            n_pasos = nint(1.0d0 / h(j))
            call integrar(trim(metodos(i)), u0, mu, h(j), n_pasos, u, n_hechos)
            error(j, i) = maxval(abs(u(:, n_pasos) - u_ref))
        end do
    end do

    open(newunit=unidad, file='resultados/orden.dat', status='replace', action='write')
    linea = '# h'                              ! primera línea: los nombres de las columnas
    do i = 1, n_metodos
        linea = trim(linea) // ' ' // trim(metodos(i))
    end do
    write(unidad, '(a)') trim(linea)
    do j = 1, n_h
        write(unidad, '(*(es16.8))') h(j), error(j, :)
    end do
    close(unidad)

    todo_bien = .true.
    print '(a)', '            metodo   orden teorico   orden observado'
    do i = 1, n_metodos
        ! Con los dos pasos más pequeños.
        orden_obs = log(error(n_h - 1, i) / error(n_h, i)) / log(2.0d0)
        if (abs(orden_obs - ordenes_teoricos(i)) <= 0.3d0) then
            print '(a20, i10, f18.2, a)', metodos(i), ordenes_teoricos(i), orden_obs, '   OK'
        else
            print '(a20, i10, f18.2, a)', metodos(i), ordenes_teoricos(i), orden_obs, '   FALLA'
            todo_bien = .false.
        end if
    end do
    print '(a)', 'Errores en resultados/orden.dat'

    if (.not. todo_bien) stop 1
end program orden
