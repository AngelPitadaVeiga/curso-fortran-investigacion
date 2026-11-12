# Unidad 11 · Elementos finitos

La última unidad es un código más largo que reúne casi todo lo anterior: módulos, Makefile, archivos
de entrada, subrutinas con `intent`, arrays dinámicos, métodos explícitos e implícitos, orden de
convergencia y figuras con Python.

El problema es una **viga en voladizo**: un rectángulo de 10 × 1, empotrado en su lado izquierdo y con
una fuerza hacia abajo en el derecho. Se resuelve con elementos finitos en 2D y las ecuaciones de la
elasticidad lineal. La incógnita es un vector, el desplazamiento de cada punto, la malla es de
triángulos, y además de la deformación se calculan las vibraciones de la viga al soltarla.

```bash
make run
python graficar.py
```

```
Malla: 729 nodos, 1280 triangulos, 1458 incognitas
Flecha en el extremo:                 -3.815E-01
Teoria de vigas (Euler-Bernoulli):    -4.000E-01
Cociente:                              0.954
```

![Viga deformada](figuras/deformada.png)

La viga se curva, y la tensión de von Mises (el color) es máxima en las caras superior e inferior,
junto al empotramiento, y casi nula en la línea central. Es el reparto que predice la teoría de vigas.

## Idea del método

La viga se divide en triángulos. Cada nodo tiene dos incógnitas, el desplazamiento horizontal y el
vertical, y dentro de cada triángulo el desplazamiento se interpola linealmente entre los tres
vértices. La deformación es entonces constante en cada triángulo y se obtiene como `B u_e`, donde `u_e`
son los desplazamientos de los vértices. La tensión es `D B u_e`, y la energía elástica del triángulo
determina su matriz de rigidez:

```
K_e = área · Bᵀ D B
```

`B` contiene las derivadas de las funciones de forma, y `D` describe el material (módulo de Young y
coeficiente de Poisson). La matriz de rigidez global, `K`, es la suma de las `K_e`, cada una colocada
en las filas y columnas de sus tres nodos. Ese proceso se llama **ensamblaje**. Con la fuerza `f`, la
estática es

```
K u = f
```

## Archivos

```
11_elementos_finitos/
├── malla.f90           crea los nodos y los triángulos
├── elasticidad.f90     las matrices B y D, y el ensamblaje de K y de la masa
├── algebra.f90         resolución de sistemas lineales (Cholesky)
├── dinamica.f90        los dos métodos de integración en el tiempo
├── solido.f90          el programa: lee, resuelve y escribe
├── orden_espacial.f90  el programa que mide el orden de convergencia
├── *.nml               los parámetros de cada caso
├── Makefile
└── graficar.py, graficar_vibracion.py
```

`solido` usa `malla`, `elasticidad`, `algebra` y `dinamica`. `dinamica` usa `algebra`, y
`orden_espacial` usa `malla`, `elasticidad` y `algebra`. El orden de lectura recomendado es ese:
`malla.f90` es corto, `elasticidad.f90` contiene el método y `solido.f90` se parece a los programas
principales de las unidades anteriores.

Elementos de Fortran que aparecen aquí:

- **Arrays de dos dimensiones para nodos y triángulos.** `x(:, i)` son las coordenadas del nodo `i`, y
  `tri(:, e)`, los tres nodos del triángulo `e`. Cada columna describe un objeto, como en la unidad 04.
- **Índices con vectores.** En el ensamblaje, `k(gl, gl) = k(gl, gl) + ke` suma una matriz de 6×6 en las
  seis filas y columnas que indica el vector `gl`. Equivale a indexar con un vector en Matlab o Julia.
- **`pack`.** La viga está empotrada a la izquierda, y los desplazamientos de esos nodos son cero, de
  modo que no son incógnitas. `libres = pack([(i, i = 1, 2*n)], .not. fijo)` da la lista de los
  grados de libertad restantes, y la submatriz del sistema es `k(libres, libres)`.
- **Resolución del sistema.** La matriz de rigidez es simétrica y definida positiva, y se resuelve con
  la factorización de Cholesky, `K = L Lᵀ`, y dos sistemas triangulares. Como la matriz es casi toda
  ceros, no es el método más rápido, pero ocupa veinte líneas. En un código real se usaría una matriz
  dispersa o LAPACK (`dpotrf` y `dpotrs` hacen lo mismo).

## Verificación

Hay dos comprobaciones. La primera compara con la teoría de vigas, y es lo que imprime el programa: la
flecha del extremo debería ser `P L³ / (3 E I)`. Con `ny = 4` casillas en el canto el cociente es 0,83,
porque los triángulos lineales son demasiado rígidos a flexión, y solo se aproxima a 1 al refinar la
malla:

