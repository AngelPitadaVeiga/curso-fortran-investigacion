!> Orden de convergencia de los dos esquemas, como en las unidades 09 y 11.
!>
!> Se integra el vórtice hasta t = 1 con mallas de 25, 50, 100 y 200 celdas por lado y
!> se mide el error de la densidad frente a la solución exacta. Al duplicar las celdas,
!> el error debe dividirse por 2 con 'primer_orden' y por 4 con 'muscl'.
!> Escribe las celdas y los errores en resultados/orden.dat.
!>
!>     ./orden_espacial
program orden_espacial
    use gas, only: conservadas
    use volumenes, only: paso_rk2, paso_maximo
    use vortice, only: lado, vortice_exacto
    implicit none

    integer, parameter :: n_mallas = 4, n_esquemas = 2
    character(len=20), parameter :: esquemas(n_esquemas) = &
        [character(len=20) :: 'primer_orden', 'muscl']
    integer, parameter :: ordenes_teoricos(n_esquemas) = [1, 2]
    double precision, parameter :: t_final = 1.0d0, cfl = 0.5d0, beta = 5.0d0

    double precision, allocatable :: q(:, :, :)
    double precision :: dx, dt, t, w(4), error(n_mallas, n_esquemas), orden(n_esquemas)
    integer :: i, j, e, m, n, unidad
    logical :: todo_bien

    do e = 1, n_esquemas
        do m = 1, n_mallas
            n = 25 * 2**(m - 1)
            dx = lado / n
            allocate(q(4, -1:n+2, -1:n+2))
            do j = -1, n + 2
                do i = -1, n + 2
                    q(:, i, j) = conservadas(vortice_exacto((i - 0.5d0) * dx, (j - 0.5d0) * dx, 0.0d0, beta))
                end do
            end do

            t = 0
            do while (t < t_final - 1.0d-12)
                dt = min(paso_maximo(q, dx, cfl), t_final - t)
                call paso_rk2(q, dx, dt, trim(esquemas(e)))
                t = t + dt
            end do

            error(m, e) = 0
            do j = 1, n
                do i = 1, n
                    w = vortice_exacto((i - 0.5d0) * dx, (j - 0.5d0) * dx, t, beta)
                    error(m, e) = error(m, e) + abs(q(1, i, j) - w(1))
                end do
            end do
            error(m, e) = error(m, e) / n**2
            deallocate(q)
        end do
    end do

    print '(a)', '  celdas    error primer_orden   orden    error muscl   orden'
    do m = 1, n_mallas
        if (m == 1) then
            print '(i8, es18.4, 8x, es18.4)', 25, error(m, :)
        else
            orden = log(error(m - 1, :) / error(m, :)) / log(2.0d0)
            print '(i8, es18.4, f8.2, es18.4, f8.2)', 25 * 2**(m - 1), &
                error(m, 1), orden(1), error(m, 2), orden(2)
        end if
    end do

    open(newunit=unidad, file='resultados/orden.dat', status='replace', action='write')
    write(unidad, '(a)') '#  celdas  error_primer_orden  error_muscl'
    do m = 1, n_mallas
        write(unidad, '(i8, 2es16.8)') 25 * 2**(m - 1), error(m, :)
    end do
    close(unidad)

    ! Se comprueba el orden entre las dos mallas más finas.
    todo_bien = .true.
    do e = 1, n_esquemas
        if (abs(orden(e) - ordenes_teoricos(e)) > 0.3d0) then
            print '(a, a, a, f5.2)', 'FALLA: ', trim(esquemas(e)), ' tiene orden ', orden(e)
            todo_bien = .false.
        end if
    end do
    if (.not. todo_bien) stop 1
    print '(a)', 'OK: orden 1 y orden 2.'
end program orden_espacial
