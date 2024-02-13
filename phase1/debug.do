# Do file for phase 1 debugging
# Example usage: do demo.do and_tb 500

delete wave *

add wave sim:/$1/Clock
add wave sim:/$1/Present_state

add wave sim:/$1/DP/BusMuxOut

add wave sim:/$1/DP/RFin
add wave sim:/$1/DP/RFout

add wave -dec sim:/$1/expectedValue

# This is black magic, don't look too closely
# You can set the registers desired here
set registers {1 2 3}
foreach reg $registers {
    set path sim:/$1/DP/RF/registers
    append path {[}
    append path $reg 
    append path {]/r/q}
    add wave -dec $path
}

add wave sim:/DP/RHI/q
add wave sim:/DP/RLO/q

restart -f
run $2 ns