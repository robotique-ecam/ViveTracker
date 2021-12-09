#----------------------------------------
#-- Name of the component
#----------------------------------------
NAME = receivers_top_level
DEPS = ../divider_module/divider.v ../pll_module/pll_module.v ../single_receiver_manager/single_receiver_manager.v ../ts4231_configurator/ts4231_configurator.v ../ts4231_configurator/ts4231Configurator.v ../serial_transmitter/serial_transmitter.v ../bmc_decoder/bmc_decoder.v ../uart_tx_module/uart_tx.v ../uart_tx_module/baudgen.v ../pulse_identifier/pulse_identifier.v ../lfsr/lfsr.v ../offset_finder/offset_finder.v ../polynomial_finder/polynomial_finder.v

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
