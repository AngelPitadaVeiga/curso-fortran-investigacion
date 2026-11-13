# Unidad 11 · Elementos finitos

Un código más largo que reúne lo anterior: módulos, Makefile, archivos de entrada, subrutinas con
`intent`, arrays dinámicos, métodos explícitos e implícitos, orden de convergencia y figuras.

El problema es una **viga en voladizo** de 10 × 1, empotrada a la izquierda y con una fuerza hacia
abajo en el extremo derecho. Se resuelve con elementos finitos en 2D y elasticidad lineal: la
incógnita es el desplazamiento de cada punto, la malla es de triángulos, y además de la deformación se
calculan las vibraciones al soltar la viga.

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

El color es la tensión de von Mises: máxima en las caras superior e inferior junto al empotramiento y
casi nula en la línea central, como predice la teoría de vigas.

## Método

Cada nodo tiene dos incógnitas (desplazamiento horizontal y vertical), y dentro de cada triángulo el
desplazamiento es lineal. La deformación es entonces constante en cada triángulo, `B u_e`, la tensión
es `D B u_e`, y la matriz de rigidez del triángulo es

```
K_e = área · Bᵀ D B
```

(`B` contiene las derivadas de las funciones de forma, y `D` el material). La matriz global `K` es la
suma de las `K_e`, cada una colocada en las filas y columnas de sus tres nodos: el **ensamblaje**. La
estática es `K u = f`.

## Archivos

```
11_elementos_finitos/
├── malla.f90           nodos y triángulos
├── elasticidad.f90     matrices B y D, ensamblaje de K y de la masa
├── algebra.f90         resolución de sistemas (Cholesky)
├── dinamica.f90        integración en el tiempo
├── solido.f90          programa principal
├── orden_espacial.f90  programa que mide el orden de convergencia
├── *.nml, Makefile
└── graficar.py, graficar_vibracion.py
```

`solido` usa `malla`, `elasticidad`, `algebra` y `dinamica`; `dinamica` usa `algebra`; y
`orden_espacial` usa `malla`, `elasticidad` y `algebra`. Elementos de Fortran que aparecen:

- `x(:, i)` son las coordenadas del nodo `i`, y `tri(:, e)`, los tres nodos del triángulo `e`.
- `k(gl, gl) = k(gl, gl) + ke` suma una matriz de 6×6 en las filas y columnas que indica el vector
  `gl`, como indexar con un vector en Matlab o Julia.
- Los nodos empotrados no son incógnitas. `libres = pack([(i, i = 1, 2*n)], .not. fijo)` da la lista
  de grados de libertad restantes, y el sistema es `k(libres, libres)`.
- La matriz de rigidez es simétrica y definida positiva, y se resuelve con Cholesky (`K = L Lᵀ`) y dos
  sistemas triangulares. Es denso y no es el método más rápido; en un código real se usaría una matriz
  dispersa o LAPACK (`dpotrf`, `dpotrs`).

## Verificación

Con la teoría de vigas, la flecha del extremo debería ser `P L³ / (3 E I)`. Los triángulos lineales
son demasiado rígidos a flexión, y el cociente solo se acerca a 1 al refinar:

| Casillas (nx × ny) | Flecha / teoría |
|---|---:|
| 20 × 2 | 0,54 |
| 40 × 4 | 0,83 |
| 80 × 8 | 0,95 |
| 120 × 12 | 0,98 |

Para medir el orden de convergencia hace falta una solución exacta, y la viga no la tiene. Se elige un
desplazamiento, `ux = sin(πx) sin(πy)`, `uy = 0` en el cuadrado unidad (nulo en todo el borde), se
sustituye en las ecuaciones y se calcula la fuerza que lo produce. Resolviendo con esa fuerza, la
solución exacta es la elegida:

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

## Vibraciones

Se parte de la deformación estática y se suelta la viga. La ecuación es `M u'' + K u = 0`, con `M`
diagonal (cada triángulo reparte un tercio de su masa en cada nodo). Se resuelve con dos métodos:

- **Explícito** (velocidad Verlet): un producto matriz-vector por paso, pero solo es estable si
  `dt < 2 / ω_max`, con `ω_max` la mayor frecuencia de la malla.
- **Implícito** (Newmark, aceleración media): resuelve un sistema en cada paso y es estable con
  cualquier `dt`. Es la regla del trapecio de la unidad 09 aplicada al sistema `u' = v`,
  `M v' = -K u`. Su matriz es la misma en todos los pasos y se factoriza una vez.

El programa calcula `ω_max` con el método de la potencia e imprime el paso máximo del explícito.

```bash
make run-vibracion
python graficar_vibracion.py
```

![Vibración](figuras/vibracion.png)

Izquierda: flecha del extremo y la que daría la teoría de vigas. El periodo simulado es 610, frente a
619 (con la malla de 40 × 4, 565, por la rigidez de los triángulos). La curva no es una sinusoide
exacta porque la deformación inicial excita varios modos. Derecha: la energía total, que se conserva.

Con `dt = 2` el implícito recorre dos periodos en 650 pasos. Con el explícito:

```bash
make run-explicito        # dt = 0.07, por debajo del máximo (0,083)
make run-inestable        # dt = 0.1
```

```
Paso maximo del metodo explicito:        2 / omega_max =  8.273E-02
Metodo: explicito   dt = 1.000E-01
La solucion ha explotado en t =  2.400E+00
```

Con `dt = 0.07` el explícito coincide con el implícito hasta nueve cifras, pero necesita casi treinta
veces más pasos (por eso solo se simula hasta `t = 200`). Con `dt = 0.1`, un 20 % sobre el límite,
explota en 24 pasos. Es la rigidez de la unidad 09: las frecuencias más altas de la malla, sin interés
físico, fijan el paso, y son más altas cuanto más fina es la malla.

## Ejercicios

1. Con `estatico.nml`, prueba mallas de 20 × 2, 40 × 4, 80 × 8 y 120 × 12, comprueba la tabla y anota
   el tiempo de cada una.
2. Duplica el espesor (`ly = 2`) y mide el cambio en la flecha; repite con doble longitud. La teoría
   da una flecha proporcional a `L³ / ly³`.
3. En `vibracion_explicito.nml`, busca por tanteo el mayor `dt` que no explota y compáralo con el
   calculado. Repite con una malla de 40 × 4.
4. Pon `nu = 0.49` (casi incompresible) y observa el efecto sobre la flecha y sobre `ω_max`.
5. Empotra también el lado derecho y calcula la deformación con una fuerza hacia abajo repartida por
   todo el cuerpo (`m * g` en cada nodo).
