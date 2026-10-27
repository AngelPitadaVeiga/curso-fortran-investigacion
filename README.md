# Curso introductorio de FORTRAN orientado a la investigación

**[TU NOMBRE]** · Universidade de Santiago de Compostela (USC) y CITMAGA

Curso práctico de unas 4 horas para investigadores que programan en Julia,
C++ o Matlab y parten de cero en Fortran. El hilo conductor es un problema
de sistemas dinámicos: la **ecuación de Liénard** (Van der Pol), que
integramos con Euler, después con **cualquier Runge–Kutta** definido por su
tablero de Butcher (explícito o implícito) y, por último, dibujamos sus
**retratos de fases**. Por el camino: Fortran moderno, rendimiento medido
con datos y cómo leer código heredado. Empezamos por el final: **por qué merece la pena**.

## La propaganda, en una gráfica

El mismo RK4 para Van der Pol desde muchas condiciones iniciales, con el
mismo algoritmo y bucles explícitos en todos los lenguajes. Tiempo por paso
(medido en un Intel Core i7-14700; repítelo en tu equipo con
`00_propaganda/ejecutar_benchmark.sh`):

![Benchmark](00_propaganda/figuras/benchmark_i7-14700.png)

- **Fortran ≈ C++** (mismo compilador, mismo código máquina). Julia bien
  escrito, del mismo orden (el script mide también su latencia JIT).
- **Python puro: ~80 veces más lento.** Matlab con bucles escalares, 1,7×;
  en su estilo habitual (vector + función anónima), ~46×.
- En Fortran el estilo cómodo (arrays pequeños, funciones que devuelven
  vectores) va **igual de rápido** que el escalar: es **fácil escribir
  código rápido y difícil escribirlo lento**.
- Sin latencia de JIT; un lenguaje vivo desde 1957 con un estándar ISO
  muy estable (el FORTRAN 77 de hace casi 50 años sigue compilando); y BLAS/LAPACK,
  la base del álgebra lineal de Julia, NumPy y Matlab, nacieron en Fortran.

Argumentos, matices y cuándo **no** usar Fortran: [00_propaganda](00_propaganda/).

## Índice

| Bloque | Contenido |
|---|---|
| [00 · Propaganda (con datos)](00_propaganda/) | por qué Fortran: benchmark en 6 lenguajes, aliasing, expresividad, cuándo no usarlo |
| [01 · Instalación](01_instalacion/) | MSYS2 (UCRT64), gfortran, make, gnuplot, VS Code, fortls, fpm |
| [02 · Hola, mundo](02_hola_mundo/) | `program`, `implicit none`, `print`; compilar a mano y desde VS Code |
| [03 · Euler para Liénard](03_euler_lienard/) | módulos, `real64`, `intent`, `namelist`, release frente a debug |
| [04 · Runge–Kutta con tableros de Butcher](04_runge_kutta_butcher/) | tipos derivados, interfaces abstractas, Newton, rigidez, convergencia |
| [05 · Retratos de fases](05_retrato_de_fases/) | reutilización de módulos, datos para graficar, figuras multipanel |
| [06 · Fortran heredado](06_fortran_legado/) | leer y modernizar FORTRAN 77 |
| [07 · Siguientes pasos](07_siguientes_pasos/) | fpm, C/Julia/Python, LAPACK, OpenMP/MPI, libros |

## Reparto orientativo (4 h)

| Hora | Bloque |
|---|---|
| 0:00 | Propaganda (00) |
| 0:20 | Instalación (01) + hola mundo (02) |
| 0:45 | Euler para Liénard (03) |
| 1:30 | *Descanso* |
| 1:40 | Runge–Kutta con tableros de Butcher (04) |
| 2:45 | Retratos de fases (05) |
| 3:20 | Benchmark en vivo (00) + Fortran heredado (06) |
| 3:45 | Siguientes pasos (07) |

## Instalación en tres líneas (Windows)

1. Instala [MSYS2](https://www.msys2.org) y, en la terminal **MSYS2 UCRT64**:
   `pacman -S mingw-w64-ucrt-x86_64-gcc-fortran mingw-w64-ucrt-x86_64-make mingw-w64-ucrt-x86_64-gnuplot make diffutils`
2. Añade `C:\msys64\ucrt64\bin` al `Path` de usuario.
3. Instala [VS Code](https://code.visualstudio.com) y abre esta carpeta (acepta las extensiones recomendadas).

Detalles, alternativas (WSL, Linux, macOS, Intel `ifx`) y problemas frecuentes en [01_instalacion](01_instalacion/).

## Compilar y ejecutar cualquier bloque

```bash
cd 03_euler_lienard
make run          # compila en modo release y ejecuta con entrada.nml
make debug        # compila con todas las comprobaciones
make plot         # vuelve a dibujar con gnuplot
make clean
```

En PowerShell, `mingw32-make` en lugar de `make`. En VS Code, **Ctrl+Shift+B**
compila y ejecuta el bloque del archivo abierto. Cada bloque (03–05) trae
también un `fpm.toml`: `fpm run`. Los parámetros se leen de `entrada.nml`
o del archivo que se pase como argumento: `./euler otro.nml`.

## Fortran frente a C++, Julia y Matlab

| | Fortran | C++ | Julia | Matlab |
|---|---|---|---|---|
| Primer índice | 1 (o el que se quiera: `u(0:n)`) | 0 | 1 | 1 |
| Almacenamiento de matrices | por columnas | por filas (`a[i][j]`) | por columnas | por columnas |
| Organización | módulos (`use`; el compilador genera `.mod`) | headers (`#include`) + fuentes | módulos (`using`) | archivos `.m` |
| Arrays | parte del lenguaje: cortes, `matmul`, `sum`, `where` | bibliotecas (`std::vector`, Eigen...) | parte del lenguaje | parte del lenguaje |
| Compilación | antes de ejecutar (AOT) | antes de ejecutar (AOT) | JIT en la 1.ª llamada | interpretado + JIT |
| Aliasing de argumentos | prohibido por el estándar: optimiza por defecto | permitido: `__restrict__` a mano | permitido: comprobaciones en tiempo de ejecución | no aplica (semántica de valor) |
| Contrato de los argumentos | `intent(in/out/inout)`, comprobado | `const&` | convención `f!` | copia al escribir |
| Memoria dinámica | `allocatable`: se libera sola | RAII / punteros inteligentes | recolector de basura | automática |
| Tipado | estático (con `implicit none`) | estático | dinámico con inferencia | dinámico |

## Integración continua

Cada `push` compila todos los bloques en Linux y en Windows (MSYS2 UCRT64),
ejecuta casos cortos y el test de convergencia de los Runge–Kutta, que falla
si algún orden observado se desvía del teórico
([`.github/workflows/ci.yml`](.github/workflows/ci.yml)). En local:
`bash .github/comprobar_todo.sh`.

## Licencia

- **Código** (`.f90`, `.f`, `.cpp`, `.jl`, `.py`, `.m`, `.sh`, `Makefile`...):
  licencia MIT ([LICENSE](LICENSE)). Úsalo, cópialo y modifícalo libremente.
- **Textos y figuras** (README y demás documentación): licencia
  Creative Commons Atribución 4.0 Internacional, CC BY 4.0
  ([LICENSE-texto](LICENSE-texto)). Puedes reutilizarlos citando la fuente.
