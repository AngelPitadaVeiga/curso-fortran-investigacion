!> Raíz cuadrada por el método de Herón (Newton para x**2 - a = 0):
!>
!>     x_{k+1} = (x_k + a / x_k) / 2
!>
!> Muestra bucles do, exit, if y print con formato. La convergencia es
!> cuadrática: el número de cifras correctas se duplica en cada iteración.
!>
!>     gfortran heron.f90 -o heron
!>     ./heron
program heron
    implicit none

    ! parameter: constantes con nombre (no se pueden modificar).
    double precision, parameter :: a = 2.0d0           ! calculamos sqrt(a)
    double precision, parameter :: tol = 1.0d-15
    integer, parameter :: max_iter = 50

    double precision :: x, x_nuevo
    integer :: k

    x = a                                              ! estimación inicial
    print '(a)', ' iter                     x         error'
    do k = 1, max_iter
        x_nuevo = 0.5d0 * (x + a / x)
        ! i5: entero en 5 columnas; f22.16: real con 16 decimales; es10.2: notación científica
        print '(i5, f22.16, es10.2)', k, x_nuevo, abs(x_nuevo - sqrt(a))
        if (abs(x_nuevo - x) <= tol * x_nuevo) exit    ! sale del bucle cuando x ya casi no cambia
        x = x_nuevo
    end do

    ! Si el bucle termina sin exit, k vale max_iter + 1.
    if (k > max_iter) then
        print '(a)', 'No ha convergido.'
    else
        print '(a, i0, a)', 'Convergencia en ', k, ' iteraciones.'
    end if
end program heron
