# Unidad 01 · Instalación

Para el curso necesitas cuatro cosas:

- **gfortran**, el compilador de Fortran.
- **make**, para compilar los proyectos de la segunda sesión.
- **Python 3** con **numpy** y **matplotlib**, para dibujar los resultados.
- **VS Code**, con las extensiones *Modern Fortran*, *Python* y *Makefile Tools*.

Lo más largo es el compilador. Cuenta con unos veinte minutos en total, y hazlo antes de
la primera clase.

## Windows

En Windows, gfortran y make vienen con MSYS2.

**1. Instalar MSYS2.** Descarga el instalador de <https://www.msys2.org> y ejecútalo
dejando la ruta que propone, `C:\msys64`.

**2. Instalar gfortran y make.** Al terminar, abre **MSYS2 UCRT64** desde el menú
Inicio (la ventana negra con `UCRT64` en el prompt) y escribe:

```bash
pacman -Syu
```

Puede que te pida cerrar la ventana. Ciérrala, ábrela otra vez y repite la orden hasta
que diga que no hay nada que actualizar. Después:

```bash
pacman -S mingw-w64-ucrt-x86_64-gcc-fortran make
```

**3. Añadir las dos carpetas al Path.** Esto sirve para que `gfortran` y `make` funcionen
también desde PowerShell y desde VS Code. Pulsa la tecla Windows, escribe *variables de
entorno* y entra en *Editar las variables de entorno de esta cuenta*. Selecciona `Path`,
pulsa *Editar* y añade estas dos entradas, **en este orden**:

```
C:\msys64\ucrt64\bin
C:\msys64\usr\bin
```

La primera tiene gfortran, y la segunda, make y otras herramientas (`rm`, `mkdir`) que usan
los Makefile del curso.

**4. Instalar Python.** Descárgalo de <https://www.python.org> y, en la primera pantalla
del instalador, marca **Add python.exe to PATH**. Es fácil olvidarse, y sin esa casilla
`python` no funcionará en la terminal.

**5. Instalar numpy y matplotlib.** Abre PowerShell (nueva, para que coja el Path) y escribe
estas tres líneas, una detrás de otra:

```powershell
pip install numpy
pip install matplotlib
pip install fortls
```

`numpy` sirve para leer los datos, `matplotlib` para dibujarlos y `fortls` es lo que da el
autocompletado de Fortran en VS Code.

**6. Instalar VS Code.** Descárgalo de <https://code.visualstudio.com>, abre la carpeta del
curso (*Archivo → Abrir carpeta*) y acepta cuando te proponga instalar las extensiones
recomendadas. Si no lo hace, pulsa `Ctrl+Mayús+X`, busca cada una por su nombre e
instálala:

| Extensión | Para qué |
|---|---|
| Modern Fortran | Colores, errores mientras escribes, autocompletado |
| Python | Lo mismo para los scripts de las figuras |
| Makefile Tools | Colores y ayuda para los Makefile |

## Linux y macOS

**Ubuntu o Debian:**

```bash
sudo apt install gfortran make python3 python3-numpy python3-matplotlib python3-pip
pip install fortls
```

Aquí `python` suele llamarse `python3`. Instala `python-is-python3` para que
los comandos del curso funcionen tal cual. Si prefieres `pip install numpy matplotlib`, en
las versiones recientes tendrás que hacerlo dentro de un entorno virtual (`python3 -m venv`).

**Fedora:** `sudo dnf install gcc-gfortran make python3-numpy python3-matplotlib`.

**macOS** (con [Homebrew](https://brew.sh)):

```bash
brew install gcc make python
pip3 install numpy matplotlib fortls
```

En macOS el comando es `gfortran` (viene con `gcc`) y `python3` en lugar de `python`.

Las extensiones de VS Code son las mismas que en Windows.

## Comprobarlo

Cierra todas las terminales, abre una nueva dentro de esta carpeta y escribe:

```bash
gfortran comprobacion.f90 -o comprobacion
./comprobacion
```

En PowerShell, `.\comprobacion`. Tiene que salir algo así:

```
Compilador: GCC version 14.2.0
matmul funciona:    2.0   3.0   4.0
Python, numpy y matplotlib encontrados.
make encontrado.
Todo listo. Bienvenido a Fortran!
```

Si falta algo, el programa te avisa de qué.

## Si algo falla

- **`gfortran` no se reconoce.** El Path no está bien, o no has cerrado y vuelto a abrir la
  terminal (o VS Code) después de cambiarlo.
- **`make` no funciona en PowerShell.** Prueba en la terminal MSYS2 UCRT64 del menú Inicio, donde
  todo funciona seguro: tus carpetas de Windows están en `/c/...`.
- **`python` abre la Microsoft Store.** No marcaste *Add python.exe to PATH*. Desinstala
  Python y vuelve a instalarlo con la casilla marcada.
- **El antivirus borra el `.exe` recién compilado.** Es un falso positivo muy común. Añade una
  exclusión para la carpeta del curso.
- **PowerShell no ejecuta `hola`.** Hay que escribir `.\hola`, con el punto y la barra.
- **`Permission denied` al compilar.** El programa sigue ejecutándose. Ciérralo y compila otra vez.
