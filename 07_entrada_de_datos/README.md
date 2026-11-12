# Unidad 07 · Entrada de datos

En la unidad 05, cambiar `mu`, `h` o `t_final` obliga a editar el código y recompilar. Con un solo
experimento no supone un problema, pero resulta incómodo al probar muchos valores. La alternativa es
que el programa lea sus parámetros de un archivo de texto.

Esta unidad contiene el mismo Euler explícito de siempre, en un solo archivo, con una diferencia: la
lectura de los parámetros.

```bash
gfortran euler.f90 -o euler
./euler
python graficar.py
```

## `namelist`

Fortran incluye el `namelist` para este fin. Se declara la lista de variables que pueden leerse, y
una sola instrucción lee todas:

```fortran
double precision :: mu = 1.0d0
double precision :: h = 0.01d0
...
namelist /parametros/ mu, h, t_final, x0, y0, archivo_salida

read(unidad, nml=parametros)
```

El archivo `entrada.nml` tiene este formato:

```fortran
&parametros
    mu      = 1.0        ! parámetro de Van der Pol
    h       = 0.01       ! tamaño de paso
    t_final = 30.0
/
```

Las variables pueden aparecer en cualquier orden, los comentarios empiezan con `!` y las variables
ausentes conservan el valor con el que se declararon. Esos valores son los valores por defecto.

Un nombre incorrecto produce un error que indica cuál es. Se puede comprobar escribiendo `muu = 1.0`
en el archivo.

## Elegir el archivo desde la terminal

El programa comprueba si recibe un argumento. Si lo recibe, lo usa como nombre del archivo:

```fortran
archivo_entrada = 'entrada.nml'
if (command_argument_count() >= 1) call get_command_argument(1, archivo_entrada)
```

```bash
./euler                 # lee entrada.nml
./euler mu5.nml         # lee mu5.nml
```

Un solo ejecutable atiende cualquier número de archivos de parámetros.

## Apertura de un archivo con control de errores

La apertura del archivo de entrada incluye `iostat=estado`:

```fortran
open(newunit=unidad, file=archivo_entrada, status='old', action='read', iostat=estado)
if (estado /= 0) then
    print '(a)', 'No puedo abrir ' // trim(archivo_entrada)
    stop 1
end if
```

Sin `iostat`, un archivo inexistente detiene el programa con un mensaje del sistema, poco claro. Con
`iostat`, el programa gestiona el error: `estado` vale 0 si la apertura tuvo éxito. `status='old'`
exige que el archivo ya exista. `stop 1` termina el programa con un código de error que otros
programas, como un script, pueden detectar.

## Ejercicios

1. Crea `mu5.nml` con `mu = 5` y `t_final = 50`, ejecuta `./euler mu5.nml` y dibuja el resultado.
2. Prueba `h = 0.4` sin recompilar y lee lo que dice el programa.
3. Elimina `archivo_salida` de `entrada.nml` y averigua dónde escribe el programa. Después deja el
   archivo sin la barra `/` final y lee el error.
4. Añade el parámetro `paso_escritura` para escribir un paso de cada varios, con la condición
   `mod(k, paso_escritura) == 0`.
