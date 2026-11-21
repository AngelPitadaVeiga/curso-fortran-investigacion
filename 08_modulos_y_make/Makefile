# Makefile de la unidad 08.
#
#     make             compila lo que haga falta
#     make run         compila y ejecuta
#     make clean       borra lo generado
#
# Para otras opciones de compilación:  make FFLAGS="-g -fcheck=all"

FC     = gfortran
FFLAGS = -O2

# En Windows, gfortran añade .exe al nombre del ejecutable.
ifeq ($(OS),Windows_NT)
    EXE = .exe
endif

# rm existe en Linux, macOS y MSYS2, pero no en la terminal de Windows (cmd), que es la que usa
# make si no encuentra otra. Se distingue porque cmd escribe las comillas de echo.
ifeq ($(shell echo "x"),"x")
    BORRAR = del /q *.o *.mod euler$(EXE) 2>nul
else
    BORRAR = rm -f *.o *.mod euler$(EXE)
endif

# Enlazar: todos los .o juntos forman el ejecutable.
euler$(EXE): modelo.o integrador.o principal.o
	$(FC) $(FFLAGS) modelo.o integrador.o principal.o -o euler

# Compilar: cada .f90 da un .o (y, si tiene un módulo, un .mod).
%.o: %.f90
	$(FC) $(FFLAGS) -c $<

# Quién usa a quién: un módulo se compila antes que quien lo usa.
integrador.o: modelo.o
principal.o: integrador.o modelo.o

run: euler$(EXE)
	./euler

clean:
	$(BORRAR)
