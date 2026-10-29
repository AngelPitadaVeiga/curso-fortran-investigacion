# Dibuja tabla.dat (columnas x, sin(x), cos(x)).   Uso:  gnuplot graficar.gp

# pngcairo da mejor calidad; si no está disponible, se usa png.
if (strstrt(GPVAL_TERMINALS, "pngcairo") > 0) {
    set terminal pngcairo size 800,450 enhanced font "Arial,11"
} else {
    set terminal png size 800,450 font "Arial,11"
}
set output 'tabla.png'

set xlabel "x"
set grid
set key top right
plot 'tabla.dat' using 1:2 with lines lw 2 title "sin(x)", \
     'tabla.dat' using 1:3 with lines lw 2 title "cos(x)"

print "Figura escrita en tabla.png"
