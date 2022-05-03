`default_nettype none

`include "../single_receiver_manager/single_receiver_manager.v"
`include "../pulse_identifier/pulse_identifier.v"
`include "../data_parser/data_parser.v"

module octo_manager (
  input wire clk_96MHz,
  input wire clk_72MHz,

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

  input wire [23:0] sys_ts,
  input wire reset_parser,

  output wire data_avl,
  output wire [271:0] sensor_iterations,
  output wire state_led_0,
  output wire state_led_1,
  output wire state_led_2,
  output wire state_led_3,
  output wire state_led_4,
  output wire state_led_5,
  output wire state_led_6,
  output wire state_led_7
  );

wire [7:0] block_wanted_number_0;
wire [40:0] block_wanted_0;
wire data_ready_0;
wire [7:0] avl_blocks_nb_0;

single_receiver_manager RECV0 (
  .clk_96MHz (clk_96MHz),
  .data_wire (data_wire_0),
  .envelop_wire (envelop_wire_0),
  .sys_ts (sys_ts),
  .block_wanted_number (block_wanted_number_0),
  .block_wanted (block_wanted_0),
  .data_ready (data_ready_0),
  .avl_blocks_nb (avl_blocks_nb_0),
  .state_led (state_led_0)
  );

wire [7:0] block_wanted_number_1;
wire [40:0] block_wanted_1;
wire data_ready_1;
wire [7:0] avl_blocks_nb_1;

single_receiver_manager RECV1 (
  .clk_96MHz (clk_96MHz),
  .data_wire (data_wire_1),
  .envelop_wire (envelop_wire_1),
  .sys_ts (sys_ts),
  .block_wanted_number (block_wanted_number_1),
  .block_wanted (block_wanted_1),
  .data_ready (data_ready_1),
  .avl_blocks_nb (avl_blocks_nb_1),
  .state_led (state_led_1)
  );

wire [7:0] block_wanted_number_2;
wire [40:0] block_wanted_2;
wire data_ready_2;
wire [7:0] avl_blocks_nb_2;

single_receiver_manager RECV2 (
  .clk_96MHz (clk_96MHz),
  .data_wire (data_wire_2),
  .envelop_wire (envelop_wire_2),
  .sys_ts (sys_ts),
  .block_wanted_number (block_wanted_number_2),
  .block_wanted (block_wanted_2),
  .data_ready (data_ready_2),
  .avl_blocks_nb (avl_blocks_nb_2),
  .state_led (state_led_2)
  );

wire [7:0] block_wanted_number_3;
wire [40:0] block_wanted_3;
wire data_ready_3;
wire [7:0] avl_blocks_nb_3;

single_receiver_manager RECV3 (
  .clk_96MHz (clk_96MHz),
  .data_wire (data_wire_3),
  .envelop_wire (envelop_wire_3),
  .sys_ts (sys_ts),
  .block_wanted_number (block_wanted_number_3),
  .block_wanted (block_wanted_3),
  .data_ready (data_ready_3),
  .avl_blocks_nb (avl_blocks_nb_3),
  .state_led (state_led_3)
  );

wire [7:0] block_wanted_number_4;
wire [40:0] block_wanted_4;
wire data_ready_4;
wire [7:0] avl_blocks_nb_4;

single_receiver_manager RECV4 (
  .clk_96MHz (clk_96MHz),
  .data_wire (data_wire_4),
  .envelop_wire (envelop_wire_4),
  .sys_ts (sys_ts),
  .block_wanted_number (block_wanted_number_4),
  .block_wanted (block_wanted_4),
  .data_ready (data_ready_4),
  .avl_blocks_nb (avl_blocks_nb_4),
  .state_led (state_led_4)
  );

wire [7:0] block_wanted_number_5;
wire [40:0] block_wanted_5;
wire data_ready_5;
wire [7:0] avl_blocks_nb_5;

single_receiver_manager RECV5 (
  .clk_96MHz (clk_96MHz),
  .data_wire (data_wire_5),
  .envelop_wire (envelop_wire_5),
  .sys_ts (sys_ts),
  .block_wanted_number (block_wanted_number_5),
  .block_wanted (block_wanted_5),
  .data_ready (data_ready_5),
  .avl_blocks_nb (avl_blocks_nb_5),
  .state_led (state_led_5)
  );

wire [7:0] block_wanted_number_6;
wire [40:0] block_wanted_6;
wire data_ready_6;
wire [7:0] avl_blocks_nb_6;

