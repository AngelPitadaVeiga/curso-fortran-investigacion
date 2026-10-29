# Bloque 03 · Variables, tipos y bucles

Lo mínimo para escribir cálculos: declarar variables, elegir la precisión,
tomar decisiones con `if` y repetir con `do`. Dos programas de un solo
archivo; se compilan a mano, como el hola mundo.

```bash
gfortran -Wall tipos.f90 -o tipos
./tipos
gfortran -Wall heron.f90 -o heron
./heron
```

(En VS Code: abre el archivo y pulsa **Ctrl+Shift+B**.)

## `tipos.f90`: tipos básicos y dos trampas

| Tipo | Ejemplo | Equivale en Julia / C++ |
|---|---|---|
| `integer` | `n = 7` | `Int32` / `int` |
| `real(real64)` | `b = 0.1_real64` | `Float64` / `double` |
| `real(real32)` (o `real` a secas) | `a = 0.1` | `Float32` / `float` |
| `logical` | `.true.`, `.false.` | `Bool` / `bool` |
| `character(len=20)` | `"Van der Pol"` | `String` / `std::string` (pero de longitud fija) |

`real64` viene del módulo intrínseco `iso_fortran_env`:

```fortran
use, intrinsic :: iso_fortran_env, only: real64
```

Las **declaraciones van todas al principio**, antes de la primera
instrucción. Con `implicit none`, usar una variable no declarada es un error
de compilación.

**Trampa 1, la división entera.** `7/2` vale `3`. gfortran lo avisa con
`-Wall` (verás el aviso al compilar `tipos.f90`: es intencionado). Basta con
que uno de los dos operandos sea real: `7/2.0_real64` vale `3.5`.

**Trampa 2, constantes sin sufijo.** `b = 0.1` guarda en `b` (doble) la
constante `0.1` de **simple** precisión: `0.10000000149011612`. Hay que
escribir `0.1_real64`. Es el error más común al portar código de Matlab o
Julia, donde `0.1` ya es doble.

La salida (`print *`, formato libre):

```
 b = 0.1         ->  0.10000000149011612
 b = 0.1_real64  ->  0.10000000000000001

 epsilon(real32) =   1.19209290E-07
 epsilon(real64) =   2.2204460492503131E-016
```

## `heron.f90`: un bucle con criterio de parada

Raíz cuadrada de 2 con el método de Herón (Newton para `x² − 2 = 0`):

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

Convergencia cuadrática: el error pasa de `1e-3` a `1e-6` y a `1e-12`.

Lo que aparece:

- **`parameter`**: constante con nombre; el compilador impide modificarla.
- **`do k = 1, n ... end do`**: el contador avanza de 1 en 1 (incluye `n`).
  `do k = n, 1, -1` cuenta hacia atrás. `exit` sale del bucle y `cycle`
  salta a la siguiente iteración. `do ... end do` sin contador repite
  hasta un `exit`.
- **`if (...) then ... else if (...) then ... else ... end if`**; en una
  sola línea, sin `then`: `if (cond) exit`.
- Comparaciones: `==`, `/=` (distinto, no `!=`), `<`, `<=`, `>`, `>=`.
  Lógicos: `.and.`, `.or.`, `.not.`.
- **Formatos**: `i5` (entero en 5 columnas), `i0` (el ancho justo),
  `f22.16` (22 columnas, 16 decimales), `es10.2` (científica), `a` (texto).
  `print '(a, i0)', 'k = ', k` frente a `print *, 'k = ', k`.
- Potencia: `x**2` (no `x^2`). Funciones intrínsecas: `sqrt`, `abs`, `exp`,
  `log`, `sin`, `mod`, `max`, `min`...

## Ejercicios

1. En `heron.f90`, cambia `real64` por `real32` en todo el programa
   (también en los sufijos). ¿Cuántas cifras correctas obtienes? ¿Qué pasa
   con `tol = 1.0e-15`? (Pista: compáralo con `epsilon`.)
2. Modifica el método para calcular la raíz cúbica: Newton para
   `x³ − a = 0` da `x_{k+1} = (2 x_k + a / x_k²) / 3`.
3. Escribe `basilea.f90` que calcule `1 + 1/2² + 1/3² + ... + 1/n²` con
   `n = 1000000` y lo compare con el límite `π²/6`. Cuidado con `1/i**2`
   (división entera) y con `i**2` cuando `i` es grande (no cabe en un
   entero de 32 bits). Pista: `pi = acos(-1.0_real64)`.

<details>
<summary>Solución del ejercicio 3</summary>

```fortran
program basilea
    use, intrinsic :: iso_fortran_env, only: real64
    implicit none
    integer, parameter :: n = 1000000
    real(real64) :: suma, pi
    integer :: i

    pi = acos(-1.0_real64)
    suma = 0.0_real64
    do i = 1, n
        suma = suma + 1.0_real64 / real(i, real64)**2
    end do
    print '(a, f20.16)', 'Suma parcial: ', suma
    print '(a, f20.16)', 'pi**2/6     : ', pi**2 / 6
    print '(a, es10.2)', 'Diferencia  : ', pi**2 / 6 - suma    ! ~ 1/n
end program basilea
```

`real(i, real64)` convierte el entero a doble antes de elevarlo al
cuadrado: `1000000**2` desbordaría un entero de 32 bits.
</details>
