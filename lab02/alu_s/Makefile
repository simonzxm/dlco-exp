VIVADO = vivado -mode batch -source
TCL_SCRIPT = run.tcl
BITSTREAM = ./build/top.bit

all: $(BITSTREAM)

$(BITSTREAM): ./*.v ./*.xdc $(TCL_SCRIPT)
	@echo "Start compiling.."
	mkdir -p build
	$(VIVADO) $(TCL_SCRIPT)
	@echo "Compile completed! Bitstream location: $@"

program: $(BITSTREAM)
	$(VIVADO) download.tcl

# --- 清理目标 ---
clean:
	rm -rf build/ .Xil/ vivado*.log vivado*.jou

.PHONY: all program clean
