// Benchmark: Van der Pol con RK4 de paso fijo desde N condiciones iniciales.
// El mismo algoritmo, con bucles explícitos, que vdp_rk4.f90, .jl, .py y vdp_rk4_handle.m.
//
// Compilar:  g++ -O3 -march=native -std=c++17 vdp_rk4.cpp -o vdp_rk4_cpp
// Uso:       vdp_rk4_cpp [N] [pasos] [repeticiones]
#include <algorithm>
#include <chrono>
#include <cstdio>
#include <cstdlib>
#include <limits>

// Integra las N trayectorias y devuelve sum(x + y) del estado final.
static double integrar(int n, int pasos) {
    const double mu = 1.0, h = 0.01;
    double suma = 0.0;
    for (int i = 1; i <= n; ++i) {
        // Condiciones iniciales deterministas e independientes de N.
        double x = -3.0 + 6.0 * ((37 * i) % 1000) / 1000.0;
        double y = -3.0 + 6.0 * ((53 * i) % 1000) / 1000.0;
        for (int k = 1; k <= pasos; ++k) {
            const double k1x = y;
            const double k1y = -mu * (x * x - 1.0) * y - x;
            const double x2 = x + 0.5 * h * k1x, y2 = y + 0.5 * h * k1y;
            const double k2x = y2;
            const double k2y = -mu * (x2 * x2 - 1.0) * y2 - x2;
            const double x3 = x + 0.5 * h * k2x, y3 = y + 0.5 * h * k2y;
            const double k3x = y3;
            const double k3y = -mu * (x3 * x3 - 1.0) * y3 - x3;
            const double x4 = x + h * k3x, y4 = y + h * k3y;
            const double k4x = y4;
            const double k4y = -mu * (x4 * x4 - 1.0) * y4 - x4;
            x = x + h / 6.0 * (k1x + 2.0 * k2x + 2.0 * k3x + k4x);
            y = y + h / 6.0 * (k1y + 2.0 * k2y + 2.0 * k3y + k4y);
        }
        suma += x + y;
    }
    return suma;
}

int main(int argc, char* argv[]) {
    const int n = argc > 1 ? std::atoi(argv[1]) : 100000;
    const int pasos = argc > 2 ? std::atoi(argv[2]) : 1000;
    const int repeticiones = argc > 3 ? std::atoi(argv[3]) : 3;

    double suma = 0.0, mejor = std::numeric_limits<double>::max();
    for (int r = 0; r < repeticiones; ++r) {
        const auto t0 = std::chrono::steady_clock::now();
        suma = integrar(n, pasos);
        const auto t1 = std::chrono::steady_clock::now();
        mejor = std::min(mejor, std::chrono::duration<double>(t1 - t0).count());
    }
    std::printf("RESULTADO C++ N=%d pasos=%d tiempo_s=%.5e suma=%.15e\n", n, pasos, mejor, suma);
    return 0;
}
