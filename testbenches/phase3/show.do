set tbName phase3_tb

# Clear the run status
restart -f

set start $1
set end [expr $1 + 1]

# Get timestamp of instruction start
when "sim:/$tbName/instrCount(15:0) == 'd$start" {
    set startTime $now
}

# End simulation at next instruction
when "sim:/$tbName/instrCount(15:0) == 'd$end" {
    set endTime $now
}

# Run for 10 cycles
run 5000 ns

wave zoomrange [expr $startTime - 15000] [expr $endTime + 15000]
wave cursor delete
wave cursor delete
wave cursor delete

wave cursor add -time $startTime -name start -lock 1
wave cursor add -time $endTime -name end -lock 1
wave cursor add -time [expr $endTime - 5000] -lock 0