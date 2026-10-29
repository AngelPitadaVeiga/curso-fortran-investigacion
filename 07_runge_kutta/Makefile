# Makefile del bloque 07: igual que el del bloque 06, pero con dos programas.
# (El programa de convergencia se llama "orden": en Linux, un ejecutable
# "convergencia" chocaría con el objetivo "make convergencia".)
#
#   make               compila en modo release
#   make debug         compila en modo debug
#   make run           ejecuta rk con entrada.nml y dibuja
#   make run-debug     lo mismo en modo debug
#   make convergencia  orden observado de todos los tableros, con figura
#   make plot          solo dibuja la solución
#   make clean         borra lo generado

FC    = gfortran
PROG  = rk
PROG2 = orden

# Módulos, en el orden en que se usan. Los programas están en app/.
MODULOS = src/modelo.f90 src/tablero_butcher.f90 src/runge_kutta.f90

# --- Modo de compilación ------------------------------------------------------
MODO ?= release
ifeq ($(MODO),debug)
  FFLAGS = -g -O0 -fcheck=all -fbacktrace -Wall -Wextra -std=f2018 \
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
  BORRAR = rm -rf $(PROG) $(PROG)_debug $(PROG2) $(PROG2)_debug *.exe build resultados
  EJEC   = ./$(1)
endif

# --- Reglas -------------------------------------------------------------------
BUILD       = build/$(MODO)
OBJETOS     = $(addprefix $(BUILD)/,$(notdir $(MODULOS:.f90=.o)))
EJECUTABLE  = $(PROG)$(SUFIJO)$(EXE)
EJECUTABLE2 = $(PROG2)$(SUFIJO)$(EXE)
vpath %.f90 src app

.PHONY: all debug run run-debug convergencia plot clean

all: $(EJECUTABLE) $(EJECUTABLE2)

debug:
	$(MAKE) MODO=debug

# Enlazar: los módulos + un programa principal -> ejecutable
$(EJECUTABLE): $(OBJETOS) $(BUILD)/principal.o
	$(FC) $(FFLAGS) $^ -o $@

$(EJECUTABLE2): $(OBJETOS) $(BUILD)/convergencia.o
	$(FC) $(FFLAGS) $^ -o $@

$(BUILD)/%.o: %.f90 | $(BUILD)
	$(FC) $(FFLAGS) -J$(BUILD) -c $< -o $@

# Quién usa a quién
$(BUILD)/runge_kutta.o: $(BUILD)/modelo.o $(BUILD)/tablero_butcher.o
$(BUILD)/principal.o $(BUILD)/convergencia.o: $(BUILD)/runge_kutta.o

$(BUILD) resultados:
	$(call CREAR,$@)

run: all | resultados
	$(call EJEC,$(EJECUTABLE))
	-gnuplot graficar.gp

run-debug:
	$(MAKE) MODO=debug run

# $(wildcard ...) lo expande make: funciona igual en sh y en cmd.exe
convergencia: all | resultados
	$(call EJEC,$(EJECUTABLE2)) $(wildcard tableros/*.txt)
	-gnuplot graficar_convergencia.gp

plot:
	gnuplot graficar.gp

clean:
	$(BORRAR)
