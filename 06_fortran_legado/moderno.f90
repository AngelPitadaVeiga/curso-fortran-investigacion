!> Traducción a Fortran moderno de legado.f, paso a paso.
!> Mismo algoritmo y mismas operaciones, en el mismo orden: la salida es
!> idéntica (make comparar). Los comentarios "F77:" señalan qué sustituye
!> cada construcción.

!> F77: COMMON /PARAM/ AMU  ->  el parámetro se pasa como argumento.
!> Las subrutinas sueltas pasan a un módulo: el compilador conoce sus
!> interfaces y comprueba cada llamada (número y tipo de argumentos).
module vdp_moderno
    use, intrinsic :: iso_fortran_env, only: real64
    implicit none                              ! F77: IMPLICIT DOUBLE PRECISION (A-H,O-Z)
    private
    public :: campo_vdp, rk4

    !> F77: EXTERNAL F  ->  interfaz abstracta: se sabe qué recibe la función.
    abstract interface
        pure function campo(t, y, mu) result(dy)
            import :: real64
            real(real64), intent(in) :: t, y(:), mu
            real(real64) :: dy(size(y))
        end function campo
    end interface

contains

    !> F77: SUBROUTINE FCN(N, T, Y, DY)  ->  función que devuelve un array.
    !> Ya no hace falta pasar N: el array conoce su tamaño.
    pure function campo_vdp(t, y, mu) result(dy)
        real(real64), intent(in) :: t, y(:), mu
        real(real64) :: dy(size(y))
        dy(1) = y(2)
        dy(2) = -mu * (y(1)**2 - 1.0_real64) * y(2) - y(1)
    end function campo_vdp

    !> F77: SUBROUTINE RK4(F, N, T, Y, H, NPASOS) con GOTO y vectores de
    !> trabajo de tamaño fijo YK(10)...  ->  bucle do, arrays automáticos
    !> del tamaño de y y operaciones con arrays completos.
    subroutine rk4(f, t, y, h, n_pasos, mu)
        procedure(campo) :: f
        real(real64), intent(inout) :: t, y(:)
        real(real64), intent(in) :: h, mu
        integer, intent(in) :: n_pasos
        real(real64), dimension(size(y)) :: k1, k2, k3, k4   ! sin límite N <= 10
        integer :: k

        do k = 1, n_pasos                      ! F77: 20 IF (K .GE. NPASOS) GOTO 99 ... GOTO 20
            k1 = f(t, y, mu)
            k2 = f(t + 0.5_real64 * h, y + 0.5_real64 * h * k1, mu)
            k3 = f(t + 0.5_real64 * h, y + 0.5_real64 * h * k2, mu)
            k4 = f(t + h, y + h * k3, mu)
            y = y + h / 6.0_real64 * (k1 + 2.0_real64 * k2 + 2.0_real64 * k3 + k4)
            t = t + h                          ! como en el original (ver README)
        end do
    end subroutine rk4

end module vdp_moderno


program vdp_moderno_principal
    use, intrinsic :: iso_fortran_env, only: real64
    use vdp_moderno, only: campo_vdp, rk4
    implicit none
    real(real64), parameter :: mu = 1.0_real64, h = 0.01_real64
    integer, parameter :: n_pasos = 3000, n_salida = 300
    real(real64) :: t, y(2)
    integer :: bloque

    t = 0.0_real64
    y = [0.5_real64, 0.0_real64]

    ! F77: FORMAT con etiqueta  ->  formato en una cadena junto al write.
    write(*, '(1x, a, 14x, a, 23x, a)') '       T', 'X', 'Y'
    write(*, '(1x, f8.3, 2e24.16)') t, y
    do bloque = 1, n_pasos / n_salida          ! F77: DO 10 IB = 1, NBLOQ ... 10 CONTINUE
        call rk4(campo_vdp, t, y, h, n_salida, mu)
        write(*, '(1x, f8.3, 2e24.16)') t, y
    end do
end program vdp_moderno_principal
