# Formatos de `print` y `write`

Con `print *` el compilador decide el ancho y el número de cifras:

```fortran
print *, 'x =', x, ' k =', k
```

```
 x =  0.33333333333333331       k =          42
```

Para decidirlo uno mismo se escribe un formato entre comillas y paréntesis, con un descriptor por
cada dato:

```fortran
print '(a, f8.4, a, i0)', 'x =', x, '   k = ', k
```

```
x =  0.3333   k = 42
```

`write` usa los mismos formatos: `write(*, '(f8.4)') x` escribe en pantalla y
`write(unidad, '(f8.4)') x`, en un archivo.

## Descriptores

`w` es el ancho del campo, en caracteres, y `d` el número de decimales. Las barras marcan dónde
empieza y acaba el campo.

| Descriptor | Escribe | Ejemplo | Salida |
|---|---|---|---|
| `a` | texto | `'(a)'`, `'Hola'` | `Hola` |
| `aw` | texto en `w` columnas | `'(a10)'`, `'rk4'` | `\|       rk4\|` |
| `iw` | entero en `w` columnas | `'(i5)'`, `42` | `\|   42\|` |
| `i0` | entero, sin espacios | `'(i0)'`, `42` | `\|42\|` |
| `fw.d` | real con `d` decimales | `'(f10.4)'`, `1/3` | `\|    0.3333\|` |
| `esw.d` | real en notación científica | `'(es12.4)'`, `1/3` | `\|  3.3333E-01\|` |
| `lw` | lógico (`T` o `F`) | `'(l2)'`, `.true.` | `\| T\|` |
| `nx` | `n` espacios | `'(i3, 3x, i3)'`, `1, 3` | `  1     3` |

Los valores se alinean a la derecha. Si un número no cabe en el ancho pedido, se escriben asteriscos:

```fortran
print '(i3)', 12345            ! ***
```

En `esw.d`, el ancho tiene que ser al menos `d + 7`: signo, una cifra, el punto, los decimales y el
exponente (`E-01`).

## Repetir y agrupar

Un número delante de un descriptor lo repite, y lo mismo con un grupo entre paréntesis. Con `*`, se
repite tantas veces como datos haya:

```fortran
print '(5f6.1)', v                        ! igual que (f6.1, f6.1, f6.1, f6.1, f6.1)
print '(a, 2(1x, i0))', 'shape =', 3, 4   ! shape = 3 4
print '(*(es12.4))', v                    ! todos los elementos de v en una línea
```

Si hay más datos que descriptores, el formato vuelve a empezar en una línea nueva. Con `v` de cinco
elementos:

```fortran
print '(3f6.1)', v
```

```
   1.0   2.0   3.0
   4.0   5.0
```

## Escribir en una variable de texto

`write` también escribe en una variable `character`, lo que sirve para convertir un número en texto:

```fortran
character(len=20) :: texto
write(texto, '(es12.5)') x
print '(a)', 'x vale ' // trim(adjustl(texto))
```

`adjustl` quita los espacios de la izquierda y `trim`, los de la derecha.
