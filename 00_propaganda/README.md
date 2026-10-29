# Bloque 00 · Propaganda (con datos)

**Mensaje central.** Fortran no es "más rápido que C++ o Julia": bien
escritos, los tres generan código máquina de la misma calidad. Lo que
Fortran ofrece es que **es fácil escribir código rápido y difícil escribirlo
lento**, sin latencia de compilación JIT, con un estándar estable desde hace
décadas y con el ecosistema numérico de base (BLAS/LAPACK) escrito en Fortran.
Frente a Python puro la diferencia es enorme; frente a Matlab, depende de
cómo se escriba (lo medimos).

Todo lo que aparece aquí se puede reproducir con los scripts de esta carpeta.

## 1. Benchmark: Van der Pol + RK4 desde N condiciones iniciales

El mismo algoritmo (RK4 de paso fijo, `mu = 1`, `h = 0.01`, 1000 pasos),
los mismos parámetros y **bucles explícitos** en todas las versiones:

| Archivo | Versión |
|---|---|
| `benchmark/vdp_rk4.f90` | Fortran, escalares |
| `benchmark/vdp_rk4_vectorial.f90` | Fortran, estado `u(2)` y una función que devuelve un vector |
| `benchmark/vdp_rk4.cpp` | C++17 (`g++ -O3 -march=native`) |
| `benchmark/vdp_rk4.jl` | Julia; mide la 1.ª llamada (con JIT) y las siguientes, sin BenchmarkTools |
| `benchmark/vdp_rk4.py` | Python puro |
| `benchmark/vdp_rk4_numpy.py` | NumPy, vectorizado sobre las condiciones iniciales |
| `benchmark/vdp_rk4.m` | Matlab, escalares (opcional) |
| `benchmark/vdp_rk4_handle.m` | Matlab, estado vector y función anónima, como con `ode45` (opcional) |

Cada programa imprime su mejor tiempo y una **suma de control**
(`Σ (x + y)` del estado final). Sirve para comprobar que todas las versiones
calculan lo mismo y para que ningún compilador pueda eliminar el cálculo.
Las condiciones iniciales son deterministas y se repiten cada 1000
trayectorias, así que `suma/N` es comparable aunque cada versión use un N distinto.

### Ejecutar

Desde la terminal de **MSYS2 UCRT64** (o Git Bash, o Linux):

```bash
./ejecutar_benchmark.sh
```

Compila y ejecuta lo que esté instalado, **salta con un aviso** lo que no
esté, comprueba las sumas de control y escribe `resultados/tiempos.dat` y
`resultados/benchmark.png`. Opciones por variables de entorno:
`SIN_MATLAB=1`, `N_RAPIDO=...`, `N_LENTO=...` (ver la cabecera del script).

Los tiempos se dan en **nanosegundos por paso de RK4 y trayectoria**, y
relativos a Fortran. Python puro usa 100 veces menos trayectorias para no
tardar minutos; al normalizar por paso, la comparación es justa.

### Resultados

**Rellena esta tabla con tu equipo.** El script escribe en la cabecera de
`resultados/tiempos.dat` la CPU, el sistema y las versiones de los
compiladores; cópialas aquí. Las cifras de ejemplo son las **medidas al
preparar el curso** (`figuras/tiempos_i7-14700.dat`), no estimaciones:

| Versión | ns / paso | × Fortran | Tu equipo: ns / paso | × Fortran |
|---|---:|---:|---:|---:|
| Fortran | 7.8 | 1.0 | | |
| Fortran, estilo vectorial | 7.8 | 1.0 | | |
| C++ | 7.6 | 0.97 | | |
| Julia (llamadas siguientes) | sin medir¹ | | | |
| Julia (1.ª llamada, con JIT) | sin medir¹ | | | |
| NumPy (vectorizado) | sin medir¹ | | | |
| Matlab, escalares | 13.6 | 1.7 | | |
| Matlab, función anónima | 359 | 46 | | |
| Python puro | 653 | 83 | | |

