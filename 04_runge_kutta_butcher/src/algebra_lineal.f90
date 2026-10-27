!> Eliminación gaussiana con pivoteo parcial, escrita a mano.
!>
!> En un código de producción se usaría LAPACK (dgesv), que es más rápido
!> y robusto. Aquí se programa para ver cómo se recorren las matrices en
!> Fortran: el almacenamiento es por columnas, así que los bucles internos
!> deben recorrer columnas (primer índice), que son contiguas en memoria.
module algebra_lineal
    use, intrinsic :: iso_fortran_env, only: real64
    implicit none
    private

    public :: resolver_sistema

contains

    !> Resuelve a*x = b. Las copias de a y b se modifican internamente;
    !> los argumentos originales no (intent(in)).
    !> singular = .true. si se encuentra un pivote nulo.
    pure subroutine resolver_sistema(a, b, x, singular)
        real(real64), intent(in) :: a(:, :), b(:)
        real(real64), intent(out) :: x(size(b))
        logical, intent(out) :: singular
        real(real64) :: m(size(b), size(b)), l(size(b)), fila(size(b)), aux
        integer :: n, k, j, p

        n = size(b)
        m = a
        x = b
        singular = .false.

        ! Eliminación: en el paso k se anulan los elementos bajo m(k,k).
        do k = 1, n
            ! Pivoteo parcial: el mayor elemento (en valor absoluto) de la columna k.
            p = k - 1 + maxloc(abs(m(k:n, k)), dim=1)
            if (.not. abs(m(p, k)) > 0.0_real64) then     ! pivote nulo
                singular = .true.
                return
            end if
            if (p /= k) then
                fila = m(k, :);  m(k, :) = m(p, :);  m(p, :) = fila
                aux = x(k);      x(k) = x(p);        x(p) = aux
            end if

            ! Multiplicadores (columna k, contigua en memoria).
            l(k+1:n) = m(k+1:n, k) / m(k, k)

            ! Actualización por columnas: m(k+1:n, j) es contiguo.
            do j = k + 1, n
                m(k+1:n, j) = m(k+1:n, j) - l(k+1:n) * m(k, j)
            end do
            x(k+1:n) = x(k+1:n) - l(k+1:n) * x(k)
        end do

        ! Sustitución regresiva, también por columnas.
        do j = n, 1, -1
            x(j) = x(j) / m(j, j)
            x(1:j-1) = x(1:j-1) - x(j) * m(1:j-1, j)
        end do
    end subroutine resolver_sistema

end module algebra_lineal
