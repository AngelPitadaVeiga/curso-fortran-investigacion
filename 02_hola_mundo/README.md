# Bloque 02 · Hola, mundo

```fortran
program hola
    implicit none
    print *, "Hola, mundo"
end program hola
```

## Compilar a mano

En PowerShell (o en la terminal de MSYS2), dentro de esta carpeta:

```powershell
gfortran hola.f90 -o hola
.\hola
```

En Linux, macOS o MSYS2: `./hola`. Sale `Hola, mundo` (con un espacio
delante: ahora vemos por qué).

`gfortran` compila **antes** de ejecutar (*ahead of time*): genera
`hola.exe`, un ejecutable que no necesita ni el compilador ni el código
fuente para funcionar.

## Desde VS Code

Abre `hola.f90` y pulsa **Ctrl+Shift+B**: en las carpetas sin `Makefile`
(bloques 01 a 05) compila y ejecuta el archivo abierto; en las que tienen
`Makefile` (06 en adelante), hace `make run`.

## Qué significa cada línea

- **`program hola` ... `end program hola`**: el programa principal. Solo
  hay uno por ejecutable. Repetir el nombre tras `end program` es opcional,
  pero es buena costumbre.
- **`implicit none`**: obliga a declarar todas las variables. Sin ella,
  Fortran (por herencia de FORTRAN 77) da tipo automáticamente: las
  variables que empiezan por `i, j, k, l, m, n` son enteras y el resto
  reales. Una errata como `veloicdad = 1` crearía en silencio una variable
  nueva. **Ponla siempre** (en el ejercicio se ve por qué).
- **`print *, ...`**: escribe en pantalla con formato libre (`*`). El
  compilador decide el formato; por eso aparece un espacio inicial. Con
  formato explícito: `print '(a)', "Hola, mundo"`.
- Fortran **no distingue mayúsculas de minúsculas**: `PRINT`, `Print` y
  `print` son lo mismo. En este curso, todo en minúsculas.

## Comparación en una línea

| Lenguaje | Hola, mundo |
|---|---|
| Fortran | `program hola; print *, "Hola, mundo"; end program` |
| C++ | `#include <iostream>` + `int main() { std::cout << "Hola, mundo\n"; }` |
| Julia | `println("Hola, mundo")` |
| Matlab | `disp('Hola, mundo')` |

Fortran y C++ se compilan antes de ejecutar; Julia compila "justo a
tiempo" (JIT) la primera vez que llama a cada función; Matlab interpreta
(con su propio JIT).

## Ejercicio

1. Añade, antes de `print`, la línea `x = 2.5` y después `print *, x`.
   Compila: da un error, porque `x` no está declarada
   (`Symbol 'x' at (1) has no IMPLICIT type`).
2. Quita `implicit none` y vuelve a compilar: ahora funciona, porque `x` es
   real "por la inicial". Cambia `x` por `n` en las dos líneas: imprime
   `2`, porque `n` es entera y `2.5` se trunca sin avisar. Por eso
   `implicit none` siempre.
3. Vuelve a dejar el programa como estaba. En el bloque 03 se declaran
   las variables como es debido.
