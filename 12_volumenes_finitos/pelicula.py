# Película a partir de las instantáneas que guarda fluido cuando dt_escritura > 0.
# Antes hay que ejecutar, por ejemplo,  make run-kh.
#
#     python pelicula.py                       (instantáneas resultados/kh_*.bin, densidad)
#     python pelicula.py kh vorticidad
#
# Escribe resultados/<nombre>_<variable>.gif, que se abre con el navegador, y también
# un .mp4 si está instalado ffmpeg.
import sys
import numpy as np
import matplotlib.pyplot as plt
from matplotlib import animation

nombre = sys.argv[1] if len(sys.argv) > 1 else "kh"
variable = sys.argv[2] if len(sys.argv) > 2 else "densidad"

# La primera línea del índice termina con el número de celdas por lado.
indice = f"resultados/{nombre}_instantaneas.dat"
n = int(open(indice).readline().split("=")[1])
numeros, tiempos = np.loadtxt(indice, unpack=True)
lado = 10


def leer(k):
    """Densidad y vorticidad de la instantánea k, como matrices n x n (fila = y)."""
    datos = np.fromfile(f"resultados/{nombre}_{k:04d}.bin", dtype=np.float32)
    # Fortran escribe por columnas (x varía más deprisa): cada bloque de n*n números,
    # leído como matriz de n filas, tiene una fila por cada y.
    rho = datos[:n * n].reshape(n, n)
    vorticidad = datos[n * n:].reshape(n, n)
    return rho if variable == "densidad" else vorticidad


# Escala de colores fija para toda la película: la de la primera instantánea para la
# densidad, y la de una intermedia para la vorticidad, que al principio es casi nula.
if variable == "densidad":
    inicial = leer(0)
    margen = 0.05 * (inicial.max() - inicial.min())
    mapa_color, minimo, maximo = "magma", inicial.min() - margen, inicial.max() + margen
else:
    extremo = np.percentile(np.abs(leer(len(tiempos) // 2)), 99.5)
    mapa_color, minimo, maximo = "RdBu_r", -extremo, extremo

fig, ax = plt.subplots(figsize=(6, 6))
imagen = ax.imshow(leer(0), origin="lower", extent=[0, lado, 0, lado], cmap=mapa_color,
                   vmin=minimo, vmax=maximo, interpolation="bilinear")
titulo = ax.set_title(f"{variable},  t = {tiempos[0]:.2f}   ({n} x {n} celdas)")
ax.set_xticks([])
ax.set_yticks([])
fig.tight_layout()


def dibujar(k):
    imagen.set_data(leer(k))
    titulo.set_text(f"{variable},  t = {tiempos[k]:.2f}   ({n} x {n} celdas)")
    return imagen, titulo


pelicula = animation.FuncAnimation(fig, dibujar, frames=len(tiempos), interval=80)
archivo = f"resultados/{nombre}_{variable}"
pelicula.save(archivo + ".gif", writer=animation.PillowWriter(fps=12), dpi=80)
print(f"Pelicula escrita en {archivo}.gif")
if animation.FFMpegWriter.isAvailable():
    pelicula.save(archivo + ".mp4", writer=animation.FFMpegWriter(fps=12), dpi=150)
    print(f"Pelicula escrita en {archivo}.mp4")
