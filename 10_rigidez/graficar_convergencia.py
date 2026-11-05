# Error frente a h en escala log-log, una curva por método.
# Antes hay que ejecutar  make convergencia.
#
#     python graficar_convergencia.py
import numpy as np
import matplotlib.pyplot as plt

# El archivo tiene, por cada método, una línea "# nombre" y después sus filas "h error".
metodos = {}
for linea in open("resultados/convergencia.dat"):
    if linea.startswith("#"):
        nombre = linea[1:].strip()
        metodos[nombre] = []
    else:
        metodos[nombre].append([float(c) for c in linea.split()])

colores = ["#2a78d6", "#eb6834", "#1baf7a", "#eda100"]
for (nombre, filas), color in zip(metodos.items(), colores):
    h, error = np.array(filas).T
    plt.loglog(h, error, "o-", color=color, lw=2, ms=6, label=nombre)

plt.xlabel("h")
plt.ylabel("error en t = 1")
plt.title("Convergencia (Van der Pol, mu = 1)")
plt.grid(alpha=0.3, which="both")
plt.legend()
plt.tight_layout()
plt.savefig("resultados/convergencia.png", dpi=150)
print("Figura escrita en resultados/convergencia.png")
