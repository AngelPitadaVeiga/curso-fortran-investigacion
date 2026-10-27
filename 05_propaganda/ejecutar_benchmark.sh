#!/usr/bin/env bash
# Benchmark Van der Pol + RK4 en Fortran, C++, Julia, Python, NumPy y Matlab.
#
# Uso (desde la terminal de MSYS2 UCRT64, Git Bash o Linux):
#     ./ejecutar_benchmark.sh
#
# Compila y ejecuta las versiones disponibles; las que no estén instaladas
# se saltan con un aviso. Escribe:
#     resultados/salida.txt   salida bruta de cada programa
#     resultados/tiempos.dat  tiempos por paso y relativos a Fortran
#     resultados/benchmark.png gráfica de barras (si hay gnuplot)
#
# Tamaños (se pueden cambiar con variables de entorno):
#     PASOS=1000         pasos de RK4 por trayectoria (h = 0.01, t_final = 10)
#     N_RAPIDO=100000    trayectorias para Fortran, C++, Julia y NumPy
#     N_LENTO=1000       trayectorias para Python puro (100 veces menos)
#     N_MATLAB=20000     trayectorias para Matlab (bucles escalares, vdp_rk4.m)
#     N_MATLAB_FA=1000   trayectorias para Matlab con función anónima (vdp_rk4_handle.m)
#     SIN_MATLAB=1       no ejecutar Matlab (arrancarlo tarda unos segundos)
# Los tiempos se comparan POR PASO Y TRAYECTORIA, así que distintos N son comparables.

set -u
cd "$(dirname "$0")"

PASOS=${PASOS:-1000}
N_RAPIDO=${N_RAPIDO:-100000}
N_LENTO=${N_LENTO:-1000}
N_MATLAB=${N_MATLAB:-20000}
N_MATLAB_FA=${N_MATLAB_FA:-1000}
REPETICIONES=3

mkdir -p resultados bin
SALIDA=resultados/salida.txt
ENTORNO=resultados/entorno.txt
: > "$SALIDA"
: > "$ENTORNO"

aviso() { echo "  AVISO: $*"; }
anota() { echo "$*" | tee -a "$ENTORNO"; }

# ---------------------------------------------------------------- hardware
echo "== Entorno"
if [ -r /proc/cpuinfo ]; then
    anota "CPU: $(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | sed 's/^ *//')"
elif command -v powershell >/dev/null 2>&1; then
    anota "CPU: $(powershell -NoProfile -Command '(Get-CimInstance Win32_Processor).Name' | tr -d '\r')"
elif command -v sysctl >/dev/null 2>&1; then
    anota "CPU: $(sysctl -n machdep.cpu.brand_string 2>/dev/null)"
fi
anota "Sistema: $(uname -s -r)"
anota "Fecha: $(date '+%Y-%m-%d %H:%M')"

# ---------------------------------------------------------------- Fortran
echo "== Fortran"
if command -v gfortran >/dev/null 2>&1; then
    anota "gfortran: $(gfortran --version | head -1)"
    gfortran -O3 -march=native benchmark/vdp_rk4.f90 -o bin/vdp_rk4_f \
        && ./bin/vdp_rk4_f "$N_RAPIDO" "$PASOS" "$REPETICIONES" | tee -a "$SALIDA"
    # El mismo algoritmo en estilo "vectorial" (u(2) y una función que devuelve un vector).
    gfortran -O3 -march=native benchmark/vdp_rk4_vectorial.f90 -o bin/vdp_rk4_vectorial_f \
        && ./bin/vdp_rk4_vectorial_f "$N_RAPIDO" "$PASOS" "$REPETICIONES" | tee -a "$SALIDA"
else
    aviso "gfortran no encontrado: sin Fortran no hay referencia para los tiempos relativos."
fi

# ---------------------------------------------------------------- C++
echo "== C++"
if command -v g++ >/dev/null 2>&1; then
    anota "g++: $(g++ --version | head -1)"
    g++ -O3 -march=native -std=c++17 benchmark/vdp_rk4.cpp -o bin/vdp_rk4_cpp \
        && ./bin/vdp_rk4_cpp "$N_RAPIDO" "$PASOS" "$REPETICIONES" | tee -a "$SALIDA"
else
    aviso "g++ no encontrado; se salta C++."
fi

# ---------------------------------------------------------------- Julia
echo "== Julia"
if command -v julia >/dev/null 2>&1; then
    anota "julia: $(julia --version)"
    julia --startup-file=no benchmark/vdp_rk4.jl "$N_RAPIDO" "$PASOS" "$REPETICIONES" | tee -a "$SALIDA"
else
    aviso "julia no encontrado; se salta Julia."
fi

