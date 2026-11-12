# Ejercicios entre las dos sesiones

Los ejercicios usan solo lo visto en la primera sesión. No es necesario resolverlos todos ni seguir
el orden. Los de Euler (del 9 al 13) son los más útiles para la segunda sesión.

Cada programa ocupa un solo archivo, como los de las unidades 03 a 06. Quien se bloquee puede
traer a clase su código, aunque no funcione, y se revisa entre todos.

## Precisión y bucles

**1. Razón áurea.** La iteración `x_{k+1} = 1 + 1/x_k` converge a `(1 + √5)/2`. Imprime el error en
cada paso y detén el bucle con un criterio de parada. Compara la columna del error con la del método
de Herón y describe la diferencia.

**2. Simple y doble precisión.** Suma `1 - 1/2 + 1/3 - 1/4 + ...` con `n = 10⁷` términos, que tiende a
`log(2)`, una vez con `real` y otra con `double precision`. Compara los dos errores. En simple
precisión, comprueba si el resultado cambia al sumar de atrás hacia delante y propón una explicación.

**3. Épsilon de la máquina.** Sin usar la función `epsilon`, busca con un bucle el menor `e = 2^(-k)`
tal que `1 + e /= 1`. Repítelo en las dos precisiones y compara con `epsilon`.

## Arrays

**4. Matriz de Hilbert.** Pide `n` por teclado y construye con `allocate` la matriz
`H(i, j) = 1/(i + j - 1)`. Calcula su traza, la suma de cada columna y su producto por un vector de
unos. Después reserva de nuevo la matriz con el doble de tamaño.

**5. Regla del trapecio.** Calcula la integral de `sin(x)` entre `0` y `π` con `n + 1` puntos y sin
bucles, mediante cortes y `sum`. Prueba `n = 10, 20, 40, ..., 1280`.

**6. Derivada con cortes.** A partir de `f(0:n)` con los valores de `sin(x)`, calcula la derivada con
diferencias centradas en una sola línea de cortes. Escribe en un archivo `x`, la derivada
aproximada y el error.

## Figuras

**7. Orden del trapecio.** Modifica el ejercicio 5 para que escriba `h` y el error en un archivo.
Dibújalos con `loglog` y mide la pendiente. Compárala con el orden que esperabas.

**8. Una figura propia.** Elige un archivo de datos de tu investigación, o genera uno con Fortran, y
prepara una figura de dos paneles para un artículo: ejes con nombre, leyenda y salida en PDF.

## Euler

**9. Oscilador armónico.** Con `mu = 0` las órbitas de Van der Pol son circunferencias y la energía
`E = x² + y²` es constante. Reduce `t_final` a 50 y dibuja `E(t)` con Euler explícito y con Euler
implícito. Calcula con lápiz y papel el factor por el que se multiplica `E` en un paso, y comprueba que coincide
con lo que dibujas.

**10. Periodo y paso.** Mide el periodo del ciclo límite de Van der Pol con Euler explícito para
`h = 0.1, 0.05, 0.025` y `0.0125`, a partir de los cruces de `x` por cero (puedes hacerlo en Python,
con `numpy`). Calcula la diferencia con el periodo de la referencia y comprueba si se divide por dos
cuando `h` se divide por dos.

**11. Otro sistema.** Adapta los dos programas a las ecuaciones de Lotka–Volterra,

```
x' =  x (1 - y)
y' = -y (1 - x)
```

cuyas órbitas son cerradas alrededor de `(1, 1)`. El método implícito necesita el jacobiano.
Dibuja las órbitas de cada método y describe lo que ocurre con ellas.

**12. Euler semiimplícito.** Actualiza `x` con el valor antiguo de `y`, y después `y` con el valor
nuevo de `x`:

```
x_{k+1} = x_k + h y_k
y_{k+1} = y_k - h x_{k+1}
```

Aplícalo al oscilador armónico (`mu = 0`) con `h = 0.1` y compara `E(t)` con la del ejercicio 9. El
método sigue siendo de orden 1, pero su comportamiento es distinto. Describe en qué.

**13. Método de Heun.** Programa Heun como una subrutina:

```
k1 = F(u)
k2 = F(u + h k1)
u_nuevo = u + h (k1 + k2) / 2
```

Compara la amplitud que da con la de Euler explícito para `h = 0.1` y `h = 0.3`. Mide su orden
integrando hasta `t = 1` con varios `h`. Después considera cuántas subrutinas habría que escribir para
probar diez métodos; la unidad 09 muestra una alternativa.
