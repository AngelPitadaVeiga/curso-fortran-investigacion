# Makefile del bloque 06 (Fortran heredado).
#
#   make            compila legado.f (FORTRAN 77) y moderno.f90
#   make run        ejecuta los dos y compara sus salidas (deben ser idénticas)
#   make debug      compila con comprobaciones (como en los demás bloques)
#   make clean

FC = gfortran

MODO ?= release
ifeq ($(MODO),debug)
  FFLAGS = -g -O0 -fcheck=all -fbacktrace -Wall -Wextra -Wno-unused-dummy-argument \
           -ffpe-trap=invalid,zero,overflow
else
  FFLAGS = -O3 -march=native
endif

# Portabilidad Windows / Linux (véase el Makefile del bloque 02)
ifeq ($(OS),Windows_NT)
  EXE = .exe
  ifeq ($(findstring /,$(SHELL)),)
    SHELL_CMD = si
  endif
endif
ifdef SHELL_CMD
  CREAR_DIR = if not exist $(1) mkdir $(1)
  COMPARAR  = fc /b $(subst /,\,$(1)) $(subst /,\,$(2)) >nul && echo Salidas identicas || echo LAS SALIDAS DIFIEREN
  BORRAR    = del /q /f $(1) 2>nul & if exist resultados rmdir /s /q resultados
  EJECUTAR  = .\$(1)
else
  CREAR_DIR = mkdir -p $(1)
  COMPARAR  = cmp -s $(1) $(2) && echo "Salidas identicas" || echo "LAS SALIDAS DIFIEREN"
  BORRAR    = rm -rf $(1) resultados
  EJECUTAR  = ./$(1)
endif

.PHONY: all debug run clean

all: legado_f77$(EXE) moderno$(EXE)

debug:
	$(MAKE) clean
	$(MAKE) MODO=debug

# -std=legacy: acepta las construcciones obsoletas de FORTRAN 77 sin avisar.
# La extensión .f indica a gfortran que el archivo es de formato fijo.
legado_f77$(EXE): legado.f
	$(FC) $(FFLAGS) -std=legacy $< -o $@

moderno$(EXE): moderno.f90
	$(FC) $(FFLAGS) -std=f2018 $< -o $@

run: all
	$(call CREAR_DIR,resultados)
	$(call EJECUTAR,legado_f77$(EXE)) > resultados/legado.txt
	$(call EJECUTAR,moderno$(EXE)) > resultados/moderno.txt
	$(call EJECUTAR,moderno$(EXE))
	$(call COMPARAR,resultados/legado.txt,resultados/moderno.txt)

clean:
	$(call BORRAR,legado_f77$(EXE) moderno$(EXE) *.mod)
