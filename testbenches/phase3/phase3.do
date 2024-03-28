# Do file for phase 3 debugging

set tbName phase3_tb

# vsim rtl_work.$tbName

delete wave *

add wave sim:/$tbName/clock
add wave -hex sim:/$tbName/DP/PC/q
add wave -hex sim:/$tbName/DP/IR/q
add wave sim:/$tbName/DP/IRin
add wave -hex sim:/$tbName/DP/BusMuxOut

# This is black magic, don't look too closely
# You can set the registers desired here
set registers { 1 2 3 4 5 6 7 8 9 10 11 12 13 }
foreach reg $registers {
    set path sim:/$tbName/DP/RF/registers
    append path {[}
    append path $reg 
    append path {]/r/q}
    add wave -hex $path
}

# You can set the registers desired here
set addrs { 52 55 142 148 }
foreach addr $addrs {
    set path sim:/$tbName/DP/memory/ram/mem
    append path {[}
    append path $addr 
    append path {]}
    add wave -hex $path
}

restart -f
run 500 ns

configure wave -namecolwidth 250
wave zoom full