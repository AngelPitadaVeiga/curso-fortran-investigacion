# Benchmark: Van der Pol con RK4 de paso fijo desde N condiciones iniciales.
# El mismo algoritmo, con bucles explícitos, que vdp_rk4.f90, .cpp, .py y vdp_rk4_handle.m.
#
# Uso:  julia vdp_rk4.jl [N] [pasos] [repeticiones]
#
# Se mide el mejor tiempo de varias repeticiones. No hace falta BenchmarkTools.

"""Integra las N trayectorias y devuelve sum(x + y) del estado final."""
function integrar(n::Int, pasos::Int)
    mu = 1.0
    h = 0.01
    suma = 0.0
    for i in 1:n
        # Condiciones iniciales deterministas e independientes de N.
        x = -3.0 + 6.0 * mod(37 * i, 1000) / 1000.0
        y = -3.0 + 6.0 * mod(53 * i, 1000) / 1000.0
        for k in 1:pasos
            k1x = y
            k1y = -mu * (x * x - 1.0) * y - x
            x2 = x + 0.5 * h * k1x; y2 = y + 0.5 * h * k1y
            k2x = y2
            k2y = -mu * (x2 * x2 - 1.0) * y2 - x2
            x3 = x + 0.5 * h * k2x; y3 = y + 0.5 * h * k2y
            k3x = y3
            k3y = -mu * (x3 * x3 - 1.0) * y3 - x3
            x4 = x + h * k3x; y4 = y + h * k3y
            k4x = y4
            k4y = -mu * (x4 * x4 - 1.0) * y4 - x4
            x = x + h / 6.0 * (k1x + 2.0 * k2x + 2.0 * k3x + k4x)
            y = y + h / 6.0 * (k1y + 2.0 * k2y + 2.0 * k3y + k4y)
        end
        suma += x + y
    end
    return suma
end

function main()
    n = length(ARGS) >= 1 ? parse(Int, ARGS[1]) : 100000
    pasos = length(ARGS) >= 2 ? parse(Int, ARGS[2]) : 1000
    repeticiones = length(ARGS) >= 3 ? parse(Int, ARGS[3]) : 3

    suma = 0.0
    mejor = Inf
    for r in 1:repeticiones
        t0 = time_ns()
        suma = integrar(n, pasos)
        mejor = min(mejor, (time_ns() - t0) / 1e9)
    end

    println("RESULTADO Julia N=$n pasos=$pasos tiempo_s=$mejor suma=$suma")
end

main()
