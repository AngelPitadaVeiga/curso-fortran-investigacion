# Unidad 08 · Módulos y make

El programa es el mismo Euler de la unidad anterior y da el mismo resultado, pero el código se reparte
en tres archivos. Cuando un programa crece, dividirlo es la única forma de mantenerlo comprensible.

```
08_modulos_y_make/
├── modelo.f90       el modelo: el campo vectorial
├── integrador.f90   el método: Euler explícito
├── principal.f90    el programa: lee, integra y escribe
├── entrada.nml
├── Makefile
└── graficar.py
```

Para probarlo:

```bash
make run
python graficar.py
```

## Módulos

Un módulo es un archivo que agrupa procedimientos para que los usen otros archivos. Este es el modelo:

```fortran
module modelo
    implicit none
    private                 ! todo es privado...
    public :: campo         ! ...salvo lo que se exporta aquí

contains

    function campo(u, mu) result(du)
        ...
    end function campo

end module modelo
```

`private` y `public` deciden qué ve el resto del programa. Quien necesita el módulo escribe
`use modelo, only: campo`, y el `only` deja claro de dónde procede cada nombre.

El método está en otro módulo, que usa el del modelo, y el programa principal usa el del método:

```
modelo.f90  →  integrador.f90  →  principal.f90
```

Cada flecha es un `use`. Cambiar de modelo solo exige modificar `modelo.f90`.

## Compilación manual

Al compilar un módulo, gfortran genera dos archivos: un `.o` con el código y un `.mod` con la
descripción de su contenido. Quien usa el módulo necesita su `.mod`, y por eso la compilación sigue un
orden:

```bash
gfortran -c modelo.f90          # genera modelo.o y modelo.mod
gfortran -c integrador.f90      # necesita modelo.mod
gfortran -c principal.f90       # necesita integrador.mod
gfortran modelo.o integrador.o principal.o -o euler
```

Las tres primeras órdenes compilan, y la última enlaza todo en un ejecutable. Con cinco módulos,
escribir estas órdenes en cada cambio es poco práctico, y para eso existe `make`.

## El Makefile

`make` lee el archivo `Makefile`, donde se declara de qué depende cada archivo y cómo se construye, y
recompila solo lo que ha cambiado. Una regla tiene esta forma:

```make
objetivo: dependencias
	orden para construirlo
```

La sangría de la orden debe ser un tabulador, no espacios. Este Makefile contiene cuatro elementos:

```make
euler: modelo.o integrador.o principal.o                    # enlazar
	$(FC) $(FFLAGS) modelo.o integrador.o principal.o -o euler

%.o: %.f90                                                  # compilar cada archivo
	$(FC) $(FFLAGS) -c $<

integrador.o: modelo.o                                      # dependencias entre módulos
principal.o: integrador.o
```

La segunda regla vale para cualquier `.f90`: `%` es un comodín y `$<` es el archivo de partida. Las
dos últimas líneas no llevan orden. Solo declaran que `integrador.o` no puede construirse antes que
`modelo.o`.

La siguiente secuencia muestra qué recompila `make` en cada caso:

```bash
make                  # la primera vez compila todo
make                  # no hay nada que hacer
touch principal.f90   # simula una edición de principal.f90
make                  # recompila solo principal.f90
touch modelo.f90
make                  # recompila todo, porque todo depende del modelo
```

`make clean` borra los archivos generados.

## Opciones de compilación

El Makefile define la variable `FFLAGS = -O2` con las opciones que se pasan a gfortran. `-O2` activa
las optimizaciones y es la opción normal. Para localizar errores existe otra forma de compilar:

```bash
make clean
make FFLAGS="-g -fcheck=all"
```

Con `-fcheck=all` el programa comprueba cada acceso a un array y avisa si el índice sale del rango.
Es más lento, pero detecta errores que de otro modo pasan desapercibidos. `error_indice.f90` recorre
una matriz de 5 filas hasta la fila 6:

```bash
gfortran -O2 error_indice.f90 -o error_indice
./error_indice
gfortran -g -fcheck=all error_indice.f90 -o error_indice
./error_indice
```

```
Suma de la primera columna = 115.0
```

```
At line 24 of file error_indice.f90
Fortran runtime error: Index '6' of dimension 1 of array 'm' above upper bound of 5
```

Sin comprobaciones, el programa da 115 sin avisar. La matriz se guarda por columnas, y tras `m(5,1)` la
memoria contiene `m(1,2)`, que vale 100. Con `-fcheck=all`, el programa se detiene e indica archivo,
línea, índice y límite.

Para desarrollar conviene compilar con `-g -fcheck=all`. Cuando el código funciona y se necesita
velocidad, se pasa a `-O2`.

## Ejercicios

1. Compila con `make FFLAGS="-g -fcheck=all"` y ejecuta con `t_final = 3000`. Mide cuánto más lento
   resulta que con `-O2`.
2. Cambia el modelo por el oscilador de Duffing, `y' = -mu (x² - 1) y - x - x³`. Cuenta los archivos
   que has tenido que modificar.
3. Añade un módulo nuevo, `escritura.f90`, con una subrutina que escriba la solución en un archivo.
   Llámala desde `principal.f90` y actualiza el Makefile.
4. Elimina del Makefile la línea `integrador.o: modelo.o`, borra los `.o` con `make clean` y ejecuta
   `make`. Lee el error.
