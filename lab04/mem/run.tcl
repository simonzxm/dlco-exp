set PART xc7a100tcsg324-1
set BUILD_DIR ./build
set IP_DIR ./build/ip

file mkdir $BUILD_DIR
file mkdir $IP_DIR
file mkdir $BUILD_DIR/reports

# Create in-memory project and generate IP
create_project -in_memory -part $PART
create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 \
    -module_name blk_mem_gen_0 -dir $IP_DIR
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
generate_target all [get_ips blk_mem_gen_0]
synth_ip [get_ips blk_mem_gen_0]

read_verilog [glob ./*.v]
read_xdc [glob ./*.xdc]

synth_design -top top -part $PART
opt_design
place_design
route_design

write_bitstream -force $BUILD_DIR/top.bit

# ============================================================
# Reports: answer lab questions from CLI
# ============================================================

# 1) Overall utilization (Block RAM, LUT, FF, etc.)
report_utilization -file $BUILD_DIR/reports/utilization.txt
puts "\n====== UTILIZATION SUMMARY ======"
puts [report_utilization -return_string]

# 2) Hierarchical utilization: shows resources per module instance
report_utilization -hierarchical -file $BUILD_DIR/reports/utilization_hierarchical.txt
puts "\n====== HIERARCHICAL UTILIZATION ======"
puts [report_utilization -hierarchical -return_string]

# 3) Cells under regfile instance (should be LUTs = Distributed RAM)
puts "\n====== REGFILE PRIMITIVES (regfile_inst) ======"
set regfile_cells [get_cells -hierarchical -filter {PRIMITIVE_TYPE =~ BMEM.*.* || PRIMITIVE_TYPE =~ CLB.*.*} regfile_inst/*]
if {[llength $regfile_cells] > 0} {
    foreach c $regfile_cells {
        puts "  $c -> [get_property REF_NAME $c] ([get_property PRIMITIVE_TYPE $c])"
    }
} else {
    puts "  (No BRAM or CLB cells found directly, checking all primitives...)"
    foreach c [get_cells -hierarchical regfile_inst/*] {
        puts "  $c -> [get_property REF_NAME $c] ([get_property PRIMITIVE_TYPE $c])"
    }
}

# 4) Cells under RAM instance (should be RAMB18E1 = Block RAM)
puts "\n====== RAM PRIMITIVES (ram_inst) ======"
foreach c [get_cells -hierarchical ram_inst/*] {
    puts "  $c -> [get_property REF_NAME $c] ([get_property PRIMITIVE_TYPE $c])"
}

# 5) Summary answer
puts "\n====== LAB QUESTION ANSWERS ======"
puts "Q: What primitive does the register file use?"
puts "A: Check regfile primitives above - expect LUT-based (Distributed RAM / RAMD64E / RAM32M etc.)"
puts ""
puts "Q: What primitive does the IP-core RAM use?"
puts "A: Check ram primitives above - expect RAMB18E1 (Block RAM)"
puts ""
puts "Q: How many Block RAMs does the IP-core use?"
set bram_cells [get_cells -hierarchical -filter {PRIMITIVE_TYPE =~ BMEM.*.*}]
puts "A: [llength $bram_cells] Block RAM(s) used total"
foreach c $bram_cells {
    puts "   $c -> [get_property REF_NAME $c]"
}

puts "\n(Full reports saved to $BUILD_DIR/reports/)"

close_project
