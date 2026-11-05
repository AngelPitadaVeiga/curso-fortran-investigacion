# Unidad 07 · Módulos y make

Es el mismo Euler explícito de la unidad 06, y da exactamente el mismo resultado. Lo
que cambia es la organización: ahora se parece a un código de investigación.

```bash
make run          # compila, ejecuta y dibuja
make clean        # borra lo generado
```

En PowerShell, `mingw32-make run`. La figura queda en `resultados/euler.png`.

```
07_modulos_y_make/
├── src/modelo.f90         el campo vectorial
├── src/metodo_euler.f90   el integrador
├── app/principal.f90      lee los parámetros, integra y escribe
├── entrada.nml            los parámetros
├── graficar.py            la figura
└── Makefile
```

## Módulos

Un módulo agrupa procedimientos, y tú decides qué se ve desde fuera:

```fortran
module modelo
    use iso_fortran_env, only: real64
    implicit none
    private                 ! todo es privado...
    public :: campo         ! ...salvo lo que se exporta
contains
    pure function campo(u, mu) result(du)
    ...
end module modelo
```

Quien lo necesita escribe `use modelo, only: campo`, igual que hacíamos con `real64`.
`pure` promete que la función no tiene efectos secundarios, y el compilador lo comprueba.

Al compilar un módulo se genera un archivo `.mod`, de modo que **un módulo tiene que
compilarse antes que quien lo usa**.

## Parámetros sin recompilar

`namelist` lee un archivo de entrada con una sola línea de código:

```fortran
namelist /parametros/ mu, h, t_final, x0, y0, archivo_salida
read(unidad, nml=parametros)
```

```fortran
&parametros
    mu = 1.0        ! los comentarios y el orden no son problema
    h  = 0.01
/
```

Lo que no aparezca conserva su valor por defecto, y un error te dirá dónde está. Puedes
tener un archivo por experimento: `./euler mu5.nml`.

## `make`

Compilar un proyecto con módulos requiere varias órdenes, y en el orden correcto. El
`Makefile` se encarga y solo recompila lo que ha cambiado. Lo importante son tres reglas:

```make
$(EJECUTABLE): $(OBJETOS)                # enlazar
$(BUILD)/%.o: %.f90 | $(BUILD)           # compilar cada archivo
$(BUILD)/metodo_euler.o: $(BUILD)/modelo.o       # quién usa a quién
```

El resto es para que funcione tanto en Windows como en Linux.

## Dos formas de compilar

| | Orden | Para qué |
|---|---|---|
| Release | `make` | Producción: rápido y sin red de seguridad |
| Debug | `make debug` | Desarrollo: lento, pero detecta los errores |

Desarrolla siempre en debug y pasa a release cuando funcione. Para ver por qué:

```bash
make demo-error
```

```
===== release: sin comprobaciones =====
Suma de la primera columna = 115.0
===== debug: -fcheck=all =====
At line 26 of file error_indice.f90
Fortran runtime error: Index '6' of dimension 1 of array 'm' above upper bound of 5
```

El programa se sale de la matriz. En release da un resultado falso sin decir nada; en
debug se detiene y te dice el archivo, la línea y el índice.

## Ejercicios

1. Crea `mu5.nml` con `mu = 5`, `t_final = 50` y
   `archivo_salida = 'resultados/mu5.dat'`. Ejecuta `./euler mu5.nml` y dibuja con
   `python graficar.py resultados/mu5.dat`.
2. Escribe `muu = 1.0` en `entrada.nml` y lee el mensaje de error.
3. Cambia un mensaje de `app/principal.f90` y ejecuta `make`. Después, toca
   `src/modelo.f90`. ¿Qué se recompila en cada caso?
4. Cambia el modelo por Duffing, `g(x) = x + x**3`. ¿Cuántos archivos has tocado?
