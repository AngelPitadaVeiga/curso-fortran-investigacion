# Unidad 07 · Entrada de datos

En la unidad 05, cambiar `mu`, `h` o `t_final` obliga a editar el código y recompilar. Aquí el mismo
Euler explícito, en un solo archivo, lee sus parámetros de un archivo de texto.

```bash
gfortran euler.f90 -o euler
./euler
python graficar.py
```

## `namelist`

Se declara la lista de variables que pueden leerse, y una instrucción lee todas:

```fortran
double precision :: mu = 1.0d0
double precision :: h = 0.01d0
...
namelist /parametros/ mu, h, t_final, x0, y0, archivo_salida

read(unidad, nml=parametros)
```

```fortran
&parametros
    mu      = 1.0        ! parámetro de Van der Pol
    h       = 0.01       ! tamaño de paso
    t_final = 30.0
/
```

Las variables pueden ir en cualquier orden, los comentarios empiezan con `!` y las ausentes conservan
el valor con el que se declararon (los valores por defecto). Un nombre incorrecto produce un error que
indica cuál es; se prueba con `muu = 1.0`.

## Elegir el archivo desde la terminal

```fortran
archivo_entrada = 'entrada.nml'
if (command_argument_count() >= 1) call get_command_argument(1, archivo_entrada)
```

```bash
./euler                 # lee entrada.nml
./euler mu5.nml         # lee mu5.nml
```

## Apertura con control de errores

```fortran
open(newunit=unidad, file=archivo_entrada, status='old', action='read', iostat=estado)
if (estado /= 0) then
    print '(a)', 'No puedo abrir ' // trim(archivo_entrada)
    stop 1
end if
```

Sin `iostat`, un archivo inexistente detiene el programa con un mensaje del sistema poco claro. Con
`iostat`, `estado` vale 0 si la apertura tuvo éxito y el programa gestiona el error. `status='old'`
exige que el archivo exista, y `stop 1` termina con un código de error que un script puede detectar.

## Ejercicios

1. Crea `mu5.nml` con `mu = 5` y `t_final = 50`, ejecuta `./euler mu5.nml` y dibuja el resultado.
2. Prueba `h = 0.4` sin recompilar y lee lo que dice el programa.
3. Quita `archivo_salida` de `entrada.nml` y averigua dónde escribe. Después quita la barra `/` final
   y lee el error.
4. Añade el parámetro `paso_escritura` para escribir un paso de cada varios (`mod(k, paso_escritura)
   == 0`).
