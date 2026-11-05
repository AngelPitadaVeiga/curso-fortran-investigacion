!> Benchmark: Van der Pol con RK4 de paso fijo desde N condiciones iniciales.
!> El mismo algoritmo, con bucles explícitos, que vdp_rk4.cpp, .jl, .py y vdp_rk4_handle.m.
!>
!> Uso:  vdp_rk4_f [N] [pasos] [repeticiones]
!> Imprime el mejor tiempo de las repeticiones y una suma de control del
!> estado final (para comprobar que todas las versiones calculan lo mismo y
!> para que el compilador no pueda eliminar el cálculo).
program vdp_rk4
    use iso_fortran_env, only: real64, int64
    implicit none
    integer :: n, pasos, repeticiones, r
    real(real64), parameter :: mu = 1.0_real64, h = 0.01_real64
    real(real64) :: suma, tiempo, mejor
    integer(int64) :: t0, t1, ticks
    character(len=32) :: texto_tiempo, texto_suma

    n = argumento(1, 100000)
    pasos = argumento(2, 1000)
    repeticiones = argumento(3, 3)

    mejor = huge(1.0_real64)
    do r = 1, repeticiones
        call system_clock(t0, ticks)
        suma = integrar(n, pasos)
        call system_clock(t1)
        tiempo = real(t1 - t0, real64) / ticks
        mejor = min(mejor, tiempo)
    end do

    ! adjustl quita los espacios iniciales del formato es: "tiempo_s=8.6E-01".
    write(texto_tiempo, '(es12.5)') mejor
    write(texto_suma, '(es23.15)') suma
    print '(a, i0, a, i0, a)', 'RESULTADO Fortran N=', n, ' pasos=', pasos, &
          ' tiempo_s=' // trim(adjustl(texto_tiempo)) // ' suma=' // trim(adjustl(texto_suma))

contains

    !> Integra las N trayectorias y devuelve sum(x + y) del estado final.
    function integrar(n, pasos) result(suma)
        integer, intent(in) :: n, pasos
        real(real64) :: suma
        real(real64) :: x, y, x2, y2, x3, y3, x4, y4, k1x, k1y, k2x, k2y, k3x, k3y, k4x, k4y
        integer :: i, k

        suma = 0.0_real64
        do i = 1, n
            ! Condiciones iniciales deterministas e independientes de N.
            x = -3.0_real64 + 6.0_real64 * mod(37 * i, 1000) / 1000.0_real64
            y = -3.0_real64 + 6.0_real64 * mod(53 * i, 1000) / 1000.0_real64
            do k = 1, pasos
                k1x = y
                k1y = -mu * (x * x - 1.0_real64) * y - x
                x2 = x + 0.5_real64 * h * k1x;  y2 = y + 0.5_real64 * h * k1y
                k2x = y2
                k2y = -mu * (x2 * x2 - 1.0_real64) * y2 - x2
                x3 = x + 0.5_real64 * h * k2x;  y3 = y + 0.5_real64 * h * k2y
                k3x = y3
                k3y = -mu * (x3 * x3 - 1.0_real64) * y3 - x3
                x4 = x + h * k3x;  y4 = y + h * k3y
                k4x = y4
                k4y = -mu * (x4 * x4 - 1.0_real64) * y4 - x4
                x = x + h / 6.0_real64 * (k1x + 2.0_real64 * k2x + 2.0_real64 * k3x + k4x)
                y = y + h / 6.0_real64 * (k1y + 2.0_real64 * k2y + 2.0_real64 * k3y + k4y)
            end do
            suma = suma + x + y
        end do
    end function integrar

    integer function argumento(i, por_defecto)
        integer, intent(in) :: i, por_defecto
        character(len=32) :: texto
        argumento = por_defecto
        if (command_argument_count() >= i) then
            call get_command_argument(i, texto)
            read(texto, *) argumento
        end if
    end function argumento

end program vdp_rk4
