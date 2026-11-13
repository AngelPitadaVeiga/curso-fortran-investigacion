# Unidad 01 · Instalación

Hacen falta cuatro componentes: **gfortran**, **make**, **Python 3** con **numpy** y **matplotlib**, y
**VS Code** con las extensiones *Modern Fortran*, *Python* y *Makefile Tools*. La instalación requiere
unos veinte minutos.

## Windows

1. **MSYS2.** Descarga el instalador de <https://www.msys2.org> y ejecútalo con la ruta que propone,
   `C:\msys64`.
2. **gfortran y make.** Abre **MSYS2 UCRT64** desde el menú Inicio y escribe:

   ```bash
   pacman -Syu
   ```

   Si pide cerrar la ventana, ciérrala, ábrela y repite hasta que no quede nada por actualizar.
   Después:

   ```bash
   pacman -S mingw-w64-ucrt-x86_64-gcc-fortran make
   ```

3. **Variable Path.** Pulsa la tecla Windows, escribe *variables de entorno* y abre *Editar las
   variables de entorno de esta cuenta*. En `Path`, añade estas dos entradas, en este orden:

   ```
   C:\msys64\ucrt64\bin
   C:\msys64\usr\bin
   ```

   La primera contiene gfortran. La segunda, make y las órdenes `rm` y `mkdir` que usan los Makefile.
4. **Python.** Descárgalo de <https://www.python.org> y marca **Add python.exe to PATH** en la primera
   pantalla del instalador.
5. **numpy y matplotlib.** En una PowerShell nueva:

   ```powershell
   pip install numpy
   pip install matplotlib
   pip install fortls
   ```

   `fortls` da el autocompletado de Fortran en VS Code.
6. **VS Code.** Descárgalo de <https://code.visualstudio.com>, abre la carpeta del curso y acepta
   instalar las extensiones recomendadas. Si no aparece la propuesta, busca cada extensión con
   `Ctrl+Mayús+X`.

## Linux y macOS

**Ubuntu y Debian:**

```bash
sudo apt install gfortran make python3 python3-numpy python3-matplotlib python3-pip python-is-python3
pip install fortls
```

(En las versiones recientes, `pip install numpy` exige un entorno virtual, y por eso se usa `apt`.)

**Fedora:** `sudo dnf install gcc-gfortran make python3-numpy python3-matplotlib`.

**macOS**, con [Homebrew](https://brew.sh): `brew install gcc make python` y
`pip3 install numpy matplotlib fortls`. Allí el intérprete se llama `python3`.

## Comprobación

Abre una terminal nueva en esta carpeta:

```bash
gfortran comprobacion.f90 -o comprobacion
./comprobacion
```

En PowerShell, `.\comprobacion`. La salida correcta es:

```
Compilador: GCC version 14.2.0
matmul funciona:    2.0   3.0   4.0
Python, numpy y matplotlib encontrados.
make encontrado.
Todo listo. Bienvenido a Fortran!
```

Si falta algún componente, el programa indica cuál.

## Errores frecuentes

- **`gfortran` no se reconoce.** El `Path` no está bien, o la terminal estaba abierta antes del
  cambio y hay que reabrirla.
- **`make` no funciona en PowerShell.** La terminal MSYS2 UCRT64 lo ejecuta sin depender del `Path`
  (los archivos de Windows están en `/c/...`).
- **`python` abre la Microsoft Store.** No se marcó *Add python.exe to PATH*. Reinstala Python con la
  casilla marcada.
- **El antivirus borra el `.exe`.** Es un falso positivo habitual. Excluye la carpeta del curso.
- **PowerShell no ejecuta `hola`.** Hay que escribir `.\hola`.
