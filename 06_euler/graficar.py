# Dibuja los dos Euler juntos: x(t) y el plano de fases.
# Antes hay que ejecutar ./euler_explicito y ./euler_implicito.
#
#     python graficar.py
import numpy as np
import matplotlib.pyplot as plt

t_e, x_e, y_e = np.loadtxt("euler_explicito.dat", unpack=True)
t_i, x_i, y_i = np.loadtxt("euler_implicito.dat", unpack=True)

fig, (izquierda, derecha) = plt.subplots(1, 2, figsize=(12, 5))

izquierda.plot(t_e, x_e, color="#2a78d6", lw=1.5, label="explicito")
izquierda.plot(t_i, x_i, color="#eb6834", lw=1.5, label="implicito")
izquierda.set_xlabel("t")
izquierda.set_ylabel("x")
izquierda.set_ylim(-5, 5)       # para que se vea algo aunque la solución explote
izquierda.legend()

derecha.plot(x_e, y_e, color="#2a78d6", lw=1.5, label="explicito")
derecha.plot(x_i, y_i, color="#eb6834", lw=1.5, label="implicito")
derecha.set_xlabel("x")
derecha.set_ylabel("y")
derecha.set_xlim(-5, 5)
derecha.set_ylim(-5, 5)
derecha.set_aspect("equal")
derecha.legend()

fig.tight_layout()
fig.savefig("euler.png", dpi=150)
print("Figura escrita en euler.png")
