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

Abre `hola.f90` y ejecuta la tarea **"Compilar y ejecutar archivo suelto"**
(Ctrl+Shift+P → *Tasks: Run Task*). Para los bloques con Makefile (03 en
adelante) basta con **Ctrl+Shift+B**.

## Qué significa cada línea

- **`program hola` ... `end program hola`**: el programa principal. Solo
  hay uno por ejecutable. Repetir el nombre tras `end program` es opcional,
  pero es buena costumbre.
- **`implicit none`**: obliga a declarar todas las variables. Sin ella,
  Fortran (por herencia de FORTRAN 77) da tipo automáticamente: las
  variables que empiezan por `i, j, k, l, m, n` son enteras y el resto
  reales. Una errata como `veloicdad = 1` crearía en silencio una variable
  nueva. **Ponla siempre** (en el bloque 06 se ve por qué).
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

Escribe `ejercicio.f90` que:

1. declare un entero `n = 10` y un real de doble precisión `suma`;
2. calcule `1 + 1/2² + 1/3² + ... + 1/n²` con un bucle `do`;
3. imprima el resultado y el valor exacto del límite, `pi²/6`.

Pistas: `use, intrinsic :: iso_fortran_env, only: real64`; los reales
dobles se declaran `real(real64) :: suma`; el bucle es
`do i = 1, n ... end do`; `pi = acos(-1.0_real64)`. ¡Cuidado con `1/i**2`!
(entero entre entero).

<details>
<summary>Solución</summary>

```fortran
program ejercicio
    use, intrinsic :: iso_fortran_env, only: real64
    implicit none
    integer :: i
    integer, parameter :: n = 10
    real(real64) :: suma, pi

    pi = acos(-1.0_real64)
    suma = 0.0_real64
    do i = 1, n
        suma = suma + 1.0_real64 / real(i, real64)**2   ! 1/i**2 seria division entera
    end do
    print *, "Suma parcial:", suma
    print *, "pi**2/6     :", pi**2 / 6
end program ejercicio
```

Prueba después con `n = 1000000`: es instantáneo. ¿Por qué se convierte `i` a
real antes de elevarlo al cuadrado? (Pista: `1000000**2` no cabe en un entero de 32 bits.)
</details>
