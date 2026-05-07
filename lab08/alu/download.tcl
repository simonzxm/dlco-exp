open_hw_manager
connect_hw_server
open_hw_target
set device [lindex [get_hw_devices] 0]
set_property PROGRAM.FILE {./build/top.bit} $device
program_hw_devices $device
close_hw_manager
