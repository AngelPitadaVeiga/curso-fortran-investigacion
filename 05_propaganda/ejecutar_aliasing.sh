#!/usr/bin/env bash
# Compila y ejecuta las demostraciones de aliasing y de expresividad.
# Uso (MSYS2 UCRT64, Git Bash o Linux):  ./ejecutar_aliasing.sh
set -eu
cd "$(dirname "$0")"
mkdir -p bin

echo "== Aliasing: que bucles vectoriza el compilador (-fopt-info-vec-optimized)"
g++ -O3 -march=native -fopt-info-vec-optimized aliasing/aliasing.cpp -o bin/aliasing_cpp 2>&1 \
    | grep -E 'aliasing.cpp:(1[5-9]|[23][0-9]):' || true
gfortran -O3 -march=native -fopt-info-vec-optimized aliasing/aliasing.f90 -o bin/aliasing_f 2>&1 \
    | grep -E 'aliasing.f90:(2[0-9]|3[0-9]|4[0-5]):' || true

echo "== Aliasing: tiempos (250000 pasos de 1000 particulas)"
./bin/aliasing_cpp
./bin/aliasing_f

echo "== Expresividad: Fortran y C++ deben imprimir lo mismo"
gfortran -O3 expresividad/expresividad.f90 -o bin/expresividad_f
g++ -O3 -std=c++17 expresividad/expresividad.cpp -o bin/expresividad_cpp
./bin/expresividad_f > bin/expresividad_f.txt
./bin/expresividad_cpp > bin/expresividad_cpp.txt
cat bin/expresividad_f.txt
if diff -q bin/expresividad_f.txt bin/expresividad_cpp.txt >/dev/null; then
    echo "(salidas identicas)"
else
    echo "AVISO: las salidas difieren"
fi
