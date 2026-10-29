# Dibuja resultados/convergencia.dat: error frente a h en escala log-log.
# Uso (tras  make convergencia):  gnuplot graficar_convergencia.gp

archivo = 'resultados/convergencia.dat'

if (strstrt(GPVAL_TERMINALS, "pngcairo") > 0) {
    set terminal pngcairo size 800,600 enhanced font "Arial,11"
} else {
    set terminal png size 800,600 font "Arial,11"
}
set output 'resultados/convergencia.png'

set title "Convergencia en t = 1 (Van der Pol, mu = 1)"
set xlabel "h"
set ylabel "error"
set logscale xy
set format x "10^{%L}"
set format y "10^{%L}"
set grid
set xrange [2e-3:0.15]
set key bottom right

# Un bloque por método; el título sale de la primera línea de cada bloque.
stats archivo using 1 nooutput
plot for [i=0:STATS_blocks-1] archivo index i using 1:2 with linespoints lw 2 pt 7 \
     title columnheader(2)

print "Figura escrita en resultados/convergencia.png"
