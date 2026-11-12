# Unidad 06 · Visualización

Fortran calcula bien y no dibuja. El reparto de tareas del curso es el siguiente: el programa de
Fortran escribe un archivo de datos y un script corto de Python lo convierte en una figura. Se usa
matplotlib.

También existe gnuplot, muy usado con Fortran y presente en códigos antiguos. Su lenguaje es
específico de la herramienta y no sirve para otras tareas. Con Python se puede, además, analizar los
datos en el mismo script, y la mayoría de quienes programan ya lo conocen.

Hacen falta `numpy` y `matplotlib`. Si no se instalaron en la [unidad 01](../01_instalacion/), se
instalan desde la terminal:

```bash
pip install numpy
pip install matplotlib
```

## Una figura sencilla

Primero se genera `tabla.dat` con la unidad 04 (`./tabla` dentro de esa carpeta). Después:

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

`np.loadtxt` lee las columnas y omite las líneas que empiezan por `#`. Con `unpack=True`, cada
columna se asigna a una variable. `savefig` guarda la figura y `show` abre una ventana con ella; el
programa termina al cerrarla.

![tabla](figuras/tabla.png)

## Varios paneles

`espiral.f90` escribe una espiral con las columnas `t x y`, y `figura_paneles.py` la dibuja de tres
formas:

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

El tercer panel es una recta porque un decaimiento exponencial es lineal en escala logarítmica.
Esa pendiente se usará en la unidad 09 para medir órdenes de convergencia.

Funciones de matplotlib que se usan en el resto del curso, sobre un panel `ax`:

| Acción | Instrucción |
|---|---|
| dibujar una curva | `ax.plot(x, y)` |
| eje logarítmico | `ax.semilogy(x, y)`; `ax.loglog(x, y)` para los dos ejes |
| nombre de los ejes | `ax.set_xlabel("x")`, `ax.set_ylabel("y")` |
| límites de los ejes | `ax.set_xlim(-3, 3)` |
| misma escala en los dos ejes | `ax.set_aspect("equal")` |
| leyenda | `ax.plot(x, y, label="...")` y `ax.legend()` |
| aspecto de la línea | `ax.plot(x, y, color="red", lw=2, ls="--")` |

## Los dos Euler

Con los tres programas de la unidad 05 ya ejecutados (`euler_explicito`, `euler_implicito` y
`referencia`), `euler.py` los compara:

```bash
python euler.py
```

Además de la figura, imprime esta tabla:

```
             periodo  amplitud  t con |error| > 0.5
referencia    6.6632    2.0086                    -
 explicito    6.7130    2.0278                   21
 implicito    6.6155    1.9897                   24
```

![Euler frente a la referencia](figuras/euler.png)

El panel derecho muestra el plano de fases al final de la simulación. Las dos soluciones de Euler
están sobre una curva cerrada muy próxima a la de referencia: la amplitud del explícito es un 1 %
mayor y la del implícito, un 1 % menor. Ese resultado, tomado solo, parecería aceptable.

El panel izquierdo muestra `x(t)` en los últimos 30 instantes. Las tres curvas tienen la misma forma
y están desfasadas. Euler explícito tiene un periodo de 6,713 frente a 6,663, y el implícito, de
6,616. Cada periodo se acumula una diferencia de unos 0,05 en el instante de cada cruce. El panel
central dibuja esa diferencia como retraso respecto a la referencia, medido en periodos:

- A `t = 3000`, el explícito va 3,34 periodos por detrás, y el implícito, 3,22 por delante.
- Un retraso de medio periodo deja la solución en oposición de fase con la referencia. El explícito
  llega a él en `t ≈ 450`, y el implícito, en `t ≈ 470`.
- El retraso crece linealmente con `t`. El error del periodo es proporcional a `h`, y los errores de
  cada periodo se suman.

## Reducir h solo retrasa el problema

Los mismos programas con `h = 0.001` y `h = 0.0001` (cambiando `h` en el código y recompilando)
dan la figura siguiente. Cada recta es el retraso de un método con un paso, en escala logarítmica, y
la línea gris horizontal marca el medio periodo:

![Retraso de fase con varios h](figuras/tiempos_largos.png)

| `h` | pasos hasta `t = 3000` | `t` con medio periodo de retraso (explícito) | (implícito) |
|---:|---:|---:|---:|
| 0,01 | 3·10⁵ | 451 | 471 |
| 0,001 | 3·10⁶ | 4549 | 4569 |
| 0,0001 | 3·10⁷ | 45 548 | no medido |

Dividir `h` entre diez multiplica por diez el tiempo que tarda en perderse la fase. Para conservar la
fase hasta `t = 3000` con un error de 0,01 periodos haría falta `h ≈ 3·10⁻⁵`, es decir, unos 10⁸ pasos
(esta cifra se obtiene extrapolando la proporcionalidad medida). RK4, en la unidad 09, consigue con
`h = 0.01` un retraso inferior a 0,001 periodos.

El implícito no mejora al explícito en este problema: el retraso tiene el mismo tamaño y signo
contrario. Para el ciclo límite de Van der Pol, Euler es un método inadecuado en tiempos largos,
con cualquiera de sus dos variantes y con cualquier paso.

## Pasos grandes

El mismo experimento con `h` grande, en la unidad 05, da órbitas muy distintas de la de referencia:

![Pasos grandes](figuras/estabilidad.png)

| `h` | Euler explícito | Euler implícito |
|---:|---|---|
| 0,01 | amplitud 2,03 | amplitud 1,99 |
| 0,3 | amplitud 2,86, con trazos en zigzag | amplitud 1,51 |
| 0,4 | la solución explota en `t = 9,6` | amplitud 1,36 |

La amplitud es el máximo de `|x|` a partir de `t = 15`, y la del ciclo real es 2,01. Con `h = 0.4`,
Euler explícito deja de tener solución acotada. Con `mu = 0.1` y `h = 0.2`, Euler implícito hace
desaparecer el ciclo y la solución converge al origen. La unidad 09 resuelve este problema con
métodos de orden mayor: RK4 con `h = 0.4` mantiene el ciclo con amplitud 2,00.

## Ejercicios

1. Añade a `figura_simple.py` una tercera curva, `sin(x) * cos(x)`. Se calcula en Python, sin tocar
   el programa de Fortran.
2. Haz que `figura_paneles.py` guarde también un PDF.
3. En `espiral.f90`, cambia `-t/10` por `-t/30`, recompila y dibuja de nuevo. Describe cómo cambia
   la pendiente del tercer panel.
4. En `euler.py`, calcula el retraso para `h = 0.001`: cambia `h` en los dos programas de la
   unidad 05, recompila, ejecuta y repite el análisis. Comprueba que el retraso final es diez veces
   menor.
