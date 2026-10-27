!> Tableros de Butcher: tipo derivado, lectura desde archivo y validación.
!>
!>     c | A
!>     --+----
!>       | b^T
!>
!> Formato del archivo (las líneas vacías y el texto tras '#' se ignoran):
!>
!>     nombre del método            (una línea de texto)
!>     s                            (número de etapas)
!>     orden                        (orden teórico)
!>     a11 ... a1s                  (s filas de A)
!>     ...
!>     as1 ... ass
!>     b1  ... bs
!>     c1  ... cs
module tablero_butcher
    use, intrinsic :: iso_fortran_env, only: real64
    implicit none
    private

    public :: tablero, leer_tablero

    !> Un tablero de Butcher. Las componentes allocatable se reservan al
    !> leer el archivo y se liberan solas cuando la variable deja de existir:
    !> no hay que llamar a deallocate (ni a free/delete como en C/C++).
    type :: tablero
        character(len=:), allocatable :: nombre
        integer :: s = 0                         !< número de etapas
        integer :: orden = 0                     !< orden teórico
        real(real64), allocatable :: a(:, :)     !< matriz A (s x s)
        real(real64), allocatable :: b(:)        !< pesos b
        real(real64), allocatable :: c(:)        !< nodos c
        logical :: explicito = .false.           !< A estrictamente triangular inferior
        logical :: rigidamente_preciso = .false. !< b = última fila de A
    end type tablero

    !> Tolerancia para las comprobaciones de consistencia.
    real(real64), parameter :: tol_consistencia = 1.0e-12_real64

contains

    !> Lee un tablero de `archivo`. Si hay un error de formato, detiene el
    !> programa con un mensaje claro (archivo y qué se esperaba).
    !> `stop 1` termina con código de salida 1. `error stop` haría lo mismo,
    !> pero gfortran añade una traza de la pila que aquí solo despista: el
    !> error está en el archivo de entrada, no en el código.
    subroutine leer_tablero(archivo, tab)
        character(len=*), intent(in) :: archivo
        type(tablero), intent(out) :: tab
        character(len=1024) :: linea
        integer :: unidad, estado, i, j
        character(len=256) :: mensaje

        open(newunit=unidad, file=archivo, status="old", action="read", iostat=estado, iomsg=mensaje)
        if (estado /= 0) then
            print '(a)', 'Error: no puedo abrir el tablero ' // archivo // ': ' // trim(mensaje)
            stop 1
        end if

        call siguiente_linea(unidad, linea, "el nombre del metodo")
        tab%nombre = trim(adjustl(linea))

        call siguiente_linea(unidad, linea, "el numero de etapas s")
        read(linea, *, iostat=estado) tab%s
        if (estado /= 0 .or. tab%s < 1) call error_formato("s debe ser un entero positivo")

        call siguiente_linea(unidad, linea, "el orden teorico")
        read(linea, *, iostat=estado) tab%orden
        if (estado /= 0 .or. tab%orden < 1) call error_formato("el orden debe ser un entero positivo")

        allocate(tab%a(tab%s, tab%s), tab%b(tab%s), tab%c(tab%s))

        do i = 1, tab%s
            call siguiente_linea(unidad, linea, "una fila de A")
            read(linea, *, iostat=estado) tab%a(i, :)
            if (estado /= 0) call error_formato("cada fila de A debe tener s numeros")
        end do
        call siguiente_linea(unidad, linea, "la fila b")
        read(linea, *, iostat=estado) tab%b
        if (estado /= 0) call error_formato("la fila b debe tener s numeros")
        call siguiente_linea(unidad, linea, "la fila c")
        read(linea, *, iostat=estado) tab%c
        if (estado /= 0) call error_formato("la fila c debe tener s numeros")
        close(unidad)

        ! ¿Explícito? A estrictamente triangular inferior: a(i,j) = 0 si j >= i.
        tab%explicito = .true.
        do j = 1, tab%s
            if (any(abs(tab%a(1:j, j)) > 0.0_real64)) tab%explicito = .false.
        end do

        tab%rigidamente_preciso = all(abs(tab%b - tab%a(tab%s, :)) <= tol_consistencia)

        call validar(tab)

    contains

        subroutine siguiente_linea(u, texto, que)
            integer, intent(in) :: u
            character(len=*), intent(out) :: texto
            character(len=*), intent(in) :: que
            integer :: est, k
            do
                read(u, '(a)', iostat=est) texto
                if (est /= 0) call error_formato("el archivo termina antes de " // que)
                k = index(texto, "#")
                if (k > 0) texto(k:) = " "
                if (len_trim(texto) > 0) exit
            end do
        end subroutine siguiente_linea

        subroutine error_formato(explicacion)
            character(len=*), intent(in) :: explicacion
            print '(a)', 'Error en el tablero ' // archivo // ': ' // explicacion
            stop 1
        end subroutine error_formato

    end subroutine leer_tablero

    !> Comprobaciones de consistencia (solo avisan; no detienen el programa).
    subroutine validar(tab)
        type(tablero), intent(in) :: tab
        integer :: i

        do i = 1, tab%s
            if (abs(tab%c(i) - sum(tab%a(i, :))) > tol_consistencia) then
                print '(a, i0, a, es12.4, a, es12.4)', 'Aviso: c(', i, ') = ', tab%c(i), &
                      ' no coincide con la suma de la fila de A = ', sum(tab%a(i, :))
            end if
        end do
        if (abs(sum(tab%b) - 1.0_real64) > tol_consistencia) then
            print '(a, es12.4, a)', 'Aviso: sum(b) = ', sum(tab%b), ' /= 1: el metodo no es consistente.'
        end if
    end subroutine validar

end module tablero_butcher