Equipo de ejemplo: Intel Core i7-14700, Windows 11, GCC 14.2.0 (gfortran y
g++), Python 3.14.3, Matlab R2025b. Todas las sumas de control coinciden
con la de Fortran con una diferencia relativa ≤ 4·10⁻¹⁴.
¹ Julia y NumPy no estaban instalados en ese equipo.

Hardware y versiones de tu equipo: CPU ______, sistema ______,
gfortran ______, g++ ______, Julia ______, Python ______, NumPy ______, Matlab ______.

![Benchmark (equipo de ejemplo)](figuras/benchmark_i7-14700.png)

### Cómo leerlo (honestamente)

- **Fortran ≈ C++.** Mismo compilador (GCC), mismo código máquina. Es lo
  esperable: no hay magia, y quien diga que Fortran es "10 veces más rápido
  que C++" está comparando programas distintos.
- **Julia**, bien escrito (funciones con tipos estables, sin variables
  globales), suele estar en el mismo orden que Fortran y C++ en bucles como
  este; el script lo mide en tu equipo. Lo que se paga es la **primera
  llamada**, que incluye la compilación JIT: por eso se mide por separado.
- **Python puro** es del orden de 100 veces más lento: cada operación
  pasa por el intérprete. **NumPy** acelera mucho cuando se puede
  vectorizar sobre una dimensión grande (aquí, las condiciones iniciales),
  pero no ayuda en el bucle temporal, que es secuencial.
- **Matlab** tiene un JIT eficaz para bucles **escalares** (1,7× aquí).
  Pero escrito en su estilo habitual (estado vector y campo como función
  anónima, lo que se le pasa a `ode45`) es ~46 veces más lento que Fortran.
- **El dato importante**: en Fortran el estilo cómodo (estado `u(2)`,
  función `campo(u)` que devuelve un vector, operaciones con arrays) va
  **igual de rápido** que el escalar y da **la misma suma de control bit a
  bit**. Los arrays pequeños de tamaño fijo viven en la pila, sin
  reservas de memoria, y el compilador los optimiza. Eso es lo que significa
  "difícil escribirlo lento".

## 2. Aliasing: por qué Fortran puede optimizar por defecto

Hay *aliasing* cuando dos nombres se refieren a la misma memoria. En C/C++
dos punteros `double*` pueden solaparse, así que el compilador debe ser
prudente: si escribir `vx[i]` pudiera modificar `fx[i+1]`, no puede
procesar varios `i` a la vez con instrucciones vectoriales (SIMD).

En Fortran, el estándar **prohíbe** pasar a un procedimiento argumentos
solapados si alguno se modifica. El compilador puede suponer que no hay
solapamiento sin comprobarlo: lo que en C++ hay que prometer a mano con
`__restrict__` (extensión no estándar de C++; `restrict` sí es estándar en C99).

Ejemplo: avanzar N partículas con Euler simpléctico (`v += dt F/m; x += dt v`),
siete arrays (`aliasing/aliasing.f90` y `aliasing/aliasing.cpp`):

```fortran
subroutine avanzar(x, y, vx, vy, fx, fy, m, dt)
    real(real64), intent(inout) :: x(:), y(:), vx(:), vy(:)
    real(real64), intent(in) :: fx(:), fy(:), m(:), dt
    do i = 1, size(x)
        vx(i) = vx(i) + dt * fx(i) / m(i)
        ...
```

```cpp
void avanzar(double* x, double* y, double* vx, double* vy,
             const double* fx, const double* fy, const double* m, double dt, int n)
```

```bash
./ejecutar_aliasing.sh
```

Resultado en el equipo de ejemplo (1000 partículas, 250 000 pasos):

| Versión | Tiempo | ¿Vectoriza? (`-fopt-info-vec`) |
|---|---:|---|
| C++ sin `__restrict__` | 0.43 s | **no** |
| C++ con `__restrict__` | 0.21 s | sí |
| Fortran, `x(:)` | 0.21 s | sí |
| Fortran, `x(n)` | 0.21 s | sí |

Matices, para ser justos:

