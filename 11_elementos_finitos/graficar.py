# Dibuja la viga deformada y la tensión de von Mises.
# Antes hay que ejecutar  make run.
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

lx, ly = x.max(), y.max()
carga = 1.0e-4                  # la de estatico.nml
escala = 5                      # la deformacion se exagera para que se vea

# Figura 1: la deformada, coloreada por von Mises, sobre el contorno sin deformar.
fig, ax = plt.subplots(figsize=(12, 3.8))
ax.plot([0, lx, lx, 0, 0], [0, 0, ly, ly, 0], color="#a3a29c", ls="--", lw=1)
malla = mtri.Triangulation(x + escala * ux, y + escala * uy, tri)
mapa = ax.tripcolor(malla, facecolors=vm, cmap="viridis")
ax.triplot(malla, color="white", lw=0.2)
ax.set_title(f"Deformada (desplazamientos x{escala}); discontinuo: sin deformar")
ax.set_aspect("equal")
fig.colorbar(mapa, ax=ax, label="von Mises", shrink=0.8)
fig.tight_layout()
fig.savefig("resultados/deformada.png", dpi=150)

# Figura 2: von Mises sobre la viga sin deformar y en la cara superior, frente a la teoría.
# En la teoría de vigas la tensión es sigma = M (y - ly/2) / I, con M = carga (lx - x) e
# I = ly**3 / 12. Se compara en el centro de los triángulos que tocan la cara superior.
xc = x[tri].mean(axis=1)
yc = y[tri].mean(axis=1)
h = ly / len(np.unique(y)[1:])                      # alto de una casilla
arriba = yc > ly - h / 2
orden = np.argsort(xc[arriba])
x_arriba = xc[arriba][orden]
teoria = carga * (lx - x_arriba) * (yc[arriba][orden] - ly / 2) / (ly**3 / 12)

fig, (campo, corte) = plt.subplots(2, 1, figsize=(12, 6.5), height_ratios=[1, 1.4])
mapa = campo.tripcolor(mtri.Triangulation(x, y, tri), facecolors=vm, cmap="viridis")
campo.set_title("Tension de von Mises, sobre la viga sin deformar")
campo.set_aspect("equal")
fig.colorbar(mapa, ax=campo, label="von Mises", shrink=0.8)

corte.plot(x_arriba, vm[arriba][orden], "o", ms=3, color="#2a78d6",
           label="elementos finitos (triangulos de la cara superior)")
corte.plot(x_arriba, teoria, color="#eb6834", lw=1.5, label="teoria de vigas")
corte.set_xlabel("x")
corte.set_ylabel("von Mises")
corte.legend()
fig.tight_layout()
fig.savefig("resultados/von_mises.png", dpi=150)

print("Figuras escritas en resultados/deformada.png y resultados/von_mises.png")
plt.show()
