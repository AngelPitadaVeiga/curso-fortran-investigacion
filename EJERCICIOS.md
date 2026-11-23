# Ejercicios

Están agrupados por temas, en el mismo orden que las unidades, y cada grupo usa solo lo visto hasta
la unidad correspondiente. No hace falta resolverlos todos ni en orden. Los marcados con (*) son más
largos o piden algo que el curso no explica del todo.

## Precisión y bucles (unidades 02 y 03)

**1. Razón áurea.** La iteración `x_{k+1} = 1 + 1/x_k` converge a `(1 + √5)/2`. Imprime el error en
cada paso, detén el bucle con un criterio de parada y compara la columna del error con la del método
de Herón.

**2. Simple y doble precisión.** Suma `1 - 1/2 + 1/3 - 1/4 + ...` con `n = 10⁷` términos, que tiende a
`log(2)`, con `real` y con `double precision`, y compara los errores. En simple precisión, comprueba
si cambia el resultado al sumar de atrás hacia delante y propón una explicación.

**3. Épsilon de la máquina.** Sin usar `epsilon`, busca con un bucle el menor `e = 2^(-k)` tal que
`1 + e /= 1`, en las dos precisiones, y compara con `epsilon`.

**4. Factoriales.** Imprime una tabla con `n` y `n!` para `n = 1, ..., 25`, calculando el factorial
con un `integer` y con un `double precision`. Busca a partir de qué `n` el entero da resultados
absurdos y explica por qué. Usa `huge` para saber cuál es el mayor entero, y elige un formato para
cada columna (ver [FORMATOS.md](FORMATOS.md)).

**5. Bisección.** Resuelve `cos(x) = x` en `[0, 1]` por bisección, con un criterio de parada sobre
la longitud del intervalo. Cuenta las iteraciones y compáralas con las que necesitaría el método de
Newton, que es el de Herón aplicado a otra función.

## Arrays y archivos (unidad 04)

**6. Matriz de Hilbert.** Pide `n` por teclado y construye con `allocate` la matriz
`H(i, j) = 1/(i + j - 1)`. Calcula su traza, la suma de cada columna y su producto por un vector de
unos. Después reserva de nuevo la matriz con el doble de tamaño.

**7. Regla del trapecio.** Calcula la integral de `sin(x)` entre `0` y `π` con `n + 1` puntos, sin
bucles (cortes y `sum`), para `n = 10, 20, 40, ..., 1280`.

**8. Derivada con cortes.** A partir de `f(0:n)` con los valores de `sin(x)`, calcula la derivada con
diferencias centradas en una línea de cortes. Escribe en un archivo `x`, la derivada y el error.

**9. Bucles y `matmul`.** Multiplica dos matrices aleatorias de `n × n` (`random_number`) con tres
bucles anidados y con `matmul`, y mide el tiempo con `cpu_time` para `n = 200, 400, 800`. Prueba
después a intercambiar el orden de los bucles: con el índice de la fila en el bucle interior, el
acceso a memoria va por columnas.

**10. Leer un archivo.** Lee `tabla.dat` (unidad 04) sin saber cuántas filas tiene: salta la línea de
cabecera y lee hasta que `read` devuelva un `iostat` distinto de cero. Imprime el número de filas y
el máximo de cada columna.

## Figuras (unidad 06)

**11. Orden del trapecio.** Modifica el ejercicio 7 para escribir `h` y el error en un archivo,
dibújalos con `loglog` y mide la pendiente.

**12. Una figura propia.** Con datos de tu investigación (o generados con Fortran), prepara una
figura de dos paneles para un artículo: ejes con nombre, leyenda y salida en PDF.

**13. Histograma.** Genera `10⁶` números, cada uno como la suma de doce valores de `random_number`
menos 6, y escríbelos en un archivo. Dibuja el histograma en Python y superpón la densidad de la normal estándar.

## Euler (unidad 05)

