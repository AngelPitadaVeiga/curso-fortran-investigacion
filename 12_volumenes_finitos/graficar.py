# Densidad y vorticidad del vórtice al final de la simulación.
# Antes hay que ejecutar  make run  (o make run-primer-orden).
#
#     python graficar.py                   (usa resultados/muscl_campo.dat)
#     python graficar.py primer_orden
#
# Escribe resultados/<nombre>_campo.png.
import sys
import numpy as np
import matplotlib.pyplot as plt

nombre = sys.argv[1] if len(sys.argv) > 1 else "muscl"
x, y, rho, u, v, p, rho_exacta = np.loadtxt(f"resultados/{nombre}_campo.dat", unpack=True)

# El archivo recorre la malla fila a fila (x varía más deprisa): se reordena en matrices n x n.
n = int(round(np.sqrt(len(x))))
x, y, rho, u, v = (a.reshape(n, n) for a in (x, y, rho, u, v))
dx = x[0, 1] - x[0, 0]

# Vorticidad: dv/dx - du/dy, con diferencias centradas (np.gradient).
vorticidad = np.gradient(v, dx, axis=1) - np.gradient(u, dx, axis=0)

fig, (izquierda, derecha) = plt.subplots(1, 2, figsize=(12, 5.2))

# Escalas de color fijas, las de la solución exacta, para comparar figuras de distintos esquemas.
mapa = izquierda.pcolormesh(x, y, rho, cmap="viridis", shading="nearest", vmin=0.49, vmax=1)
fig.colorbar(mapa, ax=izquierda, label="densidad")
c = 4                                    # una flecha de cada c celdas
izquierda.quiver(x[::c, ::c], y[::c, ::c], u[::c, ::c] - 1, v[::c, ::c] - 1,
                 color="white", scale=12)
izquierda.set_title("Densidad y velocidad (u - 1, v - 1)")

mapa = derecha.pcolormesh(x, y, vorticidad, cmap="RdBu_r", shading="nearest", vmin=-2.7, vmax=2.7)
fig.colorbar(mapa, ax=derecha, label="vorticidad")
derecha.set_title("Vorticidad")

for ax in (izquierda, derecha):
    ax.set_aspect("equal")
    ax.set_xlabel("x")
    ax.set_ylabel("y")
fig.suptitle(f"Esquema {nombre}, {n} x {n} celdas")
fig.tight_layout()
fig.savefig(f"resultados/{nombre}_campo.png", dpi=150)
print(f"Figura escrita en resultados/{nombre}_campo.png")
plt.show()
