`default_nettype none

`include "../pll_module/pll_module_sim.v"
`include "../serial_transmitter/serial_transmitter.v"
`include "../triad_manager/triad_manager_sim.v"

module receivers_top_level_sim (
  input wire clk_25MHz,
  input wire envelop_wire_0,
  input wire envelop_wire_1,
  input wire envelop_wire_2,
  input wire data_wire_0,
  input wire data_wire_1,
  input wire data_wire_2,
  output wire tx
  );
wire state_led;
wire clk_96MHz;
wire clk_12MHz;

pll_module_sim PLLs (
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

wire reset_parser_0;
wire data_avl_0;
wire [101:0] sensor_iterations_0;

triad_manager_sim TRIAD0 (
  .clk_96MHz (clk_96MHz),
  .envelop_wire_0 (envelop_wire_0),
  .envelop_wire_1 (envelop_wire_1),
  .envelop_wire_2 (envelop_wire_2),
  .data_wire_0 (data_wire_0),
  .data_wire_1 (data_wire_1),
  .data_wire_2 (data_wire_2),
  .sys_ts (sys_ts),
  .reset_parser (reset_parser_0),
  .data_avl (data_avl_0),
  .sensor_iterations (sensor_iterations_0),
  .state_led (state_led)
  );


serial_transmitter UART (
  .clk_12MHz (clk_12MHz),
  .data_availible (data_avl_0),
  .sensor_iterations (sensor_iterations_0),
  .tx (tx),
  .reset_parser (reset_parser_0)
  );

endmodule // receivers_top_level
