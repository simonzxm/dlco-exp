set part xc7a100tcsg324-1
set outputDir ./build

read_verilog [glob ./*.v]
read_xdc [glob ./*.xdc]

synth_design -top top -part $part
opt_design
place_design
route_design

write_bitstream -force $outputDir/top.bit
