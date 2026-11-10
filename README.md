# Curso introductorio de Fortran orientado a la investigación

Ángel Pita da Veiga Ramonde · Universidade de Santiago de Compostela (USC) y CITMAGA

Son dos sesiones de dos horas pensadas para gente que ya programa en Julia, C++ o
Matlab y nunca ha escrito una línea de Fortran. Empezamos con un hola mundo y
terminamos calculando la deformación y las vibraciones de una viga con elementos
finitos en 2D. Por el camino pasamos por Euler, Runge–Kutta y los problemas rígidos.

Casi todo el curso gira alrededor de un mismo problema, el oscilador de Van der Pol, que
vamos resolviendo cada vez un poco mejor, y solo en la última unidad cambiamos de
problema. Si en algún momento te pierdes, la unidad anterior funciona y es más sencilla,
así que siempre se puede volver atrás.

![Benchmark](00_propaganda/figuras/benchmark_i7-14700.png)

## Antes de empezar

Instala lo necesario **antes de la primera sesión**, siguiendo la
[unidad 01](01_instalacion/). Te llevará unos veinte minutos. En clase solo vamos a
comprobar que funciona, y no hay tiempo para instalar nada.

## Primera sesión: del hola mundo a la primera simulación

Programas de un solo archivo, que se compilan a mano.

| Unidad | De qué va |
|---|---|
| [00 · Propaganda](00_propaganda/) | Por qué merece la pena aprender Fortran, y cuándo no |
| [01 · Instalación](01_instalacion/) | Compilador, Python y VS Code |
| [02 · Hola, mundo](02_hola_mundo/) | El primer programa y cómo moverse por VS Code |
| [03 · Variables y bucles](03_variables_y_bucles/) | Tipos, precisión, bucles y formatos |
| [04 · Arrays y archivos](04_arrays_y_archivos/) | Vectores, matrices dinámicas y escribir ficheros |
| [05 · Euler](05_euler/) | Van der Pol con Euler explícito e implícito |
| [06 · Visualización](06_visualizacion/) | Dibujar con Python lo que calcula Fortran |

Entre las dos sesiones tienes una [lista de ejercicios](EJERCICIOS.md).

## Segunda sesión: del script al código de investigación

Aquí el código se reparte en varios archivos y se compila con `make`.

| Unidad | De qué va |
|---|---|
| [07 · Entrada de datos](07_entrada_de_datos/) | Leer los parámetros de un archivo, sin recompilar |
| [08 · Módulos y make](08_modulos_y_make/) | Separar el código en archivos y compilarlo con un Makefile |
| [09 · Runge–Kutta](09_runge_kutta/) | Más métodos, su orden de convergencia y qué pasa con la rigidez |
| [10 · Retrato de fases](10_retrato_de_fases/) | Usar el integrador para estudiar la dinámica |
| [11 · Elementos finitos](11_elementos_finitos/) | Una viga en 2D: un código más grande que junta todo lo anterior |

## Cómo se trabaja

Hasta la unidad 07, cada programa se compila y se ejecuta a mano desde la terminal de
VS Code:

```bash
gfortran heron.f90 -o heron
./heron
```

Desde la unidad 08 hay un `Makefile` en cada carpeta:

```bash
make run
```

Para dibujar, Python: `python graficar.py`.

## Para seguir aprendiendo

- [fortran-lang.org](https://fortran-lang.org) tiene tutoriales, y su
  [foro](https://fortran-lang.discourse.group) es muy activo.
- M. Metcalf, J. Reid, M. Cohen y R. Bader, *Modern Fortran Explained: Incorporating
  Fortran 2023*, Oxford University Press, 2023.
- M. Curcic, *Modern Fortran: Building Efficient Parallel Applications*, Manning, 2020.
- E. Hairer, S. P. Nørsett y G. Wanner, *Solving Ordinary Differential Equations I* y
  *II*, Springer. Sus [códigos](http://www.unige.ch/~hairer/software.html) están en
  Fortran.

## Licencia

El código tiene licencia [MIT](LICENSE). Los textos y las figuras, licencia
[Creative Commons Atribución 4.0](https://creativecommons.org/licenses/by/4.0/deed.es).
