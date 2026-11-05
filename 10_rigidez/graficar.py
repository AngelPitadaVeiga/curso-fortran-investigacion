# Rigidez: Van der Pol con mu = 1000 y el mismo paso h, con Radau IIA y con RK4.
# Antes hay que ejecutar  make run.
#
#     python graficar.py
import numpy as np
import matplotlib.pyplot as plt

t_radau, x_radau, _ = np.loadtxt("resultados/radau.dat", unpack=True)
t_rk4, x_rk4, _ = np.loadtxt("resultados/rk4.dat", unpack=True)

fig, (izquierda, derecha) = plt.subplots(1, 2, figsize=(13, 5))
fig.suptitle("Van der Pol rigido (mu = 1000), mismo paso h = 0.002")

izquierda.plot(t_radau, x_radau, color="#1baf7a", lw=2)
izquierda.set_title("Radau IIA (implicito): integra sin problemas")
izquierda.set_xlabel("t")
izquierda.set_ylabel("x(t)")

# RK4 acaba en Inf o NaN: solo se dibujan los valores finitos.
validos = np.isfinite(x_rk4) & (x_rk4 != 0)
derecha.semilogy(t_rk4[validos], np.abs(x_rk4[validos]), "o-", color="#e34948", lw=2, ms=6)
derecha.set_title("RK4 (explicito): la solucion explota")
derecha.set_xlabel("t")
derecha.set_ylabel("|x(t)|")

fig.tight_layout()
fig.savefig("resultados/rigidez.png", dpi=150)
print("Figura escrita en resultados/rigidez.png")
