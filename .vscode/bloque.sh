#!/usr/bin/env bash
# Compila y ejecuta el bloque del archivo abierto (Linux, macOS, WSL).
#  - Si el bloque tiene Makefile (06 en adelante), ejecuta  make <objetivo>.
#  - Si no (01 a 05), compila el archivo abierto con gfortran y lo ejecuta.
# Uso: bloque.sh <archivo_abierto> [objetivo]
archivo="$1"
objetivo="${2:-run}"

# Sube buscando un Makefile, sin salir del curso (la carpeta que contiene .vscode).
dir="$(cd "$(dirname "$archivo")" && pwd)"
while [ "$dir" != "/" ] && [ ! -f "$dir/Makefile" ] && [ ! -d "$dir/.vscode" ]; do
    dir="$(dirname "$dir")"
done

if [ -f "$dir/Makefile" ]; then
    echo ">> make $objetivo   (en $dir)"
    exec make -C "$dir" "$objetivo"
fi

case "$archivo" in
    *.f90|*.f) ;;
    *) echo "Abre un archivo .f90 para compilarlo."; exit 1 ;;
esac
if [ "$objetivo" != "run" ]; then
    echo "Este bloque no tiene Makefile: solo se puede compilar y ejecutar el archivo abierto."
    exit 1
fi
cd "$(dirname "$archivo")" || exit 1
nombre="$(basename "${archivo%.*}")"
echo ">> gfortran -Wall $(basename "$archivo") -o $nombre"
gfortran -Wall "$(basename "$archivo")" -o "$nombre" || exit 1
echo ">> ./$nombre"
exec "./$nombre"
