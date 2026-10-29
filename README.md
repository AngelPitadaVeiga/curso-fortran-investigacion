# Curso introductorio de FORTRAN orientado a la investigación

**Ángel Pita da Veiga Ramonde** · Universidade de Santiago de Compostela (USC) y CITMAGA

Curso práctico de **dos sesiones de dos horas** para investigadores que
programan en Julia, C++ o Matlab y parten de cero en Fortran. Es
**progresivo**: cada bloque añade uno o dos conceptos al anterior y el
código crece poco a poco, desde el hola mundo hasta un integrador de
Runge–Kutta implícito. El hilo conductor es un problema de sistemas
dinámicos, el **oscilador de Van der Pol** (ecuación de Liénard), que
integramos con Euler, después con cualquier Runge–Kutta definido por su
tablero de Butcher, dibujamos su **retrato de fases** y, por último,
resolvemos en su versión **rígida**. Empezamos por el final: **por qué
merece la pena**.

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

### Sesión 1 · Del hola mundo a la primera simulación

Programas de **un solo archivo**, compilados a mano con `gfortran`.

| Bloque | Qué se hace | Qué se aprende |
|---|---|---|
| [00 · Propaganda](00_propaganda/) | por qué Fortran, con datos | benchmark en 6 lenguajes, aliasing, cuándo no usarlo |
| [01 · Instalación](01_instalacion/) | MSYS2, gfortran, make, gnuplot, VS Code | comprobar que todo funciona |
| [02 · Hola, mundo](02_hola_mundo/) | el primer programa | `program`, `implicit none`, `print`, compilar |
| [03 · Variables y bucles](03_variables_y_bucles/) | tipos y raíz cuadrada por Herón | `real64`, `parameter`, `do`, `exit`, `if`, formatos |
| [04 · Arrays y archivos](04_arrays_y_archivos/) | operaciones con arrays; una tabla para gnuplot | cortes, `matmul`, `allocatable`, por columnas, `open`/`write` |
| [05 · Euler en un archivo](05_euler_un_archivo/) | Van der Pol con Euler explícito | funciones, `contains`, `intent`, el estado como array |

### Sesión 2 · Del script al código de investigación

Proyectos con **módulos**, archivo de entrada y `Makefile`.

| Bloque | Qué se hace | Qué se aprende |
|---|---|---|
| [06 · Módulos y make](06_modulos_y_make/) | el mismo Euler, organizado | módulos, `namelist`, compilación separada, release frente a debug |
| [07 · Runge–Kutta](07_runge_kutta/) | cualquier RK explícito leído de un archivo; orden de convergencia | tipos derivados, componentes `allocatable`, `matmul` |
| [08 · Retrato de fases](08_retrato_de_fases/) | campo, trayectorias, nulclinas y ciclo límite | reutilizar módulos, cortes con paso, solapamiento de argumentos |
| [09 · Rigidez](09_rigidez/) | `mu = 1000`: RK4 explota, Radau IIA no | RK implícitos con Newton, argumentos opcionales, `ieee_arithmetic` |

Los bloques 05, 06 y 07 calculan **exactamente lo mismo** con Euler (bit
a bit, lo comprueba la integración continua): cada uno reorganiza o
generaliza el anterior sin cambiar el resultado.

## Reparto orientativo

| Sesión 1 | | Sesión 2 | |
|---|---|---|---|
| 0:00 | Propaganda (00) | 0:00 | Módulos, namelist y make (06) |
| 0:15 | Instalación (01), comprobación | 0:35 | Runge–Kutta y convergencia (07) |
| 0:25 | Hola, mundo (02) | 1:10 | *Descanso* |
| 0:35 | Variables y bucles (03) | 1:20 | Retrato de fases (08) |
| 1:00 | *Descanso* | 1:45 | Rigidez (09), como demostración |
| 1:10 | Arrays y archivos (04) | 1:55 | Preguntas; benchmark en vivo (00) |
| 1:35 | Euler en un archivo (05) | | |

Conviene pedir a los asistentes que hagan la instalación (bloque 01)
**antes** de la primera sesión: en clase solo se comprueba.

## Instalación en tres líneas (Windows)

1. Instala [MSYS2](https://www.msys2.org) y, en la terminal **MSYS2 UCRT64**:
   `pacman -S mingw-w64-ucrt-x86_64-gcc-fortran mingw-w64-ucrt-x86_64-make mingw-w64-ucrt-x86_64-gnuplot make diffutils`
2. Añade `C:\msys64\ucrt64\bin` al `Path` de usuario.
3. Instala [VS Code](https://code.visualstudio.com) y abre esta carpeta (acepta las extensiones recomendadas).

Detalles, alternativas (WSL, Linux, macOS, Intel `ifx`) y problemas frecuentes en [01_instalacion](01_instalacion/).

## Compilar y ejecutar

**Bloques 02 a 05** (un archivo):

```bash
gfortran -Wall heron.f90 -o heron
./heron
```

**Bloques 06 a 09** (con `Makefile`):

```bash
cd 07_runge_kutta
make run          # compila en modo release, ejecuta con entrada.nml y dibuja
make debug        # compila con todas las comprobaciones
make plot         # vuelve a dibujar con gnuplot
make clean
```

En PowerShell, `mingw32-make` en lugar de `make`. En **VS Code**,
**Ctrl+Shift+B** con cualquier archivo abierto: si el bloque tiene
`Makefile`, hace `make run`; si no, compila y ejecuta el archivo abierto.
Los bloques 06–09 traen también un `fpm.toml` (`fpm run`).

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

Cada `push` compila y ejecuta todos los bloques en Linux y en Windows
(MSYS2 UCRT64), comprueba que los Euler de los bloques 05, 06 y 07
coinciden bit a bit, que las copias de los módulos compartidos no se han
separado y que los órdenes de convergencia de todos los Runge–Kutta son
los teóricos ([`.github/workflows/ci.yml`](.github/workflows/ci.yml)).
En local: `bash .github/comprobar_todo.sh`.

## Para seguir aprendiendo

- **fortran-lang.org**: tutoriales, compiladores, paquetes (fpm, stdlib):
  <https://fortran-lang.org>. Foro: <https://fortran-lang.discourse.group>.
- M. Metcalf, J. Reid, M. Cohen y R. Bader, *Modern Fortran Explained:
  Incorporating Fortran 2023*, Oxford University Press, 2023.
- M. Curcic, *Modern Fortran: Building Efficient Parallel Applications*, Manning, 2020.
- E. Hairer, S. P. Nørsett y G. Wanner, *Solving Ordinary Differential
  Equations I* y *II*, Springer; sus códigos (DOPRI5, RADAU5...) están en
  Fortran: <http://www.unige.ch/~hairer/software.html>.

## Licencia

- **Código** (`.f90`, `.f`, `.cpp`, `.jl`, `.py`, `.m`, `.sh`, `Makefile`...):
  licencia MIT ([LICENSE](LICENSE)). Úsalo, cópialo y modifícalo libremente.
- **Textos y figuras** (README y demás documentación): licencia
  Creative Commons Atribución 4.0 Internacional, CC BY 4.0
  ([LICENSE-texto](LICENSE-texto)). Puedes reutilizarlos citando la fuente.
