# Formatos de `print` y `write`

`print *` escribe con el formato que decide el compilador: cómodo para probar, pero con anchos y
número de cifras que no controlamos.

```fortran
print *, 'x =', x, ' k =', k
```

```
 x =  0.33333333333333331       k =          42
```

Para elegir cómo sale cada número se escribe un formato entre comillas y paréntesis, con un
descriptor por cada dato:

```fortran
print '(a, f8.4, a, i0)', 'x =', x, '   k = ', k
```

```
x =  0.3333   k = 42
```

`write` admite el mismo formato. `print fmt, ...` equivale a `write(*, fmt) ...`, y para un archivo
basta cambiar `*` por la unidad: `write(unidad, '(3es24.16)') t, x, y`.

## Descriptores

En la tabla, `w` es el ancho total del campo (en caracteres) y `d` el número de decimales. Las barras
de los ejemplos marcan dónde empieza y acaba el campo.

| Descriptor | Para | Ejemplo | Salida |
|---|---|---|---|
| `a` | texto, con su longitud | `'(a)'`, `'Hola'` | `Hola` |
| `aw` | texto en `w` columnas, alineado a la derecha | `'(a10)'`, `'rk4'` | `\|       rk4\|` |
| `iw` | entero en `w` columnas | `'(i5)'`, `42` | `\|   42\|` |
| `i0` | entero con las columnas justas | `'(i0)'`, `42` | `\|42\|` |
| `fw.d` | real con `d` decimales | `'(f10.4)'`, `1/3` | `\|    0.3333\|` |
| `f0.d` | real con `d` decimales, ancho justo | `'(f0.3)'`, `1/3` | `\|.333\|` |
| `esw.d` | real en notación científica | `'(es12.4)'`, `1/3` | `\|  3.3333E-01\|` |
| `lw` | lógico (`T` o `F`) | `'(l2)'`, `.true.` | `\| T\|` |
| `nx` | `n` espacios | `'(i3, 3x, i3)'`, `1, 3` | `  1     3` |

Los números se alinean a la derecha y se rellenan con espacios por la izquierda. Si no caben en el
ancho pedido, Fortran no lo amplía: escribe asteriscos.

```fortran
print '(i3)', 12345            ! ***
print '(f5.1)', 123456.0d0     ! *****
```

Unas cuantas observaciones:

- `es` deja una cifra antes del punto (`3.3333E-01`). Existe también `e`, que escribe `0.3333E+00`,
  más difícil de leer; en el curso solo se usa `es`.
- En `esw.d` hacen falta al menos `d + 7` columnas: signo, una cifra, el punto, `d` decimales y
  `E+01`. Con `d + 8` queda además un espacio de separación, que es lo que hacen `es16.8` y
  `es24.16`.
- Con exponentes de tres cifras desaparece la `E`: `1.0d-150` en `es12.4` sale `1.0000-150`. Python
  no lo lee como número. No pasa en el curso, pero conviene saberlo antes de escribir cantidades muy
  grandes o muy pequeñas a un archivo.
- `f0.d` no escribe el cero antes del punto (`.333`). En el curso se usa para mensajes cortos, como
  `f0.1` en `error_indice.f90`.

## Repetir y agrupar

Un número delante del descriptor lo repite: `3es24.16` es lo mismo que `es24.16, es24.16, es24.16`.
Un grupo entre paréntesis también se puede repetir, y `*` lo repite tantas veces como haga falta:

```fortran
print '(5f6.1)', v                              !    1.0   2.0   3.0   4.0   5.0
print '(a, 2(1x, i0))', 'shape =', 3, 4         ! shape = 3 4
print '(*(es12.4))', v                          ! cualquier número de columnas
```

`*(...)` es útil cuando el número de columnas depende de los datos, como en `09_runge_kutta/orden.f90`,
que escribe `h` y un error por método.

Si hay más datos que descriptores, el formato vuelve a empezar en una línea nueva. Con `v` de cinco
elementos:

```fortran
print '(3f6.1)', v
```

```
   1.0   2.0   3.0
   4.0   5.0
```

Esto se aprovecha en `10_retrato_de_fases/retrato.f90`: `write(unidad, '(2es16.8)') u` escribe una
matriz de `2 × n` como `n` líneas de dos columnas. Al revés, si hay menos datos que descriptores, la
escritura se detiene en el primer descriptor que no tiene dato.

## Los formatos del curso

| Formato | Dónde | Por qué |
|---|---|---|
| `(a)` | mensajes, cabeceras de archivos | texto tal cual |
| `(a, i0, a)` | `'Escritas ', n + 1, ' filas'` | el entero sin huecos dentro de la frase |
| `(i5, f22.16, es10.2)` | `heron.f90` | iteración, valor con todas sus cifras y error |
| `(a, 5f6.1)` | `arrays.f90`, `matrices.f90` | vectores pequeños con valores sencillos |
| `(a, l2)` | `matrices.f90` | valor de `allocated(b)` |
| `(a, 2es14.6)` | estado final `(x, y)` | siete cifras bastan para leer en pantalla |
| `(a20, i10, f18.2, a)` | `orden.f90` | tabla con columnas alineadas |
| `(3es24.16)` | `euler.dat`, `referencia.dat` | datos para Python sin perder precisión |
| `(3es16.8)`, `(4es16.8)` | unidades 10 y 11 | datos para figuras |
| `(*(es16.8))` | `orden.f90` | número de columnas variable |

Para guardar un `double precision` y poder recuperarlo exacto hacen falta 17 cifras significativas,
y `es24.16` da 17 (una antes del punto y 16 después). Cuando el archivo es solo para una figura, ocho
o nueve cifras sobran y el archivo ocupa menos.

## Escribir en una variable de texto

`write` puede escribir en una variable `character` en vez de en pantalla o en un archivo. Así se
convierte un número en texto, como en `00_propaganda/benchmark/vdp_rk4.f90`:

```fortran
character(len=30) :: texto
write(texto, '(es12.5)') x
print '(a)', 'Tiempo: ' // trim(adjustl(texto)) // ' s'
```

`adjustl` quita los espacios de la izquierda y `trim` los de la derecha.
