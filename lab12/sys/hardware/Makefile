VIVADO   = vivado -mode batch -source
SOFTWARE = ../software
BITSTREAM = ./build/top.bit

all: $(BITSTREAM)

# Build the software memory init files (main.coe / main_d.coe)
$(SOFTWARE)/main.coe $(SOFTWARE)/main_d.coe:
	$(MAKE) -C $(SOFTWARE)

$(BITSTREAM): ./*.v ./*.xdc run.tcl $(SOFTWARE)/main.coe $(SOFTWARE)/main_d.coe
	mkdir -p build
	$(VIVADO) run.tcl

prog: $(BITSTREAM)
	$(VIVADO) download.tcl

clean:
	rm -rf build/ .Xil/ *.log *.jou *.html *.xml

.PHONY: all prog clean
