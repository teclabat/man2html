# man2htm - Man Page to HTML Converter

A tool to convert Unix manual pages (troff format) to HTML. Originally developed by Sun Microsystems for the Tcl/Tk documentation.

## Overview

This tool consists of two main components:

1. **man2tcl** - A C program that parses troff-formatted man pages and converts them to Tcl scripts
2. **man2html.tcl** - A Tcl script that processes the output from man2tcl and generates HTML files

## Building

### Prerequisites

- GCC compiler
- Make
- Tcl/Tclsh (for running the conversion scripts)

### Compilation

To build the `man2tcl` executable:

```bash
make
```

This will compile `man2tcl.c` and create the `man2tcl` (or `man2tcl.exe` on Windows) executable.

### Clean Build Artifacts

To remove build artifacts:

```bash
make clean
```

### Help

To see available make targets:

```bash
make help
```

## Usage

### Converting Man Pages to HTML

The main script `man2html.tcl` accepts an input directory containing man pages and an output directory for HTML files:

```bash
./man2html.tcl <input_dir> <output_dir>
```

Or with tclsh:

```bash
tclsh man2html.tcl <input_dir> <output_dir>
```

### Examples

Convert man pages from `/usr/share/man/man1` to `./html`:

```bash
./man2html.tcl /usr/share/man/man1 ./html
```

### Options

- `-help` - Display usage information
- `-clean <output_dir>` - Remove the specified output directory (with confirmation)

### Supported Man Page Sections

The converter looks for man pages with the following extensions:
- `.1` - User commands
- `.3` - Library functions
- `.n` - Tcl/Tk commands (new commands)

## How It Works

### Two-Pass Conversion

The conversion process works in two passes:

#### Pass 1: Build Hyperlink Database
- Scans all man pages in the input directory
- Builds a database of command names and keywords
- Creates cross-reference information for generating hyperlinks

#### Pass 2: Generate HTML
- Processes each man page again
- Generates individual HTML files
- Creates hyperlinks between related pages
- Generates a `contents.html` index file

### File Structure

- `man2tcl.c` - C source for the man page parser
- `man2html.tcl` - Main conversion script
- `man2html1.tcl` - Pass 1 procedures (hyperlink database)
- `man2html2.tcl` - Pass 2 procedures (HTML generation)
- `Makefile` - Cross-platform build system

## Output

The tool generates:

1. Individual HTML files for each man page (e.g., `command.1.html`)
2. A `contents.html` file with an index of all converted pages
3. Organized sections for:
   - User Commands (*.1)
   - Tcl/Tk Commands (*.n)
   - Library Functions (*.3)

## Platform Support

The build system supports:
- **Linux/Unix** - Native build with GCC
- **Windows (MSYS/MinGW)** - Unix-like environment on Windows
- **Windows (Native)** - Native Windows build with appropriate compiler

The Makefile automatically detects the platform and adjusts accordingly.

## Notes

- The tool expects man pages in standard troff format
- HTML output uses basic HTML tags (HTML 4.01 style)
- Cross-references are automatically detected and converted to hyperlinks
- The converter handles common troff macros (.SH, .TH, .TP, .IP, etc.)

## Troubleshooting

### "man2tcl: command not found"

Make sure you've built the `man2tcl` executable:
```bash
make
```

And that it's in your PATH or in the same directory as `man2html.tcl`.

### "No man pages found"

The input directory must contain files with extensions `.1`, `.3`, or `.n`. Check that your man pages have the correct extension.

### Encoding Issues

The scripts use UTF-8 encoding. If you encounter encoding issues, make sure your man pages are in UTF-8 format, or modify the `-encoding` parameter in the source scripts.
