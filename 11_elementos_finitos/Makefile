# Makefile de la unidad 11: dos programas (solido y orden_espacial) que comparten módulos.
#
#     make                 compila los dos programas
#     make run             la viga bajo su carga (estática)
#     make run-vibracion   la viga soltada desde esa deformación, con el método implícito
#     make run-explicito   lo mismo con el método explícito (con un paso estable)
#     make run-inestable   y con un paso demasiado grande: explota
#     make run-orden       orden de convergencia en el espacio
#     make clean

FC     = gfortran
FFLAGS = -O2

ifeq ($(OS),Windows_NT)
    EXE = .exe
endif

all: solido$(EXE) orden_espacial$(EXE)

solido$(EXE): malla.o elasticidad.o algebra.o dinamica.o solido.o
	$(FC) $(FFLAGS) malla.o elasticidad.o algebra.o dinamica.o solido.o -o solido

orden_espacial$(EXE): malla.o elasticidad.o algebra.o orden_espacial.o
	$(FC) $(FFLAGS) malla.o elasticidad.o algebra.o orden_espacial.o -o orden_espacial

%.o: %.f90
	$(FC) $(FFLAGS) -c $<

dinamica.o: algebra.o
solido.o: malla.o elasticidad.o algebra.o dinamica.o
orden_espacial.o: malla.o elasticidad.o algebra.o

resultados:
	mkdir -p resultados

run: solido$(EXE) | resultados
	./solido estatico.nml

run-vibracion: solido$(EXE) | resultados
	./solido vibracion.nml

run-explicito: solido$(EXE) | resultados
	./solido vibracion_explicito.nml

run-inestable: solido$(EXE) | resultados
	./solido vibracion_inestable.nml

run-orden: orden_espacial$(EXE)
	./orden_espacial

clean:
	rm -rf *.o *.mod solido orden_espacial solido.exe orden_espacial.exe resultados
