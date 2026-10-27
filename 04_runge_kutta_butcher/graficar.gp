# Dibuja una solución del bloque 04: x(t) y la órbita en el plano (x, y).
# Uso:  gnuplot graficar.gp
#       gnuplot -e "archivo='resultados/radau_iia3.dat'; titulo='Radau IIA'" graficar.gp

if (!exists("archivo")) archivo = 'resultados/rk4.dat'
if (!exists("titulo")) titulo = 'Runge-Kutta'
salida = archivo[1:strlen(archivo)-4] . '.png'

if (strstrt(GPVAL_TERMINALS, "pngcairo") > 0) {
    set terminal pngcairo size 1200,500 enhanced font "Arial,11"
} else {
    set terminal png size 1200,500 font "Arial,11"
}
set output salida

set multiplot layout 1,2 title "Lienard (Van der Pol) - " . titulo

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
