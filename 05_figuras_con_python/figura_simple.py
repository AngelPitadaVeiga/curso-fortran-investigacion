# La figura más sencilla: lee la tabla de la unidad 04 y dibuja dos columnas.
# Antes hay que ejecutar ./tabla en la carpeta 04_arrays_y_archivos.
#
#     python figura_simple.py
import numpy as np
import matplotlib.pyplot as plt

# loadtxt ignora las líneas que empiezan por #. unpack separa las columnas.
x, seno, coseno = np.loadtxt("../04_arrays_y_archivos/tabla.dat", unpack=True)

plt.plot(x, seno, label="sin(x)")
plt.plot(x, coseno, label="cos(x)")
plt.xlabel("x")
plt.legend()
plt.grid(alpha=0.3)

plt.savefig("tabla.png", dpi=150)
print("Figura escrita en tabla.png")
plt.show()      # abre una ventana; al cerrarla termina el programa
