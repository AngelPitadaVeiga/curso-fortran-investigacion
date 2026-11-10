# Unidad 10 · Retrato de fases

Ya tenemos un integrador en el que se puede confiar, así que vamos a usarlo. En esta unidad
no hay métodos nuevos: `modelo.f90` y `runge_kutta.f90` son los de la unidad 09, sin tocar.
Solo escribimos un programa nuevo, `retrato.f90`.

```bash
make run              # tarda alrededor de un segundo
python graficar.py
```

| `mu = 1` | `mu = 5` |
|---|---|
| ![mu = 1](figuras/retrato_mu1.png) | ![mu = 5](figuras/retrato_mu5.png) |

En gris está el campo de direcciones, en azul las trayectorias, en discontinua las nulclinas
(donde `x' = 0` o `y' = 0`) y en rojo el ciclo límite. Todas las trayectorias acaban en él. Con
`mu = 5` el ciclo es de relajación: tramos lentos pegados a la nulclina, y saltos rápidos.

## Qué calcula `retrato.f90`

Escribe cuatro archivos en `resultados/`:

- `ciclo.dat`: el ciclo límite. Para conseguirlo, integramos un transitorio desde `(2, 0)`, nos
  quedamos con el estado final y seguimos desde ahí; todo lo anterior se descarta.
- `campo.dat`: flechas `x y dx dy` en una rejilla. Todas tienen la misma longitud, porque solo
  importa la dirección.
- `trayectorias.dat`: trayectorias desde una rejilla de condiciones iniciales, una detrás de
  otra.
- `parametros.dat`: `mu` y el tamaño de la caja, que necesita Python para dibujar.

## Dos detalles de Fortran

Con `h = 0.001`, cada trayectoria tiene 10 000 pasos. Para escribir menos, un corte con paso:

```fortran
write(unidad, '(2es16.8)') u(:, ::paso_escritura)
```

`u(:, ::10)` son las columnas 0, 10, 20... Como el formato tiene sitio para dos números,
Fortran lo repite hasta acabar con todos los datos, y escribe un estado por línea. No hace falta
bucle.

El otro detalle es que no se puede pasar un mismo array como dato y como resultado. Para seguir
integrando desde el final del transitorio hay que hacer una copia:

```fortran
u_inicio = u(:, n_hechos)                              ! copia
call integrar('rk4', u_inicio, mu, h, n, u, n_hechos)  ! bien
! call integrar('rk4', u(:, n_hechos), mu, h, n, u, n_hechos)   ! MAL
```

La línea comentada pasa `u` como estado inicial y como resultado a la vez. El estándar lo prohíbe,
y además `u` se vuelve a reservar al entrar. Lo malo es que no siempre da error: puede funcionar
en tu ordenador y fallar en el de otra persona, como nos pasó a nosotros.

## Ejercicios

1. Con `mu = 5` (cambia el archivo de entrada), observa los tramos lentos pegados a la nulclina y
   los saltos.
2. Con `mu = 0.1` el ciclo es casi una circunferencia de radio 2. Comprueba su amplitud con
   `maxval(u(1, :))`.
3. Empieza el transitorio en `(0.01, 0)` en lugar de en `(2, 0)`. ¿Llegas al mismo ciclo?
4. Usa `'euler'` en vez de `'rk4'` con `h = 0.05`. ¿Sigue pareciendo correcto el retrato?
