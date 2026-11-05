# Makefile de la unidad 07. Funciona con make (MSYS2, Linux, macOS) y con
# mingw32-make desde PowerShell o cmd.
#
#   make             compila en modo release (optimizado)
#   make debug       compila en modo debug (comprobaciones y avisos)
#   make run         compila (release), ejecuta con entrada.nml y dibuja
#   make run-debug   lo mismo en modo debug
#   make plot        solo dibuja (Python)
#   make demo-error  error_indice.f90 en release y en debug
#   make clean       borra lo generado

FC   = gfortran
PYTHON ?= python
PROG = euler

# Fuentes, en el orden en que se usan: un módulo antes que quien lo usa.
FUENTES = src/modelo.f90 src/metodo_euler.f90 app/principal.f90

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
# En Windows los ejecutables llevan .exe, y si make no encuentra sh usa
# cmd.exe, que tiene otras órdenes para crear y borrar carpetas.
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
  BORRAR = rm -rf $(PROG) $(PROG)_debug error_indice error_indice_debug *.exe build resultados
  EJEC   = ./$(1)
endif

# --- Reglas -------------------------------------------------------------------
BUILD      = build/$(MODO)
OBJETOS    = $(addprefix $(BUILD)/,$(notdir $(FUENTES:.f90=.o)))
EJECUTABLE = $(PROG)$(SUFIJO)$(EXE)
vpath %.f90 src app

.PHONY: all debug run run-debug plot demo-error clean

all: $(EJECUTABLE)

debug:
	$(MAKE) MODO=debug

# Enlazar: todos los objetos -> ejecutable
$(EJECUTABLE): $(OBJETOS)
	$(FC) $(FFLAGS) $^ -o $@

# Compilar: un .f90 -> un .o  (-J: carpeta donde dejar y buscar los .mod)
$(BUILD)/%.o: %.f90 | $(BUILD)
	$(FC) $(FFLAGS) -J$(BUILD) -c $< -o $@

# Quién usa a quién (use): el .mod de un módulo debe existir antes.
$(BUILD)/metodo_euler.o: $(BUILD)/modelo.o
$(BUILD)/principal.o: $(BUILD)/metodo_euler.o

$(BUILD) resultados:
	$(call CREAR,$@)

# El guion delante de python: si no está instalado, make sigue.
run: all | resultados
	$(call EJEC,$(EJECUTABLE))
	-$(PYTHON) graficar.py

run-debug:
	$(MAKE) MODO=debug run

plot:
	$(PYTHON) graficar.py

demo-error:
	$(FC) -O3 error_indice.f90 -o error_indice$(EXE)
	$(FC) -g -O0 -fcheck=all -fbacktrace error_indice.f90 -o error_indice_debug$(EXE)
	@echo ===== release: sin comprobaciones =====
	-$(call EJEC,error_indice$(EXE))
	@echo ===== debug: -fcheck=all =====
	-$(call EJEC,error_indice_debug$(EXE))

clean:
	$(BORRAR)
