`include "../uart_tx_module/baudgen.vh"

module receivers_top_level_sim_tb ();

localparam  CLOCK_TICK = 1; //((1/(96))/2) * PRESCALER;

localparam  CLOCK_PERIOD = 2*CLOCK_TICK;

localparam  FAST_TRANSITION = 8 * CLOCK_PERIOD;

localparam  SLOW_TRANSITION = 2*FAST_TRANSITION;

localparam BAUD = `B115200 * 4;

localparam BITRATE = (BAUD << 1);

localparam FRAME = (BITRATE * 11);

localparam FRAME_WAIT = (BITRATE * 4);

reg clk_96MHz = 1;
reg clk_12MHz = 1;

reg [1:0] clk_counter = 0;

reg e_in_0 = 1;
reg d_in_0 = 0;
reg d_in_1 = 0;
reg buffer = 0;

wire tx;

always @ (posedge clk_96MHz) begin
  if (clk_counter == 3) begin
    clk_12MHz <= ~clk_12MHz;
  end
  clk_counter <= clk_counter + 1;
end

receivers_top_level_sim dut (
  .clk_12MHz (clk_12MHz),
  .clk_96MHz (clk_96MHz),
  .e_in_0 (e_in_0),
  .d_in_0 (d_in_0),
  .d_in_1 (d_in_1),
  .tx (tx)
  );

always @ (posedge clk_96MHz) begin
  d_in_1 <= buffer;
  buffer <= d_in_0;
end

task one_input;
  input [3:0] deviation1;
  input [3:0] deviation2;
  input negative1;
  input negative2;
  begin
    if (negative1) begin
      #(FAST_TRANSITION - deviation1*CLOCK_PERIOD) d_in_0 = ~d_in_0;
    end else begin
      #(FAST_TRANSITION + deviation1*CLOCK_PERIOD) d_in_0 = ~d_in_0;
    end
    if (negative2) begin
      #(FAST_TRANSITION - deviation2*CLOCK_PERIOD) d_in_0 = ~d_in_0;
    end else begin
      #(FAST_TRANSITION + deviation2*CLOCK_PERIOD) d_in_0 = ~d_in_0;
    end
  end
  endtask

task zero_input;
  input [3:0] deviation;
  input negative;
  begin
    if (negative) begin
      #(SLOW_TRANSITION - deviation*CLOCK_PERIOD) d_in_0 = ~d_in_0;
    end else begin
      #(SLOW_TRANSITION + deviation*CLOCK_PERIOD) d_in_0 = ~d_in_0;
    end
  end
  endtask

task random_deviation_state;
  begin
    if ($urandom%2) begin
      one_input($urandom%4, $urandom%4, $urandom%2, $urandom%2);
    end else begin
      zero_input($urandom%4, $urandom%2);
    end
  end
endtask

always #1 clk_96MHz <= ~clk_96MHz;

initial begin
  $dumpfile("receivers_top_level_sim_tb.vcd");
  $dumpvars(0, receivers_top_level_sim_tb);

  #0 $display("start of simulation");
  #(CLOCK_PERIOD * 10) e_in_0 <= 0;
  #(CLOCK_PERIOD * 4) d_in_0 = ~d_in_0;
  #FAST_TRANSITION d_in_0 = ~d_in_0;
  one_input(0, 0, 0, 0);
  zero_input(0, 0);
  one_input(0, 0, 0, 0);
  one_input(0, 0, 0, 0);
  one_input(0, 0, 0, 0);
  zero_input(0, 0);
  zero_input(0, 0);
  one_input(0, 0, 0, 0);
  zero_input(0, 0);
  zero_input(0, 0);
  one_input(0, 0, 0, 0);
  one_input(0, 0, 0, 0);
  one_input(0, 0, 0, 0);
  zero_input(0, 0);
  one_input(0, 0, 0, 0);
  zero_input(0, 0);
  zero_input(0, 0);
  #(FRAME * 3) one_input(1, 2, 1, 0);
  random_deviation_state();
  random_deviation_state();
  random_deviation_state();
  random_deviation_state();
  random_deviation_state();
  random_deviation_state();
  random_deviation_state();
  random_deviation_state();
  random_deviation_state();
  random_deviation_state();
  random_deviation_state();
  random_deviation_state();
  random_deviation_state();
  random_deviation_state();
  random_deviation_state();
  random_deviation_state();
  random_deviation_state();
  #(FRAME * 40) $display("End of simulation");
  $finish;
end

endmodule
