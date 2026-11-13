# Unidad 10 · Retrato de fases

Esta unidad usa el integrador para estudiar la dinámica. `modelo.f90` y `runge_kutta.f90` son los de
la unidad 09; el único programa nuevo es `retrato.f90`.

```bash
make run              # tarda alrededor de un segundo
python graficar.py
```

| `mu = 1` | `mu = 5` |
|---|---|
| ![mu = 1](figuras/retrato_mu1.png) | ![mu = 5](figuras/retrato_mu5.png) |

Gris: campo de direcciones. Azul: trayectorias. Discontinuo: nulclinas (`x' = 0` e `y' = 0`). Rojo:
ciclo límite. Todas las trayectorias terminan en él. Con `mu = 5` el ciclo es de relajación: tramos
lentos junto a la nulclina y saltos rápidos.

## Qué escribe `retrato.f90`

En `resultados/`:

- `ciclo.dat`: el ciclo límite. Se integra un transitorio desde `(2, 0)`, se toma el estado final y se
  continúa desde él.
- `campo.dat`: flechas `x y dx dy` en una rejilla, todas de la misma longitud.
- `trayectorias.dat`: trayectorias desde una rejilla de condiciones iniciales, una tras otra.
- `parametros.dat`: `mu` y el tamaño de la caja, para Python.

## Dos detalles de Fortran

Cada trayectoria tiene 10 000 pasos con `h = 0.001`. Un corte con paso escribe solo una parte, sin
bucle:

```fortran
write(unidad, '(2es16.8)') u(:, ::paso_escritura)
```

El formato tiene sitio para dos números y Fortran lo repite mientras queden datos, de modo que escribe
un estado por línea.

Un mismo array no puede pasarse como dato y como resultado. Para continuar desde el final de un
tramo hay que copiar:

```fortran
u_inicio = u(:, n_hechos)                              ! copia
call integrar('rk4', u_inicio, mu, h, n, u, n_hechos)  ! correcto
! call integrar('rk4', u(:, n_hechos), mu, h, n, u, n_hechos)   ! incorrecto
```

El estándar lo prohíbe y, además, `u` se vuelve a reservar al entrar. El fallo no aparece siempre: un
programa así puede funcionar en un ordenador y fallar en otro, como pasó al preparar este curso.

## Ejercicios

1. Con `mu = 5`, observa los tramos lentos junto a la nulclina y los saltos.
2. Con `mu = 0.1` el ciclo es casi una circunferencia de radio 2. Compruébalo con `maxval(u(1, :))`.
3. Empieza el transitorio en `(0.01, 0)` en lugar de `(2, 0)` y comprueba si se llega al mismo ciclo.
4. Cambia `'rk4'` por `'euler'` con `h = 0.05` y describe en qué cambia el retrato.
