# Unidad 07 · Entrada de datos

En la unidad 05 cambiar `mu` o `h` obligaba a editar el código y recompilar. Para un experimento
suelto vale, pero cuando quieres probar veinte valores se hace insufrible. La solución es que el
programa lea sus parámetros de un archivo de texto.

Este es el mismo Euler explícito de siempre, en un solo archivo, con una novedad: la lectura de
los parámetros.

```bash
gfortran euler.f90 -o euler
./euler
python graficar.py
```

## `namelist`

Fortran trae algo muy cómodo para esto, el `namelist`. Declaras la lista de variables que quieres
poder leer, y con una sola instrucción se leen todas:

```fortran
double precision :: mu = 1.0d0
double precision :: h = 0.01d0
...
namelist /parametros/ mu, h, t_final, x0, y0, archivo_salida

read(unidad, nml=parametros)
```

Y el archivo `entrada.nml` tiene este aspecto:

```fortran
&parametros
    mu      = 1.0        ! parámetro de Van der Pol
    h       = 0.01       ! tamaño de paso
    t_final = 30.0
/
```

El orden de las variables da igual, puedes poner comentarios con `!` y lo que no aparezca
conserva el valor que le diste al declararlo. Así que las declaraciones con `= 1.0d0` son los
valores por defecto.

Si te equivocas, Fortran se queja con el nombre. Prueba a escribir `muu = 1.0` en el archivo.

## Elegir el archivo desde la terminal

Para tener un archivo por experimento, el programa mira si le has pasado un argumento:

```fortran
archivo_entrada = 'entrada.nml'
if (command_argument_count() >= 1) call get_command_argument(1, archivo_entrada)
```

y así puedes hacer:

```bash
./euler                 # lee entrada.nml
./euler mu5.nml         # lee mu5.nml
```

Con un solo ejecutable y tantos archivos como quieras.

## Abrir un archivo con cuidado

Al abrir el archivo de entrada hemos añadido `iostat=estado`:

```fortran
open(newunit=unidad, file=archivo_entrada, status='old', action='read', iostat=estado)
if (estado /= 0) then
    print '(a)', 'No puedo abrir ' // trim(archivo_entrada)
    stop 1
end if
```

Sin `iostat`, si el archivo no existe el programa se para con un error del sistema, bastante
críptico. Con `iostat`, el error lo gestionas tú: `estado` vale 0 si todo ha ido bien. `status='old'`
dice que el archivo ya debe existir, y `stop 1` termina el programa con un código de error, que
otros programas (un script, por ejemplo) pueden detectar.

## Ejercicios

1. Crea `mu5.nml` con `mu = 5` y `t_final = 50`, ejecuta `./euler mu5.nml` y dibuja el resultado.
2. Prueba con `h = 0.4` sin recompilar. ¿Qué dice el programa?
3. Quita `archivo_salida` de `entrada.nml`. ¿Dónde escribe el programa? ¿Y si te dejas fuera
   el `/` del final?
4. Añade un parámetro nuevo, `paso_escritura`, para escribir solo un paso de cada varios
   (`mod(k, paso_escritura) == 0`).
