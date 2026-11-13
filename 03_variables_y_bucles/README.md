# Unidad 03 · Variables, tipos y bucles

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

Las declaraciones van al principio del programa, antes de la primera instrucción.

`real` ocupa 32 bits y da unas siete cifras, insuficientes para cálculo científico. En el curso se
usa siempre `double precision`: 64 bits, unas dieciséis cifras, y no necesita importar nada. En
códigos de otras personas aparecen `real(real64)` y `real(8)`, que también piden 64 bits. El primero
necesita `use iso_fortran_env, only: real64`, y el segundo no está garantizado por el estándar.

## Dos errores frecuentes

`tipos.f90` reproduce los dos primeros errores de quien llega desde otro lenguaje.

**División entera.** `7/2` vale `3`. Basta con que un operando sea real: `7/2.0d0` vale `3.5`.

**Constantes sin sufijo.** `b = 0.1` no guarda 0,1 en doble precisión: la constante `0.1` es de
simple precisión y se convierte después. Hay que escribir `0.1d0`. En Matlab y en Julia `0.1` ya es
doble, y de ahí el error al traducir código.

```
 b = 0.1    ->  0.10000000149011612
 b = 0.1d0  ->  0.10000000000000001
```

## `heron.f90`

Raíz cuadrada de 2 con el método de Herón, que es Newton para `x² − 2 = 0`:

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

El número de cifras correctas se duplica en cada iteración.

Sintaxis: `do k = 1, n` incluye `n`; `exit` abandona el bucle. La desigualdad es `/=`, porque `!` inicia
un comentario, y la potencia es `x**2`. `parameter` declara una constante. En los formatos, `i5` es un
entero en 5 columnas, `f22.16` un real con 16 decimales, `es10.2` notación científica y `a` texto.

## Ejercicios

1. En `heron.f90`, cambia `double precision` por `real` y quita los `d0`. Cuenta las cifras correctas
   y explica qué ocurre con la tolerancia `1.0d-15`.
2. Calcula la raíz cúbica: Newton para `x³ − a = 0` da `x_{k+1} = (2 x_k + a / x_k²) / 3`.
3. Suma `1 + 1/2² + 1/3² + ...` hasta `n = 1000000` y compara con `π²/6` (`acos(-1.0d0)` da `π`). Hay
   dos trampas: `1/i**2` es una división entera, e `i**2` desborda 32 bits cuando `i` es grande.
