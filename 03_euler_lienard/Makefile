# Makefile del bloque 03 (Euler para Liénard).
# Funciona en Linux, macOS y Windows (MSYS2 UCRT64, con make o mingw32-make).
#
#   make            compila en modo release (optimizado)
#   make debug      compila en modo debug (comprobaciones y avisos)
#   make run        compila (release) y ejecuta con entrada.nml
#   make run-debug  compila (debug) y ejecuta
#   make plot       vuelve a dibujar los resultados con gnuplot
#   make demo-error compila error_indice.f90 en release y en debug y los ejecuta
#   make clean      borra objetos, módulos, ejecutables y resultados

FC = gfortran
PROG = euler

# ---------------------------------------------------------------------------
# Modo de compilación: release (por defecto) o debug
# ---------------------------------------------------------------------------
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
# Portabilidad Windows / Linux
# ---------------------------------------------------------------------------
# En Windows los ejecutables llevan .exe. Además, make usa sh si lo
# encuentra (MSYS2, Git Bash) y cmd.exe si no: las órdenes de crear y
# borrar carpetas cambian de uno a otro.
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

# El orden importa: un módulo debe compilarse antes que quien lo usa (use).
FUENTES = src/modelo_lienard.f90 src/solver_euler.f90 src/sistema.f90 app/principal.f90
OBJETOS = $(patsubst %.f90,$(BUILD)/%.o,$(notdir $(FUENTES)))

vpath %.f90 src app

.PHONY: all release debug run run-debug plot demo-error clean

all: $(EJECUTABLE)
release: all

debug:
	$(MAKE) MODO=debug

$(EJECUTABLE): $(OBJETOS)
	$(FC) $(FFLAGS) $^ -o $@

# -J indica dónde dejar (y buscar) los .mod
$(BUILD)/%.o: %.f90 | $(BUILD)
	$(FC) $(FFLAGS) -J$(BUILD) -c $< -o $@

$(BUILD):
	$(call CREAR_DIR,$(BUILD))

# Dependencias entre módulos (quién usa a quién)
$(BUILD)/solver_euler.o: $(BUILD)/modelo_lienard.o
$(BUILD)/principal.o: $(BUILD)/solver_euler.o $(BUILD)/sistema.o

run: all
	$(call EJECUTAR,$(EJECUTABLE))

run-debug:
	$(MAKE) MODO=debug run

plot:
	gnuplot graficar.gp

demo-error:
	$(FC) -O3 error_indice.f90 -o error_indice$(EXE)
	$(FC) -g -O0 -fcheck=all -fbacktrace error_indice.f90 -o error_indice_debug$(EXE)
	@echo ===== release: sin comprobaciones =====
	-$(call EJECUTAR,error_indice$(EXE))
	@echo ===== debug: -fcheck=all =====
	-$(call EJECUTAR,error_indice_debug$(EXE))

clean:
	$(call BORRAR,$(PROG)$(EXE) $(PROG)_debug$(EXE) error_indice$(EXE) error_indice_debug$(EXE))
