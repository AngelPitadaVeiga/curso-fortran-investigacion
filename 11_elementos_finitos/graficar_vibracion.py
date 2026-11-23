# La flecha del lado cargado y la energía total, en función del tiempo.
# Antes hay que ejecutar make run-vibracion, run-explicito o run-inestable.
#
#     python graficar_vibracion.py                         (usa resultados/flecha.dat)
#     python graficar_vibracion.py uno.dat otro.dat        varias curvas superpuestas
#
# Escribe la figura junto al primer archivo, con extensión .png.
import sys
import numpy as np
import matplotlib.pyplot as plt

archivos = sys.argv[1:] if len(sys.argv) > 1 else ["resultados/flecha.dat"]
colores = ["#2a78d6", "#eb6834", "#1baf7a"]

fig, (izquierda, derecha) = plt.subplots(1, 2, figsize=(12, 4.5))
for archivo, color in zip(archivos, colores):
    t, flecha, energia = np.loadtxt(archivo, unpack=True)
    izquierda.plot(t, flecha, color=color, lw=2, label=archivo.split("/")[-1])
    derecha.plot(t, energia, color=color, lw=2, label=archivo.split("/")[-1])

izquierda.set_xlabel("t")
izquierda.set_ylabel("flecha del lado cargado")
derecha.set_xlabel("t")
derecha.set_ylabel("energia total")
derecha.set_ylim(0, 1.5 * energia[0])
for ax in (izquierda, derecha):
    ax.legend()

fig.tight_layout()
salida = archivos[0].removesuffix(".dat") + ".png"
fig.savefig(salida, dpi=150)
print("Figura escrita en " + salida)
plt.show()
