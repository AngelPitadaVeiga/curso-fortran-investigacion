# Unidad 06 · Visualización

Fortran calcula muy bien y no sabe dibujar. No pasa nada, porque el reparto del trabajo
es sencillo: el programa de Fortran escribe un archivo de datos, y un script corto de Python lo
convierte en una figura. Usaremos matplotlib.

Hay otra herramienta muy usada con Fortran, gnuplot, y la verás en bastantes códigos antiguos.
Funciona, pero es engorrosa, y su lenguaje no sirve para nada más. Con Python, además, puedes
seguir analizando los datos en el mismo script, y es lo que ya conocen la mayoría de las
personas que programan.

Necesitas `numpy` y `matplotlib`. Si no los instalaste en la [unidad 01](../01_instalacion/),
escribe en la terminal:

```bash
pip install numpy
pip install matplotlib
```

## La figura más sencilla

Primero genera `tabla.dat` con la unidad 04 (`./tabla` dentro de esa carpeta). Después:

```bash
python figura_simple.py
```

```python
import numpy as np
import matplotlib.pyplot as plt

x, seno, coseno = np.loadtxt("../04_arrays_y_archivos/tabla.dat", unpack=True)

plt.plot(x, seno, label="sin(x)")
plt.plot(x, coseno, label="cos(x)")
plt.xlabel("x")
plt.legend()

plt.savefig("tabla.png", dpi=150)
plt.show()
```

`np.loadtxt` lee las columnas y se salta las líneas que empiezan por `#`; con `unpack=True`
cada columna va a una variable. `savefig` guarda la figura y `show` abre una ventana para
verla (el programa termina cuando la cierras).

![tabla](figuras/tabla.png)

## Varios paneles

La mayoría de las figuras tendrán más de un panel. `espiral.f90` escribe una espiral con las
columnas `t x y`, y `figura_paneles.py` la dibuja de tres maneras:

```bash
gfortran espiral.f90 -o espiral
./espiral
python figura_paneles.py
```

```python
fig, (izquierda, centro, derecha) = plt.subplots(1, 3, figsize=(12, 4))

izquierda.plot(t, x)
centro.plot(x, y)
centro.set_aspect("equal")
derecha.semilogy(t, np.sqrt(x**2 + y**2))
```

![espiral](figuras/espiral.png)

Fíjate en el tercer panel: es una recta, porque un decaimiento exponencial se ve recto en
escala logarítmica. Cuando midamos órdenes de convergencia, esa recta será lo que busquemos.

Con esto tienes casi todo lo que necesitas:

| Quiero... | Con un panel `ax` |
|---|---|
| una curva | `ax.plot(x, y)` |
| un eje logarítmico | `ax.semilogy(x, y)`, y `ax.loglog(x, y)` para los dos |
| nombres de los ejes | `ax.set_xlabel("x")`, `ax.set_ylabel("y")` |
| limitar los ejes | `ax.set_xlim(-3, 3)` |
| la misma escala en los dos ejes | `ax.set_aspect("equal")` |
| una leyenda | `ax.plot(x, y, label="...")` y `ax.legend()` |
| elegir el aspecto | `ax.plot(x, y, color="red", lw=2, ls="--")` |

## Los dos Euler

Ahora sí. Con los datos de la unidad 05 ya generados, dibujamos los dos métodos juntos:

```bash
python euler.py
```

Con `h = 0.01` los dos están casi encima del ciclo límite. Pero Euler es un método de orden 1 y
no perdona. Cambia `h` en los dos programas de la unidad 05, recompila, ejecuta y vuelve a
dibujar. Esto es lo que sale con `mu = 1`, donde la órbita gris es el ciclo límite de verdad:

![Estabilidad](figuras/estabilidad.png)

| `h` | Euler explícito | Euler implícito |
|---:|---|---|
| 0,01 | amplitud 2,03 | amplitud 1,99 |
| 0,3 | amplitud 2,83, con zigzags | amplitud 1,51 |
| 0,4 | explota en `t = 9,6` | amplitud 1,36 |

La amplitud es el máximo de `|x|` una vez pasado el transitorio, y la del ciclo real es 2,01.

Euler explícito le añade energía a la órbita en cada paso, y con un paso grande la órbita se
hincha, empieza a zigzaguear y acaba explotando. Euler implícito hace lo contrario: la órbita se
encoge. No explota, pero tampoco acierta. Con `mu = 0.1` y `h = 0.2` hasta hace desaparecer el
ciclo, y la solución cae al origen.

Ninguno de los dos es fiable con pasos grandes, y bajar `h` sale caro. Lo que queremos es un
método de orden más alto, y eso lo haremos con Runge–Kutta en la unidad 09: RK4 con `h = 0.4`
mantiene el ciclo con amplitud 2,00, justo donde Euler explícito explota.

## Ejercicios

1. Añade a `figura_simple.py` una tercera curva, `sin(x) * cos(x)`. No hace falta tocar el
   programa de Fortran: se calcula en Python.
2. Haz que `figura_paneles.py` guarde también un PDF.
3. Cambia el `-t/10` de `espiral.f90` por `-t/30`, recompila y dibuja otra vez. ¿Cómo cambia la
   pendiente del tercer panel?
4. En `euler.py`, dibuja el error de cada método respecto a una solución de referencia
   (Euler explícito con `h = 0.0001`, por ejemplo).
