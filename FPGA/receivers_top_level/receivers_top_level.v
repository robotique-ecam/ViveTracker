`default_nettype none

`include "../pll_module/pll_module.v"
`include "../serial_transmitter/serial_transmitter.v"
`include "../triad_manager/triad_manager.v"

module receivers_top_level (
  input wire clk_25MHz,
  inout wire envelop_wire_0,
  inout wire envelop_wire_1,
  inout wire envelop_wire_2,
  inout wire data_wire_0,
  inout wire data_wire_1,
  inout wire data_wire_2,
  output wire tx,
  output wire state_led
  );

wire clk_96MHz;
wire clk_12MHz;

pll_module PLLs (
  .clk_25MHz (clk_25MHz),
  .clk_96MHz (clk_96MHz),
  .clk_12MHz (clk_12MHz)
  );

reg [23:0] sys_ts = 0;
always @ (posedge clk_96MHz) begin
  if (&sys_ts) begin
    sys_ts <= 0;
  end else begin
    sys_ts <= sys_ts + 1;
  end
end

wire reset_pulse_identifier_0;
wire data_avl_0;
wire [67:0] triad_data_0;

triad_manager TRIAD0 (
  .clk_96MHz (clk_96MHz),
  .envelop_wire_0 (envelop_wire_0),
  .envelop_wire_1 (envelop_wire_1),
  .envelop_wire_2 (envelop_wire_2),
  .data_wire_0 (data_wire_0),
  .data_wire_1 (data_wire_1),
  .data_wire_2 (data_wire_2),
  .sys_ts (sys_ts),
  .reset_pulse_identifier (reset_pulse_identifier_0),
  .data_avl (data_avl_0),
  .triad_data (triad_data_0),
  .state_led (state_led)
  );


serial_transmitter UART (
  .clk_12MHz (clk_12MHz),
  .data_availible (data_avl_0),
  .triad_data (triad_data_0),
  .tx (tx),
  .reset_pulse_identifier (reset_pulse_identifier_0)
  );

//assign state_led = sys_ts[23];

endmodule // receivers_top_level

/*
LOCATE      COMP "state_led1"  SITE "F2";
IOBUF       PORT "state_led1"  IO_TYPE=LVCMOS33;
LOCATE      COMP "state_led2"  SITE "F1";
IOBUF       PORT "state_led2"  IO_TYPE=LVCMOS33;
LOCATE      COMP "state_led3"  SITE "G3";
IOBUF       PORT "state_led3"  IO_TYPE=LVCMOS33;
LOCATE      COMP "state_led4"  SITE "H4";
IOBUF       PORT "state_led4"  IO_TYPE=LVCMOS33;
*/
