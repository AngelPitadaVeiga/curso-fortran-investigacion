# Periodo, amplitud y retraso de fase de una simulación larga, respecto a la solución
# de referencia de la unidad 05 (hay que ejecutar ./referencia dentro de 05_euler).
#
#     ./rk largo.nml
#     python retraso.py resultados/largo.dat
import sys
import numpy as np

archivo = sys.argv[1] if len(sys.argv) > 1 else "resultados/largo.dat"
t, x, _ = np.loadtxt(archivo, unpack=True)
t_r, x_r, _ = np.loadtxt("../05_euler/referencia.dat", unpack=True)


def cruces(t, x):
    """Instantes en que x pasa por cero hacia arriba (con interpolación lineal)."""
    k = np.where((x[:-1] < 0) & (x[1:] >= 0))[0]
    return t[k] - x[k] * (t[k + 1] - t[k]) / (x[k + 1] - x[k])


c, c_r = cruces(t, x), cruces(t_r, x_r)
periodo_r = (c_r[-1] - c_r[0]) / (len(c_r) - 1)
n = min(len(c), len(c_r))

print(f"periodo:   {(c[-1] - c[0]) / (len(c) - 1):.4f}   (referencia: {periodo_r:.4f})")
print(f"amplitud:  {np.abs(x[t > t[-1] / 2]).max():.4f}   (referencia: {np.abs(x_r[t_r > t_r[-1] / 2]).max():.4f})")
print(f"retraso en t = {c_r[n - 1]:.0f}: {(c[n - 1] - c_r[n - 1]) / periodo_r:.3f} periodos")
