# Unidad 03 · Variables, tipos y bucles

Lo mínimo para empezar a calcular: declarar variables, elegir la precisión, tomar
decisiones y repetir cosas. Son dos programas de un solo archivo.

```bash
gfortran tipos.f90 -o tipos
./tipos
gfortran heron.f90 -o heron
./heron
```

## Una línea que verás mucho

Casi todos los programas del curso empiezan así:

```fortran
use iso_fortran_env, only: real64
```

Merece la pena pararse en ella, porque es la única que vas a copiar sin parar:

- **`use`** importa algo de un módulo. Es como `using` en Julia o `#include` en C++.
- **`iso_fortran_env`** es un módulo que trae de serie todo compilador de Fortran.
  No hay que instalar nada.
- **`only: real64`** dice que solo queremos ese nombre. Así, leyendo el principio
  del archivo, sabes de dónde viene cada cosa.
- **`real64`** es un número que identifica al tipo real de 64 bits, y por eso se
  escribe `real(real64)`. Sin esta línea, el compilador no sabe qué es `real64`.

Es necesaria porque `real` a secas tiene solo 32 bits, unas 7 cifras, que no bastan
para hacer numérica. En códigos de otras personas la verás como
`use, intrinsic :: iso_fortran_env`, que significa lo mismo.

## `tipos.f90`

| Tipo | Ejemplo | En Julia | En C++ |
|---|---|---|---|
| `integer` | `n = 7` | `Int32` | `int` |
| `real(real64)` | `b = 0.1_real64` | `Float64` | `double` |
| `logical` | `.true.` | `Bool` | `bool` |
| `character(len=20)` | `"Van der Pol"` | `String` | `std::string` |

Las declaraciones van todas al principio, antes de la primera instrucción.

Hay dos trampas en las que caerás, y que el programa enseña:

**La división entera.** `7/2` vale `3`. Basta con que uno de los dos sea real:
`7/2.0_real64` vale `3.5`.

**Las constantes sin sufijo.** `b = 0.1` no guarda 0,1 en doble precisión: la constante
`0.1` es de simple precisión y se convierte después. Hay que escribir `0.1_real64`.

```
 b = 0.1         ->  0.10000000149011612
 b = 0.1_real64  ->  0.10000000000000001
```

## `heron.f90`

Calcula la raíz cuadrada de 2 con el método de Herón, que es Newton para `x² − 2 = 0`:

```fortran
do k = 1, max_iter
    x_nuevo = 0.5_real64 * (x + a / x)
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

Mira la columna del error: el número de cifras correctas se duplica en cada paso.

Algunas cosas que conviene recordar:

- `do k = 1, n` incluye `n`. `exit` sale del bucle y `cycle` salta a la siguiente vuelta.
- "Distinto de" se escribe `/=`, porque `!` empieza un comentario.
- La potencia es `x**2`, no `x^2`.
- `parameter` declara una constante que el compilador no deja modificar.
- En los formatos, `i5` es un entero en 5 columnas, `f22.16` un real con 16 decimales,
  `es10.2` notación científica y `a` texto.

## Ejercicios

1. Cambia `real64` por `real32` en todo `heron.f90`, sufijos incluidos. ¿Cuántas
   cifras correctas obtienes? ¿Qué pasa con la tolerancia de `1.0e-15`?
2. Calcula la raíz cúbica: Newton para `x³ − a = 0` da `x_{k+1} = (2 x_k + a / x_k²) / 3`.
3. Calcula `1 + 1/2² + 1/3² + ... + 1/n²` con `n = 1000000` y compárala con `π²/6`.
   Hay dos trampas: `1/i**2` es una división entera, e `i**2` no cabe en un entero de
   32 bits si `i` es grande. Pista: `pi = acos(-1.0_real64)`.
