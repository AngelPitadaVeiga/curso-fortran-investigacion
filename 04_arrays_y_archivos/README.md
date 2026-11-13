# Unidad 04 · Arrays y archivos

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

El paso de un corte va al final en Fortran y en medio en Julia y Matlab. Los índices empiezan en 1,
pero se puede elegir otro inicio: `x(0:n)` va de `x(0)` a `x(n)`. Las matrices se guardan por columnas,
como en Julia y Matlab y al contrario que en C; por eso en el curso cada estado de una trayectoria
ocupa una columna.

## `matrices.f90`: matrices dinámicas

El tamaño de los datos casi nunca se conoce al escribir el programa. Se declara el array con
`allocatable` y se reserva la memoria cuando se conoce el tamaño:

```fortran
double precision, allocatable :: a(:, :)
read *, n
allocate(a(n, n))
```

- La memoria se libera sola cuando la variable deja de existir: no hay `free` ni `delete`.
- Al asignar un array entero a uno `allocatable`, este se reserva con el tamaño necesario:
  `b = matmul(a, a)` no requiere `allocate`.
- `deallocate(a)` y un nuevo `allocate` cambian el tamaño. `allocated(a)` indica si hay memoria, y
  `allocate(a(n, n), stat=estado)` permite comprobar si la reserva falló.
- `v = [v, x]` hace crecer un vector, pero copia el vector entero cada vez. En bucles largos conviene
  reservar el tamaño desde el principio.

El caso más frecuente del curso es guardar una trayectoria con un estado por columna:

```fortran
allocate(u(2, 0:n_pasos))       ! u(:, k) es el estado en el paso k
```

## `tabla.f90`: escritura de un archivo

```fortran
open(newunit=unidad, file="tabla.dat", status="replace", action="write")
write(unidad, '(a)') '#          x              sin(x)              cos(x)'
do i = 0, n
    write(unidad, '(3es20.10)') x(i), sin(x(i)), cos(x(i))
end do
close(unidad)
```

`newunit=` elige un número de unidad libre y `status="replace"` crea o sobrescribe el archivo. La
primera línea empieza por `#` para que Python, Julia y Matlab la traten como comentario. Fortran
calcula y escribe columnas, y otro programa las dibuja.

## Ejercicios

1. Calcula la norma de `v` de tres maneras: `sqrt(sum(v**2))`, `sqrt(dot_product(v, v))` y
   `norm2(v)`.
2. En `matrices.f90`, construye la matriz de Hilbert, `a(i, j) = 1/(i + j - 1)`, e imprime la suma de
   todos sus elementos.
3. Haz que `tabla.f90` pregunte el número de puntos y use `x` como array `allocatable`.
