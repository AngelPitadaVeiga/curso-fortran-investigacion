# Unidad 05 · Euler

Por fin una simulación de verdad. Vamos a integrar el oscilador de Van der Pol,

```
x' = y
y' = -mu (x² - 1) y - x
```

que tiene un ciclo límite estable: una órbita cerrada que atrae a todas las de alrededor. Lo
resolvemos de dos maneras, con dos programas que se parecen mucho.

| | Fórmula | Cada paso |
|---|---|---|
| Euler explícito | `u_{k+1} = u_k + h F(u_k)` | una cuenta directa |
| Euler implícito | `u_{k+1} = u_k + h F(u_{k+1})` | resolver un sistema no lineal con Newton |

```bash
gfortran euler_explicito.f90 -o euler_explicito
./euler_explicito
gfortran euler_implicito.f90 -o euler_implicito
./euler_implicito
```

```
Euler explicito: 3000 pasos. Resultados en euler_explicito.dat
Estado final (x, y) =  -1.589594E+00  7.366960E-01
Euler implicito: 3000 pasos. Resultados en euler_implicito.dat
Estado final (x, y) =  -1.232878E+00  9.693410E-01
Iteraciones de Newton en el ultimo paso: 3
```

Los dos escriben sus resultados en columnas, pero de momento no los vamos a dibujar: eso
será en la unidad siguiente. Con los números del estado final ya se ve que los dos métodos no
dan lo mismo.

## Euler explícito

Abre `euler_explicito.f90`. Tiene tres partes: los parámetros como constantes, el bucle y
la función `campo`, que está después de `contains`.

```fortran
do k = 1, n_pasos
    u = u + h * campo(u)
    write(unidad, '(3es24.16)') k * h, u
end do
```

La línea `u = u + h * campo(u)` es la fórmula del método, tal cual, con `u` como un array de
dos componentes.

Lo que va después de `contains` son procedimientos internos del programa, que pueden usar sus
variables y constantes. Por eso `campo` conoce `mu` sin que se lo pasemos.

## Euler implícito

Ábrelo al lado del anterior. Solo cambia una línea dentro del bucle, en la que ahora llamamos
a una subrutina con `call`:

```fortran
do k = 1, n_pasos
    call paso_euler_implicito(u, h, iteraciones)
    write(unidad, '(3es24.16)') k * h, u
end do
```

Fortran tiene dos clases de procedimientos. Una **función** devuelve un valor y se usa dentro
de una expresión, como `campo(u)`. Una **subrutina** se llama con `call` y devuelve sus
resultados modificando los argumentos. Es lo natural cuando hay más de un resultado, y aquí
queremos dos: el nuevo estado y las iteraciones que ha necesitado Newton.

```fortran
subroutine paso_euler_implicito(u, h, iteraciones)
    double precision, intent(inout) :: u(2)     ! entra u_k y sale u_{k+1}
    double precision, intent(in) :: h           ! solo se lee
    integer, intent(out) :: iteraciones         ! solo se escribe
    ...
```

La incógnita aparece a los dos lados de la fórmula, así que en cada paso hay que resolver
`G(z) = z - u - h F(z) = 0`. Se hace con el método de Newton, cuya matriz es `I - h J(z)`, con
`J` el jacobiano de `F`. Como es de 2x2, la resolvemos con la regla de Cramer. Parte del
estado anterior, que ya está muy cerca de la solución, y con tres o cuatro iteraciones basta.

## `intent`: para qué sirve

En Fortran los argumentos se pasan por referencia, sin copiar nada, así que un procedimiento
podría modificar cualquiera de los que recibe. `intent` te deja declarar qué piensas hacer con
cada uno, y el compilador lo comprueba.

| | Al entrar | Dentro del procedimiento |
|---|---|---|
| `intent(in)` | tiene un valor | solo se lee. Intentar modificarlo da un error de compilación |
| `intent(out)` | se considera indefinido | hay que darle un valor |
| `intent(inout)` | tiene un valor | se lee y se modifica |

Ponlo siempre. Sirve de documentación, y evita errores que luego cuesta mucho encontrar.

## Lo que todavía no nos gusta

- Para cambiar `mu` o `h` hay que recompilar.
- Euler es un método de orden 1, y eso se paga enseguida con pasos no demasiado pequeños.
- Hace falta ver las soluciones, no solo leer los números.

Lo último lo arreglamos ahora mismo, en la unidad 06. Lo primero, en la 07.

## Ejercicios

1. Pon `mu = 5` y `t_final = 50`: son oscilaciones de relajación. Cambia `h` en los dos
   programas hasta ver qué tamaño de paso aguanta cada uno.
2. Escribe una subrutina `paso_euler_explicito(u, h)` con los `intent` correctos y úsala en el
   bucle con `call`.
3. Intenta modificar `h` dentro de `paso_euler_implicito`. ¿Qué dice el compilador?
4. Haz que el programa implícito imprima el máximo de iteraciones de Newton de toda la
   simulación. ¿Depende de `h`?
