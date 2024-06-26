# Do file for phase 1 debugging
# Example usage: do demo.do and_tb 500

delete wave *

vsim rtl_work.$1

add wave sim:/$1/Clock
add wave sim:/$1/Present_state
add wave -hex sim:/$1/DP/PC/q
add wave -hex sim:/$1/DP/IR/q

add wave -hex sim:/$1/DP/BusMuxOut

# This is black magic, don't look too closely
# You can set the registers desired here
set registers {2 3 4 5}
foreach reg $registers {
    set path sim:/$1/DP/RF/registers
    append path {[}
    append path $reg 
    append path {]/r/q}
    add wave -hex $path
}

restart -f
run 300 ns

wave zoom full
configure wave -namecolwidth 210