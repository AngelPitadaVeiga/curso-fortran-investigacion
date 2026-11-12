# Unidad 04 · Arrays y archivos

Los arrays son la parte de Fortran más cercana a Matlab y a Julia. Esta unidad trata las operaciones
con arrays, las matrices dinámicas y la escritura de archivos.

```bash
gfortran arrays.f90 -o arrays
./arrays
gfortran matrices.f90 -o matrices
./matrices
gfortran tabla.f90 -o tabla
./tabla
```

## `arrays.f90`: operaciones sin bucles

```fortran
double precision :: v(5), w(5)
double precision :: a(2, 3)

v = [1.0d0, 2.0d0, 3.0d0, 4.0d0, 5.0d0]
w = 2 * v + 1
```

| Operación | Fortran | Julia | Matlab |
|---|---|---|---|
| corte | `v(2:4)` | `v[2:4]` | `v(2:4)` |
| corte con paso | `v(1:5:2)` | `v[1:2:5]` | `v(1:2:5)` |
| columna | `a(:, 2)` | `a[:, 2]` | `a(:, 2)` |
| producto elemento a elemento | `v * w` | `v .* w` | `v .* w` |
| producto de matrices | `matmul(a, b)` | `a * b` | `a * b` |
| producto escalar | `dot_product(v, w)` | `dot(v, w)` | `dot(v, w)` |

En los cortes, el paso va al final en Fortran y en medio en Julia y Matlab.

Los índices empiezan en 1, pero se puede elegir otro inicio: `x(0:n)` va de `x(0)` a `x(n)`, lo que
permite escribir `u_0, ..., u_n` igual que en las fórmulas.

Las matrices se guardan por columnas, como en Julia y Matlab y al contrario que en C. Por eso, en el
curso, cada estado de una trayectoria ocupa una columna.

## `matrices.f90`: matrices dinámicas

El tamaño de los datos casi nunca se conoce al escribir el programa. Se declara el array con
`allocatable` y se reserva la memoria cuando el tamaño ya se conoce:

```fortran
double precision, allocatable :: a(:, :)    ! dos dimensiones, tamaño sin decidir

read *, n
allocate(a(n, n))                           ! reserva la memoria
```

Propiedades de los arrays `allocatable`:

- La memoria se libera cuando la variable deja de existir. No hay `free` ni `delete`, y no se
  producen fugas.
- Al asignar un array entero a uno `allocatable`, este se reserva con el tamaño necesario:
  `b = matmul(a, a)` no requiere un `allocate` previo.
- Para cambiar el tamaño se ejecuta `deallocate(a)` y después otro `allocate`.
- `allocated(a)` indica si el array tiene memoria, y `allocate(a(n, n), stat=estado)` permite
  comprobar si la reserva ha fallado, en lugar de detener el programa.

El caso más frecuente en el curso es guardar una trayectoria con un estado por columna:

```fortran
allocate(u(2, 0:n_pasos))       ! u(:, k) es el estado en el paso k
```

Un vector puede crecer con `v = [v, x]`. Esa instrucción copia el vector completo cada vez, de modo
que en un bucle largo resulta lenta. Si se conoce el número de elementos, conviene reservarlos desde el
principio.

## `tabla.f90`: escritura de un archivo

```fortran
open(newunit=unidad, file="tabla.dat", status="replace", action="write")
write(unidad, '(a)') '#          x              sin(x)              cos(x)'
do i = 0, n
    write(unidad, '(3es20.10)') x(i), sin(x(i)), cos(x(i))
end do
close(unidad)
```

`newunit=` hace que Fortran elija un número de unidad libre, y `status="replace"` crea el archivo o
lo sobrescribe. `write` funciona como `print`, pero escribe en el archivo. La primera línea empieza por
`#` para que Python, Julia y Matlab la traten como un comentario.

Este es el esquema de trabajo del curso: Fortran calcula y escribe columnas, y otro programa las
dibuja.

## Ejercicios

1. Calcula la norma de `v` de tres maneras: `sqrt(sum(v**2))`, `sqrt(dot_product(v, v))` y
   `norm2(v)`.
2. En `matrices.f90`, construye la matriz de Hilbert, `a(i, j) = 1/(i + j - 1)`, e imprime la suma de
   todos sus elementos.
3. Modifica `tabla.f90` para que pregunte el número de puntos y use `x` como array `allocatable`.
