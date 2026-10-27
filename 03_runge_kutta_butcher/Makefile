# Makefile del bloque 03 (Runge-Kutta general con tableros de Butcher).
# Funciona en Linux, macOS y Windows (MSYS2 UCRT64, con make o mingw32-make).
#
#   make              compila en modo release los dos programas
#   make debug        compila en modo debug
#   make run          ejecuta rk_butcher con entrada.nml
#   make run-debug    lo mismo, en modo debug
#   make rigido       demostración de rigidez: RK4 frente a Radau IIA (mu = 1000)
#   make convergencia test de convergencia de todos los tableros
#   make plot         vuelve a dibujar resultados/rk4.dat
#   make clean        borra objetos, módulos, ejecutables y resultados
#
# El modelo (modelo_lienard) y las utilidades (sistema) se reutilizan del
# bloque 02: se compilan desde ../02_euler_lienard/src, sin copiarlos.

FC = gfortran
PROG = rk_butcher
PROG_CONV = convergencia_rk
BLOQUE02 = ../02_euler_lienard/src

MODO ?= release
ifeq ($(MODO),debug)
  FFLAGS = -g -O0 -fcheck=all -fbacktrace -Wall -Wextra -Wno-unused-dummy-argument \
           -ffpe-trap=invalid,zero,overflow
  SUFIJO = _debug
else
  FFLAGS = -O3 -march=native
  SUFIJO =
endif
FFLAGS += -std=f2018

# ---------------------------------------------------------------------------
# Portabilidad Windows / Linux (véase el Makefile del bloque 02)
# ---------------------------------------------------------------------------
ifeq ($(OS),Windows_NT)
  EXE = .exe
  ifeq ($(findstring /,$(SHELL)),)
    SHELL_CMD = si
  endif
endif
ifdef SHELL_CMD
  CREAR_DIR = if not exist $(subst /,\,$(1)) mkdir $(subst /,\,$(1))
  BORRAR    = del /q /f $(subst /,\,$(1)) 2>nul & if exist build rmdir /s /q build & if exist resultados rmdir /s /q resultados
  EJECUTAR  = .\$(1)
else
  CREAR_DIR = mkdir -p $(1)
  BORRAR    = rm -rf $(1) build resultados
  EJECUTAR  = ./$(1)
endif

# ---------------------------------------------------------------------------
# Fuentes y dependencias
# ---------------------------------------------------------------------------
BUILD = build/$(MODO)
EJECUTABLE = $(PROG)$(SUFIJO)$(EXE)
EJECUTABLE_CONV = $(PROG_CONV)$(SUFIJO)$(EXE)

# Módulos comunes (en orden de compilación) y programas principales.
MODULOS = $(BLOQUE02)/modelo_lienard.f90 $(BLOQUE02)/sistema.f90 \
          src/algebra_lineal.f90 src/tablero_butcher.f90 src/solver_rk.f90
OBJ_MODULOS = $(patsubst %.f90,$(BUILD)/%.o,$(notdir $(MODULOS)))

vpath %.f90 $(BLOQUE02) src app convergencia

.PHONY: all release debug run run-debug rigido convergencia plot clean

all: $(EJECUTABLE) $(EJECUTABLE_CONV)
release: all

debug:
	$(MAKE) MODO=debug

$(EJECUTABLE): $(OBJ_MODULOS) $(BUILD)/principal.o
	$(FC) $(FFLAGS) $^ -o $@

$(EJECUTABLE_CONV): $(OBJ_MODULOS) $(BUILD)/convergencia.o
	$(FC) $(FFLAGS) $^ -o $@

$(BUILD)/%.o: %.f90 | $(BUILD)
	$(FC) $(FFLAGS) -J$(BUILD) -c $< -o $@

$(BUILD):
	$(call CREAR_DIR,$(BUILD))

# Dependencias entre módulos
$(BUILD)/solver_rk.o: $(BUILD)/tablero_butcher.o $(BUILD)/algebra_lineal.o
$(BUILD)/principal.o: $(OBJ_MODULOS)
$(BUILD)/convergencia.o: $(OBJ_MODULOS)

run: all
	$(call EJECUTAR,$(EJECUTABLE))

run-debug:
	$(MAKE) MODO=debug run

rigido: all
	$(call EJECUTAR,$(EJECUTABLE)) entrada_rigido.nml tableros/rk4.txt
	$(call EJECUTAR,$(EJECUTABLE)) entrada_rigido.nml tableros/radau_iia3.txt
	gnuplot graficar_rigido.gp

convergencia: all
	$(call EJECUTAR,$(EJECUTABLE_CONV)) convergencia/convergencia.nml

plot:
	gnuplot graficar.gp

clean:
	$(call BORRAR,$(PROG)$(EXE) $(PROG)_debug$(EXE) $(PROG_CONV)$(EXE) $(PROG_CONV)_debug$(EXE))
