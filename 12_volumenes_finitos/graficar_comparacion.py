# Compara los dos esquemas con la solución exacta.
# Antes hay que ejecutar  make run  y  make run-primer-orden.
#
#     python graficar_comparacion.py
#
# Izquierda: densidad a lo largo de la recta y = 5, que pasa por el centro del vórtice.
# Derecha: densidad mínima en función del tiempo; la exacta es constante.
import numpy as np
import matplotlib.pyplot as plt

colores = {"primer_orden": "#eb6834", "muscl": "#2a78d6"}

fig, (corte, historia) = plt.subplots(1, 2, figsize=(12, 4.5))

for nombre, color in colores.items():
    x, y, rho, u, v, p, rho_exacta = np.loadtxt(f"resultados/{nombre}_campo.dat", unpack=True)
    n = int(round(np.sqrt(len(x))))
    fila = n // 2                                   # la fila de celdas con y justo por encima de 5
    x, rho, rho_exacta = (a.reshape(n, n)[fila] for a in (x, rho, rho_exacta))
    corte.plot(x, rho, color=color, lw=2, label=nombre)

    t, rho_min = np.loadtxt(f"resultados/{nombre}_historia.dat", usecols=(0, 1), unpack=True)
    historia.plot(t, rho_min, color=color, lw=2, label=nombre)

corte.plot(x, rho_exacta, color="black", ls="--", lw=1.5, label="exacta")
corte.set_xlabel("x")
corte.set_ylabel("densidad en y = 5")
corte.legend()

rho_centro = rho_exacta.min()
historia.axhline(rho_centro, color="black", ls="--", lw=1.5, label="exacta")
historia.set_xlabel("t")
historia.set_ylabel("densidad minima")
historia.legend()

fig.tight_layout()
fig.savefig("resultados/comparacion.png", dpi=150)
print("Figura escrita en resultados/comparacion.png")
plt.show()
