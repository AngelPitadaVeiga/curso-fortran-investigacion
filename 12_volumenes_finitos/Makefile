# Makefile de la unidad 12: dos programas (fluido y orden_espacial) que comparten módulos.
#
#     make                   compila los dos programas
#     make run               el vórtice con el esquema de orden 2 (vortice.nml)
#     make run-primer-orden  el mismo problema con el esquema de orden 1
#     make run-orden         orden de convergencia de los dos esquemas
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
    BORRAR = del /q *.o *.mod fluido$(EXE) orden_espacial$(EXE) 2>nul & if exist resultados rmdir /s /q resultados
else
    CREAR_RESULTADOS = mkdir -p resultados
    BORRAR = rm -rf *.o *.mod fluido$(EXE) orden_espacial$(EXE) resultados
endif

all: fluido$(EXE) orden_espacial$(EXE)

fluido$(EXE): gas.o volumenes.o vortice.o fluido.o
	$(FC) $(FFLAGS) gas.o volumenes.o vortice.o fluido.o -o fluido

orden_espacial$(EXE): gas.o volumenes.o vortice.o orden_espacial.o
	$(FC) $(FFLAGS) gas.o volumenes.o vortice.o orden_espacial.o -o orden_espacial

%.o: %.f90
	$(FC) $(FFLAGS) -c $<

volumenes.o vortice.o: gas.o
fluido.o orden_espacial.o: gas.o volumenes.o vortice.o

resultados:
	$(CREAR_RESULTADOS)

run: fluido$(EXE) | resultados
	./fluido vortice.nml

run-primer-orden: fluido$(EXE) | resultados
	./fluido vortice_primer_orden.nml

run-orden: orden_espacial$(EXE) | resultados
	./orden_espacial

clean:
	$(BORRAR)
