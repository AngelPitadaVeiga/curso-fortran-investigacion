# Unidad 04 · Arrays y archivos

Aquí es donde Fortran empieza a brillar. Si vienes de Matlab o de Julia, casi todo
te resultará familiar.

```bash
gfortran arrays.f90 -o arrays
./arrays
gfortran matrices.f90 -o matrices
./matrices
gfortran tabla.f90 -o tabla
./tabla
```

## `arrays.f90`: operar sin bucles

```fortran
real(real64) :: v(5), w(5)
real(real64) :: a(2, 3)

v = [1.0_real64, 2.0_real64, 3.0_real64, 4.0_real64, 5.0_real64]
w = 2 * v + 1
```

| Quiero... | Fortran | Julia | Matlab |
|---|---|---|---|
| Un corte | `v(2:4)` | `v[2:4]` | `v(2:4)` |
| Un corte con paso | `v(1:5:2)` | `v[1:2:5]` | `v(1:2:5)` |
| Una columna | `a(:, 2)` | `a[:, 2]` | `a(:, 2)` |
| Multiplicar elemento a elemento | `v * w` | `v .* w` | `v .* w` |
| Producto de matrices | `matmul(a, b)` | `a * b` | `a * b` |
| Producto escalar | `dot_product(v, w)` | `dot(v, w)` | `dot(v, w)` |

Dos detalles:

- Los índices empiezan en 1, pero puedes elegir otra cosa: `x(0:n)` va de `x(0)` a
  `x(n)`. Es muy cómodo para escribir `u_0, ..., u_n` como en las fórmulas.
- Las matrices se guardan **por columnas**, como en Julia y Matlab. Por eso en el
  curso cada estado de una trayectoria ocupa una columna.

## `matrices.f90`: matrices dinámicas

Casi nunca se sabe el tamaño de los datos al escribir el programa, así que esta es
la forma normal de trabajar en numérica:

```fortran
real(real64), allocatable :: a(:, :)    ! dos dimensiones, tamaño por decidir

read *, n
allocate(a(n, n))                       ! ahora sí se reserva la memoria
```

Lo que debes saber:

- **Se liberan solas.** Cuando la variable deja de existir, su memoria se libera. No
  hay `free` ni `delete`, y tampoco fugas de memoria.
- **Se reservan solas al asignar.** Si `b` es `allocatable`, `b = matmul(a, a)` le da
  el tamaño justo sin necesidad de `allocate`.
- **Se pueden redimensionar**, con `deallocate(a)` y otro `allocate`.
- **`allocated(a)`** dice si ya tiene memoria, y **`allocate(a(n, n), stat=estado)`**
  deja comprobar si la reserva ha fallado en lugar de detener el programa.
- **`size(a, 1)`** y **`shape(a)`** dan sus dimensiones.

El caso que más vamos a usar es guardar una trayectoria, con un estado en cada
columna:

```fortran
allocate(u(2, 0:n_pasos))       ! u(:, k) es el estado en el paso k
```

También se puede hacer crecer un vector con `v = [v, x]`. Es cómodo, pero copia el
vector entero cada vez, así que evítalo en bucles largos: si sabes el tamaño,
resérvalo desde el principio.

## `tabla.f90`: escribir un archivo

```fortran
open(newunit=unidad, file="tabla.dat", status="replace", action="write")
write(unidad, '(a)') '#          x              sin(x)              cos(x)'
do i = 0, n
    write(unidad, '(3es20.10)') x(i), sin(x(i)), cos(x(i))
end do
close(unidad)
```

`newunit=` le pide a Fortran un número de unidad libre, `status="replace"` crea o
sobrescribe el archivo y `write` funciona como `print`, pero hacia el archivo. La
primera línea empieza por `#` para que Python, Julia o Matlab sepan que es un
comentario.

Así trabajaremos todo el curso: Fortran calcula y escribe columnas, y otro programa
las dibuja. Eso es justo lo que veremos en la siguiente unidad.

## Ejercicios

1. Calcula la norma de `v` de tres formas: `sqrt(sum(v**2))`,
   `sqrt(dot_product(v, v))` y `norm2(v)`.
2. En `matrices.f90`, construye la matriz de Hilbert, `a(i, j) = 1/(i + j - 1)`, e
   imprime la suma de sus elementos.
3. Haz que `tabla.f90` pida `n` por teclado, con `x` como array `allocatable`.
