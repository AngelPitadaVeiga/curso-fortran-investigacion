# Unidad 00 · Propaganda

¿Por qué aprender en 2026 un lenguaje de 1957? No es porque sea el más rápido:
bien escritos, Fortran y C++ van igual. La razón es otra: **en Fortran es fácil
escribir código rápido y difícil escribirlo lento.**

## Un lenguaje hecho por matemáticos

Fortran viene de *FORmula TRANslation*. Lo creó en IBM un equipo de matemáticos y
científicos dirigido por John Backus, con un objetivo muy concreto: que
escribir fórmulas en un ordenador se pareciera a escribirlas en un papel.

Se sigue notando. Fortran es un lenguaje natural para hacer matemáticas y bastante
incómodo para la programación genérica de los informáticos. Los vectores y las
matrices son parte del lenguaje, los índices empiezan en 1 (o donde tú quieras) y
`c = a + 2*b` funciona sin bucles y sin bibliotecas.

## Una comparación

Hemos escrito el mismo programa en varios lenguajes: RK4 de paso fijo para Van der
Pol, con el mismo algoritmo y los mismos parámetros.

| Versión | ns por paso | Veces Fortran |
|---|---:|---:|
| C++ | 7,0 | 0,97 |
| Fortran | 7,2 | 1,00 |
| Fortran, con arrays y funciones que devuelven vectores | 7,3 | 1,01 |
| Julia | 12,1 | 1,68 |
| NumPy, vectorizado | 19,9 | 2,75 |
| Python puro | 247 | 34 |
| Matlab, con vectores y función anónima | 347 | 48 |

*Intel Core i7-14700, Windows 11, GCC 14.2, Julia 1.13, Python 3.12, NumPy 2.5 y
Matlab R2025b. Todas las versiones dan el mismo resultado, salvo redondeo.*

![Benchmark](figuras/benchmark_i7-14700.png)

Lo que más nos interesa está en las dos filas de Fortran. La versión cómoda, con
arrays y funciones que devuelven vectores, va tan rápido como la escrita a mano con
escalares. En Matlab o en Python, ese mismo estilo se paga muy caro.

## Otros motivos

- **Es estable.** Un programa en FORTRAN 77 sigue compilando hoy.
- **Está debajo de todo.** BLAS y LAPACK, en los que se apoyan Matlab, Julia y
  NumPy para el álgebra lineal, nacieron en Fortran.
- **Se sigue usando.** Muchos códigos de clima, física y química computacional, como
  WRF, VASP o Quantum ESPRESSO, están escritos en Fortran.
- **No hay que elegir.** Se puede llamar desde Julia, Python o C.

## Cuándo no usarlo

Para manejar texto, hacer interfaces, explorar datos o entrenar redes neuronales,
Python y Julia son mucho más cómodos. La regla es sencilla: el núcleo numérico que
tarda horas, en Fortran; todo lo demás, donde te resulte más cómodo.
