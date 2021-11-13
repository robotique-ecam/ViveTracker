module offset_finder_tb ();

reg clk = 0;
reg [16:0] polynomial = 17'h17e04;
reg [16:0] data = 17'h189d5;
reg enable = 0;

wire [16:0] offset;
wire ready;

offset_finder dut(
  .clk_96MHz (clk),
  .polynomial (polynomial),
  .data (data),
  .enable (enable),
  .offset (offset),
  .ready (ready)
  );

always #1 clk <= ~clk;

initial begin
  $dumpfile("offset_finder_tb.vcd");
  $dumpvars(0, offset_finder_tb);

  #0 $display("start of simulation");
  #5 enable <= 1;
  #64000 enable <= 0;
  #3 polynomial = 17'h1d258;
  #3 data <= 17'h42b2;
  #1 enable <= 1;
  #64000 $finish;
end

endmodule // offset_finder_tb
