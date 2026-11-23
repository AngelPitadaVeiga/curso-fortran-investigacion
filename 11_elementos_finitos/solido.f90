!> Una pieza en voladizo, empotrada por su lado izquierdo y cargada hacia abajo en el
!> derecho, resuelta con elementos finitos en 2D (elasticidad lineal). La forma de la
!> pieza la da el archivo de malla (generar_malla.py).
!>
!>   1) Estática: se calcula la deformación que produce la carga.
!>   2) Vibración (si t_final > 0): se suelta la pieza desde esa deformación y se sigue
!>      su movimiento con el método explícito o con el implícito.
!>
!>     ./solido estatico.nml
!>     ./solido vibracion.nml
program solido
    use malla, only: leer_malla
    use elasticidad, only: ensamblar, tension_von_mises
    use algebra, only: factorizar, resolver
    use dinamica, only: autovalor_maximo, paso_explicito, paso_implicito, energia
    implicit none

    ! Parámetros, con sus valores por defecto. Las unidades son arbitrarias (E = rho = 1).
    character(len=100) :: archivo_malla = 'mensula.malla'
    double precision :: e_young = 1.0d0, nu = 0.3d0, rho = 1.0d0
    double precision :: carga = 1.0d-4                  ! fuerza total en el lado cargado, hacia abajo
    double precision :: dt = 1.0d0, t_final = 0.0d0
    character(len=20) :: metodo = 'implicito'           ! 'implicito' o 'explicito'
    integer :: paso_escritura = 1
    namelist /parametros/ archivo_malla, e_young, nu, rho, carga, dt, t_final, metodo, &
                          paso_escritura

    double precision, allocatable :: x(:, :), k(:, :), m(:), f(:), u(:), kl(:, :), l(:, :)
    double precision, allocatable :: ul(:), vl(:), al(:), ml(:), vm(:), peso(:), gl(:)
    integer, allocatable :: tri(:, :), libres(:)
    logical, allocatable :: fijo_nodo(:), fijo(:)
    character(len=100) :: archivo_entrada
    double precision :: flecha, lambda, t
    integer :: i, n, nl, n_pasos, paso, unidad, estado

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
    call leer_malla(archivo_malla, x, tri, fijo_nodo, peso)
    call ensamblar(x, tri, e_young, nu, rho, k, m)
    n = size(x, 2)
    print '(a, a, a, i0, a, i0, a, i0, a)', 'Malla ', trim(archivo_malla), ': ', n, ' nodos, ', &
                                            size(tri, 2), ' triangulos, ', 2 * n, ' incognitas'

    ! 3) Condiciones de contorno: en los nodos empotrados, ux = uy = 0. Las incógnitas son
    !    los grados de libertad "libres", que se escogen con un vector de índices.
    allocate(fijo(2 * n))
    fijo(1::2) = fijo_nodo                  ! ux del nodo i: posición 2i-1
    fijo(2::2) = fijo_nodo                  ! uy del nodo i: posición 2i
    libres = pack([(i, i = 1, 2 * n)], .not. fijo)
    nl = size(libres)

    ! 4) La carga: cada nodo soporta la fracción peso de la fuerza total, hacia abajo.
    allocate(f(2 * n))
    f = 0
    f(2::2) = -carga * peso

    ! 5) Estática: K u = f en las incógnitas libres, con Cholesky.
    kl = k(libres, libres)                  ! submatriz: filas y columnas libres
    ml = m(libres)
    l = kl
    call factorizar(l)
    allocate(u(2 * n), ul(nl), vl(nl), al(nl))
    u = 0
    call resolver(l, f(libres), ul)
    u(libres) = ul

    ! La flecha es el desplazamiento vertical medio del lado cargado, con los mismos pesos
    ! que la carga. gl hace esa media directamente sobre las incógnitas libres.
    gl = -f(libres) / carga
    flecha = dot_product(gl, ul)
    vm = tension_von_mises(x, tri, e_young, nu, u)
    print '(a, es11.3)', 'Flecha del lado cargado:        ', flecha
    print '(a, es11.3)', 'Tension de von Mises maxima:    ', maxval(vm)

    ! 6) Resultados de la estática, para dibujarlos.
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

    lambda = autovalor_maximo(kl, ml)
    print '(a, es11.3)', 'Frecuencia maxima de la malla:      omega_max =', sqrt(lambda)
    print '(a, es11.3)', 'Paso maximo del metodo explicito:   2 / omega_max =', 2 / sqrt(lambda)
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
    open(newunit=unidad, file='resultados/flecha.dat', status='replace', action='write')
    write(unidad, '(a)') '#  t  flecha  energia'
    write(unidad, '(3es16.8)') 0.0d0, flecha, energia(ul, vl, kl, ml)
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
        if (mod(paso, paso_escritura) == 0) &
            write(unidad, '(3es16.8)') t, dot_product(gl, ul), energia(ul, vl, kl, ml)
    end do
    close(unidad)
    print '(a)', 'Resultados en resultados/'
end program solido
