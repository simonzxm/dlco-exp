set PART xc7a100tcsg324-1
set BUILD_DIR ./build
set IP_DIR ./build/ip

# Create IP output directory
file mkdir $BUILD_DIR
file mkdir $IP_DIR

# ============================================================
# Step 1: Generate Block RAM IP core (16x8 single-port RAM)
# ============================================================
create_project -in_memory -part $PART

# Create the IP
create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 \
    -module_name blk_mem_gen_0 -dir $IP_DIR

# Configure: Single Port RAM, 8-bit width, 16-deep, .coe init
set_property -dict [list \
    CONFIG.Memory_Type {Single_Port_RAM} \
    CONFIG.Write_Width_A {8} \
    CONFIG.Write_Depth_A {16} \
    CONFIG.Read_Width_A {8} \
    CONFIG.Enable_A {Always_Enabled} \
    CONFIG.Write_Width_B {8} \
    CONFIG.Read_Width_B {8} \
    CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
    CONFIG.Load_Init_File {true} \
    CONFIG.Coe_File [file normalize ./ram_init.coe] \
] [get_ips blk_mem_gen_0]

# Generate IP targets and synthesize
generate_target all [get_ips blk_mem_gen_0]
synth_ip [get_ips blk_mem_gen_0]

close_project

# ============================================================
# Step 2: Synthesize the full design
# ============================================================
read_verilog [glob ./*.v]
read_verilog [glob $IP_DIR/blk_mem_gen_0/synth/*.v]
read_xdc [glob ./*.xdc]

synth_design -top top -part $PART
opt_design
place_design
route_design

write_bitstream -force $BUILD_DIR/top.bit
