# Makefile for man2tcl converter
# Cross-platform build system for Windows and Linux

# Compiler settings
CC = gcc
CFLAGS = -O2 -Wall -Wextra
TARGET = man2tcl

# Detect OS - check for MSYS/Cygwin first, then Windows
ifdef MSYSTEM
    # MSYS/MinGW environment
    EXE_EXT = .exe
    RM = rm -f
    RMDIR = rm -rf
else ifeq ($(OS),Windows_NT)
    # Native Windows
    EXE_EXT = .exe
    RM = del /Q
    RMDIR = rmdir /S /Q
else
    # Linux/Unix
    EXE_EXT =
    RM = rm -f
    RMDIR = rm -rf
endif

# Final executable name
EXECUTABLE = $(TARGET)$(EXE_EXT)

# Source files
SOURCES = man2tcl.c
OBJECTS = $(SOURCES:.c=.o)

# Default target
.PHONY: all
all: $(EXECUTABLE)

# Build the executable
$(EXECUTABLE): $(OBJECTS)
	$(CC) $(CFLAGS) -o $@ $^

# Compile object files
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Clean build artifacts
.PHONY: clean
clean:
	-$(RM) $(OBJECTS) $(EXECUTABLE)

# Install target (optional)
.PHONY: install
install: $(EXECUTABLE)
	@echo "To install, copy $(EXECUTABLE) to a directory in your PATH"

# Help target
.PHONY: help
help:
	@echo "Makefile for man2tcl"
	@echo ""
	@echo "Targets:"
	@echo "  all      - Build the man2tcl executable (default)"
	@echo "  clean    - Remove build artifacts"
	@echo "  install  - Show installation instructions"
	@echo "  help     - Show this help message"
