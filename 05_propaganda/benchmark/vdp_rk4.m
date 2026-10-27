function vdp_rk4(n, pasos, repeticiones)
% VDP_RK4  Benchmark: Van der Pol con RK4 de paso fijo desde N condiciones iniciales.
%   El mismo algoritmo, con bucles explícitos, que vdp_rk4.f90, .cpp, .jl y .py.
%
%   Uso (desde la carpeta benchmark):
%       matlab -batch "vdp_rk4(20000, 1000, 3)"
if nargin < 1, n = 20000; end
if nargin < 2, pasos = 1000; end
if nargin < 3, repeticiones = 3; end

mejor = inf;
suma = 0;
for r = 1:repeticiones
    t0 = tic;
    suma = integrar(n, pasos);
    mejor = min(mejor, toc(t0));
end
fprintf('Matlab %s\n', version);
fprintf('RESULTADO Matlab N=%d pasos=%d tiempo_s=%.5e suma=%.15e\n', n, pasos, mejor, suma);
end

function suma = integrar(n, pasos)
% Integra las N trayectorias y devuelve sum(x + y) del estado final.
mu = 1.0;
h = 0.01;
suma = 0.0;
for i = 1:n
    % Condiciones iniciales deterministas e independientes de N.
    x = -3.0 + 6.0 * mod(37 * i, 1000) / 1000.0;
    y = -3.0 + 6.0 * mod(53 * i, 1000) / 1000.0;
    for k = 1:pasos
        k1x = y;
        k1y = -mu * (x * x - 1.0) * y - x;
        x2 = x + 0.5 * h * k1x;  y2 = y + 0.5 * h * k1y;
        k2x = y2;
        k2y = -mu * (x2 * x2 - 1.0) * y2 - x2;
        x3 = x + 0.5 * h * k2x;  y3 = y + 0.5 * h * k2y;
        k3x = y3;
        k3y = -mu * (x3 * x3 - 1.0) * y3 - x3;
        x4 = x + h * k3x;  y4 = y + h * k3y;
        k4x = y4;
        k4y = -mu * (x4 * x4 - 1.0) * y4 - x4;
        x = x + h / 6.0 * (k1x + 2.0 * k2x + 2.0 * k3x + k4x);
        y = y + h / 6.0 * (k1y + 2.0 * k2y + 2.0 * k3y + k4y);
    end
    suma = suma + x + y;
end
end