# ---------------------------------------------------------------- Python
# En Windows, "python" puede ser un acceso directo de la Microsoft Store que
# no hace nada: se comprueba que el intérprete funcione de verdad.
PYTHON=""
for candidato in python3 python py; do
    if command -v "$candidato" >/dev/null 2>&1 && "$candidato" -c "import sys" >/dev/null 2>&1; then
        PYTHON=$candidato
        break
    fi
done

echo "== Python puro"
if [ -n "$PYTHON" ]; then
    anota "python: $($PYTHON --version 2>&1)"
    $PYTHON benchmark/vdp_rk4.py "$N_LENTO" "$PASOS" 1 | tee -a "$SALIDA"
else
    aviso "Python no encontrado; se salta Python."
fi

echo "== NumPy"
if [ -n "$PYTHON" ] && $PYTHON -c "import numpy" >/dev/null 2>&1; then
    anota "numpy: $($PYTHON -c 'import numpy; print(numpy.__version__)')"
    $PYTHON benchmark/vdp_rk4_numpy.py "$N_RAPIDO" "$PASOS" "$REPETICIONES" | tee -a "$SALIDA"
else
    aviso "NumPy no disponible; se salta NumPy (pip install numpy)."
fi

# ---------------------------------------------------------------- Matlab
echo "== Matlab"
if [ -n "${SIN_MATLAB:-}" ]; then
    aviso "SIN_MATLAB definido; se salta Matlab."
elif command -v matlab >/dev/null 2>&1; then
    # Una sola sesión de Matlab para las dos versiones (arrancar tarda unos segundos).
    (cd benchmark && matlab -batch "vdp_rk4($N_MATLAB, $PASOS, $REPETICIONES); vdp_rk4_handle($N_MATLAB_FA, $PASOS, 1)") 2>&1 \
        | tr -d '\r' | grep -E '^(RESULTADO|Matlab)' | tee -a "$SALIDA"
    grep -m1 '^Matlab ' "$SALIDA" >> "$ENTORNO"
else
    aviso "matlab no encontrado; se salta Matlab."
fi

# ---------------------------------------------------------------- resumen
# Tiempo por paso y trayectoria (ns), relativo a Fortran, y suma de control
# por trayectoria (las condiciones iniciales se repiten cada 1000, así que
# suma/N no depende de N y se puede comparar entre versiones).
TIEMPOS=resultados/tiempos.dat
{
    echo "# Benchmark Van der Pol + RK4 (mu = 1, h = 0.01, $PASOS pasos por trayectoria)"
    sed 's/^/# /' "$ENTORNO"
    echo "# lenguaje                     ns_por_paso   relativo_a_Fortran   suma_por_trayectoria     N"
} > "$TIEMPOS"

tr -d '\r' < "$SALIDA" | grep '^RESULTADO' | awk '
    {
        for (i = 3; i <= NF; i++) { split($i, kv, "="); v[kv[1]] = kv[2] }
        n = v["N"]; p = v["pasos"]
        nombre[NR] = $2
        ns[NR] = v["tiempo_s"] / (n * p) * 1e9
        suma[NR] = v["suma"] / n
        nn[NR] = n
        if ($2 == "Fortran") ref = ns[NR]
        if ($2 == "Fortran") sref = suma[NR]
        if ("primera_s" in v) {          # Julia: primera llamada, con JIT
            extra = NR
            ns_jit = v["primera_s"] / (n * p) * 1e9
        }
        delete v
    }
    END {
        if (ref == "") ref = ns[1]
        for (k = 1; k <= NR; k++) {
            printf "\"%s\"%*s %12.3f %16.2f %26.15e %8d\n", nombre[k], 26 - length(nombre[k]), "", ns[k], ns[k] / ref, suma[k], nn[k]
            if (k == extra)
                printf "\"Julia (1a llamada, JIT)\"    %12.3f %16.2f %26.15e %8d\n", ns_jit, ns_jit / ref, suma[k], nn[k]
        }
        # Comprobación de la suma de control frente a Fortran
        for (k = 1; k <= NR; k++) {
            d = (suma[k] - sref) / sref; d = sqrt(d * d)
            estado = (d < 1e-9) ? "coincide" : "DIFIERE"
            printf "# suma de control %-26s: %s (diferencia relativa %.1e)\n", nombre[k], estado, d
        }
    }' >> "$TIEMPOS"

echo
echo "== Resumen ($TIEMPOS)"
cat "$TIEMPOS"

if command -v gnuplot >/dev/null 2>&1; then
    gnuplot graficar_benchmark.gp && echo "Figura: resultados/benchmark.png"
else
    aviso "gnuplot no encontrado; no se genera la grafica."
fi
