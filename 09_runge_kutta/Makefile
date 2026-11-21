# Makefile de la unidad 09: dos programas (rk y orden) que comparten módulos.
#
#     make                 compila los dos programas
#     make run             ejecuta rk con entrada.nml
#     make run-orden       mide el orden de convergencia
#     make run-rigido      Van der Pol con mu = 1000: RK4 frente a los implícitos
#     make clean

FC     = gfortran
FFLAGS = -O2

ifeq ($(OS),Windows_NT)
    EXE = .exe
endif

# rm y mkdir -p existen en Linux, macOS y MSYS2, pero no en la terminal de Windows (cmd), que es
# la que usa make si no encuentra otra. Se distingue porque cmd escribe las comillas de echo.
ifeq ($(shell echo "x"),"x")
    CREAR_RESULTADOS = if not exist resultados mkdir resultados
    BORRAR = del /q *.o *.mod rk$(EXE) orden$(EXE) 2>nul & if exist resultados rmdir /s /q resultados
else
    CREAR_RESULTADOS = mkdir -p resultados
    BORRAR = rm -rf *.o *.mod rk$(EXE) orden$(EXE) resultados
endif

all: rk$(EXE) orden$(EXE)

rk$(EXE): modelo.o runge_kutta.o principal.o
	$(FC) $(FFLAGS) modelo.o runge_kutta.o principal.o -o rk

orden$(EXE): modelo.o runge_kutta.o orden.o
	$(FC) $(FFLAGS) modelo.o runge_kutta.o orden.o -o orden

%.o: %.f90
	$(FC) $(FFLAGS) -c $<

runge_kutta.o: modelo.o
principal.o orden.o: runge_kutta.o

resultados:
	$(CREAR_RESULTADOS)

run: rk$(EXE) | resultados
	./rk

run-orden: orden$(EXE) | resultados
	./orden

run-rigido: rk$(EXE) | resultados
	./rk rigido_euler_implicito.nml
	./rk rigido_trapecio.nml
	./rk rigido_rk4.nml

clean:
	$(BORRAR)
