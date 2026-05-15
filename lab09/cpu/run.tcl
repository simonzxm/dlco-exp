set PART xc7a100tcsg324-1
set BUILD_DIR ./build
set IP_DIR ./build/ip

file mkdir $BUILD_DIR
file mkdir $IP_DIR

# Create in-memory project and generate BRAM IP
create_project -in_memory -part $PART
create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 \
    -module_name blk_mem_gen_0 -dir $IP_DIR
set_property -dict [list \
    CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
    CONFIG.Write_Width_A {32} \
    CONFIG.Write_Depth_A {32768} \
    CONFIG.Read_Width_A {32} \
    CONFIG.Write_Width_B {32} \
    CONFIG.Read_Width_B {32} \
    CONFIG.Enable_A {Always_Enabled} \
    CONFIG.Enable_B {Always_Enabled} \
    CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
    CONFIG.Register_PortB_Output_of_Memory_Primitives {false} \
    CONFIG.Byte_Size {8} \
    CONFIG.Use_Byte_Write_Enable {true} \
] [get_ips blk_mem_gen_0]
generate_target all [get_ips blk_mem_gen_0]
synth_ip [get_ips blk_mem_gen_0]

# Generate BRAM IP for COE file
create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 \
    -module_name blk_mem_gen_1 -dir $IP_DIR
set_property -dict [list \
    CONFIG.Memory_Type {Single_Port_ROM} \
    CONFIG.Write_Width_A {32} \
    CONFIG.Write_Depth_A {256} \
    CONFIG.Read_Width_A {32} \
    CONFIG.Enable_A {Always_Enabled} \
    CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
    CONFIG.Load_Init_File {true} \
    CONFIG.Coe_File {[file normalize ./imem.coe]} \
] [get_ips blk_mem_gen_1]
generate_target all [get_ips blk_mem_gen_1]
synth_ip [get_ips blk_mem_gen_1]

read_verilog [glob ./*.v]
read_xdc [glob ./*.xdc]

synth_design -top top -part $PART
opt_design
place_design
route_design

write_bitstream -force $BUILD_DIR/top.bit

close_project
