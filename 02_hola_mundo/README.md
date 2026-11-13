# Unidad 02 · Hola, mundo

```fortran
program hola
    implicit none
    print *, "Hola, mundo"
end program hola
```

```powershell
gfortran hola.f90 -o hola
.\hola
```

En Linux, macOS y en la terminal de MSYS2, `./hola`. La compilación y la ejecución son dos pasos,
como en C++ y a diferencia de Julia o Matlab. Una vez generado, el ejecutable funciona sin el
compilador.

`program` y `end program` delimitan el programa principal. `print *` escribe en pantalla, y el
asterisco deja el formato al compilador, por lo que sale un espacio antes del texto. `implicit none`
obliga a declarar todas las variables y debe escribirse siempre. Fortran no distingue entre `PRINT` y
`print`; en el curso todo va en minúsculas.

## VS Code

Con la carpeta del curso abierta, VS Code propone instalar las extensiones de la
[unidad 01](../01_instalacion/). Atajos útiles:

| Atajo | Acción |
|---|---|
| `Ctrl+Ñ` | Abre y cierra la terminal (teclado inglés: `` Ctrl+` ``) |
| `Ctrl+S` | Guarda. Compilar sin guardar compila la versión anterior |
| `Ctrl+P` | Abre un archivo por parte de su nombre |
| `Ctrl+Mayús+P` | Busca cualquier orden de VS Code |
| `Ctrl+Mayús+F` | Busca un texto en todos los archivos |
| `F12` | Va a la definición de una función |
| `Ctrl++` y `Ctrl+-` | Aumenta y reduce el tamaño de todo |

El atajo para comentar depende del teclado; está en *Editar → Alternar comentario de línea*.

## Ejercicio

1. Añade `x = 2.5` y `print *, x` antes de `end program`. El compilador da un error porque `x` no
   está declarada.
2. Quita `implicit none`. Ahora compila: Fortran asigna el tipo por la primera letra, de modo que las
   variables que empiezan por `i, j, k, l, m, n` son enteras y las demás, reales.
3. Cambia `x` por `n` en las dos líneas y mira el valor impreso. Piensa qué pasaría con un error de
   escritura en un nombre dentro de un programa de mil líneas.
