# Retrato de fases: campo de direcciones, trayectorias, nulclinas y ciclo límite.
# Antes hay que ejecutar  make run.
#
#     python graficar.py
import numpy as np
import matplotlib.pyplot as plt

mu, x_max, y_max, n_trayectorias = np.loadtxt("resultados/parametros.dat")

campo = np.loadtxt("resultados/campo.dat")
ciclo = np.loadtxt("resultados/ciclo.dat")

# Las trayectorias van seguidas y todas tienen los mismos puntos:
# reshape las separa en (trayectoria, punto, x o y).
trayectorias = np.loadtxt("resultados/trayectorias.dat").reshape(int(n_trayectorias), -1, 2)

fig, ax = plt.subplots(figsize=(8, 7))
ax.quiver(campo[:, 0], campo[:, 1], campo[:, 2], campo[:, 3],
          angles="xy", scale_units="xy", scale=1, color="#a3a29c", width=0.0018)
ax.plot(trayectorias[:, :, 0].T, trayectorias[:, :, 1].T, color="#2a78d6", lw=0.5, alpha=0.6)

# Nulclinas: x' = 0 es y = 0, e y' = 0 es y = -x / (mu (x^2 - 1)).
# Cerca de x = 1 y x = -1 se dispara, y esa parte no se dibuja.
ax.axhline(0, color="#eda100", ls="--", lw=2, label="x' = 0")
x = np.linspace(-x_max, x_max, 2000)
y = -x / (mu * (x**2 - 1))
y[np.abs(y) > 2 * y_max] = np.nan
ax.plot(x, y, color="#1baf7a", ls="--", lw=2, label="y' = 0")

ax.plot(ciclo[:, 0], ciclo[:, 1], color="#e34948", lw=3, label="ciclo limite")

ax.set_xlim(-x_max, x_max)
ax.set_ylim(-y_max, y_max)
ax.set_xlabel("x")
ax.set_ylabel("y")
ax.set_title(f"Van der Pol, mu = {mu:g}")
ax.legend(loc="lower right")

fig.tight_layout()
fig.savefig("resultados/retrato.png", dpi=150)
print("Figura escrita en resultados/retrato.png")
plt.show()
