# Do file for phase 1 debugging
# Example usage: do demo.do and_tb 500

vsim rtl_work.$1

delete wave *

add wave sim:/$1/Clock
add wave sim:/$1/Present_state
add wave -hex sim:/$1/DP/PC/q
add wave -hex sim:/$1/DP/IR/q
add wave sim:/$1/DP/IRin

add wave -hex sim:/$1/DP/BusMuxOut

# This is black magic, don't look too closely
# You can set the registers desired here
set registers { 5 }
foreach reg $registers {
    set path sim:/$1/DP/RF/registers
    append path {[}
    append path $reg 
    append path {]/r/q}
    add wave -dec $path
}

restart -f

run 100ns

# Override registers for branching
foreach reg $registers {
    set path sim:/$1/DP/RF/registers
    append path {[}
    append path $reg 
    append path {]/r/q}
    force -freeze $path $2 0
}

run 200 ns

wave zoom full
configure wave -namecolwidth 210