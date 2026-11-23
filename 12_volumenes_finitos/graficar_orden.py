# Error de los dos esquemas frente al tamaño de las celdas, en escala logarítmica.
# Antes hay que ejecutar  make run-orden.
#
#     python graficar_orden.py
import numpy as np
import matplotlib.pyplot as plt

celdas, error_1, error_2 = np.loadtxt("resultados/orden.dat", unpack=True)
h = 10 / celdas

fig, ax = plt.subplots(figsize=(6, 4.5))
ax.loglog(h, error_1, "o-", color="#eb6834", lw=2, label="primer_orden")
ax.loglog(h, error_2, "o-", color="#2a78d6", lw=2, label="muscl")
ax.loglog(h, error_1[-1] * (h / h[-1]), color="#a3a29c", ls=":", label="pendiente 1")
ax.loglog(h, error_2[-1] * (h / h[-1])**2, color="#a3a29c", ls="--", label="pendiente 2")
ax.set_xlabel("h (lado de una celda)")
ax.set_ylabel("error de la densidad (L1)")
ax.legend()
fig.tight_layout()
fig.savefig("resultados/orden.png", dpi=150)
print("Figura escrita en resultados/orden.png")
plt.show()
