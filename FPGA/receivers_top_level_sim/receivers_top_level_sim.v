`default_nettype none

`include "../pll_module/pll_module_sim.v"
`include "../serial_transmitter/serial_transmitter.v"
`include "../octo_manager/octo_manager_sim.v"

module receivers_top_level_sim (
  input wire clk_25MHz,
  input wire envelop_wire_0,
  input wire envelop_wire_1,
  input wire envelop_wire_2,
  input wire envelop_wire_3,
  input wire envelop_wire_4,
  input wire envelop_wire_5,
  input wire envelop_wire_6,
  input wire envelop_wire_7,
  input wire data_wire_0,
  input wire data_wire_1,
  input wire data_wire_2,
  input wire data_wire_3,
  input wire data_wire_4,
  input wire data_wire_5,
  input wire data_wire_6,
  input wire data_wire_7,
  output wire tx
  );

wire clk_96MHz;
wire clk_12MHz;
wire clk_72MHz;

pll_module_sim PLLs (
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

octo_manager_sim OCTO0 (
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
