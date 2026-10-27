# Demostración de rigidez: Van der Pol con mu = 1000 y el mismo paso h.
# Uso (tras  make rigido):  gnuplot graficar_rigido.gp

radau = 'resultados/rigido_radau_iia3.dat'
rk4   = 'resultados/rigido_rk4.dat'

if (strstrt(GPVAL_TERMINALS, "pngcairo") > 0) {
    set terminal pngcairo size 1300,500 enhanced font "Arial,11"
} else {
    set terminal png size 1300,500 font "Arial,11"
}
set output 'resultados/rigido.png'
set multiplot layout 1,2 title "Van der Pol rigido (mu = 1000), mismo paso h = 0.002"

set title "Radau IIA (implicito, L-estable): integra sin problemas"
set xlabel "t"
set ylabel "x(t)"
set grid
set yrange [-2.5:2.5]
plot radau using 1:2 with lines lw 2 lc rgb "#2ca02c" notitle

set title "RK4 (explicito): la solucion explota"
set xlabel "t"
set ylabel "|x(t)|"
set logscale y
set format y "10^{%L}"
set yrange [*:*]
plot rk4 using 1:(abs($2)) with linespoints lw 2 pt 7 lc rgb "#d62728" notitle

unset multiplot
print "Figura escrita en resultados/rigido.png"
