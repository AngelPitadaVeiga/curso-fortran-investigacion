# Unidad 08 · Módulos y make

Seguimos con el mismo Euler de la unidad anterior, que da el mismo resultado, pero ahora el
código se reparte en tres archivos. Cuando un programa crece, es la única forma de seguir
entendiéndolo.

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

Un módulo es un archivo que agrupa procedimientos para que los use otro. Este es el modelo:

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

Con `private` y `public` decides qué ve el resto del programa. Quien lo necesita escribe
`use modelo, only: campo`, y con el `only` queda claro de dónde sale cada nombre.

El método está en otro módulo, que a su vez usa el del modelo, y el programa principal usa el del
método:

```
modelo.f90  →  integrador.f90  →  principal.f90
```

Cada flecha es un `use`. Para cambiar de modelo, solo tocas `modelo.f90`.

## Compilar a mano

Cuando compilas un módulo, gfortran genera dos archivos: un `.o` con el código y un `.mod` con
la descripción de lo que hay dentro. Quien hace `use` de ese módulo necesita su `.mod`, así que
hay que compilar en orden:

```bash
gfortran -c modelo.f90          # genera modelo.o y modelo.mod
gfortran -c integrador.f90      # necesita modelo.mod
gfortran -c principal.f90       # necesita integrador.mod
gfortran modelo.o integrador.o principal.o -o euler
```

Los tres primeros compilan, y el último enlaza todo en un ejecutable. Si tienes cinco
módulos, escribir esto cada vez es un fastidio. Para eso está `make`.

## El Makefile

`make` lee un archivo, el `Makefile`, donde le dices de qué depende cada cosa y cómo se
construye, y solo recompila lo que ha cambiado. Una regla tiene esta forma:

```make
objetivo: dependencias
	orden para construirlo
```

(la sangría tiene que ser un tabulador, no espacios). Nuestro Makefile tiene cuatro cosas:

```make
euler: modelo.o integrador.o principal.o                    # enlazar
	$(FC) $(FFLAGS) modelo.o integrador.o principal.o -o euler

%.o: %.f90                                                  # compilar cada archivo
	$(FC) $(FFLAGS) -c $<

integrador.o: modelo.o                                      # quién usa a quién
principal.o: integrador.o
```

La segunda regla vale para cualquier `.f90`: `%` es un comodín y `$<` es el archivo de
partida. Las dos últimas líneas no tienen orden: solo dicen que `integrador.o` no puede
construirse antes que `modelo.o`.

Prueba esto, y mira qué se recompila cada vez:

```bash
make                  # la primera vez, todo
make                  # ahora no hay nada que hacer
touch principal.f90   # simulamos que lo hemos editado
make                  # solo se recompila principal.f90
touch modelo.f90
make                  # ahora se recompila todo, porque todo depende del modelo
```

`make clean` borra lo generado.

## Opciones de compilación

El `Makefile` tiene una variable, `FFLAGS = -O2`, con las opciones que se pasan a gfortran. `-O2`
pide optimizar, y es lo que usaremos normalmente. Pero hay otra forma de compilar, para cuando
algo falla:

```bash
make clean
make FFLAGS="-g -fcheck=all"
```

Con `-fcheck=all` el programa comprueba cada acceso a un array y avisa si te sales. Va más
lento, pero es la forma de encontrar errores. Para verlo, mira `error_indice.f90`: recorre una
matriz de 5 filas hasta la fila 6.

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

Sin comprobaciones el programa da 115 sin quejarse, porque la matriz se guarda por columnas y
después de `m(5,1)` viene `m(1,2)`, que vale 100. Con `-fcheck=all` se para y te dice archivo,
línea, índice y límite.

Mi regla: mientras desarrollas, compila con `-g -fcheck=all`. Cuando todo funcione y
quieras velocidad, pasa a `-O2`.

## Ejercicios

1. Compila con `make FFLAGS="-g -fcheck=all"` y ejecuta. ¿Cuánto más lento va con `t_final = 3000`?
2. Cambia el modelo por el oscilador de Duffing, `y' = -mu (x² - 1) y - x - x³`. ¿Cuántos
   archivos has tenido que tocar?
3. Añade un módulo nuevo, `escritura.f90`, con una subrutina que escriba la solución en un
   archivo. Usala desde `principal.f90` y actualiza el Makefile.
4. Quita la línea `integrador.o: modelo.o` del Makefile, borra los `.o` con `make clean` y
   ejecuta `make`. ¿Qué error da?
