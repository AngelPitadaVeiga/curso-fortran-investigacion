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

retrato$(EXE): modelo.o runge_kutta.o retrato.o
	$(FC) $(FFLAGS) modelo.o runge_kutta.o retrato.o -o retrato

%.o: %.f90
	$(FC) $(FFLAGS) -c $<

runge_kutta.o: modelo.o
retrato.o: runge_kutta.o

resultados:
	mkdir -p resultados

run: retrato$(EXE) | resultados
	./retrato

clean:
	rm -rf *.o *.mod retrato retrato.exe resultados
