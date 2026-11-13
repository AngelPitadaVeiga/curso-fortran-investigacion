# Unidad 05 · Euler

Se integra el oscilador de Van der Pol,

```
x' = y
y' = -mu (x² - 1) y - x
```

que tiene un ciclo límite estable: una órbita cerrada hacia la que convergen las órbitas próximas.

| | Fórmula | Cálculo en cada paso |
|---|---|---|
| Euler explícito | `u_{k+1} = u_k + h F(u_k)` | una operación directa |
| Euler implícito | `u_{k+1} = u_k + h F(u_{k+1})` | un sistema no lineal, resuelto con Newton |

Los programas integran hasta `t = 3000` (unos 450 periodos) con `h = 0.01` y escriben un punto cada
0.1 de tiempo (uno por paso, si `h` es mayor). El tiempo es largo a propósito: la unidad 06 muestra
qué le pasa a Euler al cabo de muchos periodos.

```bash
gfortran euler_explicito.f90 -o euler_explicito
./euler_explicito
gfortran euler_implicito.f90 -o euler_implicito
./euler_implicito
gfortran referencia.f90 -o referencia
./referencia
```

```
Euler explicito: 300000 pasos. Resultados en euler_explicito.dat
Estado final (x, y) =   1.920160E+00 -4.701437E-01
Euler implicito: 300000 pasos. Resultados en euler_implicito.dat
Estado final (x, y) =  -1.575844E+00  7.303223E-01
Iteraciones de Newton en el ultimo paso: 3
Referencia (RK4): 3000000 pasos. Resultados en referencia.dat
Estado final (x, y) =  -1.146986E+00 -2.564263E+00
```

`referencia.f90` calcula lo mismo con Runge–Kutta de orden 4 y `h = 0.001` (se explica en la
unidad 09). Con ese paso es mucho más preciso que Euler, y sirve para medir sus errores.

## Euler explícito

```fortran
do k = 1, n_pasos
    u = u + h * campo(u)
    if (mod(k, paso_escritura) == 0) write(unidad, '(3es24.16)') k * h, u
end do
```

`u = u + h * campo(u)` es la fórmula del método, con `u` como array de dos componentes. La función
`campo` está después de `contains`: los procedimientos internos de un programa pueden usar sus
variables, y por eso `campo` conoce `mu`.

## Euler implícito

Solo cambia una línea del bucle, que ahora llama a una subrutina:

```fortran
call paso_euler_implicito(u, h, iteraciones)
```

Una **función** devuelve un valor y se usa en una expresión, como `campo(u)`. Una **subrutina** se
invoca con `call` y devuelve sus resultados modificando los argumentos, lo que conviene cuando hay
más de uno: aquí, el estado nuevo y las iteraciones de Newton.

```fortran
subroutine paso_euler_implicito(u, h, iteraciones)
    double precision, intent(inout) :: u(2)     ! entra u_k y sale u_{k+1}
    double precision, intent(in) :: h           ! solo se lee
    integer, intent(out) :: iteraciones         ! solo se escribe
```

Cada paso exige resolver `G(z) = z - u - h F(z) = 0`. Se usa Newton con la matriz `I - h J(z)`, donde
`J` es el jacobiano de `F`. La matriz es de 2×2 y se resuelve con la regla de Cramer. Newton parte del
estado anterior y converge en tres o cuatro iteraciones.

## `intent`

Los argumentos se pasan por referencia, sin copiarlos, y un procedimiento podría modificar cualquiera.
`intent` declara el uso previsto, y el compilador lo comprueba.

| | Al entrar | Dentro del procedimiento |
|---|---|---|
| `intent(in)` | tiene un valor | solo se lee; modificarlo es un error de compilación |
| `intent(out)` | se considera indefinido | hay que asignarle un valor |
| `intent(inout)` | tiene un valor | se lee y se modifica |

## Pendiente

Cambiar `mu`, `h` o `t_final` obliga a recompilar (unidad 07). Los números del estado final no dicen
si la solución es correcta (unidad 06). Euler tiene orden 1, y la unidad 06 muestra su consecuencia.

## Ejercicios

1. Con `mu = 5` y `t_final = 50` las oscilaciones son de relajación. Busca el mayor `h` con el que
   cada programa sigue funcionando.
2. Escribe una subrutina `paso_euler_explicito(u, h)` con los `intent` correctos y llámala desde el
   bucle.
3. Intenta modificar `h` dentro de `paso_euler_implicito` y lee el mensaje del compilador.
4. Haz que el programa implícito imprima el máximo de iteraciones de Newton de toda la simulación y
   comprueba si depende de `h`.
