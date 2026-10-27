# Gráfica de barras del benchmark (tiempo por paso de RK4 y trayectoria).
# Uso: gnuplot graficar_benchmark.gp   (tras ./ejecutar_benchmark.sh)

archivo = 'resultados/tiempos.dat'

if (strstrt(GPVAL_TERMINALS, "pngcairo") > 0) {
    set terminal pngcairo size 1100,600 enhanced font "Arial,12"
} else {
    set terminal png size 1100,600 font "Arial,12"
}
set output 'resultados/benchmark.png'

set title "Van der Pol + RK4 de paso fijo: tiempo por paso y trayectoria\n(menos es mejor; escala logaritmica; numero sobre la barra = veces Fortran)"
set ylabel "nanosegundos por paso"
set logscale y
set format y "10^{%L}"
set yrange [1:*]
set style fill solid 0.85 border -1
set boxwidth 0.6
set grid ytics
set xtics rotate by -20 left nomirror
set key off
set offsets 0.5, 0.5, 0, 0

plot archivo using 0:2:xtic(1) with boxes lc rgb "#4c72b0", \
     archivo using 0:($2*1.35):(sprintf("x%.1f", $3)) with labels font ",11"
print "Figura escrita en resultados/benchmark.png"
