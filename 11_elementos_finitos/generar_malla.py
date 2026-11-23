# Genera mallas de triángulos para solido.f90 y las escribe en un archivo de texto.
#
#     python generar_malla.py                 las dos piezas: mensula.malla y viga.malla
#     python generar_malla.py viga 0.1        la viga, con triángulos de lado 0.1
#
# Cada pieza es un polígono con agujeros circulares. Los nodos son los del contorno
# (repartidos cada h) más una rejilla de triángulos equiláteros en el interior; se unen
# con una triangulación de Delaunay (la de matplotlib) y se quitan los triángulos que
# caen fuera de la pieza o dentro de un agujero.
#
# Formato del archivo:
#     una línea de comentario
#     n_nodos  n_triangulos
#     x  y  fijo  peso          una línea por nodo; fijo = 1 si está empotrado, y peso es
#                               la fracción de la carga total que soporta (suman 1)
#     n1  n2  n3                una línea por triángulo, numerando los nodos desde 1
import sys
import numpy as np
import matplotlib.tri as mtri
from matplotlib.path import Path


def pieza(nombre):
    """Contorno (antihorario), agujeros (x, y, radio), lado empotrado y lado cargado."""
    if nombre == "viga":
        contorno = [(0, 0), (10, 0), (10, 1), (0, 1)]
        agujeros = []
    elif nombre == "mensula":
        # Pieza que se estrecha desde la pared (alto 4) hasta el extremo (alto 1).
        contorno = [(0, 0), (10, 3), (10, 4), (0, 4)]
        agujeros = [(2.5, 2.4, 1.0), (5.5, 2.85, 0.7), (8.0, 3.2, 0.42)]
    else:
        raise SystemExit(f"Pieza desconocida: {nombre}")
    xmax = max(p[0] for p in contorno)
    empotrado = lambda x, y: x < 1e-9                # el lado x = 0
    cargado = lambda x, y: x > xmax - 1e-9           # el lado derecho
    return np.array(contorno, float), agujeros, empotrado, cargado


def distancia_a_segmento(p, a, b):
    t = np.clip(((p - a) @ (b - a)) / ((b - a) @ (b - a)), 0, 1)
    return np.hypot(*(p - (a + t[:, None] * (b - a))).T)


def generar(nombre, h):
    contorno, agujeros, empotrado, cargado = pieza(nombre)
    vertices = np.vstack([contorno, contorno[:1]])

    # 1) Nodos del contorno exterior y de los agujeros, separados unos h.
    puntos = []
    for a, b in zip(vertices[:-1], vertices[1:]):
        m = max(1, int(np.ceil(np.hypot(*(b - a)) / h)))
        puntos += [a + (b - a) * k / m for k in range(m)]
    for xc, yc, r in agujeros:
        m = int(np.ceil(2 * np.pi * r / h))
        puntos += [(xc + r * np.cos(2 * np.pi * k / m), yc + r * np.sin(2 * np.pi * k / m))
                   for k in range(m)]

    # 2) Rejilla interior de triángulos equiláteros (filas desplazadas medio lado), sin
    #    los puntos que quedan a menos de h/2 del contorno o de un agujero.
    x0, y0 = contorno.min(axis=0)
    x1, y1 = contorno.max(axis=0)
    filas = np.arange(y0, y1 + h, h * np.sqrt(3) / 2)
    rejilla = np.array([(x + (k % 2) * h / 2, y) for k, y in enumerate(filas)
                        for x in np.arange(x0, x1 + h, h)])
    dentro = Path(contorno).contains_points(rejilla)
    lejos = np.ones(len(rejilla), bool)
    for a, b in zip(vertices[:-1], vertices[1:]):
        lejos &= distancia_a_segmento(rejilla, a, b) > h / 2
    for xc, yc, r in agujeros:
        lejos &= np.hypot(rejilla[:, 0] - xc, rejilla[:, 1] - yc) > r + h / 2
    nodos = np.vstack([puntos, rejilla[dentro & lejos]])

    # 3) Delaunay, y fuera los triángulos cuyo centro no está en la pieza.
    triangulos = mtri.Triangulation(nodos[:, 0], nodos[:, 1]).triangles
    centros = nodos[triangulos].mean(axis=1)
    validos = Path(contorno).contains_points(centros)
    for xc, yc, r in agujeros:
        validos &= np.hypot(centros[:, 0] - xc, centros[:, 1] - yc) > r
    triangulos = triangulos[validos]

    # 4) Unas pasadas de suavizado: cada nodo interior va al centro de sus vecinos.
    interior = np.arange(len(nodos)) >= len(puntos)
    vecinos = [set() for _ in nodos]
    for t in triangulos:
        for i in t:
            vecinos[i].update(t)
    for _ in range(5):
        nuevos = nodos.copy()
        for i in np.flatnonzero(interior):
            nuevos[i] = nodos[list(vecinos[i])].mean(axis=0)
        nodos = nuevos

    # 5) Vértices en sentido antihorario (área positiva), como espera elasticidad.f90.
    a, b, c = (nodos[triangulos[:, k]] for k in range(3))
    area = 0.5 * ((b - a)[:, 0] * (c - a)[:, 1] - (c - a)[:, 0] * (b - a)[:, 1])
    triangulos[area < 0] = triangulos[area < 0][:, [0, 2, 1]]

    # 6) Empotramiento, y la carga repartida por el lado derecho: a cada nodo le toca la
    #    mitad de los dos tramos de contorno que lo tocan.
    fijo = np.array([empotrado(x, y) for x, y in nodos], int)
    con_carga = np.flatnonzero([cargado(x, y) for x, y in nodos])
    con_carga = con_carga[np.argsort(nodos[con_carga, 1])]
    tramos = np.diff(nodos[con_carga, 1])
    peso = np.zeros(len(nodos))
    peso[con_carga[:-1]] += tramos / 2
    peso[con_carga[1:]] += tramos / 2
    peso /= peso.sum()

    archivo = f"{nombre}.malla"
    with open(archivo, "w") as f:
        f.write(f"# {nombre}, h = {h}:  n_nodos n_triangulos / x y fijo peso / n1 n2 n3\n")
        f.write(f"{len(nodos)} {len(triangulos)}\n")
        for (x, y), fi, p in zip(nodos, fijo, peso):
            f.write(f"{x:16.8e} {y:16.8e} {fi:2d} {p:16.8e}\n")
        for t in triangulos + 1:
            f.write(f"{t[0]:8d} {t[1]:8d} {t[2]:8d}\n")
    print(f"{archivo}: {len(nodos)} nodos, {len(triangulos)} triangulos")


if len(sys.argv) > 1:
    generar(sys.argv[1], float(sys.argv[2]) if len(sys.argv) > 2 else 0.15)
else:
    generar("mensula", 0.15)
    generar("viga", 0.125)
