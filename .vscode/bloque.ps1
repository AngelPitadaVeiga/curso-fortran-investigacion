# Compila y ejecuta el bloque del archivo abierto (Windows).
#  - Si el bloque tiene Makefile (06 en adelante), ejecuta  make <objetivo>.
#  - Si no (01 a 05), compila el archivo abierto con gfortran y lo ejecuta.
# Uso: bloque.ps1 <archivo_abierto> [objetivo]
param(
    [Parameter(Mandatory = $true)][string]$Archivo,
    [string]$Objetivo = "run"
)

# Sube desde la carpeta del archivo buscando un Makefile, sin salir del curso
# (la raíz del curso es la carpeta que contiene .vscode).
$fuente = Get-Item -LiteralPath $Archivo   # (no $archivo: PowerShell no distingue mayúsculas)
$dir = $fuente.Directory
while ($dir -and -not (Test-Path (Join-Path $dir.FullName "Makefile")) `
             -and -not (Test-Path (Join-Path $dir.FullName ".vscode"))) {
    $dir = $dir.Parent
}

if ($dir -and (Test-Path (Join-Path $dir.FullName "Makefile"))) {
    # En MSYS2 UCRT64 make se llama mingw32-make; si hay un 'make' en el PATH, se usa ese.
    $make = "mingw32-make"
    if (Get-Command make -ErrorAction SilentlyContinue) { $make = "make" }
    Write-Host ">> $make $Objetivo   (en $($dir.FullName))"
    & $make -C $dir.FullName $Objetivo
    exit $LASTEXITCODE
}

# Sin Makefile: un programa de un solo archivo.
if ($fuente.Extension -notin @(".f90", ".f")) {
    Write-Host "Abre un archivo .f90 para compilarlo."
    exit 1
}
if ($Objetivo -ne "run") {
    Write-Host "Este bloque no tiene Makefile: solo se puede compilar y ejecutar el archivo abierto."
    exit 1
}
Set-Location $fuente.DirectoryName
$nombre = $fuente.BaseName
Write-Host ">> gfortran -Wall $($fuente.Name) -o $nombre"
& gfortran -Wall $fuente.Name -o $nombre
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Host ">> .\$nombre"
& ".\$nombre.exe"
exit $LASTEXITCODE
