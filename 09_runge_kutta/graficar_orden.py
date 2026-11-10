# Error frente a h en escala log-log, una curva por método.
# Antes hay que ejecutar  make run-orden.
#
#     python graficar_orden.py
import numpy as np
import matplotlib.pyplot as plt

# La primera línea del archivo es un comentario con los nombres de las columnas.
nombres = open("resultados/orden.dat").readline().split()[2:]
h, *errores = np.loadtxt("resultados/orden.dat", unpack=True)

colores = ["#2a78d6", "#eb6834", "#1baf7a", "#eda100", "#6250d6"]
for error, nombre, color in zip(errores, nombres, colores):
    plt.loglog(h, error, "o-", color=color, lw=2, ms=6, label=nombre)

plt.xlabel("h")
plt.ylabel("error en t = 1")
plt.title("Convergencia (Van der Pol, mu = 1)")
plt.grid(alpha=0.3, which="both")
plt.legend()
plt.tight_layout()
plt.savefig("resultados/orden.png", dpi=150)
print("Figura escrita en resultados/orden.png")
plt.show()
