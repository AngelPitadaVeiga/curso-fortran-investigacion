# La flecha del extremo de la viga y la energía total, en función del tiempo.
# Antes hay que ejecutar make run-vibracion, run-explicito o run-inestable.
#
#     python graficar_vibracion.py                    (usa resultados/punta.dat)
#     python graficar_vibracion.py otro.dat
import sys
import numpy as np
import matplotlib.pyplot as plt

archivo = sys.argv[1] if len(sys.argv) > 1 else "resultados/punta.dat"

# La primera línea es un comentario con la frecuencia de la teoría de vigas.
omega1 = float(open(archivo).readline().split("=")[1])
t, flecha, energia = np.loadtxt(archivo, unpack=True)

fig, (izquierda, derecha) = plt.subplots(1, 2, figsize=(12, 4.5))

izquierda.plot(t, flecha, color="#2a78d6", lw=2, label="elementos finitos")
izquierda.plot(t, flecha[0] * np.cos(omega1 * t), color="#eb6834", ls="--", lw=1.5,
               label="teoria de vigas: cos(omega1 t)")
izquierda.set_xlabel("t")
izquierda.set_ylabel("flecha del extremo")
izquierda.legend()

derecha.plot(t, energia, color="#1baf7a", lw=2)
derecha.set_xlabel("t")
derecha.set_ylabel("energia total")
derecha.set_ylim(0, 1.5 * energia[0])

fig.tight_layout()
salida = archivo.removesuffix(".dat") + ".png"
fig.savefig(salida, dpi=150)
print("Figura escrita en " + salida)
plt.show()
