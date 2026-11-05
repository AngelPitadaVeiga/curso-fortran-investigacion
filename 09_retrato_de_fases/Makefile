# Makefile de la unidad 09 (como el de la unidad 08, con un solo programa).
#
#   make               compila en modo release
#   make debug         compila en modo debug
#   make run           ejecuta retrato con entrada.nml y dibuja
#   make run-debug     lo mismo en modo debug
#   make plot          solo dibuja
#   make clean         borra lo generado

FC    = gfortran
PYTHON ?= python
PROG  = retrato

# Módulos (copia exacta de los de la unidad 08), en el orden en que se usan.
MODULOS = src/modelo.f90 src/tablero_butcher.f90 src/runge_kutta.f90

# --- Modo de compilación ------------------------------------------------------
MODO ?= release
ifeq ($(MODO),debug)
  FFLAGS = -g -O0 -fcheck=all -fbacktrace -std=f2018 \
           -ffpe-trap=invalid,zero,overflow
  SUFIJO = _debug
else
  FFLAGS = -O3 -march=native
endif

# --- Windows / Linux ----------------------------------------------------------
ifeq ($(OS),Windows_NT)
  EXE = .exe
  ifeq ($(findstring /,$(SHELL)),)
    CMD = si
  endif
endif
ifdef CMD
  CREAR  = if not exist $(subst /,\,$(1)) mkdir $(subst /,\,$(1))
  BORRAR = del /q /f *.exe 2>nul & if exist build rmdir /s /q build & if exist resultados rmdir /s /q resultados
  EJEC   = .\$(1)
else
  CREAR  = mkdir -p $(1)
  BORRAR = rm -rf $(PROG) $(PROG)_debug *.exe build resultados
  EJEC   = ./$(1)
endif

# --- Reglas -------------------------------------------------------------------
BUILD       = build/$(MODO)
OBJETOS     = $(addprefix $(BUILD)/,$(notdir $(MODULOS:.f90=.o)))
EJECUTABLE  = $(PROG)$(SUFIJO)$(EXE)
vpath %.f90 src app

.PHONY: all debug run run-debug plot clean

all: $(EJECUTABLE)

debug:
	$(MAKE) MODO=debug

# Enlazar: los módulos + el programa principal -> ejecutable
$(EJECUTABLE): $(OBJETOS) $(BUILD)/principal.o
	$(FC) $(FFLAGS) $^ -o $@

$(BUILD)/%.o: %.f90 | $(BUILD)
	$(FC) $(FFLAGS) -J$(BUILD) -c $< -o $@

# Quién usa a quién
$(BUILD)/runge_kutta.o: $(BUILD)/modelo.o $(BUILD)/tablero_butcher.o
$(BUILD)/principal.o: $(BUILD)/runge_kutta.o

$(BUILD) resultados:
	$(call CREAR,$@)

run: all | resultados
	$(call EJEC,$(EJECUTABLE))
	-$(PYTHON) graficar.py

run-debug:
	$(MAKE) MODO=debug run

plot:
	$(PYTHON) graficar.py

clean:
	$(BORRAR)
