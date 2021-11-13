module lfsr_tb ();

reg clk = 0;
reg enable = 0;
reg [16:0] polynomial = 17'h1d258;
reg [16:0] start_data = 1;
wire [16:0] value;
wire [16:0] iteration_number;

lfsr dut(
  .clk_96MHz (clk),
  .polynomial (polynomial),
  .start_data (start_data),
  .enable (enable),
  .value (value),
  .iteration_number (iteration_number)
  );

always #1 clk <= ~clk;

initial begin
  $dumpfile("lfsr_tb.vcd");
  $dumpvars(0, lfsr_tb);

  #0 $display("start of simulation");
  #5 enable <= 1;
  #15000 $finish;
end

endmodule // lfsr_tb
