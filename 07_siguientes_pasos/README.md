# Bloque 07 · Siguientes pasos

Un mapa para seguir aprendiendo por vuestra cuenta: una explicación breve
y enlaces por tema.

## fpm: el gestor de paquetes de Fortran

Compila sin Makefile (resuelve solo el orden de los módulos), gestiona
dependencias (otros repositorios de git o carpetas locales, como en los
bloques 04 y 05), ejecuta tests y crea proyectos nuevos:

```bash
fpm new mi_proyecto     # crea src/, app/, test/ y fpm.toml
fpm build
fpm run
fpm test
```

- Documentación: <https://fpm.fortran-lang.org>
- Registro de paquetes: <https://fortran-lang.org/packages/>
- **stdlib**, la biblioteca estándar "no oficial" de la comunidad (ordenación,
  estadística, cadenas, álgebra lineal...), se usa como dependencia de fpm:
  <https://stdlib.fortran-lang.org>

## Interoperabilidad: `iso_c_binding`, Julia, C++ y Python

Con `bind(c)` (Fortran 2003) una rutina de Fortran se puede llamar desde
cualquier lenguaje que sepa llamar a C:

```fortran
module norma_mod
    use, intrinsic :: iso_c_binding, only: c_double, c_int
    implicit none
contains
    function norma(n, x) result(r) bind(c, name="norma")
        integer(c_int), value, intent(in) :: n
        real(c_double), intent(in) :: x(n)
        real(c_double) :: r
        r = norm2(x)
    end function norma
end module norma_mod
```

Biblioteca compartida: `gfortran -shared -fPIC norma.f90 -o libnorma.so`
(en Windows, `-o libnorma.dll`).

**Desde C++**:

```cpp
extern "C" double norma(int n, const double* x);
// g++ principal.cpp norma.o -lgfortran
```

**Desde Julia** con `ccall`, sin envoltorios ni recompilar nada:

```julia
x = [1.0, 2.0, 2.0]
r = ccall((:norma, "./libnorma.so"), Cdouble, (Cint, Ptr{Cdouble}), length(x), x)
```

**Desde Python** con `f2py` (incluido en NumPy), que genera un módulo de
Python a partir de una subrutina normal (sin `bind(c)`):

```fortran
subroutine norma_py(n, x, r)
    integer, intent(in) :: n
    double precision, intent(in) :: x(n)
    double precision, intent(out) :: r
    r = norm2(x)
end subroutine norma_py
```

```bash
python -m numpy.f2py -c norma_py.f90 -m norma_f
python -c "import norma_f; print(norma_f.norma_py([1.0, 2.0, 2.0]))"    # 3.0
```

f2py deduce `n` del tamaño de `x` y devuelve los argumentos `intent(out)`.
La biblioteca con `bind(c)` también se puede cargar desde Python con
`ctypes`, igual que desde Julia.

- Interoperabilidad con C en gfortran: <https://gcc.gnu.org/onlinedocs/gfortran/Interoperability-with-C.html>
- Julia, *Calling C and Fortran code*: <https://docs.julialang.org/en/v1/manual/calling-c-and-fortran-code/>
- f2py: <https://numpy.org/doc/stable/f2py/>
- Tutorial de fortran-lang sobre interoperabilidad: <https://fortran-lang.org/learn/>

## LAPACK

No escribáis vuestra eliminación gaussiana (salvo para aprender, como en el
bloque 04). LAPACK resuelve sistemas lineales (`dgesv`), mínimos cuadrados
(`dgels`), autovalores (`dsyev`, `dgeev`), SVD (`dgesvd`)... Las rutinas se
llaman directamente desde Fortran y se enlaza con `-llapack -lblas` (o con
OpenBLAS, que incluye LAPACK: `-lopenblas`). En MSYS2: `pacman -S mingw-w64-ucrt-x86_64-openblas`.

```fortran
call dgesv(n, 1, a, n, ipiv, b, n, info)   ! resuelve a*x = b; x queda en b
```

- LAPACK: <https://www.netlib.org/lapack/> (guía de usuario: <https://www.netlib.org/lapack/lug/>)
- Buscador de rutinas: <https://www.netlib.org/lapack/explore-html/>
- Interfaz moderna con fpm: `stdlib_linalg` en stdlib.

## Paralelismo: `do concurrent`, OpenMP y MPI

| Herramienta | Memoria | Cómo se usa | Cuándo |
|---|---|---|---|
| `do concurrent` | compartida | parte del lenguaje (Fortran 2008): "estas iteraciones son independientes" | bucles independientes; algunos compiladores lo paralelizan o lo llevan a GPU |
| OpenMP | compartida | directivas `!$omp parallel do`; compilar con `-fopenmp` | un nodo, varios núcleos: lo primero que hay que probar |
| MPI | distribuida | biblioteca (`use mpi_f08`); varios procesos que intercambian mensajes | varios nodos de un clúster |
| Coarrays | distribuida | parte del lenguaje (Fortran 2008) | alternativa a MPI integrada en el lenguaje |

Ejemplo inmediato con el benchmark del bloque 00: las N trayectorias son
independientes.

```fortran
!$omp parallel do reduction(+:suma) private(x, y, ...)
do i = 1, n
    ...
end do
```

- OpenMP: <https://www.openmp.org/specifications/>
- MPI: <https://www.mpi-forum.org>; en Windows, MS-MPI
  (`pacman -S mingw-w64-ucrt-x86_64-msmpi`); en Linux, Open MPI o MPICH.
- Coarrays con gfortran: OpenCoarrays, <http://www.opencoarrays.org>

## Comunidad, estándar y libros

- **fortran-lang.org**: tutoriales, lista de compiladores, paquetes y noticias:
  <https://fortran-lang.org>
- Foro **Fortran Discourse** (muy activo y amable con principiantes):
  <https://fortran-lang.discourse.group>
- **El estándar**: comité ISO WG5, <https://wg5-fortran.org> (Fortran 2023
  es la versión vigente); el comité técnico J3, <https://j3-fortran.org>.
  El borrador final de cada estándar es descargable gratis desde esas páginas.
- Documentación de **gfortran**: <https://gcc.gnu.org/onlinedocs/gfortran/>
- **Intel ifx** (gratuito): <https://www.intel.com/content/www/us/en/developer/tools/oneapi/fortran-compiler.html>
- **LFortran**, compilador moderno e interactivo (en desarrollo): <https://lfortran.org>

Libros recomendados:

- M. Metcalf, J. Reid, M. Cohen y R. Bader, *Modern Fortran Explained:
  Incorporating Fortran 2023*, Oxford University Press, 2023. La referencia
  del lenguaje, escrita por miembros del comité.
- M. Curcic, *Modern Fortran: Building Efficient Parallel Applications*,
  Manning, 2020. Práctico, con un proyecto completo y paralelismo con coarrays.
- R. J. Hanson y T. Hopkins, *Numerical Computing with Modern Fortran*,
  SIAM, 2013. Orientado a cálculo numérico.
- I. Chivers y J. Sleightholme, *Introduction to Programming with Fortran*,
  Springer (4.ª ed., 2018). Introductorio y muy completo.
- E. Hairer, S. P. Nørsett y G. Wanner, *Solving Ordinary Differential
  Equations I*, y E. Hairer y G. Wanner, *Solving Ordinary Differential
  Equations II*, Springer. No son de Fortran, pero sus códigos (DOPRI5,
  RADAU5...) sí lo son y se pueden descargar de <http://www.unige.ch/~hairer/software.html>.
