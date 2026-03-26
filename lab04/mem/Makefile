VIVADO = vivado -mode batch -source
TCL_SCRIPT = run.tcl
BITSTREAM = ./build/top.bit

all: $(BITSTREAM)

$(BITSTREAM): ./*.v ./*.xdc ./*.coe ./*.txt $(TCL_SCRIPT)
	mkdir -p build
	$(VIVADO) $(TCL_SCRIPT)

prog: $(BITSTREAM)
	$(VIVADO) download.tcl

clean:
	rm -rf build/ .Xil/ *.log *.jou *.html *.xml *.str

.PHONY: all prog clean
