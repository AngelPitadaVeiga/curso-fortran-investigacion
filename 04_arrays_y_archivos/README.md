# Unidad 04 · Arrays y archivos

Aquí es donde Fortran empieza a lucirse. Si vienes de Matlab o de Julia, casi todo te va a
sonar.

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
double precision :: v(5), w(5)
double precision :: a(2, 3)

v = [1.0d0, 2.0d0, 3.0d0, 4.0d0, 5.0d0]
w = 2 * v + 1
```

| Quiero... | Fortran | Julia | Matlab |
|---|---|---|---|
| un corte | `v(2:4)` | `v[2:4]` | `v(2:4)` |
| un corte con paso | `v(1:5:2)` | `v[1:2:5]` | `v(1:2:5)` |
| una columna | `a(:, 2)` | `a[:, 2]` | `a(:, 2)` |
| multiplicar elemento a elemento | `v * w` | `v .* w` | `v .* w` |
| producto de matrices | `matmul(a, b)` | `a * b` | `a * b` |
| producto escalar | `dot_product(v, w)` | `dot(v, w)` | `dot(v, w)` |

Ojo con el paso en los cortes: en Fortran va al final, y en Julia y Matlab, en medio.

Los índices empiezan en 1, pero puedes elegir: `x(0:n)` va de `x(0)` a `x(n)`, que es muy
cómodo para escribir `u_0, ..., u_n` como en las fórmulas.

Las matrices se guardan por columnas, como en Julia y Matlab, y al revés que en C. Por eso en
este curso cada estado de una trayectoria ocupará una columna.

## `matrices.f90`: matrices dinámicas

Casi nunca se conoce el tamaño de los datos cuando escribes el programa, así que lo normal es
declarar el array con `allocatable` y reservar la memoria cuando ya sabes cuánta hace falta:

```fortran
double precision, allocatable :: a(:, :)    ! dos dimensiones, tamaño por decidir

read *, n
allocate(a(n, n))                           ! ahora sí se reserva la memoria
```

Cuatro cosas que ayudan:

- La memoria se libera sola cuando la variable deja de existir. No hay `free` ni `delete`, y
  tampoco fugas.
- Si asignas un array entero a uno `allocatable`, se reserva solo con el tamaño que toca:
  `b = matmul(a, a)` no necesita `allocate`.
- Para cambiar de tamaño haces `deallocate(a)` y otro `allocate`.
- `allocated(a)` dice si ya tiene memoria, y `allocate(a(n, n), stat=estado)` te deja
  comprobar si la reserva ha fallado en vez de parar el programa.

El caso que más vamos a usar es guardar una trayectoria con un estado en cada columna:

```fortran
allocate(u(2, 0:n_pasos))       ! u(:, k) es el estado en el paso k
```

También puedes hacer crecer un vector con `v = [v, x]`. Es cómodo, pero copia el vector entero
cada vez, así que en un bucle largo es lento. Si sabes cuántos elementos habrá, resérvalos
desde el principio.

## `tabla.f90`: escribir un archivo

```fortran
open(newunit=unidad, file="tabla.dat", status="replace", action="write")
write(unidad, '(a)') '#          x              sin(x)              cos(x)'
do i = 0, n
    write(unidad, '(3es20.10)') x(i), sin(x(i)), cos(x(i))
end do
close(unidad)
```

`newunit=` hace que Fortran elija un número de unidad libre, y `status="replace"` crea el
archivo o lo sobrescribe. `write` funciona como `print`, pero hacia el archivo. La primera línea
empieza por `#` para que Python, Julia o Matlab sepan que es un comentario.

Así vamos a trabajar durante todo el curso: Fortran calcula y escribe columnas, y otro programa
las dibuja.

## Ejercicios

1. Calcula la norma de `v` de tres formas: `sqrt(sum(v**2))`, `sqrt(dot_product(v, v))` y
   `norm2(v)`.
2. En `matrices.f90`, construye la matriz de Hilbert, `a(i, j) = 1/(i + j - 1)`, e imprime la
   suma de todos sus elementos.
3. Haz que `tabla.f90` pregunte cuántos puntos quieres, con `x` como array `allocatable`.
