# Bloque 00 · Instalación en Windows

Objetivo: tener **gfortran**, **make** y **gnuplot** en la línea de órdenes,
y **VS Code** con la extensión *Modern Fortran*. Unos 20 minutos.

## 1. MSYS2 (entorno UCRT64)

MSYS2 proporciona gfortran, make y gnuplot compilados para Windows.

1. Descarga el instalador desde <https://www.msys2.org> e instálalo en la
   ruta por defecto, `C:\msys64`.
2. Abre la terminal **"MSYS2 UCRT64"** (menú Inicio). El prompt muestra
   `UCRT64` en morado. *UCRT64 es el entorno que recomienda MSYS2.*
3. Actualiza e instala los paquetes:

   ```bash
   pacman -Syu
   ```

   Si te pide cerrar la terminal, ciérrala, vuelve a abrirla y repite
   `pacman -Syu`. Después:

   ```bash
   pacman -S mingw-w64-ucrt-x86_64-gcc-fortran mingw-w64-ucrt-x86_64-make mingw-w64-ucrt-x86_64-gnuplot make
   ```

   | Paquete | Qué instala |
   |---|---|
   | `mingw-w64-ucrt-x86_64-gcc-fortran` | `gfortran` (y `gcc`) |
   | `mingw-w64-ucrt-x86_64-make` | `mingw32-make.exe`, para usar desde PowerShell y VS Code |
   | `mingw-w64-ucrt-x86_64-gnuplot` | `gnuplot` |
   | `make` | `make`, para usar dentro de la terminal de MSYS2 |

   Opcional: `mingw-w64-ucrt-x86_64-gcc` ya viene con el anterior y sirve
   para el C++ del bloque 05 (`g++`).

## 2. Añadir MSYS2 al PATH de Windows

Para usar `gfortran` desde PowerShell y VS Code:

1. Tecla Windows → escribe *"variables de entorno"* →
   **Editar las variables de entorno de esta cuenta**.
2. En *Variables de usuario*, selecciona `Path` → **Editar** → **Nuevo**:

   ```
   C:\msys64\ucrt64\bin
   ```

3. Acepta y **cierra y vuelve a abrir** PowerShell y VS Code.

Comprueba en PowerShell:

```powershell
gfortran --version
mingw32-make --version
gnuplot --version
```

> **`make` o `mingw32-make`.** En `C:\msys64\ucrt64\bin` el programa se llama
> `mingw32-make`. En la terminal de MSYS2 existe además `make`. Son el mismo
> GNU Make y los Makefile del curso funcionan con los dos. Si quieres escribir
> `make` en PowerShell, crea un alias en tu perfil
> (`notepad $PROFILE` y añade `Set-Alias make mingw32-make`).

## 3. VS Code y la extensión Modern Fortran

1. Instala VS Code: <https://code.visualstudio.com>.
2. Abre la carpeta del curso (**Archivo → Abrir carpeta**). VS Code ofrecerá
   instalar las extensiones recomendadas (`.vscode/extensions.json`); acepta.
   La importante es **Modern Fortran** (`fortran-lang.linter-gfortran`).
3. **Ctrl+Shift+B** compila y ejecuta el bloque del archivo abierto
   (tareas definidas en `.vscode/tasks.json`).

## 4. fortls y fpm

**fortls** es el servidor de lenguaje (autocompletado, ir a la definición,
documentación al pasar el ratón). Con el Python de Windows
(<https://www.python.org>):

```powershell
pip install fortls
```

Si VS Code no lo encuentra, pon la ruta completa de `fortls.exe` en el
ajuste `fortran.fortls.path`. Alternativa sin Python de Windows:
`pacman -S mingw-w64-ucrt-x86_64-python-fortls` en MSYS2.

**fpm** (*Fortran Package Manager*) compila proyectos sin Makefile.
Descarga el ejecutable de Windows de
<https://github.com/fortran-lang/fpm/releases>, renómbralo a `fpm.exe` y
cópialo en una carpeta del PATH (por ejemplo `C:\msys64\ucrt64\bin`).
Alternativa: `pacman -S mingw-w64-ucrt-x86_64-fpm`.

## 5. Comprobación final

En PowerShell, dentro de esta carpeta:

```powershell
gfortran comprobacion.f90 -o comprobacion
.\comprobacion
```

Debe mostrar algo así:

```
Compilador: GCC version 16.2.0          (o la versión que tengas)
matmul funciona:    2.0   3.0   4.0
gnuplot encontrado.
Todo listo. Bienvenido a Fortran!
```

**Si esto compila y ejecuta, estás listo.** Prueba también un bloque completo:

```powershell
cd ..\02_euler_lienard
mingw32-make run
```

## Alternativas

**WSL (Ubuntu dentro de Windows).**
`wsl --install` en PowerShell como administrador; después, en Ubuntu:

```bash
sudo apt update && sudo apt install gfortran make gnuplot
```

VS Code se conecta a WSL con la extensión *WSL*.

**Linux (Debian/Ubuntu).** Igual que WSL: `sudo apt install gfortran make gnuplot`.
En Fedora: `sudo dnf install gcc-gfortran make gnuplot`.

**macOS (Homebrew).** `brew install gcc gnuplot fpm` (gfortran viene con `gcc`).

**Intel `ifx`.** Compilador gratuito de Intel, parte de *oneAPI*:
<https://www.intel.com/content/www/us/en/developer/tools/oneapi/fortran-compiler.html>.
En Windows necesita además las *Build Tools* de Visual Studio. Las opciones
son distintas a las de gfortran (`-O3 -xHost`, `-check all -traceback`), así
que los Makefile del curso no sirven tal cual con `ifx`; con fpm basta
`fpm run --compiler ifx`.

## Problemas frecuentes

| Síntoma | Causa y solución |
|---|---|
| `"gfortran" no se reconoce como un comando...` | Falta `C:\msys64\ucrt64\bin` en el PATH, o no has reabierto la terminal o VS Code tras añadirlo. |
| `make: command not found` en PowerShell | Usa `mingw32-make` (o crea el alias de la sección 2). |
| `make` funciona pero se comporta raro | Puede haber otro `make` antes en el PATH (Git, Strawberry Perl, Chocolatey...). Comprueba con `where.exe make`. |
| El antivirus borra o bloquea el `.exe` recién compilado | Falso positivo frecuente con ejecutables nuevos sin firmar. Añade una exclusión para la carpeta del curso. |
| Caracteres raros (`Ã³`) en la consola | La consola de Windows no usa UTF-8 por defecto. Los programas del curso imprimen sin tildes para evitarlo. Opcional: `chcp 65001`. |
| PowerShell no ejecuta `hola` | En PowerShell hay que escribir `.\hola` (con `.\`). |
| `pacman` se queda bloqueado o da errores de claves | Cierra todas las terminales de MSYS2 y repite `pacman -Syu`. |
| `fortls` no arranca en VS Code | Ruta completa en `fortran.fortls.path`, o desactívalo con `fortran.fortls.disabled`. |
| `error: ... cannot open output file ...exe: Permission denied` | El programa sigue en ejecución (o lo tiene abierto el antivirus). Ciérralo y recompila. |
