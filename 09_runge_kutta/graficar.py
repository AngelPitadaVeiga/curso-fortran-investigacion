# Dibuja una solución (columnas t, x, y): x(t) y el plano de fases.
#
#     python graficar.py                           (dibuja resultados/rk.dat)
#     python graficar.py resultados/otro.dat       (dibuja otro.dat y guarda otro.png)
import sys
import numpy as np
import matplotlib.pyplot as plt

archivo = sys.argv[1] if len(sys.argv) > 1 else "resultados/rk.dat"
t, x, y = np.loadtxt(archivo, unpack=True)

fig, (izquierda, derecha) = plt.subplots(1, 2, figsize=(12, 5))

izquierda.plot(t, x, color="#2a78d6", lw=1.5)
izquierda.set_xlabel("t")
izquierda.set_ylabel("x")

derecha.plot(x, y, color="#2a78d6", lw=1.5)
derecha.set_xlabel("x")
derecha.set_ylabel("y")
derecha.set_aspect("equal")

salida = archivo.removesuffix(".dat") + ".png"
fig.tight_layout()
fig.savefig(salida, dpi=150)
print("Figura escrita en " + salida)
plt.show()
