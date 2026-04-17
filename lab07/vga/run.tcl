set PART xc7a100tcsg324-1
set BUILD_DIR ./build
set IP_DIR ./build/ip

file mkdir $BUILD_DIR
file mkdir $IP_DIR

# Create in-memory project and generate IP
create_project -in_memory -part $PART
create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 \
    -module_name image_rom -dir $IP_DIR
set_property -dict [list \
    CONFIG.Memory_Type {Single_Port_ROM} \
    CONFIG.Write_Width_A {12} \
    CONFIG.Write_Depth_A {307200} \
    CONFIG.Read_Width_A {12} \
    CONFIG.Enable_A {Always_Enabled} \
    CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
    CONFIG.Load_Init_File {true} \
    CONFIG.Coe_File [file normalize ./image.coe] \
] [get_ips image_rom]
generate_target all [get_ips image_rom]
synth_ip [get_ips image_rom]

# Generate Clocking Wizard IP
create_ip -name clk_wiz -vendor xilinx.com -library ip -version 6.0 -module_name clk_wiz_0 -dir $IP_DIR
set_property -dict [list \
    CONFIG.PRIM_IN_FREQ {100.000} \
    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {25.000} \
    CONFIG.USE_LOCKED {false} \
    CONFIG.USE_RESET {false} \
] [get_ips clk_wiz_0]
generate_target all [get_ips clk_wiz_0]
synth_ip [get_ips clk_wiz_0]

read_verilog [glob ./*.v]
read_xdc [glob ./*.xdc]

synth_design -top top -part $PART
opt_design
place_design
route_design

write_bitstream -force $BUILD_DIR/top.bit
