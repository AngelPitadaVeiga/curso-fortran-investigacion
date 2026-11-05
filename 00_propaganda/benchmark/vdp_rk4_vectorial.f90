!> Benchmark, estilo "vectorial": el mismo RK4 que vdp_rk4.f90, pero escrito
!> como se escribiría en Matlab con una función anónima: el estado es un
!> vector u(2), el campo es una función que devuelve un vector y las etapas
!> son vectores. Es el estilo cómodo... y en Fortran no cuesta rendimiento:
!> los arrays de tamaño fijo viven en la pila y el compilador lo optimiza
!> igual que la versión escalar.
!>
!> Uso:  vdp_rk4_vectorial_f [N] [pasos] [repeticiones]
program vdp_rk4_vectorial
    use iso_fortran_env, only: real64, int64
    implicit none
    integer :: n, pasos, repeticiones, r
    real(real64), parameter :: mu = 1.0_real64, h = 0.01_real64
    real(real64) :: suma, mejor
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
        mejor = min(mejor, real(t1 - t0, real64) / ticks)
    end do

    write(texto_tiempo, '(es12.5)') mejor
    write(texto_suma, '(es23.15)') suma
    print '(a, i0, a, i0, a)', 'RESULTADO Fortran-vectorial N=', n, ' pasos=', pasos, &
          ' tiempo_s=' // trim(adjustl(texto_tiempo)) // ' suma=' // trim(adjustl(texto_suma))

contains

    pure function campo(u) result(du)
        real(real64), intent(in) :: u(2)
        real(real64) :: du(2)
        du = [u(2), -mu * (u(1) * u(1) - 1.0_real64) * u(2) - u(1)]
    end function campo

    function integrar(n, pasos) result(suma)
        integer, intent(in) :: n, pasos
        real(real64) :: suma
        real(real64), dimension(2) :: u, k1, k2, k3, k4
        integer :: i, k

        suma = 0.0_real64
        do i = 1, n
            u = [-3.0_real64 + 6.0_real64 * mod(37 * i, 1000) / 1000.0_real64, &
                 -3.0_real64 + 6.0_real64 * mod(53 * i, 1000) / 1000.0_real64]
            do k = 1, pasos
                k1 = campo(u)
                k2 = campo(u + 0.5_real64 * h * k1)
                k3 = campo(u + 0.5_real64 * h * k2)
                k4 = campo(u + h * k3)
                u = u + h / 6.0_real64 * (k1 + 2.0_real64 * k2 + 2.0_real64 * k3 + k4)
            end do
            suma = suma + u(1) + u(2)
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

end program vdp_rk4_vectorial
