# Dibuja la viga deformada, coloreada por la tensión de von Mises.
# Antes hay que ejecutar  make run.
#
#     python graficar.py
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.tri as mtri

x, y, ux, uy = np.loadtxt("resultados/nodos.dat", unpack=True)
tri = np.loadtxt("resultados/triangulos.dat", dtype=int) - 1     # en Fortran empiezan en 1
vm = np.loadtxt("resultados/tension.dat")

escala = 5      # la deformacion se exagera para que se vea

fig, (arriba, abajo) = plt.subplots(2, 1, figsize=(12, 5), sharex=True)

arriba.triplot(mtri.Triangulation(x, y, tri), color="#a3a29c", lw=0.4)
arriba.set_title("Malla sin deformar")
arriba.set_aspect("equal")

malla = mtri.Triangulation(x + escala * ux, y + escala * uy, tri)
mapa = abajo.tripcolor(malla, facecolors=vm, cmap="viridis")
abajo.triplot(malla, color="white", lw=0.2)
abajo.set_title(f"Deformada (x{escala}), coloreada por la tension de von Mises")
abajo.set_aspect("equal")
fig.colorbar(mapa, ax=abajo, orientation="horizontal", pad=0.15, aspect=40, label="von Mises")

fig.tight_layout()
fig.savefig("resultados/deformada.png", dpi=150)
print("Figura escrita en resultados/deformada.png")
plt.show()
