#----------------------------------------
#-- Name of the component
#----------------------------------------
NAME = offset_finder
DEPS = ../lfsr/lfsr.v

#-------------------------------------------------------
#-- By default --> simulation and synthesis
#-------------------------------------------------------
all: sim sint

#----------------------------------------------
#-- make sim
#----------------------------------------------
#-- Make the simulation given by the test bench
#----------------------------------------------
sim: $(NAME)_tb.vcd

#-----------------------------------------------
#-  make sint
#-----------------------------------------------
#-  Make the synthesis for icestick FPGA
#-----------------------------------------------
sint: $(NAME).bin

#-----------------------------------------------
#-  make flash
#-----------------------------------------------
#-  Flash the icestick FPGA with the bitstream
#-----------------------------------------------
flash:
	sudo iceprog $(NAME).bin

#-------------------------------
#-- Compilation and simulation
#-------------------------------
$(NAME)_tb.vcd: $(NAME).v $(NAME)_tb.v $(DEPS)

	#-- Compilation
	iverilog $^ -o $(NAME)_tb.out

	#-- Simulation
	./$(NAME)_tb.out

	#-- To see the simulation in gtkwave
	gtkwave $@ $(NAME)_tb.gtkw &

#------------------------------
#-- Complete synthesis
#------------------------------
$(NAME).bin: $(NAME).pcf $(NAME).v

	#-- Synthesis
	yosys -p "synth_ice40 -blif $(NAME).blif" $(NAME).v $(DEPS)

	#-- Place & route
	arachne-pnr -d 1k -p $(NAME).pcf $(NAME).blif -o $(NAME).txt

	#-- Generate final bitstrem file
	icepack $(NAME).txt $(NAME).bin


#-- Limpiar todo
clean:
	rm -f *.bin *.txt *.blif *.out *.vcd *~

.PHONY: all clean
