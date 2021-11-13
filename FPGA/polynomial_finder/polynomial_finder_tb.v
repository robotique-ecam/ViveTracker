module polynomial_finder_tb ();

reg clk = 0;
reg [23:0] ts_last_data = 24'h9C586A;
reg [23:0] ts_last_data1 = 24'hA3B827;
reg [16:0] decoded_data = 17'h149D0;
reg [16:0] decoded_data1 = 17'h1C8F9;
reg enable = 0;

wire [16:0] polynomial;
wire [16:0] iteration_number;
wire ready;

polynomial_finder poly_find(
  .clk_96MHz (clk),
  .ts_last_data (ts_last_data),
  .ts_last_data1 (ts_last_data1),
  .decoded_data (decoded_data),
  .decoded_data1 (decoded_data1),
  .enable (enable),
  .polynomial (polynomial),
  .iteration_number (iteration_number),
  .ready (ready)
  );

always #1 clk <= ~clk;

initial begin
  $dumpfile("polynomial_finder_tb.vcd");
  $dumpvars(0, polynomial_finder_tb);

  #0 $display("start of simulation");
  #5 enable <= 1;
  #65000 $finish;
end

endmodule // polynomial_finder_tb
