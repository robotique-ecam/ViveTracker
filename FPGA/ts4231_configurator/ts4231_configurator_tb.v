`define SIMULATION

module ts4231_configurator_tb ();

reg clk = 0;

wire envelop = 0;

wire data;

ts4231_configurator dut (
  .clk (clk),
  .envelop (envelop),
  .data (data)
  );

always #1 clk = ~clk;

initial begin
  $dumpfile("ts4231_configurator_tb.vcd");
  $dumpvars(0, ts4231_configurator_tb);

  #0 $display("start of simulation");

  #100 $display("End of simulation");
  $finish;
end

endmodule // ts4231_configurator_tb
