# Unidad 01 · Instalación

Necesitas tres cosas: el compilador, Python con matplotlib y VS Code. Hazlo antes
de la primera clase; son unos 20 minutos.

## 1. El compilador

En Windows lo más cómodo es MSYS2:

1. Descarga el instalador de <https://www.msys2.org> e instálalo en la ruta que
   propone, `C:\msys64`.
2. Abre la terminal **MSYS2 UCRT64** desde el menú Inicio y ejecuta:

   ```bash
   pacman -Syu
   ```

   Si te pide cerrar la terminal, ciérrala, ábrela de nuevo y repite la orden.

3. Instala gfortran y make:

   ```bash
   pacman -S mingw-w64-ucrt-x86_64-gcc-fortran mingw-w64-ucrt-x86_64-make
   ```

4. Añade `C:\msys64\ucrt64\bin` al `Path`: tecla Windows, escribe *variables de
   entorno*, entra en **Editar las variables de entorno de esta cuenta**, selecciona
   `Path` y añade una entrada nueva con esa ruta.

En PowerShell, make se llama `mingw32-make`. Es el mismo programa.

**En Linux:** `sudo apt install gfortran make`. **En macOS:** `brew install gcc`.

## 2. Python y matplotlib

Instala Python desde <https://www.python.org> y marca la casilla **Add python.exe to
PATH** en la primera pantalla. Después, en PowerShell:

```powershell
pip install numpy matplotlib fortls
```

`fortls` es lo que da el autocompletado de Fortran en VS Code.

## 3. VS Code

Instala [VS Code](https://code.visualstudio.com) y abre la carpeta del curso con
**Archivo → Abrir carpeta**. Te propondrá instalar las extensiones recomendadas;
di que sí. Lo vemos con más calma en la [unidad 02](../02_hola_mundo/).

## Comprueba que todo funciona

Cierra y vuelve a abrir la terminal, entra en esta carpeta y ejecuta:

```powershell
gfortran comprobacion.f90 -o comprobacion
.\comprobacion
```

Tiene que salir algo así:

```
Compilador: GCC version 14.2.0
matmul funciona:    2.0   3.0   4.0
Python y matplotlib encontrados.
Todo listo. Bienvenido a Fortran!
```

## Si algo falla

| Qué pasa | Qué hacer |
|---|---|
| `gfortran` no se reconoce | Revisa el `Path` y cierra y abre de nuevo la terminal o VS Code. |
| `make` no se reconoce en PowerShell | Escribe `mingw32-make`. |
| PowerShell no ejecuta `hola` | Hay que escribir `.\hola`. |
| El antivirus borra el `.exe` | Añade una exclusión para la carpeta del curso. |
| `Permission denied` al compilar | El programa sigue abierto. Ciérralo y vuelve a compilar. |
