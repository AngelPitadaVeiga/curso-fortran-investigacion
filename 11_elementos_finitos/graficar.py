# Dibuja una solución de fem: la curva en varios instantes, y el mapa de x y t.
#
#     python graficar.py resultados/calor.dat
#     python graficar.py resultados/fisher.dat
import sys
import numpy as np
import matplotlib.pyplot as plt

archivo = sys.argv[1] if len(sys.argv) > 1 else "resultados/calor.dat"

# La primera línea es un comentario con los tiempos de las columnas 2, 3, ...
tiempos = np.array(open(archivo).readline().split(":")[1].split(), dtype=float)
x, *columnas = np.loadtxt(archivo, unpack=True)
u = np.array(columnas)          # u[i] es la solución en tiempos[i]

fig, (izquierda, derecha) = plt.subplots(1, 2, figsize=(12, 5))

colores = plt.cm.viridis(np.linspace(0, 1, len(tiempos)))
for t, ui, color in zip(tiempos, u, colores):
    izquierda.plot(x, ui, color=color, label=f"t = {t:.3g}")
izquierda.set_xlabel("x")
izquierda.set_ylabel("u")
izquierda.legend(fontsize=8, ncol=2)

mapa = derecha.pcolormesh(x, tiempos, u, shading="nearest", cmap="viridis")
derecha.set_xlabel("x")
derecha.set_ylabel("t")
fig.colorbar(mapa, ax=derecha, label="u")

fig.tight_layout()
salida = archivo.removesuffix(".dat") + ".png"
fig.savefig(salida, dpi=150)
print("Figura escrita en " + salida)
plt.show()
