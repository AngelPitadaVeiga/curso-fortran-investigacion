# Bloque 06 · Fortran heredado: cómo leerlo y cómo modernizarlo

Tarde o temprano os llegará "el código del grupo", escrito en FORTRAN 77
hace 30 años. Funciona, está validado... y da miedo tocarlo. Este bloque es
una guía para leerlo y un ejemplo de traducción.

```bash
make run      # compila legado.f y moderno.f90, los ejecuta y compara sus salidas
```

| Archivo | Contenido |
|---|---|
| `legado.f` | Van der Pol con RK4 en FORTRAN 77 típico: formato fijo, `IMPLICIT DOUBLE PRECISION`, `COMMON`, `GOTO`, `DIMENSION`, `EXTERNAL`, `FORMAT` con etiqueta |
| `moderno.f90` | la misma rutina en Fortran moderno, con comentarios `F77:` que indican qué sustituye cada cosa |

Las dos versiones dan una salida **idéntica, carácter a carácter** (también
con `-O3 -march=native`), y el estado final coincide con el RK4 del bloque 03.

## Guía rápida para leer FORTRAN 77

### Formato fijo (archivos `.f`, `.for`)

```
C     comentario: 'C' o '*' en la columna 1
      X = 1.0D0                         <- instrucciones entre las columnas 7 y 72
   10 CONTINUE                          <- etiqueta numérica en las columnas 1-5
      Y = A + B +
     &    C                             <- un carácter en la columna 6: continuación
```

- **Lo que pase de la columna 72 se ignora en silencio** (herencia de las
  tarjetas perforadas). Es una fuente clásica de errores al editar.
- Los espacios no significan nada: `DO 10 I = 1, N` y `DO10I=1,N` son lo mismo.
- Todo en mayúsculas por costumbre; Fortran no distingue mayúsculas.

### Tipado implícito

Sin declaración, las variables que empiezan por **I, J, K, L, M, N** son
`INTEGER` y el resto `REAL` (simple precisión). Por eso se ve tanto

```fortran
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
```

que hace dobles todas las que no empiezan por I–N. Peligro: una errata
(`VELOCIDDA = ...`) crea una variable nueva sin avisar. En código moderno,
`implicit none` siempre.

### Las construcciones típicas

| FORTRAN 77 | Qué es | Fortran moderno |
|---|---|---|
| `COMMON /PARAM/ AMU` | memoria global compartida; cada rutina la declara con **sus propios nombres y tipos**, y basta un desajuste para leer basura | argumentos, o variables de módulo (`parameter` si son constantes) |
| `GOTO 20`, `IF (...) GOTO 99` | saltos | `do`, `do while`, `exit`, `cycle`, `if-then-else`, `select case` |
| `DO 30 I = 1, N` / `30 CONTINUE` | bucle cerrado por una etiqueta | `do i = 1, n ... end do` |
| `DIMENSION Y(N)`, `Y(1)`, `Y(*)` | arrays de tamaño explícito o asumido (sin comprobación de límites) | `real(real64) :: y(:)` (forma asumida: el array conoce su tamaño) |
| `DIMENSION YK(10)` como trabajo | tamaño máximo fijo ("N <= 10") | arrays automáticos `k1(size(y))` o `allocatable` |
| `EXTERNAL F` | "F es una función", sin decir cómo se llama | interfaz abstracta + `procedure(campo) :: f` |
| subrutinas sueltas | el compilador **no comprueba** número ni tipo de argumentos | subrutinas dentro de módulos: interfaces explícitas |
| `1.0D0`, `.EQ.`, `.GE.` | doble precisión, comparaciones | `1.0_real64`, `==`, `>=` (los antiguos siguen valiendo) |
| `REAL*8`, `INTEGER*4` | extensiones no estándar (muy comunes) | `real(real64)`, `integer(int32)` |
| `WRITE(6,100)` + `100 FORMAT(...)` | unidad 6 = pantalla, formato en otra línea | `write(*, '(...)')` |
| `IF (X) 10, 20, 30` | IF aritmético (negativo, cero, positivo) | `if` / `else if` |
| `EQUIVALENCE (A, B)` | dos nombres para la misma memoria | casi nunca hace falta; `transfer` o punteros |
| `DATA X /1.0/`, `SAVE` | inicialización estática, variables que persisten entre llamadas | inicialización en la declaración (implica `save`) |
| `ENTRY` | varios puntos de entrada en una subrutina | procedimientos separados en un módulo |
| `PARAMETER (N = 100)` | constante con nombre (¡esto ya era bueno!) | `integer, parameter :: n = 100` |

