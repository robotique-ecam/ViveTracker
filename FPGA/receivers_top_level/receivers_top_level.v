`default_nettype none

`include "../pll_module/pll_module.v"
`include "../serial_transmitter/serial_transmitter.v"
`include "../octo_manager/octo_manager.v"

module receivers_top_level (
  input wire clk_25MHz,
  inout wire envelop_wire_0,
  inout wire envelop_wire_1,
  inout wire envelop_wire_2,
  inout wire envelop_wire_3,
  inout wire envelop_wire_4,
  inout wire envelop_wire_5,
  inout wire envelop_wire_6,
  inout wire envelop_wire_7,
  inout wire data_wire_0,
  inout wire data_wire_1,
  inout wire data_wire_2,
  inout wire data_wire_3,
  inout wire data_wire_4,
  inout wire data_wire_5,
  inout wire data_wire_6,
  inout wire data_wire_7,
  output wire tx,
  output wire state_led_0,
  output wire state_led_1,
  output wire state_led_2,
  output wire state_led_3,
  output wire state_led_4,
  output wire state_led_5,
  output wire state_led_6,
  output wire state_led_7,
  output wire global_configuration_state_led
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
wire [271:0] sensor_iterations_0;

octo_manager OCTO0 (
  .clk_96MHz (clk_96MHz),
  .clk_72MHz (clk_72MHz),
  .envelop_wire_0 (envelop_wire_0),
  .envelop_wire_1 (envelop_wire_1),
  .envelop_wire_2 (envelop_wire_2),
  .envelop_wire_3 (envelop_wire_3),
  .envelop_wire_4 (envelop_wire_4),
  .envelop_wire_5 (envelop_wire_5),
  .envelop_wire_6 (envelop_wire_6),
  .envelop_wire_7 (envelop_wire_7),
  .data_wire_0 (data_wire_0),
  .data_wire_1 (data_wire_1),
  .data_wire_2 (data_wire_2),
  .data_wire_3 (data_wire_3),
  .data_wire_4 (data_wire_4),
  .data_wire_5 (data_wire_5),
  .data_wire_6 (data_wire_6),
  .data_wire_7 (data_wire_7),
  .sys_ts (sys_ts),
  .reset_parser (reset_parser_0),
  .data_avl (data_avl_0),
  .sensor_iterations (sensor_iterations_0),
  .state_led_0 (state_led_0),
  .state_led_1 (state_led_1),
  .state_led_2 (state_led_2),
  .state_led_3 (state_led_3),
  .state_led_4 (state_led_4),
  .state_led_5 (state_led_5),
  .state_led_6 (state_led_6),
  .state_led_7 (state_led_7)
  );


serial_transmitter UART (
  .clk_12MHz (clk_12MHz),
  .data_availible (data_avl_0),
  .sensor_iterations (sensor_iterations_0),
  .tx (tx),
  .reset_parser (reset_parser_0)
  );

assign global_configuration_state_led = !(!state_led_0 && !state_led_1 && !state_led_2 && !state_led_3 && !state_led_4 && !state_led_5 && !state_led_6 && !state_led_7); 

endmodule // receivers_top_level
