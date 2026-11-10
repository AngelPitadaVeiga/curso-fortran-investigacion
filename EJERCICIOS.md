# Ejercicios entre las dos sesiones

Con lo de la primera sesión puedes hacerlos todos. No hace falta terminarlos, ni siquiera
empezarlos por orden, pero si solo tienes tiempo para unos pocos, haz los de Euler: son los que
más nos van a servir en la segunda sesión.

Cada programa cabe en un solo archivo, como los de las unidades 03 a 06. Si te atascas, trae el
código a clase aunque no funcione, y lo miramos juntos.

## Para soltar la mano

**1. La razón áurea.** La iteración `x_{k+1} = 1 + 1/x_k` converge a `(1 + √5)/2`. Imprime el
error en cada paso y para cuando sea suficientemente pequeño. Compara con lo que pasaba con el
método de Herón: ¿converge igual de rápido? ¿Qué ves en la columna del error?

**2. Simple frente a doble.** Suma `1 - 1/2 + 1/3 - 1/4 + ...` con `n = 10⁷` términos, que tiende a
`log(2)`, una vez con `real` y otra con `double precision`. Mira el error de cada una. ¿Cambia el
resultado en simple precisión si sumas de atrás hacia delante? Piensa por qué.

**3. El épsilon de la máquina.** Sin usar la función `epsilon`, busca con un bucle el menor
`e = 2^(-k)` tal que `1 + e /= 1`. Hazlo en las dos precisiones y comprueba con `epsilon`.

## Arrays

**4. La matriz de Hilbert.** Pide `n` por teclado y construye con `allocate` la matriz
`H(i, j) = 1/(i + j - 1)`. Calcula su traza, la suma de cada columna y el producto con un vector
de unos. Después, vuelve a reservarla con el doble de tamaño.

**5. La regla del trapecio.** Calcula la integral de `sin(x)` entre `0` y `π` con `n + 1` puntos,
sin bucles: usa cortes y `sum`. Prueba con `n = 10, 20, 40, ..., 1280`.

**6. Derivar con cortes.** Dado `f(0:n)` con los valores de `sin(x)`, calcula la derivada con
diferencias centradas en una sola línea con cortes. Escribe en un archivo `x`, la derivada
aproximada y el error.

## Figuras

**7. El orden del trapecio.** Modifica el ejercicio 5 para que escriba `h` y el error en un
archivo, y dibújalos con `loglog`. ¿Qué pendiente sale? ¿Es la que esperabas?

**8. Tu propia figura.** Elige un archivo de datos de tu investigación (o genera uno con
Fortran) y prepara una figura de dos paneles para un artículo: con los ejes nombrados, con
leyenda y guardada en PDF.

## Euler

**9. El oscilador armónico.** Con `mu = 0` las órbitas de Van der Pol son circunferencias y
`E = x² + y²` es constante. Dibuja `E(t)` con Euler explícito y con Euler implícito. ¿Qué le pasa
a cada uno? Haz la cuenta a mano: ¿por qué número queda multiplicada `E` en un paso?

**10. El mapa de estabilidad.** Haz que `euler_explicito.f90` recorra una lista de valores de `h`
con un bucle y, para cada uno, escriba en un archivo la amplitud de la órbita en la segunda
mitad de la simulación (o `NaN` si ha explotado). Dibuja la amplitud frente a `h`. Después, haz
lo mismo con el implícito y compara. Te vendrá bien meter el cálculo en una subrutina.

**11. Otro sistema.** Pasa los dos programas a las ecuaciones de depredador–presa de
Lotka–Volterra,

```
x' =  x (1 - y)
y' = -y (1 - x)
```

cuyas órbitas son cerradas alrededor de `(1, 1)`. Para el implícito tendrás que calcular el
jacobiano. Dibuja las órbitas. ¿Qué hace cada método con ellas?

**12. Euler semiimplícito.** Actualiza primero `x` con el `y` viejo, y después `y` con el `x`
nuevo:

```
x_{k+1} = x_k + h y_k
y_{k+1} = y_k - h x_{k+1}
```

Pruébalo con el oscilador armónico (`mu = 0`) y `h = 0.1`, y compara `E(t)` con el ejercicio 9.
Sigue siendo de orden 1, pero algo en él es distinto. ¿Qué?

## Para ir abriendo boca

**13. Tu primer método de orden 2.** Programa el método de Heun como una subrutina:

```
k1 = F(u)
k2 = F(u + h k1)
u_nuevo = u + h (k1 + k2) / 2
```

Compara su amplitud con la de Euler explícito para `h = 0.1` y `h = 0.3`, y mide su orden
integrando hasta `t = 1` con varios `h`. Después piensa: si quisieras probar diez métodos, ¿te
gustaría escribir diez subrutinas distintas? Mira cómo lo resolvemos en la unidad 09.
