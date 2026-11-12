# Unidad 01 · Instalación

El curso necesita cuatro componentes:

- **gfortran**, el compilador de Fortran.
- **make**, que compila los proyectos de la segunda sesión.
- **Python 3** con **numpy** y **matplotlib**, para dibujar los resultados.
- **VS Code**, con las extensiones *Modern Fortran*, *Python* y *Makefile Tools*.

La instalación completa requiere unos veinte minutos y debe hacerse antes de la primera sesión.

## Windows

En Windows, gfortran y make se instalan con MSYS2.

**1. MSYS2.** Descarga el instalador de <https://www.msys2.org> y ejecútalo con la ruta que propone,
`C:\msys64`.

**2. gfortran y make.** Abre **MSYS2 UCRT64** desde el menú Inicio (la ventana negra que muestra
`UCRT64` en el prompt) y escribe:

```bash
pacman -Syu
```

Si pide cerrar la ventana, ciérrala, ábrela de nuevo y repite la orden hasta que no quede nada por
actualizar. Después escribe:

```bash
pacman -S mingw-w64-ucrt-x86_64-gcc-fortran make
```

**3. Variable Path.** Para que `gfortran` y `make` funcionen en PowerShell y en VS Code hay que
añadir dos carpetas al `Path`. Pulsa la tecla Windows, escribe *variables de entorno* y abre
*Editar las variables de entorno de esta cuenta*. Selecciona `Path`, pulsa *Editar* y añade estas dos
entradas, en este orden:

```
C:\msys64\ucrt64\bin
C:\msys64\usr\bin
```

La primera contiene gfortran. La segunda contiene make y las órdenes `rm` y `mkdir`, que usan los
Makefile del curso.

**4. Python.** Descárgalo de <https://www.python.org>. En la primera pantalla del instalador, marca
la casilla **Add python.exe to PATH**. Sin ella, la orden `python` no funciona en la terminal.

**5. numpy y matplotlib.** Abre una PowerShell nueva, para que lea el `Path` actualizado, y escribe
una orden detrás de otra:

```powershell
pip install numpy
pip install matplotlib
pip install fortls
```

`numpy` lee los datos y `matplotlib` los dibuja. `fortls` proporciona el autocompletado de Fortran en
VS Code.

**6. VS Code.** Descárgalo de <https://code.visualstudio.com> y abre la carpeta del curso con
*Archivo → Abrir carpeta*. VS Code propone instalar las extensiones recomendadas; acepta la
propuesta. Si no aparece, pulsa `Ctrl+Mayús+X`, busca cada extensión por su nombre e instálala:

| Extensión | Función |
|---|---|
| Modern Fortran | Colores, errores mientras se escribe y autocompletado |
| Python | Lo mismo para los scripts de las figuras |
| Makefile Tools | Colores y ayuda para los Makefile |

## Linux y macOS

**Ubuntu y Debian:**

```bash
sudo apt install gfortran make python3 python3-numpy python3-matplotlib python3-pip
pip install fortls
```

En estas distribuciones el intérprete se llama `python3`. El paquete `python-is-python3` añade el
nombre `python`, que usan las órdenes del curso. En las versiones recientes, `pip install numpy`
exige un entorno virtual (`python3 -m venv`), y por eso aquí numpy y matplotlib se instalan con
`apt`.

**Fedora:** `sudo dnf install gcc-gfortran make python3-numpy python3-matplotlib`.

**macOS**, con [Homebrew](https://brew.sh):

```bash
brew install gcc make python
pip3 install numpy matplotlib fortls
```

En macOS el intérprete también es `python3`. Las extensiones de VS Code son las mismas que en
Windows.

## Comprobación

Cierra las terminales abiertas, abre una nueva en esta carpeta y escribe:

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

- **`gfortran` no se reconoce.** El `Path` no está bien configurado, o la terminal (o VS Code)
  estaba abierta antes del cambio y hay que cerrarla y abrirla de nuevo.
- **`make` no funciona en PowerShell.** La terminal MSYS2 UCRT64 del menú Inicio lo ejecuta sin
  depender del `Path`. Los archivos de Windows están en `/c/...`.
- **`python` abre la Microsoft Store.** No se marcó *Add python.exe to PATH*. Desinstala Python e
  instálalo otra vez con la casilla marcada.
- **El antivirus borra el `.exe` recién compilado.** Es un falso positivo habitual con ejecutables
  sin firma. Añade la carpeta del curso a las exclusiones.
- **PowerShell no ejecuta `hola`.** Hay que escribir `.\hola`, con el punto y la barra.
- **`Permission denied` al compilar.** El programa anterior sigue en ejecución. Ciérralo y compila de
  nuevo.
