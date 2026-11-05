function vdp_rk4_handle(n, pasos, repeticiones)
% VDP_RK4_HANDLE  El mismo RK4 que vdp_rk4.f90, escrito en el estilo habitual
%   de Matlab: el estado es un vector columna y el campo una función anónima
%   (como se le pasaría a ode45). Mismo algoritmo y mismas operaciones; solo
%   cambia el estilo. Compárese con vdp_rk4_vectorial.f90.
%
%   Uso:  matlab -batch "vdp_rk4_handle(1000, 1000, 1)"
if nargin < 1, n = 1000; end
if nargin < 2, pasos = 1000; end
if nargin < 3, repeticiones = 1; end

mu = 1.0;
h = 0.01;
F = @(u) [u(2); -mu * (u(1) * u(1) - 1.0) * u(2) - u(1)];

mejor = inf;
suma = 0;
for r = 1:repeticiones
    t0 = tic;
    suma = 0.0;
    for i = 1:n
        u = [-3.0 + 6.0 * mod(37 * i, 1000) / 1000.0;
             -3.0 + 6.0 * mod(53 * i, 1000) / 1000.0];
        for k = 1:pasos
            k1 = F(u);
            k2 = F(u + 0.5 * h * k1);
            k3 = F(u + 0.5 * h * k2);
            k4 = F(u + h * k3);
            u = u + h / 6.0 * (k1 + 2.0 * k2 + 2.0 * k3 + k4);
        end
        suma = suma + u(1) + u(2);
    end
    mejor = min(mejor, toc(t0));
end
fprintf('RESULTADO Matlab-funcion-anonima N=%d pasos=%d tiempo_s=%.5e suma=%.15e\n', n, pasos, mejor, suma);
end
