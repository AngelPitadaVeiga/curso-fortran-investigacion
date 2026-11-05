# Ejercicios entre las dos sesiones

Con lo visto en la primera sesión puedes hacerlos todos. No hace falta terminarlos, pero
intenta llegar al menos a los de Euler: son los que preparan la segunda sesión.

Cada programa cabe en un solo archivo, como los de las unidades 03 a 06. Si te atascas,
trae tu código a clase, aunque no funcione: lo veremos juntos.

## Calentamiento

**1. La razón áurea.** La iteración `x_{k+1} = 1 + 1/x_k` converge a `(1 + √5)/2`. Imprime
el error en cada iteración y detente con un criterio de parada. ¿Converge igual de rápido
que el método de Herón? ¿Cómo se ve en la columna del error?

**2. Simple o doble precisión.** Suma `1 - 1/2 + 1/3 - 1/4 + ...`, cuyo límite es `log(2)`,
con `n = 10⁷` términos, en `real32` y en `real64`. Compara los errores. En `real32`, ¿cambia
el resultado si sumas de atrás hacia adelante? ¿Por qué?

**3. El épsilon de la máquina.** Sin usar la función `epsilon`, encuentra con un bucle el
menor `e = 2^(-k)` tal que `1 + e /= 1`. Hazlo en las dos precisiones y comprueba el
resultado con `epsilon`.

## Arrays

**4. La matriz de Hilbert.** Pide `n` por teclado y construye con `allocate` la matriz
`H(i, j) = 1/(i + j - 1)`. Imprime su traza, la suma de cada columna y `matmul(H, v)`, con `v`
un vector de unos. Después, resérvala de nuevo con el doble de tamaño.

**5. Regla del trapecio.** Calcula la integral de `sin(x)` entre `0` y `π` con `n + 1` puntos
en un array `x(0:n)`, sin bucles: con cortes y `sum`. Pruébalo con `n = 10, 20, 40, ..., 1280`.

**6. Derivadas con cortes.** En un array `f(0:n)` con `sin(x)`, calcula la derivada con
diferencias centradas usando una sola línea con cortes. Escribe `x`, la derivada aproximada
y el error en un archivo.

## Figuras

**7. Orden del trapecio.** Modifica el ejercicio 5 para escribir `h` y el error en un archivo
y dibújalos con `loglog`. ¿Qué pendiente sale? ¿Qué orden esperabas?

**8. La figura de tu trabajo.** Coge un archivo de datos de tu investigación, o crea uno con
Fortran, y haz una figura con dos paneles lista para un artículo: ejes con nombre, leyenda y
guardada en PDF.

## Euler

**9. El oscilador armónico.** Con `mu = 0`, las órbitas de Van der Pol son circunferencias y
`E = x² + y²` se conserva. Dibuja `E(t)` con Euler explícito y con Euler implícito. ¿Qué le
pasa en cada caso? Comprueba tus resultados con una cuenta a mano: ¿por qué número queda
multiplicada `E` en cada paso?

**10. El mapa de estabilidad.** Modifica `euler_explicito.f90` para que recorra varios `h` con
un bucle y, para cada uno, escriba en un archivo la amplitud de la órbita en la segunda mitad
de la simulación (o que ha explotado). Dibuja la amplitud frente a `h` para `mu = 1`. Haz lo
mismo con Euler implícito y compara. Para esto te vendrá bien una subrutina.

**11. Otro sistema.** Adapta los dos programas al sistema depredador–presa de Lotka–Volterra,

```
x' =  x (1 - y)
y' = -y (1 - x)
```

que tiene órbitas cerradas alrededor de `(1, 1)`. Para el implícito tendrás que calcular el
jacobiano. Dibuja las órbitas: ¿qué hace cada método?

**12. Euler semiimplícito.** Actualiza primero `x` con el valor antiguo de `y`, y luego `y` con
el valor *nuevo* de `x`:

```
x_{k+1} = x_k + h y_k
y_{k+1} = y_k - h x_{k+1}
```

Pruébalo con el oscilador armónico (`mu = 0`) y `h = 0.1`, y compara `E(t)` con el ejercicio 9.
Sigue siendo de orden 1, pero ¿qué tiene de especial?

## Reto, para ir abriendo boca

**13. Tu primer método de orden 2.** Programa el método de Heun como subrutina:

```
k1 = F(u)
k2 = F(u + h k1)
u_nuevo = u + h (k1 + k2) / 2
```

Compara su amplitud con la de Euler explícito para `h = 0.1` y `h = 0.3`, y mide el orden
integrando hasta `t = 1` con varios `h`. Después piensa en esto: si quisieras probar diez
métodos distintos, ¿querrías escribir diez subrutinas? La respuesta está en la unidad 08.
