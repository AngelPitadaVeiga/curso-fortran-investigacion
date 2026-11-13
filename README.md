# Curso introductorio de Fortran orientado a la investigación

Ángel Pita da Veiga Ramonde · Universidade de Santiago de Compostela (USC) y CITMAGA

Curso de dos sesiones de dos horas para personas que programan en Julia, C++ o Matlab y no han
escrito nunca Fortran. Empieza con un programa de una línea y termina con un código de elementos
finitos en 2D que calcula la deformación y las vibraciones de una viga. Entre ambos extremos se integra
el oscilador de Van der Pol con Euler, con Runge–Kutta y con métodos implícitos.

![Benchmark](00_propaganda/figuras/benchmark_i7-14700.png)

## Instalación

Antes de empezar hay que instalar lo que describe la [unidad 01](01_instalacion/). Requiere unos
veinte minutos.

## Unidades

- [00 · Propaganda](00_propaganda/): razones para usar Fortran, y cuándo no.
- [01 · Instalación](01_instalacion/): compilador, make, Python y VS Code.
- [02 · Hola, mundo](02_hola_mundo/): el primer programa y VS Code.
- [03 · Variables y bucles](03_variables_y_bucles/): tipos, precisión y formatos.
- [04 · Arrays y archivos](04_arrays_y_archivos/): vectores, matrices dinámicas y ficheros.
- [05 · Euler](05_euler/): Van der Pol con Euler explícito e implícito.
- [06 · Visualización](06_visualizacion/): figuras con Python y la deriva de fase de Euler.
- [07 · Entrada de datos](07_entrada_de_datos/): parámetros leídos de un archivo.
- [08 · Módulos y make](08_modulos_y_make/): código en varios archivos y Makefile.
- [09 · Runge–Kutta](09_runge_kutta/): más métodos, orden de convergencia y rigidez.
- [10 · Retrato de fases](10_retrato_de_fases/): estudio de la dinámica con el integrador.
- [11 · Elementos finitos](11_elementos_finitos/): una viga en 2D.
- [Ejercicios](EJERCICIOS.md).

## Compilar y ejecutar

Hasta la unidad 07 cada programa se compila desde la terminal de VS Code:

```bash
gfortran heron.f90 -o heron
./heron
```

Desde la unidad 08 hay un `Makefile` en cada carpeta (`make run`). Las figuras se dibujan con
`python graficar.py`.

## Bibliografía

- [fortran-lang.org](https://fortran-lang.org) y su [foro](https://fortran-lang.discourse.group).
- M. Metcalf, J. Reid, M. Cohen y R. Bader, *Modern Fortran Explained: Incorporating Fortran 2023*,
  Oxford University Press, 2023.
- M. Curcic, *Modern Fortran: Building Efficient Parallel Applications*, Manning, 2020.
- E. Hairer, S. P. Nørsett y G. Wanner, *Solving Ordinary Differential Equations I* y *II*,
  Springer. Sus [códigos](http://www.unige.ch/~hairer/software.html) están en Fortran.

## Licencia

El código tiene licencia [MIT](LICENSE). Los textos y las figuras, licencia
[Creative Commons Atribución 4.0](https://creativecommons.org/licenses/by/4.0/deed.es).
