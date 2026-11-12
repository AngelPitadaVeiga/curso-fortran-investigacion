# Unidad 03 · Variables, tipos y bucles

Esta unidad presenta la declaración de variables, la elección de la precisión, las decisiones con
`if` y las repeticiones con `do`. Consta de dos programas, cada uno en un solo archivo.

```bash
gfortran tipos.f90 -o tipos
./tipos
gfortran heron.f90 -o heron
./heron
```

## Tipos

| Tipo | Ejemplo | En Julia | En C++ |
|---|---|---|---|
| `integer` | `n = 7` | `Int32` | `int` |
| `double precision` | `b = 0.1d0` | `Float64` | `double` |
| `real` | `a = 0.1` | `Float32` | `float` |
| `logical` | `.true.` | `Bool` | `bool` |
| `character(len=20)` | `"Van der Pol"` | `String` | `std::string` |

Todas las declaraciones van al principio del programa, antes de la primera instrucción. En Julia y en
Matlab no existe esa norma.

El tipo `real` ocupa 32 bits y da unas siete cifras decimales, insuficientes para el cálculo
científico. En el curso se usa siempre `double precision`, que ocupa 64 bits y da unas dieciséis cifras.
Forma parte del lenguaje y no requiere importar nada.

En códigos de otras personas aparecen también `real(real64)` y `real(8)`. Ambos piden 64 bits. El
primero necesita la línea `use iso_fortran_env, only: real64` al principio del programa. El segundo
funciona en gfortran, aunque el estándar no garantiza que el 8 equivalga a 64 bits. El curso usa
`double precision` porque no necesita ninguna línea adicional.

## Dos errores frecuentes

`tipos.f90` reproduce los dos primeros errores que cometen quienes llegan desde otros lenguajes.

**División entera.** `7/2` vale `3`, porque ambos operandos son enteros. Basta con que uno de ellos
sea real: `7/2.0d0` vale `3.5`.

**Constantes sin sufijo.** `b = 0.1` no guarda 0,1 en doble precisión. La constante `0.1` es de
simple precisión y se convierte a doble después de redondearla. La forma correcta es `0.1d0`, donde
`d0` indica doble precisión. En Matlab y en Julia la constante `0.1` ya es doble, y de ahí viene el
error al traducir código.

```
 b = 0.1    ->  0.10000000149011612
 b = 0.1d0  ->  0.10000000000000001
```

## `heron.f90`

Calcula la raíz cuadrada de 2 con el método de Herón, que es el método de Newton para `x² − 2 = 0`:

```fortran
do k = 1, max_iter
    x_nuevo = 0.5d0 * (x + a / x)
    print '(i5, f22.16, es10.2)', k, x_nuevo, abs(x_nuevo - sqrt(a))
    if (abs(x_nuevo - x) <= tol * x_nuevo) exit
    x = x_nuevo
end do
```

```
 iter                     x         error
    1    1.5000000000000000  8.58E-02
    2    1.4166666666666665  2.45E-03
    3    1.4142156862745097  2.12E-06
    4    1.4142135623746899  1.59E-12
    5    1.4142135623730949  2.22E-16
    6    1.4142135623730949  2.22E-16
Convergencia en 6 iteraciones.
```

En la columna del error, el número de cifras correctas se duplica en cada iteración.

Detalles de sintaxis:

- `do k = 1, n` incluye el valor `n`. `exit` abandona el bucle y `cycle` pasa a la siguiente vuelta.
- La desigualdad se escribe `/=`, porque `!` inicia un comentario. La potencia es `x**2`.
- `parameter` declara una constante, y el compilador impide modificarla.
- En los formatos, `i5` es un entero en 5 columnas, `f22.16` un real con 16 decimales, `es10.2` un
  número en notación científica y `a` un texto. Dan control completo sobre el formato de los archivos
  de datos.

## Ejercicios

1. Cambia `double precision` por `real` en `heron.f90` y elimina los `d0`. Cuenta las cifras correctas
   que se obtienen y explica qué ocurre con la tolerancia `1.0d-15`.
2. Calcula la raíz cúbica. El método de Newton para `x³ − a = 0` da
   `x_{k+1} = (2 x_k + a / x_k²) / 3`.
3. Suma `1 + 1/2² + 1/3² + ...` hasta `n = 1000000` y compara con `π²/6`. Hay dos trampas: `1/i**2`
   es una división entera, y `i**2` desborda un entero de 32 bits cuando `i` es grande. Para `π`,
   usa `acos(-1.0d0)`.
