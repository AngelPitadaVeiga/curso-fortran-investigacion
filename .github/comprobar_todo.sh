#!/usr/bin/env bash
# Compila y ejecuta casos cortos de todos los bloques (lo usa la integración
# continua, pero también se puede lanzar a mano desde la raíz del repositorio
# en MSYS2 UCRT64, Git Bash o Linux):
#
#     bash .github/comprobar_todo.sh
#
# Termina con error si algo no compila, si un programa falla, si el Euler del
# bloque 04 no reproduce el del bloque 03 o si algún orden de convergencia se
# desvía del teórico. No necesita gnuplot (los programas avisan y siguen).
# El benchmark del bloque 00 solo se compila, no se ejecuta.
set -euo pipefail
cd "$(dirname "$0")/.."
RAIZ=$(pwd)

titulo() { echo; echo "=================== $* ==================="; }

titulo "01 instalacion"
mkdir -p build_ci
gfortran -Wall -std=f2018 01_instalacion/comprobacion.f90 -o build_ci/comprobacion
./build_ci/comprobacion

titulo "02 hola mundo"
gfortran -Wall -std=f2018 02_hola_mundo/hola.f90 -o build_ci/hola
./build_ci/hola

titulo "03 Euler-Lienard"
make -C 03_euler_lienard all debug
make -C 03_euler_lienard run-debug
make -C 03_euler_lienard run          # deja resultados/euler.dat (release)
make -C 03_euler_lienard demo-error

titulo "04 Runge-Kutta: compilacion y todos los tableros"
make -C 04_runge_kutta_butcher all debug
cd 04_runge_kutta_butcher
for t in tableros/*.txt; do
    ./rk_butcher entrada.nml "$t"
done

titulo "04: Euler explicito del bloque 04 = bloque 03 (bit a bit)"
grep -v '^#' resultados/euler_explicito.dat > "$RAIZ/build_ci/euler04.txt"
grep -v '^#' ../03_euler_lienard/resultados/euler.dat > "$RAIZ/build_ci/euler03.txt"
cmp "$RAIZ/build_ci/euler04.txt" "$RAIZ/build_ci/euler03.txt"
echo "Identicos."

titulo "04: test de convergencia (release y debug)"
./convergencia_rk convergencia/convergencia.nml
./convergencia_rk_debug convergencia/convergencia.nml
cd "$RAIZ"

titulo "05 retrato de fases"
make -C 05_retrato_de_fases all debug
make -C 05_retrato_de_fases run
make -C 05_retrato_de_fases run-debug

titulo "00 propaganda (el benchmark solo se compila)"
mkdir -p build_ci/00
gfortran -O3 -march=native 00_propaganda/benchmark/vdp_rk4.f90 -o build_ci/00/vdp_rk4_f
gfortran -O3 -march=native 00_propaganda/benchmark/vdp_rk4_vectorial.f90 -o build_ci/00/vdp_rk4_vectorial_f
g++ -O3 -march=native -std=c++17 00_propaganda/benchmark/vdp_rk4.cpp -o build_ci/00/vdp_rk4_cpp
# Caso minimo para comprobar que Fortran y C++ calculan lo mismo
./build_ci/00/vdp_rk4_f 1000 100 1
./build_ci/00/vdp_rk4_cpp 1000 100 1
bash 00_propaganda/ejecutar_aliasing.sh
cmp 00_propaganda/bin/expresividad_f.txt 00_propaganda/bin/expresividad_cpp.txt

titulo "06 Fortran heredado"
make -C 06_fortran_legado run
cmp 06_fortran_legado/resultados/legado.txt 06_fortran_legado/resultados/moderno.txt
make -C 06_fortran_legado debug
make -C 06_fortran_legado run
cmp 06_fortran_legado/resultados/legado.txt 06_fortran_legado/resultados/moderno.txt

titulo "TODO CORRECTO"
