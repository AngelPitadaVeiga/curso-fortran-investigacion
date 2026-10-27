# graficar.jl (OPCIONAL): dibuja con Julia los mismos .dat que usa gnuplot.
#
# Requisitos (una sola vez):   julia -e 'using Pkg; Pkg.add("Plots")'
# Uso, desde la carpeta del bloque y tras `make run`:
#     julia graficar.jl
# Genera resultados/retrato_julia.png.
#
# Muestra que los datos en columnas que escribe Fortran son un formato de
# intercambio universal: el cálculo en Fortran, el dibujo donde se prefiera.

using Plots

"""
    leer_bloques(archivo)

Lee un archivo de columnas al estilo gnuplot: ignora las líneas que empiezan
por '#', separa *bloques* con dos líneas en blanco (lo que gnuplot llama
`index`) y, dentro de un bloque, separa curvas con una línea en blanco
(se inserta una fila de NaN para que Plots no las una).
"""
function leer_bloques(archivo)
    bloques = Matrix{Float64}[]
    filas = Vector{Float64}[]
    blancos = 0
    for linea in eachline(archivo)
        l = strip(linea)
        startswith(l, "#") && continue
        if isempty(l)
            blancos += 1
            continue
        end
        if blancos >= 2 && !isempty(filas)
            push!(bloques, permutedims(reduce(hcat, filas)))
            filas = Vector{Float64}[]
        elseif blancos == 1 && !isempty(filas)
            push!(filas, fill(NaN, length(filas[end])))
        end
        blancos = 0
        push!(filas, parse.(Float64, split(l)))
    end
    isempty(filas) || push!(bloques, permutedims(reduce(hcat, filas)))
    return bloques
end

carpeta = "resultados"
mus = vec(leer_bloques(joinpath(carpeta, "mus.dat"))[1])

paneles = Plots.Plot[]
for (i, mu) in enumerate(mus)
    archivo(tipo) = joinpath(carpeta, "$(tipo)_$(i).dat")
    campo = leer_bloques(archivo("campo"))[1]
    tray = leer_bloques(archivo("trayectorias"))[1]
    nulclinas = leer_bloques(archivo("nulclinas"))
    ciclo = leer_bloques(archivo("ciclo"))[1]

    # Límites: los de la rejilla de flechas, con un pequeño margen.
    dx = (maximum(campo[:, 1]) - minimum(campo[:, 1])) / 40
    dy = (maximum(campo[:, 2]) - minimum(campo[:, 2])) / 40
    p = quiver(campo[:, 1], campo[:, 2], quiver = (campo[:, 3], campo[:, 4]),
               color = :gray, alpha = 0.6, label = "")
    plot!(p, tray[:, 1], tray[:, 2], lw = 0.6, color = :steelblue, label = "trayectorias")
    plot!(p, nulclinas[1][:, 1], nulclinas[1][:, 2], ls = :dash, lw = 2, color = :orange, label = "x' = 0")
    plot!(p, nulclinas[2][:, 1], nulclinas[2][:, 2], ls = :dash, lw = 2, color = :green, label = "y' = 0")
    plot!(p, ciclo[:, 1], ciclo[:, 2], lw = 3, color = :red, label = "ciclo limite")
    plot!(p, xlims = (minimum(campo[:, 1]) - dx, maximum(campo[:, 1]) + dx),
             ylims = (minimum(campo[:, 2]) - dy, maximum(campo[:, 2]) + dy),
             title = "mu = $(mu)", xlabel = "x", ylabel = "y", legend = :bottomright)
    push!(paneles, p)
end

figura = plot(paneles..., layout = (1, length(paneles)), size = (520 * length(paneles), 560))
savefig(figura, joinpath(carpeta, "retrato_julia.png"))
println("Figura escrita en ", joinpath(carpeta, "retrato_julia.png"))
