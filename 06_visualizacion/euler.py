# Compara los dos Euler de la unidad 05 con la solución de referencia.
# Antes hay que ejecutar los tres programas dentro de 05_euler:
# euler_explicito, euler_implicito y referencia.
#
#     python euler.py
import numpy as np
import matplotlib.pyplot as plt
from numpy.lib.stride_tricks import sliding_window_view

t, x_e, y_e = np.loadtxt("../05_euler/euler_explicito.dat", unpack=True)
t_i, x_i, y_i = np.loadtxt("../05_euler/euler_implicito.dat", unpack=True)
t_r, x_r, y_r = np.loadtxt("../05_euler/referencia.dat", unpack=True)

# La referencia se escribe cada 0.1 de tiempo; la interpolamos en los instantes de cada Euler.
x_ref_e = np.interp(t, t_r, x_r)
x_ref_i = np.interp(t_i, t_r, x_r)


def cruces(t, x):
    """Instantes en que x pasa por cero hacia arriba (con interpolación lineal)."""
    k = np.where((x[:-1] < 0) & (x[1:] >= 0))[0]
    return t[k] - x[k] * (t[k + 1] - t[k]) / (x[k + 1] - x[k])


def periodo(t, x):
    c = cruces(t, x)
    return (c[-1] - c[0]) / (len(c) - 1)


def envolvente(t, error, ancho=7.0):
    """Máximo del error en ventanas de ancho 7 (algo más que un periodo)."""
    n = int(ancho / (t[1] - t[0]))
    return t[:len(t) - n + 1], sliding_window_view(error, n).max(axis=1)


# Periodo y amplitud del ciclo, y el primer instante en que el error de x supera 0.5.
print(f"{'':>10} {'periodo':>9} {'amplitud':>9} {'t con |error| > 0.5':>20}")
for nombre, tt, x, x_ref in [("referencia", t_r, x_r, x_r), ("explicito", t, x_e, x_ref_e),
                              ("implicito", t_i, x_i, x_ref_i)]:
    tv, env = envolvente(tt, np.abs(x - x_ref))
    despega = f"{tv[np.argmax(env > 0.5)]:.0f}" if (env > 0.5).any() else "-"
    ultimos = tt > tt[-1] / 2
    print(f"{nombre:>10} {periodo(tt, x):9.4f} {np.abs(x[ultimos]).max():9.4f} {despega:>20}")

fig, (izquierda, centro, derecha) = plt.subplots(1, 3, figsize=(15, 4.6))

# x(t) al final de la simulación.
ventana = t > t[-1] - 30
izquierda.plot(t_r[t_r > t_r[-1] - 30], x_r[t_r > t_r[-1] - 30], color="#a3a29c", lw=5, alpha=0.7,
               label="referencia")
izquierda.plot(t[ventana], x_e[ventana], color="#2a78d6", lw=1.5, label="explicito")
izquierda.plot(t_i[ventana], x_i[ventana], color="#eb6834", lw=1.5, label="implicito")
izquierda.set_title(f"x(t) al final, de t = {t[-1] - 30:.0f} a {t[-1]:.0f}")
izquierda.set_xlabel("t")
izquierda.set_ylabel("x")
izquierda.legend(loc="upper left", fontsize=8)

# Retraso acumulado: cuánto más tarde (o antes) que la referencia llega cada Euler al
# mismo cruce por cero, medido en periodos. Si llega a 0.5, está justo en oposición de fase.
c_r = cruces(t_r, x_r)
for tt, x, color, nombre in [(t, x_e, "#2a78d6", "explicito"), (t_i, x_i, "#eb6834", "implicito")]:
    c = cruces(tt, x)
    n = min(len(c), len(c_r))
    centro.plot(c_r[:n], (c[:n] - c_r[:n]) / periodo(t_r, x_r), color=color, lw=1.5, label=nombre)
centro.axhline(0.5, color="#a3a29c", ls="--", lw=1)
centro.axhline(-0.5, color="#a3a29c", ls="--", lw=1)
centro.set_title("Retraso respecto a la referencia")
centro.set_xlabel("t")
centro.set_ylabel("retraso, en periodos")
centro.legend(fontsize=8)
centro.grid(alpha=0.3)

# Plano de fases al final.
derecha.plot(x_r[t_r > t_r[-1] - 30], y_r[t_r > t_r[-1] - 30], color="#a3a29c", lw=5, alpha=0.7,
             label="referencia")
derecha.plot(x_e[ventana], y_e[ventana], color="#2a78d6", lw=1.2, label="explicito")
derecha.plot(x_i[ventana], y_i[ventana], color="#eb6834", lw=1.2, label="implicito")
derecha.set_title("Plano de fases al final")
derecha.set_xlabel("x")
derecha.set_ylabel("y")
derecha.set_aspect("equal")
derecha.legend(loc="upper left", fontsize=8)

fig.tight_layout()
fig.savefig("euler.png", dpi=150)
print("Figura escrita en euler.png")
plt.show()