single_receiver_manager RECV6 (
  .clk_96MHz (clk_96MHz),
  .data_wire (data_wire_6),
  .envelop_wire (envelop_wire_6),
  .sys_ts (sys_ts),
  .block_wanted_number (block_wanted_number_6),
  .block_wanted (block_wanted_6),
  .data_ready (data_ready_6),
  .avl_blocks_nb (avl_blocks_nb_6),
  .state_led (state_led_6)
  );

wire [7:0] block_wanted_number_7;
wire [40:0] block_wanted_7;
wire data_ready_7;
wire [7:0] avl_blocks_nb_7;

single_receiver_manager RECV7 (
  .clk_96MHz (clk_96MHz),
  .data_wire (data_wire_7),
  .envelop_wire (envelop_wire_7),
  .sys_ts (sys_ts),
  .block_wanted_number (block_wanted_number_7),
  .block_wanted (block_wanted_7),
  .data_ready (data_ready_7),
  .avl_blocks_nb (avl_blocks_nb_7),
  .state_led (state_led_7)
  );

wire [16:0] polynomial;
wire [16:0] iteration_0;
wire [16:0] iteration_1;
wire [16:0] iteration_2;
wire [16:0] iteration_3;
wire [16:0] iteration_4;
wire [16:0] iteration_5;
wire [16:0] iteration_6;
wire [16:0] iteration_7;
wire pulse_identifier_ready;
wire reset_pulse_identifier;

pulse_identifier PULSE_IDENTIFIER0 (
  .clk_72MHz (clk_72MHz),
  .block_wanted_0 (block_wanted_0),
  .block_wanted_1 (block_wanted_1),
  .block_wanted_2 (block_wanted_2),
  .block_wanted_3 (block_wanted_3),
  .block_wanted_4 (block_wanted_4),
  .block_wanted_5 (block_wanted_5),
  .block_wanted_6 (block_wanted_6),
  .block_wanted_7 (block_wanted_7),
  .data_ready_0 (data_ready_0),
  .data_ready_1 (data_ready_1),
  .data_ready_2 (data_ready_2),
  .data_ready_3 (data_ready_3),
  .data_ready_4 (data_ready_4),
  .data_ready_5 (data_ready_5),
  .data_ready_6 (data_ready_6),
  .data_ready_7 (data_ready_7),
  .avl_blocks_nb_0 (avl_blocks_nb_0),
  .avl_blocks_nb_1 (avl_blocks_nb_1),
  .avl_blocks_nb_2 (avl_blocks_nb_2),
  .avl_blocks_nb_3 (avl_blocks_nb_3),
  .avl_blocks_nb_4 (avl_blocks_nb_4),
  .avl_blocks_nb_5 (avl_blocks_nb_5),
  .avl_blocks_nb_6 (avl_blocks_nb_6),
  .avl_blocks_nb_7 (avl_blocks_nb_7),
  .reset (reset_pulse_identifier),
  .polynomial (polynomial),
  .ready (pulse_identifier_ready),
  .block_wanted_number_0 (block_wanted_number_0),
  .block_wanted_number_1 (block_wanted_number_1),
  .block_wanted_number_2 (block_wanted_number_2),
  .block_wanted_number_3 (block_wanted_number_3),
  .block_wanted_number_4 (block_wanted_number_4),
  .block_wanted_number_5 (block_wanted_number_5),
  .block_wanted_number_6 (block_wanted_number_6),
  .block_wanted_number_7 (block_wanted_number_7),
  .iteration_0 (iteration_0),
  .iteration_1 (iteration_1),
  .iteration_2 (iteration_2),
  .iteration_3 (iteration_3),
  .iteration_4 (iteration_4),
  .iteration_5 (iteration_5),
  .iteration_6 (iteration_6),
  .iteration_7 (iteration_7),
  .sys_ts (sys_ts)
  );

data_parser PARSER0(
  .clk_72MHz (clk_72MHz),
  .pulse_identifier_ready (pulse_identifier_ready),
  .iteration_0 (iteration_0),
  .iteration_1 (iteration_1),
  .iteration_2 (iteration_2),
  .iteration_3 (iteration_3),
  .iteration_4 (iteration_4),
  .iteration_5 (iteration_5),
  .iteration_6 (iteration_6),
  .iteration_7 (iteration_7),
  .polynomial (polynomial),
  .reset_parser (reset_parser),
  .sensor_iterations (sensor_iterations),
  .sensor_data_avl (data_avl),
  .reset_pulse_identifier (reset_pulse_identifier)
  );

endmodule // octo_manager
