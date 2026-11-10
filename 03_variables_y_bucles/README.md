# Unidad 03 · Variables, tipos y bucles

Lo mínimo para empezar a calcular: declarar variables, elegir la precisión, tomar decisiones
y repetir cosas. Son dos programas de un solo archivo.

```bash
gfortran tipos.f90 -o tipos
./tipos
gfortran heron.f90 -o heron
./heron
```

## Los tipos

| Tipo | Ejemplo | En Julia | En C++ |
|---|---|---|---|
| `integer` | `n = 7` | `Int32` | `int` |
| `double precision` | `b = 0.1d0` | `Float64` | `double` |
| `real` | `a = 0.1` | `Float32` | `float` |
| `logical` | `.true.` | `Bool` | `bool` |
| `character(len=20)` | `"Van der Pol"` | `String` | `std::string` |

Las declaraciones van todas al principio del programa, antes de la primera instrucción. Si
vienes de Julia o de Matlab, esto choca un poco.

Fíjate en que el real "normal" es de 32 bits, unas siete cifras, y no sirve para hacer cálculo
científico. Para eso usaremos siempre `double precision`, que son 64 bits y unas dieciséis
cifras. Es parte del lenguaje, así que no hay que importar nada.

Si miras códigos de otras personas, es posible que veas `real(real64)` o `real(8)`. Son
formas de pedir también 64 bits. La primera necesita una línea como
`use iso_fortran_env, only: real64` al principio del programa, y la segunda funciona en gfortran,
pero el estándar no garantiza que ese 8 sean 64 bits. Por sencillez, en el curso usamos
`double precision`.

## Las dos trampas

`tipos.f90` enseña las dos primeras cosas que le salen mal a todo el mundo.

**La división entera.** `7/2` vale `3`, porque son dos enteros. Basta con que uno sea real:
`7/2.0d0` vale `3.5`.

**Las constantes sin sufijo.** `b = 0.1` no guarda 0,1 en doble precisión: la constante `0.1`
es de simple precisión, y se convierte después. Hay que escribir `0.1d0`, donde `d0` significa
"doble". Es el error más típico al traducir código de Matlab o Julia, donde `0.1` ya es doble.

```
 b = 0.1    ->  0.10000000149011612
 b = 0.1d0  ->  0.10000000000000001
```

## `heron.f90`

Calcula la raíz cuadrada de 2 con el método de Herón, que es Newton para `x² − 2 = 0`:

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

Mira la columna del error: en cada paso el número de cifras correctas se duplica.

Unas cuantas cosas que conviene saber:

- `do k = 1, n` incluye el `n`. Con `exit` sales del bucle y con `cycle` saltas a la siguiente vuelta.
- "Distinto de" se escribe `/=`, porque `!` empieza un comentario. La potencia es `x**2`.
- `parameter` declara una constante, y el compilador no te deja modificarla.
- En los formatos, `i5` es un entero en 5 columnas, `f22.16` un real con 16 decimales, `es10.2`
  notación científica y `a` texto. Son feos al principio, pero te dan control total sobre lo que
  escribes.

## Ejercicios

1. Cambia `double precision` por `real` en `heron.f90`, y los `d0` por nada. ¿Cuántas cifras
   correctas consigues? ¿Qué le pasa a la tolerancia `1.0d-15`?
2. Haz que calcule la raíz cúbica. Newton para `x³ − a = 0` da `x_{k+1} = (2 x_k + a / x_k²) / 3`.
3. Suma `1 + 1/2² + 1/3² + ...` hasta `n = 1000000` y compáralo con `π²/6`. Cuidado con dos
   cosas: `1/i**2` es una división entera, e `i**2` se sale de un entero de 32 bits cuando `i`
   es grande. Para `π`, usa `acos(-1.0d0)`.
