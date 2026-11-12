# Unidad 00 · Propaganda

Fortran no es más rápido que los demás lenguajes compilados: bien escritos, Fortran y C++ producen el
mismo código. La ventaja es otra. Un programa de cálculo escrito de la forma más natural en Fortran
suele ser rápido, y el mismo estilo en otros lenguajes puede ser mucho más lento.

## Un lenguaje de matemáticos

El nombre viene de *FORmula TRANslation*. Lo diseñó en IBM un equipo de matemáticos y científicos
dirigido por John Backus, con el objetivo de que una fórmula se escribiera en el ordenador de forma
parecida a como se escribe en papel.

Eso se nota en el lenguaje. Los vectores y las matrices forman parte de él, los índices empiezan en 1
o en el valor que se elija, y `c = a + 2*b` suma vectores sin bucles ni bibliotecas. En cambio,
Fortran está peor adaptado a la programación genérica: manejo de texto, estructuras de datos
complejas o aplicaciones web.

## Medidas

Se escribió el mismo programa en varios lenguajes: Runge–Kutta de orden 4 con paso fijo para Van der
Pol, desde muchas condiciones iniciales, con el mismo algoritmo y los mismos parámetros.

| Versión | ns por paso | Veces Fortran |
|---|---:|---:|
| C++ | 7,0 | 0,97 |
| Fortran | 7,2 | 1,00 |
| Fortran, con arrays y funciones que devuelven vectores | 7,3 | 1,01 |
| Julia | 12,1 | 1,68 |
| NumPy, vectorizado | 19,9 | 2,75 |
| Python puro | 247 | 34 |
| Matlab, con vectores y función anónima | 347 | 48 |

Las medidas son de un Intel Core i7-14700 con Windows 11, GCC 14.2, Julia 1.13, Python 3.12, NumPy 2.5
y Matlab R2025b. Todas las versiones dan el mismo resultado salvo redondeo.

![Benchmark](figuras/benchmark_i7-14700.png)

Las dos filas de Fortran son las más relevantes. La versión con arrays pequeños y funciones que
devuelven vectores tarda lo mismo que la escrita con escalares. En Matlab y en Python, ese estilo
multiplica el tiempo de ejecución.

## Otros datos

- Un programa escrito en FORTRAN 77 compila hoy sin cambios.
- BLAS y LAPACK, que usan Matlab, Julia y NumPy para el álgebra lineal, se escribieron en Fortran.
- WRF, VASP y Quantum ESPRESSO, entre otros códigos de clima, física y química, están escritos en
  Fortran.
- Fortran puede llamarse desde Julia, Python y C.

## Cuándo no usarlo

El tratamiento de texto, las interfaces, la exploración de datos y el aprendizaje automático se
resuelven mejor con Python o Julia. El criterio razonable es escribir en Fortran el núcleo numérico
que tarda horas y usar otro lenguaje para el resto.