### Un detalle numérico que conviene respetar

`legado.f` avanza el tiempo con `T = T + H`, que acumula redondeo (en el
bloque 02 se usa `t = k*h`). La traducción **conserva** `t = t + h` a
propósito: el objetivo de una traducción es reproducir el resultado
original; las mejoras numéricas van después, en un cambio aparte y
comprobando su efecto.

## Cómo modernizar código heredado sin romperlo

1. **Antes de tocar nada, guarda salidas de referencia** de varios casos
   (como `resultados/legado.txt`). Cada cambio se valida contra ellas
   (`make run` lo hace aquí con `cmp`).
2. **Compila el original con todos los avisos**:
   `gfortran -std=legacy -Wall -Wextra -fcheck=all`. Suelen aparecer
   variables sin usar, sin inicializar, conversiones implícitas, índices
   fuera de rango...
3. **Pasa a forma libre** (`.f` → `.f90`). Hay herramientas que lo hacen
   automáticamente, por ejemplo [`findent`](https://sourceforge.net/projects/findent/)
   (`findent -ofree < legado.f > legado.f90`) y después
   [`fprettify`](https://github.com/fortran-lang/fprettify) para el formato.
4. **Mete las subrutinas en un módulo**: el compilador empezará a
   comprobar las llamadas y aparecerán errores latentes (argumentos de tipo
   o número equivocado).
5. **Añade `implicit none`** rutina a rutina y declara todo, con `intent`.
6. **Sustituye `COMMON`** por argumentos o variables de módulo, y los
   `GOTO` por bloques estructurados.
7. **Cambia los arrays de trabajo de tamaño fijo** por arrays automáticos o
   `allocatable`.
8. Solo entonces, mejoras de algoritmo o de rendimiento.

No hace falta reescribirlo todo: el código moderno puede llamar al
antiguo (y viceversa) en el mismo programa; basta con escribir una interfaz
para las rutinas antiguas. Se puede modernizar por partes.

## Ejercicio

1. En `FCN` de `legado.f`, añade `+ 5.0D0` al final de la línea `DY(2) = ...`
   pero **empezando más allá de la columna 72** (rellena con espacios).
   Compila con `gfortran -std=legacy legado.f` y ejecuta: ¿cambia algo?
   Compila ahora con `-Wall`.
2. Deshaz lo anterior. En `FCN`, cambia el nombre `AMU` por `BMU` (en el
   `COMMON` y en la fórmula), solo en esa subrutina. ¿Compila? ¿Cambia el resultado?
3. Deshaz lo anterior. En `FCN`, añade `REAL AMU` justo antes del `COMMON`.
   ¿Qué dice el compilador? ¿Qué pasa con el resultado?

<details>
<summary>Soluciones</summary>

1. Sin `-Wall` compila sin decir nada y el resultado **no cambia**: el
   `+ 5.0D0` se ignora. Con `-Wall`: `Warning: Line truncated at (1) [-Wline-truncation]`.
2. Compila y da el mismo resultado: un `COMMON` es un bloque de memoria y
   sus variables se asocian **por posición**, no por nombre. Cada rutina
   puede llamarlas como quiera (y así se ve en mucho código antiguo).
3. gfortran avisa: `Named COMMON block 'param' at (1) shall be of the same
   size as elsewhere (4 vs 8 bytes)`, pero compila. `FCN` lee los 4
   primeros bytes del `DOUBLE PRECISION` como si fueran un `REAL`: el valor
   de `mu` es basura y la solución cambia por completo (`x(30) = 0.077` en
   lugar de `-1.42`). Con módulos y `implicit none` este error es imposible.
</details>
