// Aliasing en C++: la misma actualización de partículas que aliasing.f90,
// sin y con __restrict__.
//
// Compilar y ver qué bucles vectoriza el compilador:
//   g++ -O3 -march=native -fopt-info-vec-optimized aliasing.cpp -o aliasing_cpp
//
// Sin __restrict__, el compilador debe suponer que x, y, vx, vy, fx, fy y m
// pueden solaparse en memoria (escribir vx[i] podría cambiar fx[i+1]...).
// Con pocos punteros GCC genera dos versiones del bucle y comprueba el
// solapamiento al ejecutar; con 7 punteros renuncia y no vectoriza.
#include <chrono>
#include <cstdio>
#include <vector>

// Euler simpléctico para N partículas en el plano: v += dt*F/m, x += dt*v.
__attribute__((noinline))
void avanzar(double* x, double* y, double* vx, double* vy,
             const double* fx, const double* fy, const double* m, double dt, int n) {
    for (int i = 0; i < n; ++i) {
        vx[i] += dt * fx[i] / m[i];
        vy[i] += dt * fy[i] / m[i];
        x[i] += dt * vx[i];
        y[i] += dt * vy[i];
    }
}

// Idéntico, pero prometiendo al compilador que no hay solapamiento.
// __restrict__ no es C++ estándar (sí lo es restrict en C99): es una extensión
// de GCC, Clang, MSVC e Intel. Si la promesa es falsa, el resultado es indefinido.
__attribute__((noinline))
void avanzar_restrict(double* __restrict__ x, double* __restrict__ y,
                      double* __restrict__ vx, double* __restrict__ vy,
                      const double* __restrict__ fx, const double* __restrict__ fy,
                      const double* __restrict__ m, double dt, int n) {
    for (int i = 0; i < n; ++i) {
        vx[i] += dt * fx[i] / m[i];
        vy[i] += dt * fy[i] / m[i];
        x[i] += dt * vx[i];
        y[i] += dt * vy[i];
    }
}

template <class F>
double medir(F f, int repeticiones) {
    const auto t0 = std::chrono::steady_clock::now();
    for (int r = 0; r < repeticiones; ++r) f();
    return std::chrono::duration<double>(std::chrono::steady_clock::now() - t0).count();
}

int main() {
    const int n = 1000, repeticiones = 250000;
    const double dt = 1e-6;
    std::vector<double> x(n, 0.0), y(n, 0.0), vx(n, 1.0), vy(n, 0.0), fx(n, 0.0), fy(n, -1.0), m(n, 2.0);

    // Cada versión parte de los mismos datos iniciales.
    const double t1 = medir([&] { avanzar(x.data(), y.data(), vx.data(), vy.data(),
                                          fx.data(), fy.data(), m.data(), dt, n); }, repeticiones);
    x.assign(n, 0.0); y.assign(n, 0.0); vx.assign(n, 1.0); vy.assign(n, 0.0);
    const double t2 = medir([&] { avanzar_restrict(x.data(), y.data(), vx.data(), vy.data(),
                                                   fx.data(), fy.data(), m.data(), dt, n); }, repeticiones);

    std::printf("C++ sin __restrict__: %.3f s\n", t1);
    std::printf("C++ con __restrict__: %.3f s\n", t2);
    std::printf("(control: x = %.6f, y = %.6f)\n", x[0], y[0]);
    return 0;
}
