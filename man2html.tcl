#!/usr/bin/env tclsh
# man2html.tcl --
#
# This file contains procedures that work in conjunction with the
# man2tcl program to generate HTML files from Tcl manual entries.
#
# Copyright (c) 1996 Sun Microsystems, Inc.

##############################################################################
# sarray --
#
# Save an array to a file so that it can be sourced.
#
# Arguments:
# file - Name of the output file
# args - Name of the arrays to save

proc sarray {file args} {
    set file [open $file w]
    foreach a $args {
        upvar $a array
        if {![array exists array]} {
            puts "sarray: \"$a\" isn't an array"
            break
        }

        foreach name [lsort [array names array]] {
            regsub -all " " $name "\\ " name1
            puts $file "set ${a}($name1) \{$array($name)\}"
        }
    }
    close $file
}

##############################################################################
# footer --
#
# Builds footer info for HTML pages
#
# Arguments:
# packages - List of packages to link to.

proc footer {packages} {
    lappend f "<HR>"
    set h "\["
    foreach package $packages {
        lappend h "<A HREF=\"../$package/contents.html\">$package</A>"
        lappend h "|"
    }
    lappend f [join [lreplace $h end end {}] " "]
    lappend f "<HR>"
    lappend f "<PRE>Copyright &#169; 1989-1994 The Regents of the University of California."
    lappend f "Copyright &#169; 1994-1996 Sun Microsystems, Inc."
    lappend f "</PRE>"
    return [join $f "\n"]
}

##############################################################################
# doDir --
#
# Given a directory as argument, translate all the man pages in
# that directory. By default, only processes .n files (Tcl/Tk commands).
#
# Arguments:
# dir - Name of the directory.

proc doDir {dir} {
    foreach f [lsort [glob -directory $dir "*.n"]] {
        do $f    ;# defined in man2html1.tcl & man2html2.tcl
    }
}

##############################################################################
# showUsage --
#
# Display usage information and exit.

proc showUsage {} {
    puts stderr "Usage: [info script] \[options\] input_dir output_dir"
    puts stderr ""
    puts stderr "Options:"
    puts stderr "  -clean output_dir  Remove output directory"
    puts stderr "  -help              Show this help message"
    puts stderr ""
    puts stderr "Arguments:"
    puts stderr "  input_dir          Directory containing man pages to convert"
    puts stderr "  output_dir         Directory where HTML files will be generated"
    puts stderr ""
    puts stderr "Example:"
    puts stderr "  [info script] /path/to/man/pages /path/to/html/output"
    exit 1
}

##############################################################################
# main --
#
# Main code for converting Tcl manual pages to HTML.
#
# Arguments:
# argv - List of arguments to this script.

proc main {argv} {
    global html_dir package scriptDir
    # Global vars used in man2html1.tcl and man2html2.tcl
    global NAME_file KEY_file lib state curFile file inDT textState nestStk
    global curFont fontStart fontEnd noFillCount footer

    # Get the directory where this script is located
    set scriptPath [info script]
    if {$scriptPath eq ""} {
        set scriptPath [info nameofexecutable]
    }

    # Normalize path - but file normalize in MSYS can mishandle Windows drive letters
    # Check if path is already absolute (Unix-style or Windows-style)
    if {[string match "/*" $scriptPath] || [regexp {^[A-Za-z]:[/\\]} $scriptPath]} {
        # Already absolute, just get dirname
        set scriptDir [file dirname $scriptPath]
    } else {
        # Relative path, normalize it
        set scriptDir [file dirname [file normalize $scriptPath]]
    }

    # Parse command line arguments
    if {[llength $argv] == 0} {
        showUsage
    }

    # Handle -clean option
    if {[lindex $argv 0] eq "-clean"} {
        if {[llength $argv] != 2} {
            showUsage
        }
        set html_dir [lindex $argv 1]
        puts -nonewline "Recursively remove: $html_dir? (y/n) "
        flush stdout
        if {[gets stdin] eq "y"} {
            puts "Removing: $html_dir"
            file delete -force $html_dir
        }
        exit 0
    }

    # Handle -help option
    if {[lindex $argv 0] eq "-help" || [lindex $argv 0] eq "--help"} {
        showUsage
    }

    # Require exactly 2 arguments: input_dir output_dir
    if {[llength $argv] != 2} {
        puts stderr "Error: Invalid number of arguments"
        showUsage
    }

    set input_dir  [lindex $argv 0]
    set html_dir   [lindex $argv 1]

    # Validate input directory
    if {![file exists $input_dir]} {
        puts stderr "Error: Input directory does not exist: $input_dir"
        exit 1
    }
    if {![file isdirectory $input_dir]} {
        puts stderr "Error: Input path is not a directory: $input_dir"
        exit 1
    }

    # Check for man pages in input directory
    if {[llength [glob -nocomplain -directory $input_dir "*.n"]] == 0} {
        puts stderr "Error: No man pages (*.n) found in: $input_dir"
        exit 1
    }

    # Create output directory if it doesn't exist
    if {![file exists $html_dir]} {
        puts "Creating output directory: $html_dir"
        file mkdir $html_dir
    } elseif {![file isdirectory $html_dir]} {
        puts stderr "Error: Output path exists but is not a directory: $html_dir"
        exit 1
    }

    # Set package name from input directory
    set package [file tail $input_dir]
    set footer [footer [list $package]]

    puts "Converting man pages from: $input_dir"
    puts "Output HTML directory: $html_dir"
    puts ""

    # Pass 1: Build hyperlink database arrays (NAME_file and KEY_file)
    puts "Pass 1: Scanning man pages and building hyperlink database..."
    uplevel #0 [list source -encoding utf-8 $scriptDir/man2html1.tcl]

    doDir $input_dir

    # Clean up the NAME_file and KEY_file database arrays
    catch {unset KEY_file()}
    foreach name [lsort [array names NAME_file]] {
        set file_name $NAME_file($name)
        if {[llength $file_name] > 1} {
            set file_name [lsort $file_name]
            puts "Warning: '$name' multiply defined in: $file_name; using last"
            set NAME_file($name) [lindex $file_name end]
        }
    }

    # Pass 2: Translate man pages to HTML
    puts "\nPass 2: Generating HTML pages..."
    uplevel #0 [list source -encoding utf-8 $scriptDir/man2html2.tcl]

    doDir $input_dir

    puts "\nConversion complete!"
    puts "HTML files generated in: $html_dir"
}

##############################################################################
# Entry point

if {[catch {main $argv} result]} {
    global errorInfo
    puts stderr "Error: $result"
    puts stderr ""
    puts stderr "Stack trace:"
    puts stderr $errorInfo
    exit 1
}
