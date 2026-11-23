# Error de los elementos finitos frente al tamaño de la malla, en escala logarítmica.
# Antes hay que ejecutar  make run-orden.
#
#     python graficar_orden.py
import numpy as np
import matplotlib.pyplot as plt

casillas, error = np.loadtxt("resultados/orden.dat", unpack=True)
h = 1 / casillas

fig, ax = plt.subplots(figsize=(6, 4.5))
ax.loglog(h, error, "o-", color="#2a78d6", lw=2, label="error maximo en los nodos")
ax.loglog(h, error[0] * (h / h[0])**2, color="#a3a29c", ls="--", label="pendiente 2")
ax.set_xlabel("h (lado de una casilla)")
ax.set_ylabel("error")
ax.legend()
fig.tight_layout()
fig.savefig("resultados/orden.png", dpi=150)
print("Figura escrita en resultados/orden.png")
plt.show()
