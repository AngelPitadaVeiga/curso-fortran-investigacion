# Unidad 00 · Propaganda

¿Por qué aprender un lenguaje de 1957? No porque sea más rápido que el resto: bien
escritos, Fortran y C++ van igual. La razón es otra: en Fortran es fácil escribir código
rápido y difícil escribirlo lento.

## Un lenguaje hecho por matemáticos

Fortran viene de *FORmula TRANslation*. Lo hizo en IBM un equipo de matemáticos y
científicos dirigido por John Backus, con una idea muy concreta: que escribir una fórmula en
el ordenador se pareciera a escribirla en un papel.

Se nota. Es un lenguaje muy natural para hacer matemáticas y bastante incómodo para la
programación genérica que les gusta a los informáticos. Los vectores y las matrices son parte
del lenguaje, los índices empiezan en 1 (o donde quieras) y `c = a + 2*b` funciona sin
bucles y sin bibliotecas.

## Una comparación

Escribimos el mismo programa en varios lenguajes: RK4 de paso fijo para Van der Pol desde
muchas condiciones iniciales, con el mismo algoritmo y los mismos parámetros en todos.

| Versión | ns por paso | Veces Fortran |
|---|---:|---:|
| C++ | 7,0 | 0,97 |
| Fortran | 7,2 | 1,00 |
| Fortran, con arrays y funciones que devuelven vectores | 7,3 | 1,01 |
| Julia | 12,1 | 1,68 |
| NumPy, vectorizado | 19,9 | 2,75 |
| Python puro | 247 | 34 |
| Matlab, con vectores y función anónima | 347 | 48 |

Medido en un Intel Core i7-14700 con Windows 11, GCC 14.2, Julia 1.13, Python 3.12, NumPy 2.5
y Matlab R2025b. Todas las versiones dan el mismo resultado, salvo redondeo.

![Benchmark](figuras/benchmark_i7-14700.png)

Lo que más nos interesa son las dos filas de Fortran. La versión cómoda, con arrays y
funciones que devuelven vectores, va igual de rápido que la escrita a mano con escalares. En
Matlab o en Python ese mismo estilo sale carísimo.

## Otras razones

Fortran es muy estable: un programa en FORTRAN 77 sigue compilando hoy. Está debajo de casi
todo, porque BLAS y LAPACK, en los que se apoyan Matlab, Julia y NumPy para el álgebra lineal,
nacieron en Fortran. Y se sigue usando mucho en códigos de clima, física y química
computacional, como WRF, VASP o Quantum ESPRESSO. Además, no hay que elegir: se puede llamar
desde Julia, Python o C.

## Cuándo no usarlo

Para manejar texto, hacer interfaces, explorar datos o entrenar redes neuronales, Python y
Julia son mucho más cómodos. La regla que yo sigo es sencilla: el núcleo numérico que tarda
horas, en Fortran, y todo lo demás en lo que te resulte más cómodo.
