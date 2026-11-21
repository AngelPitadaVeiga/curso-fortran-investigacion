# Makefile de la unidad 10.
#
#     make             compila
#     make run         ejecuta retrato con entrada.nml
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
    BORRAR = del /q *.o *.mod retrato$(EXE) 2>nul & if exist resultados rmdir /s /q resultados
else
    CREAR_RESULTADOS = mkdir -p resultados
    BORRAR = rm -rf *.o *.mod retrato$(EXE) resultados
endif

retrato$(EXE): modelo.o runge_kutta.o retrato.o
	$(FC) $(FFLAGS) modelo.o runge_kutta.o retrato.o -o retrato

%.o: %.f90
	$(FC) $(FFLAGS) -c $<

runge_kutta.o: modelo.o
retrato.o: runge_kutta.o

resultados:
	$(CREAR_RESULTADOS)

run: retrato$(EXE) | resultados
	./retrato

clean:
	$(BORRAR)
