# Retrato de fases (bloque 08).   Uso:  gnuplot graficar.gp
# Lee mu, x_max e y_max de resultados/parametros.gp (lo escribe el programa).

load 'resultados/parametros.gp'

if (strstrt(GPVAL_TERMINALS, "pngcairo") > 0) {
    set terminal pngcairo size 800,700 enhanced font "Arial,11"
} else {
    set terminal png size 800,700 font "Arial,11"
}
set output 'resultados/retrato.png'

set title sprintf("Van der Pol, mu = %g:  x' = y,  y' = -mu (x^2 - 1) y - x", mu)
set xlabel "x"
set ylabel "y"
set xrange [-x_max:x_max]
set yrange [-y_max:y_max]
set key bottom right font ",9" opaque
set samples 2000

# Nulclina y' = 0:  y = -x / (mu (x^2 - 1)). Se corta (1/0) donde se sale
# mucho de la caja, para que no dibuje una línea vertical en x = 1 y x = -1.
nulclina(x) = (abs(mu * (x**2 - 1)) > 0 && abs(x / (mu * (x**2 - 1))) < 2 * y_max) ? -x / (mu * (x**2 - 1)) : 1/0

plot 'resultados/campo.dat' using 1:2:3:4 with vectors head size 0.06,20 filled lc rgb "#9e9e9e" notitle, \
     'resultados/trayectorias.dat' using 1:2 with lines lw 0.8 lc rgb "#6baed6" title "trayectorias", \
     0 with lines dt 2 lw 2 lc rgb "#ff7f0e" title "x' = 0", \
     nulclina(x) with lines dt 2 lw 2 lc rgb "#2ca02c" title "y' = 0", \
     'resultados/ciclo.dat' using 1:2 with lines lw 3 lc rgb "#d62728" title "ciclo limite"

print "Figura escrita en resultados/retrato.png"
