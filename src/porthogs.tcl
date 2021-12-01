#!/usr/bin/env tclsh
package require Tcl 8.6

set version 0.1.0

proc quit message {
    puts stderr "Error: $message."
    exit 1
}

proc portHog port_number {
    if {$port_number eq "" || ![string is double $port_number]} {
        quit "bad port number $port_number."
    }
    
    try {
        set process_id [exec lsof -ti:$port_number]
    } on error message {
        quit "failed to find process on port $port_number"
    }
    
    if {$process_id eq ""} {
        quit "no process found on port $port_number"
    }
    
    try {
        set process_info [lindex [split [exec ps -p $process_id] "\n"] end]
    } on error message {
        quit "failed to find process name for $process_id"
    }

    if {$process_info eq ""} {
        quit "failed to find process name for $process_id"
    }

    return $process_info
}

if {$argc eq 0} {
    quit "no input"
}

foreach arg $argv {
    if {$arg in {"" -h -help --help help}} {
        lappend help "🐷 porthogs v$version"
        lappend help "Find which processes are hogging what ports."
        lappend help {Usage: porthogs [port numbers...]}
    
        puts stdout [join $help "\n\n"]
        exit 0
    }

    if {$arg in {"" -v -version --version version}} {
        puts stdout $version
        exit 0
    }

    append hogs "\n[portHog $arg]"
}

puts "    PID TTY          TIME CMD $hogs"
exit 0