- Con pocos punteros, GCC genera en C++ **dos versiones del bucle** y
  comprueba el solapamiento al ejecutar ("*loop versioned for vectorization
  because of possible aliasing*"); entonces la diferencia desaparece. Con 7
  punteros hay demasiadas parejas que comprobar y renuncia.
- Con arrays de forma asumida `x(:)`, gfortran también añade una
  comprobación en tiempo de ejecución (el informe usa la misma frase), pero
  vectoriza; con forma explícita `x(n)` no necesita ninguna.
- La garantía de Fortran es una **obligación del programador**: llamar a
  `avanzar(x, x, ...)` es un programa incorrecto, aunque el compilador no
  siempre lo detecte.

## 3. Expresividad

Las mismas operaciones en Fortran (`expresividad/expresividad.f90`) y en
C++17 estándar sin bibliotecas (`expresividad/expresividad.cpp`). Ambos
programas imprimen exactamente lo mismo (`./ejecutar_aliasing.sh` lo comprueba).

<table>
<tr><th>Fortran</th><th>C++ (estándar, sin Eigen)</th></tr>
<tr><td>

```fortran
c = a + 2.0_real64 * b
```

</td><td>

```cpp
for (int i = 0; i < n; ++i) c[i] = a[i] + 2.0 * b[i];
```

</td></tr>
<tr><td>

```fortran
norma = norm2(a)
```

</td><td>

```cpp
double s = 0.0;
for (int i = 0; i < n; ++i) s += a[i] * a[i];
double norma = std::sqrt(s);
```

</td></tr>
<tr><td>

```fortran
where (a > 0.0_real64)
    b = sqrt(a)
elsewhere
    b = 0.0_real64
end where
```

</td><td>

```cpp
for (int i = 0; i < n; ++i)
    b[i] = a[i] > 0.0 ? std::sqrt(a[i]) : 0.0;
```

</td></tr>
<tr><td>

```fortran
lap(2:n-1) = u(1:n-2) - 2*u(2:n-1) + u(3:n)
```

</td><td>

```cpp
for (int i = 1; i < n - 1; ++i)
    lap[i] = u[i-1] - 2.0 * u[i] + u[i+1];
```

</td></tr>
<tr><td>

```fortran
y = matmul(mat, x)
sc = sum(mat, dim=1)
```

</td><td>

```cpp
// mat guardada por columnas: mat[i + j*n]
for (int j = 0; j < n; ++j)
    for (int i = 0; i < n; ++i) {
        y[i] += mat[i + j*n] * x[j];
        sc[j] += mat[i + j*n];
    }
```

</td></tr>
<tr><td>

```fortran
print *, maxval(c), maxloc(c, dim=1)
```

</td><td>

```cpp
auto it = std::max_element(c.begin(), c.end());
std::printf("%f %d\n", *it, int(it - c.begin()) + 1);
```

</td></tr>
</table>

En C++ existen bibliotecas (Eigen, Blaze, `std::valarray`, `mdspan` en
C++23) que dan una sintaxis parecida; en Fortran los arrays
multidimensionales, sus cortes y estas operaciones son **parte del
lenguaje** desde Fortran 90, y el compilador conoce su significado.
Julia y Matlab tienen una sintaxis de arrays muy parecida (y el primer
Matlab, a finales de los 70, era una interfaz interactiva a LINPACK y
EISPACK, bibliotecas escritas en Fortran).

## 4. Argumentos verificables

### Historia y estabilidad del estándar

| Año | Versión | Novedades principales |
|---|---|---|
| 1957 | FORTRAN (IBM 704, equipo de John Backus) | el primer lenguaje de alto nivel de uso extendido, con un compilador optimizador |
| 1966 | FORTRAN 66 | primer estándar (ANSI) |
| 1978 | FORTRAN 77 | `if-then-else`, `character` |
| 1991 | Fortran 90 | forma libre, módulos, sintaxis de arrays, `allocatable`, tipos derivados, `intent` |
| 1997 | Fortran 95 | `pure`, `elemental`, `forall` |
| 2004 | Fortran 2003 | orientación a objetos, punteros a procedimiento, interoperabilidad con C (`iso_c_binding`) |
| 2010 | Fortran 2008 | coarrays (paralelismo), `do concurrent`, submódulos, `execute_command_line` |
| 2018 | Fortran 2018 | más paralelismo (teams, eventos), más interoperabilidad con C |
| 2023 | Fortran 2023 (ISO/IEC 1539-1:2023, noviembre de 2023) | expresiones condicionales, `typeof`/`classof`, tipos enumerados; la siguiente revisión prepara plantillas genéricas |

La compatibilidad hacia atrás es una prioridad del comité: un programa
en FORTRAN 77 sigue compilando hoy con gfortran o ifx.
Hay pocas características "borradas" (por ejemplo, contadores de bucle
reales) y los compiladores las siguen aceptando con un aviso.

### BLAS y LAPACK

- **BLAS** (operaciones básicas de álgebra lineal) y **LAPACK** (sistemas
  lineales, mínimos cuadrados, autovalores, SVD) tienen su implementación
  de referencia en **Fortran** (<https://www.netlib.org/lapack/>).
- `\` y `eig` en **Matlab**, el módulo `LinearAlgebra` de **Julia**,
  `numpy.linalg` y `scipy.linalg` en **Python**, y **R** llaman a
  BLAS/LAPACK para el álgebra lineal densa. Las implementaciones optimizadas
  (OpenBLAS, Intel MKL, Apple Accelerate) mantienen la interfaz de LAPACK,
  definida en Fortran.
- Honestidad: SciPy envolvió durante décadas bibliotecas en FORTRAN 77
  (QUADPACK, ODEPACK, FITPACK, ARPACK...) y en los últimos años está
  traduciendo parte de ellas a C, sobre todo para simplificar su compilación
  y distribución. BLAS/LAPACK siguen siendo la base.

### Dónde se usa hoy

- **Clima y meteorología**: el IFS del Centro Europeo de Predicción a Plazo
  Medio (ECMWF), WRF, CESM e ICON están escritos principalmente en Fortran.
- **Física y química computacional**: VASP, Quantum ESPRESSO, CP2K, SIESTA.
- **HPC**: Fortran sigue siendo uno de los lenguajes principales en los
  grandes centros de supercomputación, con OpenMP, MPI y coarrays.

### Interoperabilidad

- Con **C**: `iso_c_binding` (Fortran 2003) permite llamar a C y ser
  llamado desde C con una interfaz estándar y portable.
- Con **Julia**: `ccall` llama directamente a una biblioteca compilada con
  `bind(c)`, sin envoltorios.
- Con **Python**: `f2py` (incluido en NumPy) genera el módulo de Python
  a partir del código Fortran.
- Con **C++**: a través de la interfaz C (`extern "C"`).

Ejemplos y enlaces: <https://fortran-lang.org/learn/>.

### Cuándo **no** usar Fortran

- Manejo de texto, ficheros complejos (JSON, HDF5 existe pero es más
  incómodo), interfaces gráficas, web, scripts de "pegamento": Python o
  Julia son mucho más cómodos.
- Exploración interactiva y prototipos: Julia, Python o Matlab.
- Cuando se necesita un ecosistema amplio de bibliotecas no numéricas
  (aprendizaje automático, estadística aplicada, visualización).
- Programación genérica: Fortran todavía no tiene plantillas (llegarán en
  una próxima revisión del estándar); C++ y Julia son mucho más flexibles.
- GPU: existen CUDA Fortran, OpenACC y OpenMP *offload*, pero el ecosistema
  es menor que en C++ (CUDA, Kokkos, SYCL) o Julia (CUDA.jl).
- Si el equipo no conoce Fortran y el cálculo no es el cuello de botella.

**Regla práctica**: el núcleo numérico que tarda horas, en Fortran (o C++,
o Julia bien escrito); todo lo demás, donde sea más cómodo. Y conectarlos
(`iso_c_binding`, `ccall`, `f2py`).
