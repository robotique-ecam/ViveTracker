 `include "baudgen.vh"

 module uart_tx_tb ();

 localparam  BAUD = `B115200;

 localparam  BITRATE = (BAUD << 1);

 localparam  FRAME = (BITRATE * 11);

 localparam  FRAME_WAIT = (BITRATE * 4);

 reg clk = 0, dtr = 0, rst = 0;

 wire tx, ready;

 uart_tx #(
   .BAUD (`B115200)
   )
   dut(
     .clk (clk),
     .start (dtr),
     .rstn (rst),
     .data ("A"),
     .tx (tx),
     .ready (ready)
     );

 always #1 clk = ~clk;

 initial begin
   $dumpfile("uart_tx_tb.vcd");
   $dumpvars(0, uart_tx_tb);

   #0 $display("start of simulation");

   #1 dtr <= 0;
   #1 rst <= 1;

   #FRAME_WAIT dtr <= 1;
   #(BITRATE * 2) dtr <= 0;

   #(FRAME_WAIT * 3) dtr <= 1;
   #(FRAME * 1) dtr <= 0;

   #(FRAME_WAIT * 4) $display("End of simulation");
   $finish;
 end

 endmodule // uart_tx_tb
