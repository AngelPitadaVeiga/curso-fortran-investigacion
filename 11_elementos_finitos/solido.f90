!> Una viga en voladizo: un rectángulo [0, lx] x [0, ly] empotrado en su lado izquierdo
!> y cargado en el derecho, resuelto con elementos finitos en 2D (elasticidad lineal).
!>
!>   1) Estática: se calcula la deformación que produce la carga.
!>   2) Vibración (si t_final > 0): se suelta la viga desde esa deformación y se
!>      sigue su movimiento con el método explícito o con el implícito.
!>
!>     ./solido estatico.nml
!>     ./solido vibracion.nml
program solido
    use malla, only: crear_malla
    use elasticidad, only: ensamblar, tension_von_mises
    use algebra, only: factorizar, resolver
    use dinamica, only: autovalor_maximo, paso_explicito, paso_implicito, energia
    implicit none

    ! Parámetros, con sus valores por defecto. Las unidades son arbitrarias (E = rho = 1).
    double precision :: lx = 10.0d0, ly = 1.0d0         ! tamaño de la viga
    integer :: nx = 40, ny = 4                          ! casillas en cada dirección (ny, par)
    double precision :: e_young = 1.0d0, nu = 0.3d0, rho = 1.0d0
    double precision :: carga = 1.0d-4                  ! fuerza total en el extremo, hacia abajo
    double precision :: dt = 1.0d0, t_final = 0.0d0
    character(len=20) :: metodo = 'implicito'           ! 'implicito' o 'explicito'
    integer :: paso_escritura = 1
    namelist /parametros/ lx, ly, nx, ny, e_young, nu, rho, carga, dt, t_final, metodo, &
                          paso_escritura

    double precision, allocatable :: x(:, :), k(:, :), m(:), f(:), u(:), kl(:, :), l(:, :)
    double precision, allocatable :: ul(:), vl(:), al(:), ml(:), vm(:)
    integer, allocatable :: tri(:, :), libres(:)
    logical, allocatable :: fijo(:)
    character(len=100) :: archivo_entrada
    double precision :: peso, flecha, flecha_vigas, omega1, lambda, t
    integer :: i, j, n, nl, punta, p_punta, n_pasos, paso, unidad, estado

    ! 1) Parámetros.
    archivo_entrada = 'estatico.nml'
    if (command_argument_count() >= 1) call get_command_argument(1, archivo_entrada)
    open(newunit=unidad, file=archivo_entrada, status='old', action='read', iostat=estado)
    if (estado /= 0) then
        print '(a)', 'No puedo abrir ' // trim(archivo_entrada)
        stop 1
    end if
    read(unidad, nml=parametros)
    close(unidad)

    ! 2) Malla y matrices.
    call crear_malla(lx, ly, nx, ny, x, tri)
    call ensamblar(x, tri, e_young, nu, rho, k, m)
    n = size(x, 2)
    print '(a, i0, a, i0, a, i0, a)', 'Malla: ', n, ' nodos, ', size(tri, 2), ' triangulos, ', 2 * n, &
                                      ' incognitas'

    ! 3) Condiciones de contorno: empotrado en x = 0, es decir, ux = uy = 0 en esos nodos.
    !    Las incógnitas son los grados de libertad "libres"; se escogen con un vector de índices.
    allocate(fijo(2 * n))
    fijo = .false.
    do i = 1, n
        if (x(1, i) < 1.0d-9 * lx) fijo(2*i - 1:2*i) = .true.
    end do
    libres = pack([(i, i = 1, 2 * n)], .not. fijo)
    nl = size(libres)

    ! 4) La carga: una fuerza total "carga" hacia abajo, repartida por el lado derecho.
    !    Los nodos de las esquinas cargan con medio tramo y los demás, con uno entero.
    allocate(f(2 * n))
    f = 0
    do j = 0, ny
        peso = ly / ny
        if (j == 0 .or. j == ny) peso = peso / 2
        f(2 * (j * (nx + 1) + nx + 1)) = -carga / ly * peso
    end do

    ! 5) Estática: K u = f en las incógnitas libres, con Cholesky.
    kl = k(libres, libres)                  ! submatriz: filas y columnas libres
    ml = m(libres)
    l = kl
    call factorizar(l)
    allocate(u(2 * n), ul(nl), vl(nl), al(nl))
    u = 0
    call resolver(l, f(libres), ul)
    u(libres) = ul

    punta = (ny / 2) * (nx + 1) + nx + 1    ! nodo del extremo, a media altura
    flecha = u(2 * punta)
    flecha_vigas = -carga * lx**3 / (3 * e_young * ly**3 / 12)     ! teoría de vigas
    omega1 = 1.8751d0**2 * sqrt(e_young * ly**2 / (12 * rho * lx**4))
    print '(a, es11.3)', 'Flecha en el extremo:                ', flecha
    print '(a, es11.3)', 'Teoria de vigas (Euler-Bernoulli):   ', flecha_vigas
    print '(a, f7.3)',   'Cociente:                            ', flecha / flecha_vigas

    ! 6) Resultados de la estática, para dibujarlos.
    vm = tension_von_mises(x, tri, e_young, nu, u)
    open(newunit=unidad, file='resultados/nodos.dat', status='replace', action='write')
    write(unidad, '(a)') '#  x  y  ux  uy'
    do i = 1, n
        write(unidad, '(4es16.8)') x(:, i), u(2*i - 1), u(2*i)
    end do
    close(unidad)
    open(newunit=unidad, file='resultados/triangulos.dat', status='replace', action='write')
    write(unidad, '(a)') '#  los tres nodos de cada triangulo (empiezan en 1)'
    write(unidad, '(3i8)') tri
    close(unidad)
    open(newunit=unidad, file='resultados/tension.dat', status='replace', action='write')
    write(unidad, '(a)') '#  tension de von Mises de cada triangulo'
    write(unidad, '(es16.8)') vm
    close(unidad)

    ! 7) Vibración.
    if (t_final <= 0) then
        print '(a)', 'Resultados en resultados/'
        stop
    end if

    p_punta = findloc(libres, 2 * punta, dim=1)         ! posición del nodo en las incógnitas
    lambda = autovalor_maximo(kl, ml)
    print '(a, es11.3)', 'Frecuencia de la viga segun la teoria:  omega1 =', omega1
    print '(a, es11.3, a, f6.1)', 'Periodo =', 2 * acos(-1.0d0) / omega1
    print '(a, es11.3)', 'Frecuencia maxima de la malla:           omega_max =', sqrt(lambda)
    print '(a, es11.3)', 'Paso maximo del metodo explicito:        2 / omega_max =', 2 / sqrt(lambda)
    print '(a, a, a, es10.3)', 'Metodo: ', trim(metodo), '   dt =', dt

    ! Se parte de la deformación estática (ul) y en reposo.
    vl = 0
    al = -matmul(kl, ul) / ml
    if (metodo == 'implicito') then
        ! Matriz del paso implícito: diag(m) + dt**2/4 * K. No cambia, se factoriza una vez.
        l = dt**2 / 4 * kl
        do i = 1, nl
            l(i, i) = l(i, i) + ml(i)
        end do
        call factorizar(l)
    else if (metodo /= 'explicito') then
        print '(a)', 'Metodo desconocido: ' // trim(metodo)
        stop 1
    end if

    n_pasos = nint(t_final / dt)
    open(newunit=unidad, file='resultados/punta.dat', status='replace', action='write')
    write(unidad, '(a, es14.6)') '# omega1 =', omega1
    write(unidad, '(a)') '#  t  flecha_del_extremo  energia'
    write(unidad, '(3es16.8)') 0.0d0, ul(p_punta), energia(ul, vl, kl, ml)
    do paso = 1, n_pasos
        if (metodo == 'implicito') then
            call paso_implicito(ul, vl, al, dt, kl, l)
        else
            call paso_explicito(ul, vl, al, dt, kl, ml)
        end if
        t = paso * dt
        if (.not. (maxval(abs(ul)) < 1.0d6)) then
            print '(a, es10.3)', 'La solucion ha explotado en t =', t
            exit
        end if
        if (mod(paso, paso_escritura) == 0) write(unidad, '(3es16.8)') t, ul(p_punta), energia(ul, vl, kl, ml)
    end do
    close(unidad)
    print '(a)', 'Resultados en resultados/'
end program solido
