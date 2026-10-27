!> Comprobación de la instalación: si esto compila y ejecuta, estás listo.
!>
!>     gfortran comprobacion.f90 -o comprobacion
!>     ./comprobacion
program comprobacion
    use, intrinsic :: iso_fortran_env, only: real64, compiler_version
    implicit none
    real(real64) :: a(3, 3), x(3)
    integer :: estado, estado_cmd

    a = reshape([2, 0, 0, 0, 3, 0, 0, 0, 4], [3, 3])
    x = matmul(a, [1.0_real64, 1.0_real64, 1.0_real64])

    print '(a)', 'Compilador: ' // compiler_version()
    print '(a, 3f6.1)', 'matmul funciona: ', x            ! 2 3 4

    ! ¿Hay gnuplot en el PATH? (no es imprescindible, pero se usa en el curso)
    call execute_command_line('gnuplot --version', exitstat=estado, cmdstat=estado_cmd)
    if (estado_cmd == 0 .and. estado == 0) then
        print '(a)', 'gnuplot encontrado.'
    else
        print '(a)', 'Aviso: no encuentro gnuplot (las figuras no se generaran).'
    end if

    print '(a)', 'Todo listo. Bienvenido a Fortran!'
end program comprobacion
