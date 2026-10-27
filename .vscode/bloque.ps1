# Ejecuta un objetivo de make en el bloque del archivo abierto (Windows).
# Sube desde la carpeta del archivo hasta encontrar un Makefile.
# Uso: bloque.ps1 <carpeta_del_archivo> [objetivo]
param(
    [Parameter(Mandatory = $true)][string]$Carpeta,
    [string]$Objetivo = "run"
)

$dir = Get-Item -LiteralPath $Carpeta
while ($dir -and -not (Test-Path (Join-Path $dir.FullName "Makefile"))) {
    $dir = $dir.Parent
}
if (-not $dir) {
    Write-Host "No se encontro ningun Makefile por encima de $Carpeta."
    Write-Host "Abre un archivo de un bloque (03, 04, 05, 06...) o usa la tarea 'Compilar archivo suelto'."
    exit 1
}

# En MSYS2 UCRT64 el ejecutable se llama mingw32-make; si hay un 'make' en el PATH, se usa ese.
$make = "mingw32-make"
if (Get-Command make -ErrorAction SilentlyContinue) { $make = "make" }

Write-Host ">> $make $Objetivo   (en $($dir.FullName))"
& $make -C $dir.FullName $Objetivo
exit $LASTEXITCODE
