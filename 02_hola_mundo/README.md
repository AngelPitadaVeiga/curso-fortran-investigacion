# Unidad 02 · Hola, mundo

El programa más corto del curso:

```fortran
program hola
    implicit none
    print *, "Hola, mundo"
end program hola
```

Para compilarlo y ejecutarlo, abre una terminal en esta carpeta:

```powershell
gfortran hola.f90 -o hola
.\hola
```

En Linux, macOS y en la terminal de MSYS2 se ejecuta con `./hola`.

La compilación y la ejecución son dos pasos separados, como en C++ y a diferencia de Julia o Matlab.
Primero gfortran genera el ejecutable. A partir de ahí, el ejecutable funciona sin el compilador y sin
el código fuente.

## Las líneas del programa

`program` y `end program` delimitan el programa principal, y cada ejecutable tiene uno solo.
`print *` escribe en pantalla, y el asterisco deja el formato a elección del compilador, por lo que
aparece un espacio antes del texto. `implicit none` obliga a declarar todas las variables, y debe
escribirse en todos los programas. El ejercicio muestra qué ocurre sin ella.

Fortran no distingue entre `PRINT` y `print`. En el curso todo se escribe en minúsculas.

## VS Code

Con la carpeta del curso abierta, VS Code propone instalar las extensiones de la
[unidad 01](../01_instalacion/): Modern Fortran, Python y Makefile Tools. Si ya están instaladas, no
hay que hacer nada más.

Atajos de teclado útiles:

| Atajo | Acción |
|---|---|
| `Ctrl+Ñ` | Abre y cierra la terminal (con teclado inglés, `` Ctrl+` ``) |
| `Ctrl+S` | Guarda el archivo. Compilar sin guardar compila la versión anterior |
| `Ctrl+P` | Abre un archivo escribiendo parte de su nombre |
| `Ctrl+Mayús+P` | Busca cualquier orden de VS Code |
| `Ctrl+B` | Muestra y oculta la barra lateral |
| `Ctrl+Mayús+F` | Busca un texto en todos los archivos |
| `Alt+↑` y `Alt+↓` | Mueve la línea actual |
| `Ctrl+D` | Selecciona la siguiente aparición de la palabra |
| `F12` | Va a la definición de una función |
| `Ctrl++` y `Ctrl+-` | Aumenta y reduce el tamaño de todo |

El atajo para comentar líneas depende de la distribución del teclado. Se consulta en el menú
*Editar → Alternar comentario de línea*. En la terminal, la flecha ↑ recupera la orden anterior y la
tecla `Tab` completa nombres de archivo.

## Ejercicio

1. Añade `x = 2.5` y `print *, x` antes de `end program`. Compila. El compilador da un error porque
   `x` no está declarada.
2. Quita `implicit none` y compila de nuevo. Ahora compila, porque Fortran asigna el tipo según la
   primera letra del nombre: las variables que empiezan por `i, j, k, l, m, n` son enteras, y las demás,
   reales.
3. Cambia `x` por `n` en las dos líneas y ejecuta. Observa el valor impreso. Considera lo que ocurriría
   con un error de escritura en el nombre de una variable dentro de un programa de mil líneas.
