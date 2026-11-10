# Unidad 02 · Hola, mundo

El programa más corto que vamos a escribir:

```fortran
program hola
    implicit none
    print *, "Hola, mundo"
end program hola
```

Para compilarlo y ejecutarlo, abre una terminal dentro de esta carpeta:

```powershell
gfortran hola.f90 -o hola
.\hola
```

En Linux, macOS o la terminal de MSYS2 se ejecuta con `./hola`.

Fíjate en que son dos pasos, como en C++ y a diferencia de Julia o Matlab: primero gfortran
genera el ejecutable, y a partir de ahí ya no hace falta ni el compilador ni el código.

## Qué significa cada línea

`program` y `end program` marcan el programa principal; solo puede haber uno por
ejecutable. `print *` escribe en pantalla, y el asterisco deja el formato en manos del
compilador, por eso sale un espacio delante del texto. Y `implicit none` obliga a declarar
todas las variables. Ponla siempre; en el ejercicio verás por qué.

A Fortran le da igual que escribas `PRINT` o `print`. Aquí lo escribiremos todo en
minúsculas.

## Moverse por VS Code

Con la carpeta del curso abierta, VS Code te propondrá instalar las extensiones de la
[unidad 01](../01_instalacion/): Modern Fortran, Python y Makefile Tools. Si ya las tienes, no
hay que hacer nada más.

Estos atajos te van a ahorrar mucho tiempo:

| Atajo | Qué hace |
|---|---|
| `Ctrl+Ñ` | Abre y cierra la terminal (con teclado inglés, `` Ctrl+` ``) |
| `Ctrl+S` | Guarda. Compilar sin guardar es el error de principiante más repetido |
| `Ctrl+P` | Abre un archivo escribiendo parte de su nombre |
| `Ctrl+Mayús+P` | Busca cualquier orden de VS Code |
| `Ctrl+B` | Muestra y oculta la barra lateral |
| `Ctrl+Mayús+F` | Busca un texto en todos los archivos |
| `Alt+↑` y `Alt+↓` | Mueve la línea actual |
| `Ctrl+D` | Selecciona la siguiente aparición de la palabra |
| `F12` | Va a la definición de una función |
| `Ctrl++` y `Ctrl+-` | Agranda y reduce todo |

El atajo para comentar líneas depende del teclado; mira cuál es en el menú *Editar →
Alternar comentario de línea*. En la terminal, la flecha ↑ recupera la última orden y `Tab`
completa nombres de archivo.

## Ejercicio

1. Añade `x = 2.5` y `print *, x` antes del `end program`. Compila: da un error, porque `x` no
   está declarada.
2. Quita `implicit none` y vuelve a compilar. Ahora funciona, porque Fortran decide el tipo por
   la primera letra: las variables que empiezan por `i, j, k, l, m, n` son enteras y las demás,
   reales.
3. Cambia `x` por `n` en las dos líneas. ¿Qué imprime? Piensa ahora en una errata en el nombre
   de una variable, en un programa de mil líneas.