| Casillas (nx × ny) | Flecha / teoría |
|---|---:|
| 20 × 2 | 0,54 |
| 40 × 4 | 0,83 |
| 80 × 8 | 0,95 |
| 120 × 12 | 0,98 |

La segunda es medir el orden de convergencia, como en la unidad 09. Para ello hace falta una solución
exacta, y la viga no la tiene. Se construye una solución artificial: se elige el desplazamiento
`ux = sin(πx) sin(πy)`, `uy = 0` en el cuadrado unidad, que vale cero en todo el borde, se sustituye en
las ecuaciones y se calcula la fuerza que lo produciría. Si se resuelve con esa fuerza, la solución
exacta es la elegida y se puede medir el error.

```bash
make run-orden
```

```
  casillas     error maximo     orden
         4       7.4906E-02
         8       1.9270E-02      1.96
        16       4.8970E-03      1.98
        32       1.2307E-03      1.99
OK: orden 2.
```

Con triángulos lineales, el error se divide por cuatro al duplicar las casillas, es decir, orden 2.

## Vibraciones

La parte dinámica parte de la deformación estática y suelta la viga. Sin rozamiento, oscila
indefinidamente. La ecuación es `M u'' + K u = 0`, donde `M` es la matriz de masa. Aquí `M` es
diagonal y se guarda como un vector: cada triángulo reparte un tercio de su masa en cada nodo. El
resultado es un sistema de ecuaciones diferenciales ordinarias, que se resuelve con dos métodos:

- **Explícito** (velocidad Verlet). Cada paso cuesta un producto matriz-vector, pero solo es estable si
  `dt < 2 / ω_max`, donde `ω_max` es la mayor frecuencia de la malla.
- **Implícito** (Newmark, aceleración media). Cada paso resuelve un sistema, pero es estable con
  cualquier `dt`. Es la regla del trapecio de la unidad 09 aplicada al sistema de primer orden
  `u' = v`, `M v' = -K u`. La matriz del sistema es la misma en todos los pasos, así que se factoriza
  una sola vez antes del bucle.

El programa calcula `ω_max` con el método de la potencia, que multiplica un vector por `M⁻¹K` hasta que
se alinea con el autovector dominante, e imprime el paso máximo del método explícito.

```bash
make run-vibracion
python graficar_vibracion.py
```

![Vibración](figuras/vibracion.png)

El panel izquierdo muestra la flecha del extremo y la que da la frecuencia de la teoría de vigas. El
periodo simulado es 610, frente a 619 de la teoría. Con la malla de 40 × 4 sale 565, por la rigidez
de los triángulos lineales. La curva no es una sinusoide exacta porque la viga se suelta desde su
deformación estática, que no coincide con el primer modo de vibración y excita también otros. El panel
derecho muestra la energía total, que se conserva.

Con `dt = 2`, el método implícito recorre dos periodos en 650 pasos. El explícito se ejecuta con:

```bash
make run-explicito
```

Con `dt = 0.07`, por debajo del máximo (0,083), es estable y coincide con el implícito hasta nueve
cifras. Necesita casi treinta veces más pasos, y por eso solo se simula hasta `t = 200`. Con un paso
mayor que el máximo:

```bash
make run-inestable
```

```
Paso maximo del metodo explicito:        2 / omega_max =  8.273E-02
Metodo: explicito   dt = 1.000E-01
La solucion ha explotado en t =  2.400E+00
```

Con `dt = 0.1`, un 20 % por encima del límite, la solución explota en 24 pasos. Es la rigidez de la
unidad 09: las frecuencias más altas de la malla, que carecen de interés físico, determinan el paso.
Cuanto más fina es la malla, más altas son esas frecuencias y menor es el paso permitido.

## Ejercicios

1. Con `estatico.nml`, prueba mallas de 20 × 2, 40 × 4, 80 × 8 y 120 × 12, comprueba la tabla anterior y
   anota el tiempo de cada una.
2. Duplica el espesor de la viga (`ly = 2`) y mide el cambio en la flecha. Repite con una viga de doble
   longitud. Compara con la teoría, en la que la flecha es proporcional a `L³ / ly³`.
3. En `vibracion_explicito.nml`, busca por tanteo el mayor `dt` que no explota y compáralo con el que
   calcula el programa. Repite con una malla de 40 × 4.
4. Cambia `nu` a `0.49`, un material casi incompresible, y observa el efecto sobre la flecha y sobre la
   frecuencia máxima.
5. Empotra también el lado derecho y calcula la deformación con una fuerza hacia abajo repartida por
   todo el cuerpo (`m * g` en cada nodo).
