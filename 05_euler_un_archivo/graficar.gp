# Dibuja euler.dat (columnas t, x, y): x(t) y la órbita en el plano (x, y).
# Uso:  gnuplot graficar.gp

if (strstrt(GPVAL_TERMINALS, "pngcairo") > 0) {
    set terminal pngcairo size 1200,500 enhanced font "Arial,11"
} else {
    set terminal png size 1200,500 font "Arial,11"
}
set output 'euler.png'

set multiplot layout 1,2 title "Van der Pol (mu = 1) - Euler explicito, h = 0.01"

set title "x(t)"
set xlabel "t"
set ylabel "x"
set grid
plot 'euler.dat' using 1:2 with lines lw 1.5 lc rgb "#1f77b4" notitle

set title "Orbita en el plano (x, y)"
set xlabel "x"
set ylabel "y"
set size ratio -1
plot 'euler.dat' using 2:3 with lines lw 1.5 lc rgb "#d62728" notitle

unset multiplot
print "Figura escrita en euler.png"
