`timescale 1s/ 1ms
`include "../uart_tx_module/baudgen.vh"

module receivers_top_level_sim_tb ();

localparam  CLOCK_TICK = 0.999; //((1/(96))/2) * PRESCALER;

localparam  CLOCK_PERIOD = 2*CLOCK_TICK;

localparam  FAST_TRANSITION = 8 * CLOCK_PERIOD;

localparam  SLOW_TRANSITION = 2*FAST_TRANSITION;

localparam BAUD = `B115200 * 4;

localparam BITRATE = (BAUD << 1);

localparam FRAME = (BITRATE * 11);

localparam FRAME_WAIT = (BITRATE * 4);

reg clk = 1;

reg [1:0] clk_counter = 0;

reg envelop_wire_0 = 0;
reg envelop_wire_1 = 0;
reg envelop_wire_2 = 0;
reg data_wire_0 = 0;
reg data_wire_1 = 0;
reg data_wire_2 = 0;

wire tx;

receivers_top_level_sim dut (
  .clk_25MHz (clk),
  .envelop_wire_4 (envelop_wire_0),
  .envelop_wire_3 (envelop_wire_1),
  .envelop_wire_7 (envelop_wire_2),
  .data_wire_4 (data_wire_0),
  .data_wire_3 (data_wire_1),
  .data_wire_7 (data_wire_2),
  .tx (tx)
  );

task one_input;
  input [3:0] deviation1;
  input [3:0] deviation2;
  input negative1;
  input negative2;
  begin
    if (negative1) begin
      #(FAST_TRANSITION - deviation1*CLOCK_PERIOD) wire_data_changing <= ~wire_data_changing;
    end else begin
      #(FAST_TRANSITION + deviation1*CLOCK_PERIOD) wire_data_changing <= ~wire_data_changing;
    end
    if (negative2) begin
      #(FAST_TRANSITION - deviation2*CLOCK_PERIOD) wire_data_changing <= ~wire_data_changing;
    end else begin
      #(FAST_TRANSITION + deviation2*CLOCK_PERIOD) wire_data_changing <= ~wire_data_changing;
    end
  end
  endtask

task zero_input;
  input [3:0] deviation;
  input negative;
  begin
    if (negative) begin
      #(SLOW_TRANSITION - deviation*CLOCK_PERIOD) wire_data_changing <= ~wire_data_changing;
    end else begin
      #(SLOW_TRANSITION + deviation*CLOCK_PERIOD) wire_data_changing <= ~wire_data_changing;
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

always #0.333 clk <= ~clk;

reg [1:0] data_wire_used = 0;
reg wire_data_changing = 0;

always @ (posedge clk) begin
  if (data_wire_used == 0) begin
    data_wire_0 <= wire_data_changing;
  end else if (data_wire_used == 1) begin
    data_wire_1 <= wire_data_changing;
  end else begin
    data_wire_2 <= wire_data_changing;
  end
end

initial begin
  $dumpfile("receivers_top_level_sim_tb.vcd");
  $dumpvars(0, receivers_top_level_sim_tb);

  #0 $display("start of simulation");
  wire_data_changing <= 0;
  #20 wire_data_changing <= ~wire_data_changing;
  zero_input(0, 0);
  one_input(0, 0, 0, 0);
  one_input(0, 0, 0, 0);
  one_input(0, 0, 0, 0);
  zero_input(0, 0);
  zero_input(0, 0);
  one_input(0, 0, 0, 0);
  zero_input(0, 0);
  one_input(0, 0, 0, 0);
  one_input(0, 0, 0, 0);
  one_input(0, 0, 0, 0);
  one_input(0, 0, 0, 0);
  zero_input(0, 0);
  one_input(0, 0, 0, 0);
  zero_input(0, 0);
  zero_input(0, 0);
  one_input(0, 0, 0, 0);
  wire_data_changing <= ~wire_data_changing;
  #SLOW_TRANSITION data_wire_used <= 2;
  if (wire_data_changing != 0) begin
    wire_data_changing <= 0;
  end
  #(SLOW_TRANSITION*(499 - 17)) wire_data_changing <= ~wire_data_changing;
  zero_input(0, 0);
  one_input(0, 0, 0, 0);
  one_input(0, 0, 0, 0);
  one_input(0, 0, 0, 0);
  one_input(0, 0, 0, 0);
  zero_input(0, 0);
  zero_input(0, 0);
  one_input(0, 0, 0, 0);
  one_input(0, 0, 0, 0);
  one_input(0, 0, 0, 0);
  zero_input(0, 0);
  zero_input(0, 0);
  zero_input(0, 0);
  one_input(0, 0, 0, 0);
  zero_input(0, 0);
  zero_input(0, 0);
  zero_input(0, 0);
  wire_data_changing <= ~wire_data_changing;
  #SLOW_TRANSITION data_wire_used <= 1;
  if (wire_data_changing != 0) begin
    wire_data_changing <= 0;
  end
  #(SLOW_TRANSITION*15 - 1) wire_data_changing <= ~wire_data_changing;
  zero_input(0, 0);
  one_input(0, 0, 0, 0);
  one_input(0, 0, 0, 0);
  one_input(0, 0, 0, 0);
  one_input(0, 0, 0, 0);
  zero_input(0, 0);
  zero_input(0, 0);
  one_input(0, 0, 0, 0);
  one_input(0, 0, 0, 0);
  one_input(0, 0, 0, 0);
  zero_input(0, 0);
  zero_input(0, 0);
  zero_input(0, 0);
  one_input(0, 0, 0, 0);
  zero_input(0, 0);
  zero_input(0, 0);
  zero_input(0, 0);
  wire_data_changing <= ~wire_data_changing;



  #SLOW_TRANSITION data_wire_used <= 2;
  if (wire_data_changing != 0) begin
    wire_data_changing <= 0;
  end
  #(SLOW_TRANSITION*(15000-17-15-1)) wire_data_changing <= ~wire_data_changing;
  one_input(0, 0, 0, 0);
  one_input(0, 0, 0, 0);
  zero_input(0, 0);
  zero_input(0, 0);
  one_input(0, 0, 0, 0);
  one_input(0, 0, 0, 0);
  zero_input(0, 0);
  zero_input(0, 0);
  one_input(0, 0, 0, 0);
  zero_input(0, 0);
  one_input(0, 0, 0, 0);
  zero_input(0, 0);
  one_input(0, 0, 0, 0);
  zero_input(0, 0);
  one_input(0, 0, 0, 0);
  zero_input(0, 0);
  zero_input(0, 0);
  one_input(0, 0, 0, 0);
  zero_input(0, 0);
  wire_data_changing <= ~wire_data_changing;
  #SLOW_TRANSITION data_wire_used <= 1;
  if (wire_data_changing != 0) begin
    wire_data_changing <= 0;
  end
  #(SLOW_TRANSITION*(500 - 1-17)) wire_data_changing <= ~wire_data_changing;
  one_input(0, 0, 0, 0);
  one_input(0, 0, 0, 0);
  zero_input(0, 0);
  zero_input(0, 0);
  one_input(0, 0, 0, 0);
  one_input(0, 0, 0, 0);
  one_input(0, 0, 0, 0);
  zero_input(0, 0);
  one_input(0, 0, 0, 0);
  zero_input(0, 0);
  one_input(0, 0, 0, 0);
  one_input(0, 0, 0, 0);
  one_input(0, 0, 0, 0);
  zero_input(0, 0);
  zero_input(0, 0);
  one_input(0, 0, 0, 0);
  zero_input(0, 0);
  one_input(0, 0, 0, 0);
  wire_data_changing <= ~wire_data_changing;
  #SLOW_TRANSITION data_wire_used <= 0;
  if (wire_data_changing != 0) begin
    wire_data_changing <= 0;
  end
  #(SLOW_TRANSITION*15) wire_data_changing <= ~wire_data_changing;
  zero_input(0, 0);
  one_input(0, 0, 0, 0);
  one_input(0, 0, 0, 0);
  one_input(0, 0, 0, 0);
  one_input(0, 0, 0, 0);
  zero_input(0, 0);
  zero_input(0, 0);
  one_input(0, 0, 0, 0);
  one_input(0, 0, 0, 0);
  one_input(0, 0, 0, 0);
  zero_input(0, 0);
  zero_input(0, 0);
  zero_input(0, 0);
  one_input(0, 0, 0, 0);
  zero_input(0, 0);
  zero_input(0, 0);
  zero_input(0, 0);
  wire_data_changing <= ~wire_data_changing;
  #(FRAME * 40) $display("End of simulation");
  #20 $display("End of simulation");
  $finish;
end

endmodule
