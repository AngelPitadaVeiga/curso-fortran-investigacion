# Ejercicios entre las dos sesiones

Usan solo lo visto en la primera sesión. No hace falta resolverlos todos ni en orden; los de Euler (9
a 13) son los más útiles para la segunda sesión. Cada programa ocupa un solo archivo, como los de las
unidades 03 a 06. Quien se bloquee puede traer su código a clase, aunque no funcione.

## Precisión y bucles

**1. Razón áurea.** La iteración `x_{k+1} = 1 + 1/x_k` converge a `(1 + √5)/2`. Imprime el error en
cada paso, detén el bucle con un criterio de parada y compara la columna del error con la del método
de Herón.

**2. Simple y doble precisión.** Suma `1 - 1/2 + 1/3 - 1/4 + ...` con `n = 10⁷` términos, que tiende a
`log(2)`, con `real` y con `double precision`, y compara los errores. En simple precisión, comprueba
si cambia el resultado al sumar de atrás hacia delante y propón una explicación.

**3. Épsilon de la máquina.** Sin usar `epsilon`, busca con un bucle el menor `e = 2^(-k)` tal que
`1 + e /= 1`, en las dos precisiones, y compara con `epsilon`.

## Arrays

**4. Matriz de Hilbert.** Pide `n` por teclado y construye con `allocate` la matriz
`H(i, j) = 1/(i + j - 1)`. Calcula su traza, la suma de cada columna y su producto por un vector de
unos. Después reserva de nuevo la matriz con el doble de tamaño.

**5. Regla del trapecio.** Calcula la integral de `sin(x)` entre `0` y `π` con `n + 1` puntos, sin
bucles (cortes y `sum`), para `n = 10, 20, 40, ..., 1280`.

**6. Derivada con cortes.** A partir de `f(0:n)` con los valores de `sin(x)`, calcula la derivada con
diferencias centradas en una línea de cortes. Escribe en un archivo `x`, la derivada y el error.

## Figuras

**7. Orden del trapecio.** Modifica el ejercicio 5 para escribir `h` y el error en un archivo,
dibújalos con `loglog` y mide la pendiente.

**8. Una figura propia.** Con datos de tu investigación (o generados con Fortran), prepara una figura
de dos paneles para un artículo: ejes con nombre, leyenda y salida en PDF.

## Euler

**9. Oscilador armónico.** Con `mu = 0` las órbitas son circunferencias y `E = x² + y²` es constante.
Reduce `t_final` a 50 y dibuja `E(t)` con Euler explícito y con Euler implícito. Calcula con lápiz y
papel el factor por el que se multiplica `E` en un paso y compáralo con lo que dibujas.

**10. Periodo y paso.** Mide el periodo del ciclo límite de Van der Pol con Euler explícito para
`h = 0.1, 0.05, 0.025` y `0.0125`, a partir de los cruces de `x` por cero (en Python, con `numpy`).
Compara con el periodo de la referencia y comprueba si la diferencia se divide por dos cuando `h` se
divide por dos.

**11. Otro sistema.** Adapta los dos programas a Lotka–Volterra,

```
x' =  x (1 - y)
y' = -y (1 - x)
```

cuyas órbitas son cerradas alrededor de `(1, 1)`. El implícito necesita el jacobiano. Dibuja las
órbitas de cada método y describe lo que les ocurre.

**12. Euler semiimplícito.** Actualiza `x` con el `y` antiguo, y después `y` con el `x` nuevo:

```
x_{k+1} = x_k + h y_k
y_{k+1} = y_k - h x_{k+1}
```

Aplícalo al oscilador armónico (`mu = 0`) con `h = 0.1` y compara `E(t)` con el ejercicio 9. Sigue
siendo de orden 1, pero su comportamiento es distinto: describe en qué.

**13. Método de Heun.** Programa Heun como subrutina:

```
k1 = F(u)
k2 = F(u + h k1)
u_nuevo = u + h (k1 + k2) / 2
```

Compara su amplitud con la de Euler explícito para `h = 0.1` y `h = 0.3`, y mide su orden integrando
hasta `t = 1` con varios `h`. La unidad 09 muestra cómo probar muchos métodos sin escribir una
subrutina para cada uno.
