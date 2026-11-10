# Makefile de la unidad 11: dos programas (fem y orden_espacial) que comparten módulos.
#
#     make                 compila los dos programas
#     make run             ecuación del calor con Euler implícito
#     make run-explicito   la misma, con Euler explícito: explota
#     make run-fisher      un frente de Fisher-KPP
#     make run-orden       orden de convergencia en el espacio
#     make clean

FC     = gfortran
FFLAGS = -O2

ifeq ($(OS),Windows_NT)
    EXE = .exe
endif

all: fem$(EXE) orden_espacial$(EXE)

fem$(EXE): malla.o tridiagonal.o ensamblaje.o evolucion.o fem.o
	$(FC) $(FFLAGS) malla.o tridiagonal.o ensamblaje.o evolucion.o fem.o -o fem

orden_espacial$(EXE): malla.o tridiagonal.o ensamblaje.o orden_espacial.o
	$(FC) $(FFLAGS) malla.o tridiagonal.o ensamblaje.o orden_espacial.o -o orden_espacial

%.o: %.f90
	$(FC) $(FFLAGS) -c $<

evolucion.o: tridiagonal.o
fem.o: malla.o ensamblaje.o evolucion.o
orden_espacial.o: malla.o ensamblaje.o tridiagonal.o

resultados:
	mkdir -p resultados

run: fem$(EXE) | resultados
	./fem calor.nml

run-explicito: fem$(EXE) | resultados
	./fem calor_explicito.nml

run-fisher: fem$(EXE) | resultados
	./fem fisher.nml

run-orden: orden_espacial$(EXE)
	./orden_espacial

clean:
	rm -rf *.o *.mod fem orden_espacial fem.exe orden_espacial.exe resultados
