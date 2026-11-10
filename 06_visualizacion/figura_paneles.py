# Una figura con tres paneles. Antes hay que ejecutar ./espiral.
#
#     python figura_paneles.py
import numpy as np
import matplotlib.pyplot as plt

t, x, y = np.loadtxt("espiral.dat", unpack=True)

fig, (izquierda, centro, derecha) = plt.subplots(1, 3, figsize=(12, 4))

izquierda.plot(t, x)
izquierda.set_xlabel("t")
izquierda.set_ylabel("x")
izquierda.set_title("x(t)")

centro.plot(x, y)
centro.set_xlabel("x")
centro.set_ylabel("y")
centro.set_title("Plano de fases")
centro.set_aspect("equal")      # la misma escala en los dos ejes

derecha.semilogy(t, np.sqrt(x**2 + y**2))       # eje y logarítmico
derecha.set_xlabel("t")
derecha.set_title("Distancia al origen")

fig.tight_layout()
fig.savefig("espiral.png", dpi=150)
print("Figura escrita en espiral.png")
plt.show()
