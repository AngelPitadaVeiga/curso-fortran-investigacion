!> Comprobación de la instalación: si esto compila y ejecuta, estás listo.
!>
!>     gfortran comprobacion.f90 -o comprobacion
!>     ./comprobacion
program comprobacion
    use iso_fortran_env, only: compiler_version
    implicit none
    double precision :: a(3, 3), x(3)
    integer :: estado, estado_cmd

    a = reshape([2, 0, 0, 0, 3, 0, 0, 0, 4], [3, 3])
    x = matmul(a, [1.0d0, 1.0d0, 1.0d0])

    print '(a)', 'Compilador: ' // compiler_version()
    print '(a, 3f6.1)', 'matmul funciona: ', x            ! 2 3 4

    ! ¿Hay Python con numpy y matplotlib? Con él haremos las figuras.
    call execute_command_line('python -c "import numpy, matplotlib"', exitstat=estado, cmdstat=estado_cmd)
    if (estado_cmd == 0 .and. estado == 0) then
        print '(a)', 'Python, numpy y matplotlib encontrados.'
    else
        print '(a)', 'Aviso: Python no encuentra numpy o matplotlib (pip install numpy matplotlib).'
    end if

    ! ¿Y make?
    call execute_command_line('make --version', exitstat=estado, cmdstat=estado_cmd)
    if (estado_cmd == 0 .and. estado == 0) then
        print '(a)', 'make encontrado.'
    else
        print '(a)', 'Aviso: no encuentro make.'
    end if

    print '(a)', 'Todo listo. Bienvenido a Fortran!'
end program comprobacion
