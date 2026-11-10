!> Ensamblaje de las matrices de masa M y de rigidez K con elementos lineales:
!>
!>     M(i, j) = integral de phi_i * phi_j        K(i, j) = integral de phi_i' * phi_j'
!>
!> donde phi_i es la función "sombrero" del nodo i: vale 1 en x(i), 0 en los
!> demás nodos y es lineal entre ellos. Cada elemento aporta una matriz 2x2
!> que se suma en las posiciones de sus dos nodos.
module ensamblaje
    implicit none
    private
    public :: ensamblar

contains

    subroutine ensamblar(x, m_dia, m_fuera, k_dia, k_fuera)
        double precision, intent(in) :: x(:)
        double precision, allocatable, intent(out) :: m_dia(:), m_fuera(:), k_dia(:), k_fuera(:)
        double precision :: he
        integer :: n, e

        n = size(x)
        allocate(m_dia(n), k_dia(n), m_fuera(n-1), k_fuera(n-1))
        m_dia = 0
        k_dia = 0

        do e = 1, n - 1
            he = x(e+1) - x(e)                          ! longitud del elemento

            ! Masa local:    he/6 * [2 1; 1 2]
            m_dia(e) = m_dia(e) + he / 3
            m_dia(e+1) = m_dia(e+1) + he / 3
            m_fuera(e) = he / 6

            ! Rigidez local: 1/he * [1 -1; -1 1]
            k_dia(e) = k_dia(e) + 1 / he
            k_dia(e+1) = k_dia(e+1) + 1 / he
            k_fuera(e) = -1 / he
        end do
    end subroutine ensamblar

end module ensamblaje
