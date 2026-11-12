# Unidad 09 · Runge–Kutta

Euler tiene orden 1: pierde la fase en tiempos largos y falla con pasos moderados. Esta unidad reúne
cinco métodos en un módulo y permite elegir el que se usa desde el archivo de entrada:

| Método | Orden | Fórmula |
|---|---:|---|
| `euler` | 1 | `u + h F(u)` |
| `heun` | 2 | promedio de la pendiente al principio y al final del paso |
| `rk4` | 4 | Runge–Kutta clásico, con cuatro evaluaciones de `F` |
| `euler_implicito` | 1 | el de la unidad 05 |
| `trapecio` | 2 | versión implícita de Heun |

```
09_runge_kutta/
├── modelo.f90         el campo vectorial y su jacobiano
├── runge_kutta.f90    los métodos
├── principal.f90      el programa rk: lee, integra y escribe
├── orden.f90          el programa orden: mide el orden de cada método
├── entrada.nml, largo.nml, rigido_*.nml
├── Makefile
└── graficar.py, graficar_orden.py, graficar_rigido.py, retraso.py
```

```bash
make run                  # RK4 con entrada.nml
python graficar.py
```

El método se elige con `metodo` en `entrada.nml`: `euler`, `heun`, `rk4`, `euler_implicito` o
`trapecio`. No hace falta recompilar.

## Estructura del código

Cada método es una función que recibe el estado `u_k` y devuelve `u_{k+1}`. RK4 se escribe igual que en
los libros:

```fortran
function paso_rk4(u, mu, h) result(u_nuevo)
    double precision, intent(in) :: u(2), mu, h
    double precision :: u_nuevo(2), k1(2), k2(2), k3(2), k4(2)
    k1 = campo(u, mu)
    k2 = campo(u + h / 2 * k1, mu)
    k3 = campo(u + h / 2 * k2, mu)
    k4 = campo(u + h * k3, mu)
    u_nuevo = u + h / 6 * (k1 + 2 * k2 + 2 * k3 + k4)
end function paso_rk4
```

La subrutina `integrar` recorre los pasos y en cada uno elige la función con un `select case`, según
el nombre del método. Comparar un texto en cada paso no es lo más eficiente, pero el código se lee con facilidad, y en
estas unidades se da prioridad a eso.

Los dos métodos implícitos comparten la función `paso_implicito`, que tiene un parámetro `theta`:
`theta = 1` es Euler implícito y `theta = 1/2` es el trapecio. La función resuelve el sistema con
Newton, igual que en la unidad 05.

## Paso grande

En la unidad 06, Euler explícito explotaba con `h = 0.4`. Con `h = 0.4` y `rk4` en `entrada.nml`:

![RK4 con h = 0.4](figuras/rk4_h04.png)

El ciclo límite sale con amplitud 2,00.

## Tiempos largos

La unidad 06 midió el retraso de fase de Euler a `t = 3000`. `largo.nml` repite la simulación con el
método que se elija, y `retraso.py` lo compara con la referencia de la unidad 05 (que hay que haber
ejecutado):

```bash
./rk largo.nml
python retraso.py resultados/largo.dat
```

Retraso respecto a la referencia a `t ≈ 3000`, en periodos (un valor positivo es un retraso, y uno
negativo, un adelanto):

| Método | `h = 0.01` | `h = 0.1` |
|---|---:|---:|
| `euler` | 3,34 | 37,7 |
| `heun` | −0,012 | −0,91 |
| `rk4` | 0,000 | 0,005 |
| `euler_implicito` | −3,22 | −26,7 |
| `trapecio` | 0,006 | 0,58 |

RK4 con `h = 0.1` (30 000 pasos) conserva la fase mejor que Euler con `h = 0.01` (300 000 pasos), y
también que Euler con `h = 0.0001` en el mismo intervalo (su retraso a `t = 3000` es de 0,03
periodos, con 3·10⁷ pasos). Con `h = 0.01`, RK4 y el trapecio no pierden la fase de forma apreciable
en 450 periodos.

## Comprobación del orden

El orden de convergencia permite comprobar que un método está bien programado. Si un método tiene
orden `p`, al dividir `h` entre dos el error se divide por `2^p`. `make run-orden` integra hasta
`t = 1` con `h = 0.1, 0.05, 0.025, 0.0125`, compara con una referencia (RK4 con `h = 10⁻⁴`) y calcula
el orden:

```
            metodo   orden teorico   orden observado
euler                        1              0.99   OK
heun                         2              2.09   OK
rk4                          4              4.05   OK
euler_implicito              1              1.01   OK
trapecio                     2              2.00   OK
```

```bash
python graficar_orden.py
```

![Convergencia](figuras/orden.png)

En escala logarítmica cada método es una recta cuya pendiente es su orden. Un coeficiente mal
escrito cambia la pendiente. Si un orden se desvía más de 0,3 del teórico, el programa escribe
`FALLA` y termina con un código de error.

## Rigidez

Van der Pol con `mu = 1000` tiene dos escalas de tiempo muy distintas, y esa propiedad se llama
rigidez. Se comparan los métodos con el mismo paso, `h = 0.002`:

```bash
make run-rigido
python graficar_rigido.py
```

```
Metodo: euler_implicito   mu = 1000.0   h = 2.00E-03   pasos = 500000
Pasos hechos: 500000   estado final (x, y) =  -1.312748E+00  1.814911E-03
Metodo: trapecio   mu = 1000.0   h = 2.00E-03   pasos = 500000
Pasos hechos: 500000   estado final (x, y) =  -2.056631E+00  6.367805E-04
Metodo: rk4   mu = 1000.0   h = 2.00E-03   pasos = 500000
La solucion ha explotado en el paso 6, t = 1.20E-02
```

![Rigidez](figuras/rigido.png)

RK4, de orden 4, explota a los seis pasos. Los dos implícitos, de orden 1 y 2, llegan al final. En esa
zona el jacobiano tiene un autovalor de unos −3000, y RK4 solo es estable con `h` menor que `10⁻³`,
aunque la solución varíe despacio. El paso queda limitado por la estabilidad y no por la precisión.
Los métodos implícitos no tienen esa restricción.

Los dos implícitos son poco precisos. Ambos saltan en `t = 807`, pero después del salto llegan a
valores distintos. Para integrar varios ciclos con precisión se necesitan métodos implícitos de orden
alto, como los de la familia Radau, que se escriben igual con más etapas. RADAU5, de Hairer y Wanner,
es un código en Fortran muy utilizado.

La unidad 11 vuelve a encontrar este problema, en otro contexto.

## Ejercicios

1. Escribe en Fortran un `paso_ralston`, el método de orden 2 con `k2 = F(u + 2h/3 k1)` y
   `u_nuevo = u + h (k1 + 3 k2) / 4`. Añádelo a `integrar` y comprueba con `orden` que tiene orden 2.
2. Cambia el `/ 6` de RK4 por `/ 7` y ejecuta `orden`. Anota el orden que resulta.
3. Con `mu = 5` y `h = 0.1`, compara Euler, Heun y RK4 y decide cuál conserva mejor el ciclo límite.
4. Busca el mayor `h` con el que RK4 no explota para `mu = 1000`. Usa `t_final = 5` para acortar las
   pruebas.
5. Con `largo.nml`, mide el retraso de Heun para `h = 0.05` y comprueba que queda entre los valores de
   la tabla para `h = 0.01` y `h = 0.1`.