**14. Oscilador armónico.** Con `mu = 0` las órbitas son circunferencias y `E = x² + y²` es
constante. Reduce `t_final` a 50 y dibuja `E(t)` con Euler explícito y con Euler implícito. Calcula
con lápiz y papel el factor por el que se multiplica `E` en un paso y compáralo con lo que dibujas.

**15. Periodo y paso.** Mide el periodo del ciclo límite de Van der Pol con Euler explícito para
`h = 0.1, 0.05, 0.025` y `0.0125`, a partir de los cruces de `x` por cero (en Python, con `numpy`).
Compara con el periodo de la referencia y comprueba si la diferencia se divide por dos cuando `h` se
divide por dos.

**16. Otro sistema.** Adapta los dos programas a Lotka–Volterra,

```
x' =  x (1 - y)
y' = -y (1 - x)
```

cuyas órbitas son cerradas alrededor de `(1, 1)`. El implícito necesita el jacobiano. Dibuja las
órbitas de cada método y describe lo que les ocurre.

**17. Euler semiimplícito.** Actualiza `x` con el `y` antiguo, y después `y` con el `x` nuevo:

```
x_{k+1} = x_k + h y_k
y_{k+1} = y_k - h x_{k+1}
```

Aplícalo al oscilador armónico (`mu = 0`) con `h = 0.1` y compara `E(t)` con el ejercicio 14. Sigue
siendo de orden 1, pero su comportamiento es distinto: describe en qué.

**18. Método de Heun.** Programa Heun como subrutina:

```
k1 = F(u)
k2 = F(u + h k1)
u_nuevo = u + h (k1 + k2) / 2
```

Compara su amplitud con la de Euler explícito para `h = 0.1` y `h = 0.3`, y mide su orden integrando
hasta `t = 1` con varios `h`.

## Archivos de entrada (unidad 07)

**19. Varias simulaciones.** Prepara tres archivos `.nml` con `h = 0.1, 0.01` y `0.001`, cada uno con
su archivo de salida, y lánzalos uno detrás de otro desde la terminal sin recompilar. Dibuja las tres
soluciones en una sola figura.

**20. Un parámetro más.** Añade al namelist un entero `cada`, de modo que el programa solo escriba
una de cada `cada` filas. Comprueba que un archivo de entrada antiguo, sin `cada`, sigue funcionando.

**21. Errores del usuario.** Prueba qué ocurre si el `.nml` tiene un nombre de variable mal escrito,
si falta la `/` final o si `h` es negativo. Añade al programa las comprobaciones necesarias para que
termine con un mensaje claro en cada caso (`iostat` en el `read` y un `if` para `h`).

## Módulos y make (unidad 08)

**22. Lotka–Volterra en módulos.** Pasa el ejercicio 16 a la estructura de la unidad 08: un módulo con
el modelo, otro con el integrador y un programa principal. Escribe su `Makefile` y comprueba que, al
cambiar solo el modelo, `make` recompila lo que depende de él y nada más.

**23. Un objetivo más en el Makefile.** Añade un objetivo `make figura` que ejecute el programa si
hace falta y después `python graficar.py`.

**24. Lo privado.** En `modelo.f90`, quita `campo` de la lista `public` y compila. Lee el error. Después
declara una variable en el módulo, primero pública y luego privada, y comprueba en cada caso si el
programa principal puede leerla y modificarla.

## Runge–Kutta (unidad 09)

**25. Un método de orden 3.** Añade a `runge_kutta.f90` el método de Kutta de orden 3:

```
k1 = F(u)
k2 = F(u + h k1 / 2)
k3 = F(u - h k1 + 2 h k2)
u_nuevo = u + h (k1 + 4 k2 + k3) / 6
```

Inclúyelo en `orden.f90` y comprueba que el orden observado es 3.

**26. Coste y precisión.** Para cada método explícito, cuenta cuántas veces se evalúa `campo` hasta
`t = 10` y dibuja el error final frente a ese número, en escala logarítmica. ¿A partir de qué
precisión compensa RK4 frente a Heun?

