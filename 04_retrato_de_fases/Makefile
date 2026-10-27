# Makefile del bloque 04 (retratos de fases).
# Funciona en Linux, macOS y Windows (MSYS2 UCRT64, con make o mingw32-make).
#
#   make            compila en modo release
#   make debug      compila en modo debug
#   make run        calcula los retratos de fases y genera la figura
#   make run-debug  lo mismo, en modo debug
#   make plot       vuelve a dibujar (gnuplot resultados/retrato.gp)
#   make clean      borra objetos, módulos, ejecutables y resultados
#
# Reutilización: el modelo y las utilidades vienen del bloque 02 y el
# solver Runge-Kutta del bloque 03. Se compilan desde sus carpetas
# (referencias relativas), sin copiar ningún archivo.

FC = gfortran
PROG = retrato
BLOQUE02 = ../02_euler_lienard/src
BLOQUE03 = ../03_runge_kutta_butcher/src

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

# En orden de compilación: primero lo reutilizado, después lo propio.
FUENTES = $(BLOQUE02)/modelo_lienard.f90 $(BLOQUE02)/sistema.f90           $(BLOQUE03)/algebra_lineal.f90 $(BLOQUE03)/tablero_butcher.f90 $(BLOQUE03)/solver_rk.f90           src/retrato_fases.f90 app/principal.f90
OBJETOS = $(patsubst %.f90,$(BUILD)/%.o,$(notdir $(FUENTES)))

vpath %.f90 $(BLOQUE02) $(BLOQUE03) src app

.PHONY: all release debug run run-debug plot clean

all: $(EJECUTABLE)
release: all

debug:
	$(MAKE) MODO=debug

$(EJECUTABLE): $(OBJETOS)
	$(FC) $(FFLAGS) $^ -o $@

$(BUILD)/%.o: %.f90 | $(BUILD)
	$(FC) $(FFLAGS) -J$(BUILD) -c $< -o $@

$(BUILD):
	$(call CREAR_DIR,$(BUILD))

# Dependencias entre módulos
$(BUILD)/solver_rk.o: $(BUILD)/tablero_butcher.o $(BUILD)/algebra_lineal.o
$(BUILD)/retrato_fases.o: $(BUILD)/modelo_lienard.o $(BUILD)/solver_rk.o
$(BUILD)/principal.o: $(BUILD)/retrato_fases.o $(BUILD)/sistema.o

run: all
	$(call EJECUTAR,$(EJECUTABLE))

run-debug:
	$(MAKE) MODO=debug run

plot:
	gnuplot resultados/retrato.gp

clean:
	$(call BORRAR,$(PROG)$(EXE) $(PROG)_debug$(EXE))
