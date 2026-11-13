# Unidad 08 · Módulos y make

El mismo Euler de la unidad anterior, con el mismo resultado, repartido en tres archivos:

```
08_modulos_y_make/
├── modelo.f90       el campo vectorial
├── integrador.f90   Euler explícito
├── principal.f90    lee, integra y escribe
├── entrada.nml
├── Makefile
└── graficar.py
```

```bash
make run
python graficar.py
```

## Módulos

Un módulo agrupa procedimientos para que los usen otros archivos:

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

Quien lo necesita escribe `use modelo, only: campo`. El integrador usa el modelo, y el programa
principal usa el integrador:

```
modelo.f90  →  integrador.f90  →  principal.f90
```

## Compilar a mano

Al compilar un módulo, gfortran genera un `.o` con el código y un `.mod` con la descripción de su
contenido. Quien usa el módulo necesita su `.mod`, así que se compila en orden:

```bash
gfortran -c modelo.f90          # genera modelo.o y modelo.mod
gfortran -c integrador.f90      # necesita modelo.mod
gfortran -c principal.f90       # necesita integrador.mod
gfortran modelo.o integrador.o principal.o -o euler
```

## El Makefile

`make` lee las dependencias de cada archivo y recompila solo lo que ha cambiado. Una regla es
`objetivo: dependencias` seguida de la orden, con sangría de tabulador:

```make
euler: modelo.o integrador.o principal.o                    # enlazar
	$(FC) $(FFLAGS) modelo.o integrador.o principal.o -o euler

%.o: %.f90                                                  # compilar cada archivo
	$(FC) $(FFLAGS) -c $<

integrador.o: modelo.o                                      # dependencias entre módulos
principal.o: integrador.o
```

La segunda regla vale para cualquier `.f90` (`%` es un comodín y `$<`, el archivo de partida). Las dos
últimas líneas no llevan orden: solo indican que `integrador.o` necesita `modelo.o`. Para ver qué
recompila:

```bash
make                  # la primera vez compila todo
make                  # no hay nada que hacer
touch principal.f90   # simula una edición
make                  # recompila solo principal.f90
touch modelo.f90
make                  # recompila todo
```

`make clean` borra lo generado.

## Opciones de compilación

`FFLAGS = -O2` activa las optimizaciones. Para localizar errores:

```bash
make clean
make FFLAGS="-g -fcheck=all"
```

`-fcheck=all` comprueba los índices de los arrays y avisa al salirse del rango. `error_indice.f90`
recorre una matriz de 5 filas hasta la fila 6:

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

Sin comprobaciones el programa da 115 sin avisar: la matriz se guarda por columnas y tras `m(5,1)`
viene `m(1,2)`, que vale 100. Conviene desarrollar con `-g -fcheck=all` y pasar a `-O2` cuando el
código funciona.

## Ejercicios

1. Compila con `-g -fcheck=all`, ejecuta con `t_final = 3000` y mide cuánto más lento va que con
   `-O2`.
2. Cambia el modelo por el de Duffing, `y' = -mu (x² - 1) y - x - x³`, y cuenta los archivos
   modificados.
3. Añade un módulo `escritura.f90` con una subrutina que escriba la solución, llámala desde
   `principal.f90` y actualiza el Makefile.
4. Quita del Makefile la línea `integrador.o: modelo.o`, haz `make clean` y `make`, y lee el error.
