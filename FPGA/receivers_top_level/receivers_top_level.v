`default_nettype none

`include "../pll_module/pll_module.v"
`include "../serial_transmitter/serial_transmitter.v"
`include "../triad_manager/triad_manager.v"

module receivers_top_level (
  input wire clk_25MHz,
  inout wire envelop_wire_00,
  inout wire envelop_wire_01,
  inout wire envelop_wire_02,
  inout wire data_wire_00,
  inout wire data_wire_01,
  inout wire data_wire_02,
  output wire tx,
  output wire state_led
  );

wire clk_96MHz;
wire clk_12MHz;
wire clk_72MHz;

pll_module PLLs (
  .clk_25MHz (clk_25MHz),
  .clk_96MHz (clk_96MHz),
  .clk_12MHz (clk_12MHz),
  .clk_72MHz (clk_72MHz)
  );

reg [23:0] sys_ts = 0;
always @ (posedge clk_96MHz) begin
  if (&sys_ts) begin
    sys_ts <= 0;
  end else begin
    sys_ts <= sys_ts + 1;
  end
end

wire reset_parser_0;
wire data_avl_0;
wire [101:0] sensor_iterations_0;

triad_manager TRIAD0 (
  .clk_96MHz (clk_96MHz),
  .clk_72MHz (clk_72MHz),
  .envelop_wire_0 (envelop_wire_00),
  .envelop_wire_1 (envelop_wire_01),
  .envelop_wire_2 (envelop_wire_02),
  .data_wire_0 (data_wire_00),
  .data_wire_1 (data_wire_01),
  .data_wire_2 (data_wire_02),
  .sys_ts (sys_ts),
  .reset_parser (reset_parser_0),
  .data_avl (data_avl_0),
  .sensor_iterations (sensor_iterations_0)
  );


serial_transmitter UART (
  .clk_12MHz (clk_12MHz),
  .data_availible (data_avl_0),
  .sensor_iterations (sensor_iterations_0),
  .tx (tx),
  .reset_parser (reset_parser_0)
  );

endmodule // receivers_top_level