**27. Paso máximo de RK4.** Con `mu = 10, 30, 100` y `300`, busca por tanteo el mayor `h` con el que
RK4 no explota. Dibuja ese `h` frente a `mu` y compara con lo que se ve en `rigido_rk4.nml`.

**28. (\*) Paso adaptativo.** Usa Heun y Euler a la vez: la diferencia entre ambos estima el error
del paso. Si es mayor que una tolerancia, repite el paso con `h/2`; si es mucho menor, duplica `h`
en el siguiente. Cuenta los pasos que necesita para `mu = 5` y dibuja `h` frente a `t`.

## Retrato de fases (unidad 10)

**29. Periodo y amplitud frente a `mu`.** Para `mu` entre `0.1` y `10`, mide en el ciclo límite el
periodo y el máximo de `x`. Dibuja las dos curvas y compara el periodo para `mu` grande con la
aproximación `(3 - 2 log 2) mu`.

**30. Otro retrato.** En una copia de la carpeta, cambia `modelo.f90` por el péndulo amortiguado,
`x' = y`, `y' = -sin(x) - mu y`, y dibuja su retrato de fases en `[-2π, 2π] × [-3, 3]`. Identifica
los puntos de equilibrio estables e inestables.

## Elementos finitos (unidad 11)

El [README de la unidad](11_elementos_finitos/README.md) tiene cuatro ejercicios más.

**31. Tiempo de cálculo.** Genera la ménsula con triángulos de lado 0.3, 0.2 y 0.15
(`python generar_malla.py mensula 0.2`) y mide cuánto tarda `make run` con cada una. ¿Por cuánto se
multiplica el tiempo cuando se duplica el número de nodos?

**32. Periodo de vibración.** En la figura de `graficar_vibracion.py`, mide el periodo de la flecha y
comprueba si cambia al refinar la malla.

**33. Más carga.** Multiplica `carga` por 10 en `estatico.nml`. Comprueba que la flecha y la tensión
de von Mises también se multiplican por 10, como corresponde a un problema lineal.

## Volúmenes finitos (unidad 12)

El [README de la unidad](12_volumenes_finitos/README.md) tiene tres ejercicios más.

**34. Ejecutar.** Compila con `make` y ejecuta `make run` y `make run-primer-orden`. Localiza los
archivos que se han creado en `resultados/` y lee sus primeras líneas para saber qué contiene cada
columna.

**35. La densidad.** Escribe un script de Python que lea `resultados/muscl_campo.dat`, reorganice la
densidad en una matriz de `n × n` (`reshape`) y la dibuje con `pcolormesh` y una barra de colores.
Añade las curvas de nivel de la densidad exacta con `contour`.

**36. Vorticidad.** Calcula la vorticidad `v_x - u_y` con `np.gradient` y dibújala. Compara su
máximo con el exacto, `beta e^(1/2) / π`, en los dos esquemas.

**37. Película del vórtice.** Añade `dt_escritura = 0.1` a `vortice.nml`, ejecuta `make run` y
haz la película con `python pelicula.py muscl`. Comprueba que el vórtice recorre la diagonal del
cuadrado y vuelve a su sitio en `t = 10`. Haz lo mismo con el esquema de primer orden.

**38. Error frente al tiempo.** La tercera columna de `resultados/*_historia.dat` es el error de la
densidad. Dibújala frente al tiempo para los dos esquemas, en escala logarítmica en el eje vertical, y
compara con la densidad mínima de `graficar_comparacion.py`.

**39. Kelvin–Helmholtz.** Pon `n = 100` en `kelvin_helmholtz.nml`, ejecuta `make run-kh` y haz las
películas de la densidad y de la vorticidad (`python pelicula.py kh vorticidad`). Repite con `n = 200`
y compara: ¿qué detalles aparecen al refinar la malla?

**40. Crecimiento de la inestabilidad.** La cuarta columna de `resultados/kh_historia.dat` es la
energía cinética del movimiento vertical. Dibújala frente al tiempo en escala logarítmica. Al
principio crece como una exponencial: mide su ritmo de crecimiento con la pendiente, y localiza el
instante en que deja de crecer.
