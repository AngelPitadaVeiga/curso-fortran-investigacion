# Van der Pol con mu = 1000 y el mismo paso: los implícitos frente a RK4.
# Antes hay que ejecutar  make run-rigido.
#
#     python graficar_rigido.py
import numpy as np
import matplotlib.pyplot as plt

t_i, x_i, _ = np.loadtxt("resultados/rigido_euler_implicito.dat", unpack=True)
t_t, x_t, _ = np.loadtxt("resultados/rigido_trapecio.dat", unpack=True)
t_r, x_r, _ = np.loadtxt("resultados/rigido_rk4.dat", unpack=True)

fig, (izquierda, derecha) = plt.subplots(1, 2, figsize=(13, 5))
fig.suptitle("Van der Pol rigido (mu = 1000), mismo paso h = 0.002")

izquierda.plot(t_i, x_i, color="#1baf7a", lw=2, label="Euler implicito")
izquierda.plot(t_t, x_t, color="#6250d6", lw=2, ls="--", label="trapecio")
izquierda.legend()
izquierda.set_title("Metodos implicitos: integran sin problemas")
izquierda.set_xlabel("t")
izquierda.set_ylabel("x(t)")

# RK4 acaba en Inf o NaN: solo se dibujan los valores finitos.
validos = np.isfinite(x_r) & (x_r != 0)
derecha.semilogy(t_r[validos], np.abs(x_r[validos]), "o-", color="#e34948", lw=2, ms=6)
derecha.set_title("RK4: la solucion explota")
derecha.set_xlabel("t")
derecha.set_ylabel("|x(t)|")

fig.tight_layout()
fig.savefig("resultados/rigido.png", dpi=150)
print("Figura escrita en resultados/rigido.png")
plt.show()
