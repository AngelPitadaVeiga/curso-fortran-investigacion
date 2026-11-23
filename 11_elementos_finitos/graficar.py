# Dibuja la malla, la pieza deformada y la tensión de von Mises.
# Antes hay que ejecutar  make run  (o ./solido viga.nml).
#
#     python graficar.py
#
# Escribe resultados/deformada.png y resultados/von_mises.png.
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.tri as mtri

x, y, ux, uy = np.loadtxt("resultados/nodos.dat", unpack=True)
tri = np.loadtxt("resultados/triangulos.dat", dtype=int) - 1     # en Fortran empiezan en 1
vm = np.loadtxt("resultados/tension.dat")
malla = mtri.Triangulation(x, y, tri)

# La deformación se exagera hasta que el mayor desplazamiento sea un 8 % del tamaño.
tamano = max(x.max() - x.min(), y.max() - y.min())
escala = 0.08 * tamano / np.hypot(ux, uy).max()

# Figura 1: la malla y la pieza deformada, coloreada por von Mises.
fig, (arriba, abajo) = plt.subplots(2, 1, figsize=(10, 8.5))
arriba.triplot(malla, color="#2a78d6", lw=0.4)
arriba.set_title(f"Malla: {len(x)} nodos, {len(tri)} triangulos")

deformada = mtri.Triangulation(x + escala * ux, y + escala * uy, tri)
abajo.triplot(malla, color="#d8d7d2", lw=0.3)
mapa = abajo.tripcolor(deformada, facecolors=vm, cmap="viridis")
abajo.set_title(f"Deformada (desplazamientos x{escala:.0f}), coloreada por von Mises; gris: sin deformar")
fig.colorbar(mapa, ax=abajo, label="von Mises", shrink=0.8)
for ax in (arriba, abajo):
    ax.set_aspect("equal")
fig.tight_layout()
fig.savefig("resultados/deformada.png", dpi=150)

# Figura 2: von Mises sobre la pieza sin deformar. Para que el dibujo sea continuo, el
# valor de cada nodo es la media de los triángulos que lo tocan.
suma = np.zeros(len(x))
cuenta = np.zeros(len(x))
for k in range(3):
    np.add.at(suma, tri[:, k], vm)
    np.add.at(cuenta, tri[:, k], 1)
vm_nodos = suma / cuenta

fig, ax = plt.subplots(figsize=(10, 5))
mapa = ax.tricontourf(malla, vm_nodos, levels=30, cmap="inferno")
ax.tricontour(malla, vm_nodos, levels=10, colors="white", linewidths=0.4, alpha=0.6)
ax.set_title("Tension de von Mises")
ax.set_aspect("equal")
fig.colorbar(mapa, ax=ax, label="von Mises", shrink=0.8)
fig.tight_layout()
fig.savefig("resultados/von_mises.png", dpi=150)

print("Figuras escritas en resultados/deformada.png y resultados/von_mises.png")
plt.show()
