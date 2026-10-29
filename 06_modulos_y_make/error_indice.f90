!> Demostración de -fcheck=all: un acceso fuera de rango.
!>
!> La matriz m tiene 5 filas, pero el bucle recorre la primera columna
!> hasta la fila 6. Como Fortran guarda las matrices por columnas, en
!> memoria m(6, 1) "cae" sobre m(1, 2): en modo release el programa lee
!> un dato de otra columna y sigue tan tranquilo, con un resultado falso.
!> En modo debug, -fcheck=all detiene el programa y dice el archivo, la
!> línea, el índice y el límite.
!>
!>     make demo-error
program error_indice
    use, intrinsic :: iso_fortran_env, only: real64
    implicit none
    real(real64) :: m(5, 2), suma
    integer :: i, n

    m(:, 1) = [1.0_real64, 2.0_real64, 3.0_real64, 4.0_real64, 5.0_real64]
    m(:, 2) = 100.0_real64

    ! n se decide en tiempo de ejecución para que el compilador no pueda
    ! detectar el error al compilar. Sin argumentos, n = 6: ¡error!
    n = 6 - command_argument_count()

    suma = 0.0_real64
    do i = 1, n
        suma = suma + m(i, 1)       ! m(6, 1) no existe
    end do

    print '(a, f0.1)', 'Suma de la primera columna = ', suma
    print '(a)', 'Valor correcto: 1+2+3+4+5 = 15.0'
end program error_indice
