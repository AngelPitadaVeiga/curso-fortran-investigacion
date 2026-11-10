!> Matrices dinámicas: el tamaño se decide al ejecutar, no al compilar.
!>
!>     gfortran matrices.f90 -o matrices
!>     ./matrices
program matrices
    implicit none
    double precision, allocatable :: a(:, :), b(:, :), u(:, :), v(:)
    integer :: n, i, n_pasos, estado

    ! 1) allocatable + allocate: la dimensión la da el usuario.
    print '(a)', 'Dimension de la matriz:'
    read *, n
    allocate(a(n, n), stat=estado)         ! con stat, si falla no se detiene: lo comprobamos
    if (estado /= 0) then
        print '(a)', 'No hay memoria suficiente.'
        stop 1
    end if
    a = 0
    do i = 1, n
        a(i, i) = i                        ! diagonal 1, 2, ..., n
    end do
    print '(a, 2(1x, i0))', 'shape(a) =', shape(a)
    print '(a, f8.1)', 'traza de a =', sum([(a(i, i), i = 1, n)])

    ! 2) Al asignar un array entero, b se reserva sola con el tamaño justo.
    print '(a, l2)', 'allocated(b) antes de asignar:', allocated(b)
    b = matmul(a, a)
    print '(a, l2)', 'allocated(b) despues de asignar:', allocated(b)
    print '(a, f8.1)', 'b(n, n) =', b(n, n)

    ! 3) Para cambiar de tamaño: deallocate y otra vez allocate.
    deallocate(a)
    allocate(a(2 * n, 3))
    print '(a, 2(1x, i0))', 'shape(a), nuevo =', shape(a)

    ! 4) El uso más habitual en numérica: una trayectoria, con un estado por columna.
    n_pasos = 1000
    allocate(u(2, 0:n_pasos))              ! u(:, k) es el estado en el paso k
    u(:, 0) = [1.0d0, 0.0d0]
    print '(a, 2f6.1)', 'estado inicial u(:, 0) =', u(:, 0)
    print '(a, i0)', 'columnas de u = ', size(u, 2)

    ! 5) Un vector que crece. Es cómodo, pero copia el vector entero cada vez:
    !    en un bucle largo es lento. Si sabes el tamaño, resérvalo desde el principio.
    v = [double precision ::]              ! vector vacío
    do i = 1, 4
        v = [v, dble(i**2)]
    end do
    print '(a, 4f6.1)', 'v =', v

    ! No hace falta deallocate al final: todo se libera solo.
end program matrices
