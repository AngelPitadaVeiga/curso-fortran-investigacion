#!/usr/bin/env bash
# Compila y ejecuta casos cortos de todos los bloques (lo usa la integración
# continua, pero también se puede lanzar a mano desde la raíz del repositorio
# en MSYS2 UCRT64, Git Bash o Linux):
#
#     bash .github/comprobar_todo.sh
#
# Termina con error si algo no compila, si un programa falla, si los Euler
# de los bloques 05, 06 y 07 no coinciden bit a bit, si las copias de los
# módulos compartidos se han separado o si algún orden de convergencia se
# desvía del teórico. No necesita gnuplot. El benchmark del bloque 00 solo
# se compila y se ejecuta con un caso mínimo.
set -euo pipefail
cd "$(dirname "$0")/.."
RAIZ=$(pwd)
CI="$RAIZ/build_ci"
F="gfortran -Wall -std=f2018"

titulo() { echo; echo "=================== $* ==================="; }
sin_cabecera() { grep -v '^#' "$1"; }

rm -rf "$CI"
mkdir -p "$CI"

titulo "01 instalacion y 02 hola mundo"
$F 01_instalacion/comprobacion.f90 -o "$CI/comprobacion"
"$CI/comprobacion"
$F 02_hola_mundo/hola.f90 -o "$CI/hola"
"$CI/hola"

titulo "03 variables y bucles"
# tipos.f90 tiene una división entera intencionada: se compila sin -Werror.
cd 03_variables_y_bucles
$F tipos.f90 -o "$CI/tipos"
"$CI/tipos"
$F heron.f90 -o "$CI/heron"
"$CI/heron"
cd "$RAIZ"

titulo "04 arrays y archivos"
cd 04_arrays_y_archivos
$F arrays.f90 -o "$CI/arrays"
"$CI/arrays"
$F tabla.f90 -o "$CI/tabla"
"$CI/tabla"
cd "$RAIZ"

titulo "05 Euler en un archivo (release y debug)"
cd 05_euler_un_archivo
gfortran -O3 -march=native euler.f90 -o "$CI/euler05"
"$CI/euler05"
sin_cabecera euler.dat > "$CI/euler05_release.txt"
$F -g -O0 -fcheck=all -ffpe-trap=invalid,zero,overflow euler.f90 -o "$CI/euler05_debug"
"$CI/euler05_debug"
sin_cabecera euler.dat > "$CI/euler05_debug.txt"
cd "$RAIZ"

titulo "06 modulos y make"
make -C 06_modulos_y_make all debug
make -C 06_modulos_y_make run-debug
sin_cabecera 06_modulos_y_make/resultados/euler.dat > "$CI/euler06_debug.txt"
make -C 06_modulos_y_make run
sin_cabecera 06_modulos_y_make/resultados/euler.dat > "$CI/euler06_release.txt"
make -C 06_modulos_y_make demo-error

titulo "07 Runge-Kutta"
make -C 07_runge_kutta all debug
make -C 07_runge_kutta run-debug
make -C 07_runge_kutta run
cd 07_runge_kutta
for t in tableros/*.txt; do
    ./rk entrada.nml "$t"
done
./rk entrada.nml tableros/euler_explicito.txt
sin_cabecera resultados/rk.dat > "$CI/euler07_release.txt"
./rk_debug entrada.nml tableros/euler_explicito.txt
sin_cabecera resultados/rk.dat > "$CI/euler07_debug.txt"
./convergencia tableros/*.txt
./convergencia_debug tableros/*.txt
cd "$RAIZ"

titulo "Euler de los bloques 05, 06 y 07: identicos bit a bit"
for modo in release debug; do
    cmp "$CI/euler05_$modo.txt" "$CI/euler06_$modo.txt"
    cmp "$CI/euler06_$modo.txt" "$CI/euler07_$modo.txt"
    echo "$modo: identicos."
done

titulo "Copias de los modulos compartidos"
cmp 06_modulos_y_make/src/modelo.f90 07_runge_kutta/src/modelo.f90
for m in modelo tablero_butcher runge_kutta; do
    cmp 07_runge_kutta/src/$m.f90 08_retrato_de_fases/src/$m.f90
done
cmp 07_runge_kutta/src/tablero_butcher.f90 09_rigidez/src/tablero_butcher.f90
cmp 07_runge_kutta/app/convergencia.f90 09_rigidez/app/convergencia.f90
cmp 07_runge_kutta/tableros/rk4.txt 09_rigidez/tableros/rk4.txt
echo "Copias identicas."

titulo "08 retrato de fases"
make -C 08_retrato_de_fases all debug
make -C 08_retrato_de_fases run
make -C 08_retrato_de_fases run-debug

titulo "09 rigidez"
make -C 09_rigidez all debug
make -C 09_rigidez run              # Radau (1,5 millones de pasos) y RK4, que explota
grep -q 'explotado' <(cd 09_rigidez && ./rigidez entrada.nml tableros/rk4.txt resultados/rk4.dat)
echo "RK4 explota, como debe."
cd 09_rigidez
./convergencia tableros/euler_implicito.txt tableros/gauss_legendre2.txt tableros/radau_iia3.txt
./convergencia_debug tableros/euler_implicito.txt tableros/gauss_legendre2.txt tableros/radau_iia3.txt
# En debug, solo un caso corto con Radau (RK4 se detendría con SIGFPE, a propósito).
sed -e 's/t_final = 3000.0/t_final = 10.0/' entrada.nml > "$CI/rigidez_corto.nml"
./rigidez_debug "$CI/rigidez_corto.nml"
cd "$RAIZ"

titulo "00 propaganda (el benchmark solo se compila)"
mkdir -p "$CI/00"
gfortran -O3 -march=native 00_propaganda/benchmark/vdp_rk4.f90 -o "$CI/00/vdp_rk4_f"
gfortran -O3 -march=native 00_propaganda/benchmark/vdp_rk4_vectorial.f90 -o "$CI/00/vdp_rk4_vectorial_f"
g++ -O3 -march=native -std=c++17 00_propaganda/benchmark/vdp_rk4.cpp -o "$CI/00/vdp_rk4_cpp"
# Caso mínimo para comprobar que Fortran y C++ calculan lo mismo
"$CI/00/vdp_rk4_f" 1000 100 1
"$CI/00/vdp_rk4_cpp" 1000 100 1
bash 00_propaganda/ejecutar_aliasing.sh
cmp 00_propaganda/bin/expresividad_f.txt 00_propaganda/bin/expresividad_cpp.txt

titulo "TODO CORRECTO"
