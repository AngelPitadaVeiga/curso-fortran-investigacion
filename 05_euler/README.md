# Unidad 05 · Euler

Primera simulación. Se integra el oscilador de Van der Pol,

```
x' = y
y' = -mu (x² - 1) y - x
```

que tiene un ciclo límite estable: una órbita cerrada hacia la que convergen las órbitas próximas. Se
resuelve con dos métodos, en dos programas casi idénticos.

| | Fórmula | Cálculo en cada paso |
|---|---|---|
| Euler explícito | `u_{k+1} = u_k + h F(u_k)` | una operación directa |
| Euler implícito | `u_{k+1} = u_k + h F(u_{k+1})` | un sistema no lineal, resuelto con Newton |

Los dos programas integran hasta `t = 3000`, es decir, unos 450 periodos, con `h = 0.01`. El tiempo es
largo a propósito: la unidad 06 muestra qué ocurre con Euler al cabo de muchos periodos.

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

Los tres estados finales son distintos. En la unidad 06 se dibuja la causa. Cada programa escribe un
punto cada 0.1 de tiempo (o uno por paso, si `h` es mayor que 0.1).

## `referencia.f90`

El tercer programa calcula la misma solución con el método de Runge–Kutta de orden 4 y un paso diez
veces menor (`h = 0.001`). La unidad 09 explica el método. Por ahora basta saber que con ese paso es
mucho más preciso que Euler, y que sus resultados sirven de referencia para medir los errores de los
otros dos.

## Euler explícito

`euler_explicito.f90` tiene tres partes: los parámetros como constantes, el bucle principal y la
función `campo`, situada después de `contains`.

```fortran
do k = 1, n_pasos
    u = u + h * campo(u)
    if (mod(k, paso_escritura) == 0) write(unidad, '(3es24.16)') k * h, u
end do
```

La línea `u = u + h * campo(u)` es la fórmula del método, con `u` como array de dos componentes.

Los procedimientos situados después de `contains` son internos al programa y pueden usar sus variables
y constantes. Por eso `campo` conoce `mu` sin recibirlo como argumento.

## Euler implícito

`euler_implicito.f90` difiere del anterior en una línea del bucle, donde ahora se llama a una
subrutina con `call`:

```fortran
do k = 1, n_pasos
    call paso_euler_implicito(u, h, iteraciones)
    if (mod(k, paso_escritura) == 0) write(unidad, '(3es24.16)') k * h, u
end do
```

Fortran distingue dos clases de procedimientos. Una **función** devuelve un valor y se usa dentro de
una expresión, como `campo(u)`. Una **subrutina** se invoca con `call` y devuelve sus resultados
modificando los argumentos. Resulta adecuada cuando hay más de un resultado, como aquí: el estado
nuevo y el número de iteraciones de Newton.

```fortran
subroutine paso_euler_implicito(u, h, iteraciones)
    double precision, intent(inout) :: u(2)     ! entra u_k y sale u_{k+1}
    double precision, intent(in) :: h           ! solo se lee
    integer, intent(out) :: iteraciones         ! solo se escribe
    ...
```

La incógnita aparece en los dos miembros de la fórmula, de modo que cada paso exige resolver
`G(z) = z - u - h F(z) = 0`. Se usa el método de Newton, cuya matriz es `I - h J(z)`, con `J` el
jacobiano de `F`. La matriz es de 2×2 y se resuelve con la regla de Cramer. Newton parte del estado
anterior, que está cerca de la solución, y converge en tres o cuatro iteraciones.

## `intent`

En Fortran los argumentos se pasan por referencia, sin copiarlos, y un procedimiento podría modificar
cualquiera de los que recibe. `intent` declara el uso previsto de cada argumento, y el compilador lo
comprueba.

| | Al entrar | Dentro del procedimiento |
|---|---|---|
| `intent(in)` | tiene un valor | solo se lee; modificarlo es un error de compilación |
| `intent(out)` | se considera indefinido | hay que asignarle un valor |
| `intent(inout)` | tiene un valor | se lee y se modifica |

Conviene declararlo siempre. Documenta el uso de cada argumento y evita errores difíciles de localizar.

## Limitaciones de estos programas

- Cambiar `mu`, `h` o `t_final` exige recompilar. La unidad 07 lo resuelve.
- Los números del estado final no permiten juzgar si la solución es correcta. La unidad 06 dibuja las
  soluciones.
- Euler tiene orden 1. La unidad 06 muestra una consecuencia directa de ello.

## Ejercicios

1. Con `mu = 5` y `t_final = 50`, las oscilaciones son de relajación. Cambia `h` en los dos programas
   y busca el mayor paso con el que cada uno sigue funcionando.
2. Escribe una subrutina `paso_euler_explicito(u, h)` con los `intent` correctos y llámala con `call`
   dentro del bucle.
3. Intenta modificar `h` dentro de `paso_euler_implicito` y lee el mensaje del compilador.
4. Haz que el programa implícito imprima el máximo de iteraciones de Newton de toda la simulación.
   Comprueba si depende de `h`.
