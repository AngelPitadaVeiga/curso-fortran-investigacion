!> Tipos básicos de Fortran y las dos trampas más frecuentes.
!>
!>     gfortran tipos.f90 -o tipos
!>     ./tipos
program tipos
    use, intrinsic :: iso_fortran_env, only: real32, real64
    implicit none

    ! Declaraciones: siempre al principio, antes de cualquier instrucción.
    integer :: n
    real(real32) :: a              ! real de 32 bits (simple precisión)
    real(real64) :: b              ! real de 64 bits (doble precisión), el habitual
    logical :: es_par
    character(len=20) :: nombre

    n = 7
    a = 0.1
    b = 0.1_real64                 ! el sufijo _real64 hace la constante doble
    es_par = (mod(n, 2) == 0)
    nombre = "Van der Pol"

    print *, "n      =", n
    print *, "a      =", a
    print *, "b      =", b
    print *, "es_par =", es_par
    print *, "nombre = ", trim(nombre)      ! trim quita los espacios del final

    ! Trampa 1: entero entre entero es una división entera.
    print *
    print *, "7/2          =", 7 / 2
    print *, "7/2.0_real64 =", 7 / 2.0_real64

    ! Trampa 2: una constante sin sufijo es de simple precisión,
    ! aunque se guarde en una variable doble.
    b = 0.1
    print *
    print *, "b = 0.1         ->", b
    b = 0.1_real64
    print *, "b = 0.1_real64  ->", b

    ! Cuántas cifras tiene cada tipo: el menor eps con 1 + eps /= 1.
    print *
    print *, "epsilon(real32) =", epsilon(a)
    print *, "epsilon(real64) =", epsilon(b)
end program tipos
