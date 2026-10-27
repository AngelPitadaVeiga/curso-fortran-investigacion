#!/usr/bin/env bash
# Ejecuta un objetivo de make en el bloque del archivo abierto (Linux, macOS, WSL).
# Sube desde la carpeta del archivo hasta encontrar un Makefile.
# Uso: bloque.sh <carpeta_del_archivo> [objetivo]
dir="$1"
objetivo="${2:-run}"
while [ "$dir" != "/" ] && [ ! -f "$dir/Makefile" ]; do
    dir="$(dirname "$dir")"
done
if [ ! -f "$dir/Makefile" ]; then
    echo "No se encontro ningun Makefile por encima de $1."
    exit 1
fi
echo ">> make $objetivo   (en $dir)"
make -C "$dir" "$objetivo"
