// Expresividad: las mismas operaciones que expresividad.f90, en C++17
// estándar (sin bibliotecas externas como Eigen o Blaze).
//
//   g++ -O3 -std=c++17 expresividad.cpp -o expresividad_cpp
#include <algorithm>
#include <cmath>
#include <cstdio>
#include <vector>

int main() {
    const int n = 5;
    std::vector<double> a(n), b(n, 1.0), c(n), u(n), lap(n, 0.0), x(n, 1.0), y(n, 0.0);
    // Matriz n x n guardada por columnas, como en Fortran: mat[i + j*n] = mat(i,j)
    std::vector<double> mat(n * n);

    for (int i = 0; i < n; ++i) a[i] = (i + 1) - 3.0;            // -2 -1 0 1 2
    for (int i = 0; i < n; ++i) u[i] = a[i] * a[i];
    for (int j = 0; j < n; ++j)
        for (int i = 0; i < n; ++i) mat[i + j * n] = (i + 1) + (j + 1);

    // 1. Combinación lineal de vectores
    for (int i = 0; i < n; ++i) c[i] = a[i] + 2.0 * b[i];

    // 2. Norma euclídea
    double s = 0.0;
    for (int i = 0; i < n; ++i) s += a[i] * a[i];
    std::printf("norma(a)        = %10.4f\n", std::sqrt(s));

    // 3. Operación condicional elemento a elemento
    for (int i = 0; i < n; ++i) b[i] = a[i] > 0.0 ? std::sqrt(a[i]) : 0.0;

    // 4. Diferencias finitas (laplaciano 1D) en los nodos interiores
    for (int i = 1; i < n - 1; ++i) lap[i] = u[i - 1] - 2.0 * u[i] + u[i + 1];

    // 5. Producto matriz-vector y sumas por columnas
    for (int j = 0; j < n; ++j)
        for (int i = 0; i < n; ++i) y[i] += mat[i + j * n] * x[j];
    std::vector<double> sumcol(n, 0.0);
    for (int j = 0; j < n; ++j)
        for (int i = 0; i < n; ++i) sumcol[j] += mat[i + j * n];

    auto imprime = [](const char* nombre, const std::vector<double>& v) {
        std::printf("%s", nombre);
        for (double vi : v) std::printf("%8.3f", vi);
        std::printf("\n");
    };
    imprime("c               = ", c);
    imprime("b               = ", b);
    imprime("lap             = ", lap);
    imprime("mat*x           = ", y);
    imprime("sumas columnas  = ", sumcol);

    // 6. Máximo y su posición (contando desde 1, como en Fortran)
    const auto it = std::max_element(c.begin(), c.end());
    std::printf("max(c)          = %8.3f  en i = %d\n", *it, int(it - c.begin()) + 1);
    return 0;
}
