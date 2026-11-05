# Gráfica de barras del benchmark: tiempo por paso de RK4 y trayectoria.
#
#     python graficar_benchmark.py                       (lee resultados/tiempos.dat)
#     python graficar_benchmark.py archivo.dat salida.png
import shlex
import sys
import matplotlib.pyplot as plt

entrada = sys.argv[1] if len(sys.argv) > 1 else "resultados/tiempos.dat"
salida = sys.argv[2] if len(sys.argv) > 2 else "resultados/benchmark.png"

# Cada fila:  "nombre"  ns_por_paso  relativo_a_Fortran  suma  N
filas = []
for linea in open(entrada):
    if not linea.startswith("#"):
        campos = shlex.split(linea)
        filas.append((campos[0], float(campos[1]), float(campos[2])))
filas.sort(key=lambda fila: fila[1], reverse=True)     # el más rápido, arriba

nombres = [fila[0] for fila in filas]
tiempos = [fila[1] for fila in filas]

fig, ax = plt.subplots(figsize=(10, 5))
ax.barh(nombres, tiempos, color="#2a78d6", height=0.6)
ax.set_xscale("log")
ax.set_xlabel("nanosegundos por paso (escala logaritmica; menos es mejor)")
ax.set_title("Van der Pol + RK4 de paso fijo")
ax.grid(axis="x", alpha=0.3)
ax.set_axisbelow(True)
for nombre, tiempo, relativo in filas:
    ax.annotate(f" {tiempo:.3g} ns  (x{relativo:.3g})", (tiempo, nombre), va="center")
ax.set_xlim(right=max(tiempos) * 6)

fig.tight_layout()
fig.savefig(salida, dpi=150)
print("Figura escrita en " + salida)
