!> Un error clásico: salirse de una matriz.
!>
!> La matriz m tiene 5 filas, pero el bucle llega hasta la fila 6. Como Fortran
!> guarda las matrices por columnas, m(6, 1) cae sobre m(1, 2): el programa lee un
!> dato de otra columna y sigue tan tranquilo, con un resultado falso.
!>
!>     gfortran -O2 error_indice.f90 -o error_indice
!>     ./error_indice
!>     gfortran -g -fcheck=all error_indice.f90 -o error_indice
!>     ./error_indice
program error_indice
    implicit none
    double precision :: m(5, 2), suma
    integer :: i, n

    m(:, 1) = [1.0d0, 2.0d0, 3.0d0, 4.0d0, 5.0d0]
    m(:, 2) = 100.0d0

    ! n se decide al ejecutar para que el compilador no pueda ver el error.
    n = 6 - command_argument_count()

    suma = 0.0d0
    do i = 1, n
        suma = suma + m(i, 1)       ! m(6, 1) no existe
    end do

    print '(a, f0.1)', 'Suma de la primera columna = ', suma
    print '(a)', 'Valor correcto: 1+2+3+4+5 = 15.0'
end program error_indice
