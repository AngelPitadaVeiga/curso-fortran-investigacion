# Curso introductorio de Fortran orientado a la investigación

Ángel Pita da Veiga Ramonde · Universidade de Santiago de Compostela (USC) y CITMAGA

El curso consta de dos sesiones de dos horas. Está dirigido a personas que programan en Julia,
C++ o Matlab y no han escrito nunca Fortran. Empieza con un programa de una línea y termina con un
código de elementos finitos en 2D que calcula la deformación y las vibraciones de una viga.

Entre ambos extremos se integra el oscilador de Van der Pol con Euler, con Runge–Kutta y con
métodos implícitos. Ese problema se mantiene de la unidad 05 a la 10, y cada unidad lo resuelve con
un programa mejor que el anterior. La unidad 11 cambia de problema. Todas las unidades parten de la
anterior, de modo que quien no consiga terminar una puede continuar desde la previa.

![Benchmark](00_propaganda/figuras/benchmark_i7-14700.png)

## Instalación

El material de la [unidad 01](01_instalacion/) debe estar instalado antes de la primera sesión y
requiere unos veinte minutos. En clase solo se comprueba que funciona.

## Primera sesión: de un programa de una línea a la primera simulación

Los programas ocupan un archivo y se compilan desde la terminal.

| Unidad | Contenido |
|---|---|
| [00 · Propaganda](00_propaganda/) | Razones para usar Fortran y casos en los que no conviene |
| [01 · Instalación](01_instalacion/) | Compilador, make, Python y VS Code |
| [02 · Hola, mundo](02_hola_mundo/) | El primer programa y el manejo básico de VS Code |
| [03 · Variables y bucles](03_variables_y_bucles/) | Tipos, precisión, bucles y formatos de salida |
| [04 · Arrays y archivos](04_arrays_y_archivos/) | Vectores, matrices dinámicas y escritura de ficheros |
| [05 · Euler](05_euler/) | Van der Pol con Euler explícito e implícito, y una solución de referencia |
| [06 · Visualización](06_visualizacion/) | Figuras con Python y la deriva de fase de Euler en tiempos largos |

Entre las dos sesiones hay una [lista de ejercicios](EJERCICIOS.md).

## Segunda sesión: de un archivo a un código de investigación

El código se reparte en varios archivos y se compila con `make`.

| Unidad | Contenido |
|---|---|
| [07 · Entrada de datos](07_entrada_de_datos/) | Lectura de los parámetros desde un archivo, sin recompilar |
| [08 · Módulos y make](08_modulos_y_make/) | División del código en módulos y compilación con un Makefile |
| [09 · Runge–Kutta](09_runge_kutta/) | Más métodos, orden de convergencia, retraso de fase y rigidez |
| [10 · Retrato de fases](10_retrato_de_fases/) | Uso del integrador para estudiar la dinámica |
| [11 · Elementos finitos](11_elementos_finitos/) | Una viga en 2D, con estática y vibraciones |

## Compilar y ejecutar

Hasta la unidad 07 cada programa se compila y se ejecuta desde la terminal de VS Code:

```bash
gfortran heron.f90 -o heron
./heron
```

Desde la unidad 08 cada carpeta tiene un `Makefile`:

```bash
make run
```

Las figuras se dibujan con `python graficar.py`.

## Bibliografía

- [fortran-lang.org](https://fortran-lang.org) reúne tutoriales, y su
  [foro](https://fortran-lang.discourse.group) recibe preguntas de todos los niveles.
- M. Metcalf, J. Reid, M. Cohen y R. Bader, *Modern Fortran Explained: Incorporating Fortran 2023*,
  Oxford University Press, 2023.
- M. Curcic, *Modern Fortran: Building Efficient Parallel Applications*, Manning, 2020.
- E. Hairer, S. P. Nørsett y G. Wanner, *Solving Ordinary Differential Equations I* y *II*,
  Springer. Sus [códigos](http://www.unige.ch/~hairer/software.html) están escritos en Fortran.

## Licencia

El código tiene licencia [MIT](LICENSE). Los textos y las figuras tienen licencia
[Creative Commons Atribución 4.0](https://creativecommons.org/licenses/by/4.0/deed.es).
