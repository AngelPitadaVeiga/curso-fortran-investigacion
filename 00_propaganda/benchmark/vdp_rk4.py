"""Benchmark: Van der Pol con RK4 de paso fijo desde N condiciones iniciales.

Python puro: el mismo algoritmo, con bucles explícitos, que vdp_rk4.f90,
.cpp, .jl y .m.

Uso:  python vdp_rk4.py [N] [pasos] [repeticiones]
"""
import sys
import time


def integrar(n, pasos):
    """Integra las N trayectorias y devuelve sum(x + y) del estado final."""
    mu = 1.0
    h = 0.01
    suma = 0.0
    for i in range(1, n + 1):
        # Condiciones iniciales deterministas e independientes de N.
        x = -3.0 + 6.0 * ((37 * i) % 1000) / 1000.0
        y = -3.0 + 6.0 * ((53 * i) % 1000) / 1000.0
        for _ in range(pasos):
            k1x = y
            k1y = -mu * (x * x - 1.0) * y - x
            x2 = x + 0.5 * h * k1x
            y2 = y + 0.5 * h * k1y
            k2x = y2
            k2y = -mu * (x2 * x2 - 1.0) * y2 - x2
            x3 = x + 0.5 * h * k2x
            y3 = y + 0.5 * h * k2y
            k3x = y3
            k3y = -mu * (x3 * x3 - 1.0) * y3 - x3
            x4 = x + h * k3x
            y4 = y + h * k3y
            k4x = y4
            k4y = -mu * (x4 * x4 - 1.0) * y4 - x4
            x = x + h / 6.0 * (k1x + 2.0 * k2x + 2.0 * k3x + k4x)
            y = y + h / 6.0 * (k1y + 2.0 * k2y + 2.0 * k3y + k4y)
        suma += x + y
    return suma


def main():
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 1000
    pasos = int(sys.argv[2]) if len(sys.argv) > 2 else 1000
    repeticiones = int(sys.argv[3]) if len(sys.argv) > 3 else 1

    mejor = float("inf")
    suma = 0.0
    for _ in range(repeticiones):
        t0 = time.perf_counter()
        suma = integrar(n, pasos)
        mejor = min(mejor, time.perf_counter() - t0)
    print(f"RESULTADO Python N={n} pasos={pasos} tiempo_s={mejor:.5e} suma={suma:.15e}")


if __name__ == "__main__":
    main()
