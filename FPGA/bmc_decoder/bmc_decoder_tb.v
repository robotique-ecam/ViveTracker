module bmc_decoder_tb ();

parameter bit_considered = 17;

localparam  CLOCK_TICK = 1; //((1/(96))/2) * PRESCALER;

localparam  CLOCK_PERIOD = 2*CLOCK_TICK;

localparam  FAST_TRANSITION = 8 * CLOCK_PERIOD;

localparam  SLOW_TRANSITION = 2*FAST_TRANSITION;

reg clk = 1;

reg d_in_0 = 0;
reg d_in_1 = 0;
reg buffer = 0;
reg envelop = 1;

reg enabled = 0;
reg [23:0] system_timestamp = 0;
reg reset = 0;

wire [bit_considered-1:0] decoded_data;
wire data_availible;
wire [23:0] timestamp_last_data;

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

task random_deviation_state_errored;
  begin
    if ($urandom%2) begin
      one_input($urandom%5, $urandom%5, $urandom%2, $urandom%2);
    end else begin
      zero_input($urandom%5, $urandom%2);
    end
  end
endtask

bmc_decoder #(
  .bit_considered (bit_considered)
  )
  dut (
  .clk_96MHz (clk),
  .d_in_0 (d_in_0),
  .d_in_1 (d_in_1),
  .e_in_0 (envelop),
  .enabled (enabled),
  .sys_ts (system_timestamp),
  .reset (reset),
  .decoded_data (decoded_data),
  .data_availible (data_availible),
  .ts_last_data (timestamp_last_data)
  );

always @ (posedge clk) begin
  system_timestamp <= system_timestamp + 1;
end

always @ (posedge clk) begin
  d_in_1 <= buffer;
  buffer <= d_in_0;
end

always @ (negedge clk) begin
  d_in_1 <= buffer;
  buffer <= d_in_0;
end

always #CLOCK_TICK clk <= ~clk;

initial begin
  $dumpfile("bmc_decoder_tb.vcd");
  $dumpvars(0, bmc_decoder_tb);

  #0 $display("start of simulation");
  #(CLOCK_PERIOD * 10) enabled = 1;
  #(CLOCK_PERIOD * 2) envelop = 0;
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
  #(CLOCK_PERIOD * 15) envelop = 1;
  #(CLOCK_PERIOD * 15) envelop = 0;
  #(CLOCK_PERIOD * 3) d_in_0 = ~d_in_0;
  one_input(2, 1, 1, 0);
  zero_input(1, 1);
  one_input(1, 2, 0, 1);
  one_input(0, 0, 0, 0);
  one_input(2, 0, 1, 0);
  zero_input(2, 1);
  zero_input(0, 0);
  one_input(1, 3, 0, 0);
  zero_input(2, 0);
  zero_input(1, 0);
  one_input(1, 2, 0, 0);
  one_input(0, 0, 0, 0);
  one_input(2, 1, 0, 0);
  zero_input(1, 0);
  one_input(2, 1, 0, 0);
  zero_input(3, 1);
  one_input(0, 3, 0, 1);
  #(CLOCK_PERIOD * 10) one_input(1, 2, 1, 0);
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
  #(CLOCK_PERIOD * 10) random_deviation_state_errored();
  random_deviation_state_errored();
  random_deviation_state_errored();
  random_deviation_state_errored();
  random_deviation_state_errored();
  random_deviation_state_errored();
  random_deviation_state_errored();
  random_deviation_state_errored();
  random_deviation_state_errored();
  random_deviation_state_errored();
  random_deviation_state_errored();
  random_deviation_state_errored();
  random_deviation_state_errored();
  random_deviation_state_errored();
  random_deviation_state_errored();
  random_deviation_state_errored();
  random_deviation_state_errored();
  random_deviation_state_errored();
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
  random_deviation_state();
  #(CLOCK_PERIOD * 50) $display("End of simulation");
  $finish;
end

endmodule // bmc_decoder_tb
