TARGET=receivers_top_level
TOP=receivers_top_level

OBJS+=$(TARGET).v

TRELLIS=/usr/local/share/trellis

all: ${TARGET}.bit

$(TARGET).json: $(OBJS)
	yosys -p "synth_ecp5 -json $@" $(OBJS)

$(TARGET)_out.config: $(TARGET).json
	nextpnr-ecp5 --25k --package CABGA381 --speed 6 --json $< --textcfg $@ --lpf $(TARGET).lpf --freq 65

$(TARGET).bit: $(TARGET)_out.config
	ecppack --compress --svf ${TARGET}.svf $< $@

${TARGET}.svf : ${TARGET}.bit


$(TARGET)_tb.vcd: $(OBJS) $(TARGET)_tb.v
	# Compilation
	iverilog $^ -o $(TARGET)_tb.out

	# Simulation
	./$(TARGET)_tb.out

	# To see the simulation in gtkwave
	gtkwave $@ $(TARGET)_tb.gtkw



# Make the simulation given by the test bench
sim: $(TARGET)_tb.vcd

# Compile, then program the SPI memory, then reboot ECP5
prog: ${TARGET}.svf
	sudo ecpdap flash write --freq 5000 $(TARGET).bit

# Compile and flash volatile memory of ECP5, at reboot, the program stored
# in the SPI is redefined as internal circuit
flash: ${TARGET}.svf
	sudo ecpdap program --freq 5000 $(TARGET).bit

clean:
	rm -f *.svf *.bit *.config *.ys $(TARGET).json *.out *.vcd

.PHONY: prog clean
