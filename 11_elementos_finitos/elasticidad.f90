!> Elasticidad lineal en 2D (tensión plana, espesor 1) con triángulos lineales.
!>
!> Cada nodo tiene dos incógnitas, el desplazamiento (ux, uy), y se numeran así:
!> el nodo i tiene los grados de libertad 2i-1 (ux) y 2i (uy).
!>
!> Dentro de un triángulo, el desplazamiento es lineal, así que la deformación
!> (exx, eyy, gxy) es constante y sale de los desplazamientos de sus tres nodos:
!>
!>     deformación = B * u_elemento        tensión = D * deformación
!>     K_elemento  = área * B' * D * B
module elasticidad
    implicit none
    private
    public :: ensamblar, tension_von_mises

contains

    !> Matriz que relaciona tensión y deformación (tensión plana).
    function matriz_d(e_young, nu) result(d)
        double precision, intent(in) :: e_young, nu
        double precision :: d(3, 3)
        d = 0
        d(1, 1) = 1
        d(1, 2) = nu
        d(2, 1) = nu
        d(2, 2) = 1
        d(3, 3) = (1 - nu) / 2
        d = e_young / (1 - nu**2) * d
    end function matriz_d

    !> Para un triángulo con vértices xe(:, 1:3), calcula su área y la matriz B (3x6).
    subroutine matriz_b(xe, b, area)
        double precision, intent(in) :: xe(2, 3)
        double precision, intent(out) :: b(3, 6), area
        double precision :: bi(3), ci(3)
        integer :: a

        ! Derivadas de las funciones de forma (cada una vale 1 en su vértice y 0 en
        ! los otros dos): dN_a/dx = bi(a) / (2 area),  dN_a/dy = ci(a) / (2 area).
        bi = [xe(2, 2) - xe(2, 3), xe(2, 3) - xe(2, 1), xe(2, 1) - xe(2, 2)]
        ci = [xe(1, 3) - xe(1, 2), xe(1, 1) - xe(1, 3), xe(1, 2) - xe(1, 1)]
        area = 0.5d0 * ((xe(1, 2) - xe(1, 1)) * (xe(2, 3) - xe(2, 1)) &
                      - (xe(1, 3) - xe(1, 1)) * (xe(2, 2) - xe(2, 1)))

        b = 0
        do a = 1, 3
            b(1, 2*a - 1) = bi(a)           ! exx = dux/dx
            b(2, 2*a) = ci(a)               ! eyy = duy/dy
            b(3, 2*a - 1) = ci(a)           ! gxy = dux/dy + duy/dx
            b(3, 2*a) = bi(a)
        end do
        b = b / (2 * area)
    end subroutine matriz_b

    !> Ensambla la matriz de rigidez k y la masa m de cada grado de libertad.
    !> La masa es "concentrada": cada triángulo reparte un tercio de su masa en
    !> cada nodo, así que m es un vector y no una matriz.
    subroutine ensamblar(x, tri, e_young, nu, rho, k, m)
        double precision, intent(in) :: x(:, :), e_young, nu, rho
        integer, intent(in) :: tri(:, :)
        double precision, allocatable, intent(out) :: k(:, :), m(:)
        double precision :: d(3, 3), b(3, 6), area, ke(6, 6)
        integer :: e, n, gl(6)

        n = size(x, 2)
        allocate(k(2*n, 2*n), m(2*n))
        k = 0
        m = 0
        d = matriz_d(e_young, nu)

        do e = 1, size(tri, 2)
            call matriz_b(x(:, tri(:, e)), b, area)
            ke = area * matmul(transpose(b), matmul(d, b))

            ! Los seis grados de libertad del triángulo, en la numeración global.
            gl = [2*tri(1, e) - 1, 2*tri(1, e), 2*tri(2, e) - 1, 2*tri(2, e), &
                  2*tri(3, e) - 1, 2*tri(3, e)]
            k(gl, gl) = k(gl, gl) + ke
            m(gl) = m(gl) + rho * area / 3
        end do
    end subroutine ensamblar

    !> Tensión de von Mises de cada triángulo, a partir de los desplazamientos u.
    function tension_von_mises(x, tri, e_young, nu, u) result(vm)
        double precision, intent(in) :: x(:, :), e_young, nu, u(:)
        integer, intent(in) :: tri(:, :)
        double precision :: vm(size(tri, 2))
        double precision :: d(3, 3), b(3, 6), area, s(3)
        integer :: e, gl(6)

        d = matriz_d(e_young, nu)
        do e = 1, size(tri, 2)
            call matriz_b(x(:, tri(:, e)), b, area)
            gl = [2*tri(1, e) - 1, 2*tri(1, e), 2*tri(2, e) - 1, 2*tri(2, e), &
                  2*tri(3, e) - 1, 2*tri(3, e)]
            s = matmul(d, matmul(b, u(gl)))         ! (sxx, syy, txy)
            vm(e) = sqrt(s(1)**2 - s(1) * s(2) + s(2)**2 + 3 * s(3)**2)
        end do
    end function tension_von_mises

end module elasticidad
