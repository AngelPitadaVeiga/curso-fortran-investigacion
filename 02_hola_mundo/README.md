# Unidad 02 · Hola, mundo

Este es el programa más corto que vamos a escribir:

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

En Linux, macOS o la terminal de MSYS2 se ejecuta con `./hola`.

Fíjate en que son dos pasos, como en C++ y a diferencia de Julia o Matlab. Primero
`gfortran` genera el ejecutable, y a partir de ahí ya no hace falta ni el compilador
ni el código fuente.

## Línea a línea

- **`program` y `end program`** marcan el programa principal.
- **`implicit none`** obliga a declarar todas las variables. Ponla siempre; el
  ejercicio de abajo explica por qué.
- **`print *`** escribe en pantalla, y el asterisco deja el formato en manos del
  compilador. Por eso aparece un espacio delante del texto.

A Fortran le dan igual las mayúsculas: `PRINT` y `print` son lo mismo. Aquí lo
escribiremos todo en minúsculas.

## Moverse por VS Code

**Extensiones.** Con la carpeta del curso abierta, VS Code te propone las que hacen
falta. Si no lo hace, búscalas con `Ctrl+Mayús+X`:

| Extensión | Para qué sirve |
|---|---|
| Modern Fortran | Colores, errores mientras escribes, autocompletado y depuración |
| C/C++ | Aporta el depurador que usa Modern Fortran |
| Python | Para los scripts de las figuras |
| Error Lens | Muestra los errores en la misma línea donde ocurren |
| Rainbow CSV | Colorea las columnas de los archivos de datos |

**Atajos que usarás a todas horas:**

| Atajo | Qué hace |
|---|---|
| `Ctrl+Ñ` | Abre y cierra la terminal |
| `Ctrl+S` | Guarda (compilar sin guardar es el error clásico) |
| `Ctrl+P` | Abre un archivo escribiendo parte de su nombre |
| `Ctrl+Mayús+P` | Busca cualquier orden de VS Code |
| `Ctrl+B` | Muestra u oculta la barra lateral |
| `Ctrl+Mayús+F` | Busca en todos los archivos |
| `Ctrl+Ç` | Comenta o descomenta las líneas seleccionadas |
| `Alt+↑` y `Alt+↓` | Mueve la línea actual |
| `Ctrl+D` | Selecciona la siguiente aparición de la palabra |
| `F12` | Va a la definición de una función |
| `Ctrl++` y `Ctrl+-` | Aumenta y reduce el tamaño de todo |

En la terminal, `↑` recupera la última orden y `Tab` completa los nombres de archivo.
`Ctrl+Ñ` y `Ctrl+Ç` son para teclado español; con otro teclado, los encontrarás con
`Ctrl+Mayús+P`.

## Ejercicio

1. Añade `x = 2.5` y `print *, x` antes del `end program`. Compila. ¿Qué error da?
2. Quita `implicit none` y compila de nuevo. Ahora funciona: las variables que
   empiezan por `i, j, k, l, m, n` son enteras y las demás, reales.
3. Cambia `x` por `n`. ¿Qué imprime? Imagina ahora una errata en el nombre de una
   variable en un programa de mil líneas.
