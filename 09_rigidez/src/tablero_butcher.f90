!> Tableros de Butcher: un tipo derivado y su lectura desde un archivo.
!>
!>     c | A
!>     --+----
!>       | b^T
!>
!> El archivo tiene dos namelist: &etapas con s (para saber el tamaño) y
!> &coeficientes con nombre, orden, A, b y c. Véase tableros/rk4.txt.
module tablero_butcher
    use, intrinsic :: iso_fortran_env, only: real64
    implicit none
    private
    public :: tablero, leer_tablero, es_explicito

    !> Un tipo derivado agrupa datos, como un struct de C++ o de Julia.
    !> Las componentes allocatable se liberan solas.
    type :: tablero
        character(len=:), allocatable :: nombre
        integer :: s = 0                         !< número de etapas
        integer :: orden = 0                     !< orden teórico
        real(real64), allocatable :: a(:, :)     !< matriz A (s x s)
        real(real64), allocatable :: b(:)        !< pesos
        real(real64), allocatable :: c(:)        !< nodos
    end type tablero

contains

    !> Lee un tablero del archivo. Lo que no aparezca en el archivo vale 0.
    subroutine leer_tablero(archivo, tab)
        character(len=*), intent(in) :: archivo
        type(tablero), intent(out) :: tab
        integer :: s, orden, unidad, estado
        character(len=100) :: nombre
        real(real64), allocatable :: a(:, :), b(:), c(:)
        namelist /etapas/ s
        namelist /coeficientes/ nombre, orden, a, b, c

        open(newunit=unidad, file=archivo, status="old", action="read", iostat=estado)
        if (estado /= 0) then
            print '(a)', 'Error: no puedo abrir el tablero ' // archivo
            stop 1
        end if

        ! Primero s, para poder reservar A, b y c; después, los coeficientes.
        read(unidad, nml=etapas)
        allocate(a(s, s), b(s), c(s))
        a = 0
        b = 0
        c = 0
        nombre = ''
        orden = 0
        read(unidad, nml=coeficientes)
        close(unidad)

        ! Constructor del tipo: los argumentos en el orden de las componentes.
        tab = tablero(trim(nombre), s, orden, a, b, c)
    end subroutine leer_tablero

    !> .true. si A es estrictamente triangular inferior (a_ij = 0 si j >= i):
    !> cada etapa solo usa las anteriores y se calcula directamente.
    pure function es_explicito(tab) result(si)
        type(tablero), intent(in) :: tab
        logical :: si
        integer :: i
        si = .true.
        do i = 1, tab%s
            if (any(abs(tab%a(i, i:tab%s)) > 0)) si = .false.
        end do
    end function es_explicito

end module tablero_butcher
