# Dibuja la solución del bloque 02: x(t) y la órbita en el plano (x, y).
# Uso:  gnuplot graficar.gp
#       gnuplot -e "archivo='resultados/otro.dat'" graficar.gp

if (!exists("archivo")) archivo = 'resultados/euler.dat'
salida = archivo[1:strlen(archivo)-4] . '.png'

# pngcairo da mejor calidad; si no está disponible, se usa png.
if (strstrt(GPVAL_TERMINALS, "pngcairo") > 0) {
    set terminal pngcairo size 1200,500 enhanced font "Arial,11"
} else {
    set terminal png size 1200,500 font "Arial,11"
}
set output salida

set multiplot layout 1,2 title "Lienard (Van der Pol) - Euler explicito"

set title "x(t)"
set xlabel "t"
set ylabel "x"
set grid
plot archivo using 1:2 with lines lw 1.5 lc rgb "#1f77b4" notitle

set title "Orbita en el plano (x, y)"
set xlabel "x"
set ylabel "y"
set size ratio -1
plot archivo using 2:3 with lines lw 1.5 lc rgb "#d62728" notitle

unset multiplot
print "Figura escrita en " . salida
