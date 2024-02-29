# Do file for phase 1 demo
# Example usage: do demo.do and_tb 500

delete wave *

add wave sim:/$1/Clock
add wave sim:/$1/Present_state

add wave -hex sim:/$1/DP/IR/q
add wave -dec sim:/$1/DP/BusMuxOut
add wave -dec sim:/$1/DP/RZ/q

add wave -dec sim:/$1/expectedValue

# This is black magic, don't look too closely
# You can set the registers desired here
set registers {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15}
foreach reg $registers {
    set path sim:/$1/DP/RF/registers
    append path {[}
    append path $reg 
    append path {]/r/q}
    add wave -dec $path
}

add wave -dec sim:/DP/RHI/q
add wave -dec sim:/DP/RLO/q

restart -f
run $2 ns

wave zoom full