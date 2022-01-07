`default_nettype none

`include "../inout_face_manager/inout_face_manager.v"
`include "../single_receiver_manager/single_receiver_manager.v"
`include "../pulse_identifier/pulse_identifier.v"
`include "../data_parser/data_parser.v"

module triad_manager (
  input wire clk_96MHz,
  input wire clk_72MHz,

  inout wire envelop_wire_0,
  inout wire envelop_wire_1,
  inout wire envelop_wire_2,

  inout wire data_wire_0,
  inout wire data_wire_1,
  inout wire data_wire_2,

  input wire [23:0] sys_ts,
  input wire reset_parser,

  output wire data_avl,
  output wire [101:0] sensor_iterations,

  output wire state_led
  );
wire state_led1;
wire state_led2;
wire state_led3;
wire state_led4;

wire d_0_oe;
wire d_0_out;
wire d_0_in_0;
wire d_0_in_1;

wire d_1_oe;
wire d_1_out;
wire d_1_in_0;
wire d_1_in_1;

wire d_2_oe;
wire d_2_out;
wire d_2_in_0;
wire d_2_in_1;

wire e_0_oe;
wire e_0_out;
wire e_0_in;

wire e_1_oe;
wire e_1_out;
wire e_1_in;

wire e_2_oe;
wire e_2_out;
wire e_2_in;

inout_face_manager INOUT0 (
  .clk_96MHz (clk_96MHz),

  .data_wire_0 (data_wire_0),
  .d_0_oe (d_0_oe),
  .d_0_out (d_0_out),
  .d_0_in_0 (d_0_in_0),
  .d_0_in_1 (d_0_in_1),

  .data_wire_1 (data_wire_1),
  .d_1_oe (d_1_oe),
  .d_1_out (d_1_out),
  .d_1_in_0 (d_1_in_0),
  .d_1_in_1 (d_1_in_1),

  .data_wire_2 (data_wire_2),
  .d_2_oe (d_2_oe),
  .d_2_out (d_2_out),
  .d_2_in_0 (d_2_in_0),
  .d_2_in_1 (d_2_in_1),

  .envelop_wire_0 (envelop_wire_0),
  .e_0_oe (e_0_oe),
  .e_0_out (e_0_out),
  .e_0_in (e_0_in),

  .envelop_wire_1 (envelop_wire_1),
  .e_1_oe (e_1_oe),
  .e_1_out (e_1_out),
  .e_1_in (e_1_in),

  .envelop_wire_2 (envelop_wire_2),
  .e_2_oe (e_2_oe),
  .e_2_out (e_2_out),
  .e_2_in (e_2_in)
  );

wire [7:0] block_wanted_number_0;
wire [40:0] block_wanted_0;
wire data_ready_0;
wire [7:0] avl_blocks_nb_0;

single_receiver_manager RECV0 (
  .clk_96MHz (clk_96MHz),
  .e_in_0 (e_0_in),
  .d_in_0 (d_0_in_0),
  .d_in_1 (d_0_in_1),
  .sys_ts (sys_ts),
  .block_wanted_number (block_wanted_number_0),
  .envelop_output_enable (e_0_oe),
  .envelop_output (e_0_out),
  .data_output_enable (d_0_oe),
  .data_output (d_0_out),
  .block_wanted (block_wanted_0),
  .data_ready (data_ready_0),
  .avl_blocks_nb (avl_blocks_nb_0)//,
  //.state_led (state_led)
  );

wire [7:0] block_wanted_number_1;
wire [40:0] block_wanted_1;
wire data_ready_1;
wire [7:0] avl_blocks_nb_1;

single_receiver_manager RECV1 (
  .clk_96MHz (clk_96MHz),
  .e_in_0 (e_1_in),
  .d_in_0 (d_1_in_0),
  .d_in_1 (d_1_in_1),
  .sys_ts (sys_ts),
  .block_wanted_number (block_wanted_number_1),
  .envelop_output_enable (e_1_oe),
  .envelop_output (e_1_out),
  .data_output_enable (d_1_oe),
  .data_output (d_1_out),
  .block_wanted (block_wanted_1),
  .data_ready (data_ready_1),
  .avl_blocks_nb (avl_blocks_nb_1),
  .state_led (state_led2)
  );

wire [7:0] block_wanted_number_2;
wire [40:0] block_wanted_2;
wire data_ready_2;
wire [7:0] avl_blocks_nb_2;

single_receiver_manager RECV2 (
  .clk_96MHz (clk_96MHz),
  .e_in_0 (e_2_in),
  .d_in_0 (d_2_in_0),
  .d_in_1 (d_2_in_1),
  .sys_ts (sys_ts),
  .block_wanted_number (block_wanted_number_2),
  .envelop_output_enable (e_2_oe),
  .envelop_output (e_2_out),
  .data_output_enable (d_2_oe),
  .data_output (d_2_out),
  .block_wanted (block_wanted_2),
  .data_ready (data_ready_2),
  .avl_blocks_nb (avl_blocks_nb_2),
  .state_led (state_led3)
  );

wire [16:0] pulse_id_0;
wire [16:0] pulse_id_1;
wire [16:0] pulse_id_2;
wire [16:0] polynomial;
wire pulse_identifier_ready;

pulse_identifier PULSE_IDENTIFIER0 (
  .clk_72MHz (clk_72MHz),
  .block_wanted_0 (block_wanted_0),
  .block_wanted_1 (block_wanted_1),
  .block_wanted_2 (block_wanted_2),
  .data_ready_0 (data_ready_0),
  .data_ready_1 (data_ready_1),
  .data_ready_2 (data_ready_2),
  .avl_blocks_nb_0 (avl_blocks_nb_0),
  .avl_blocks_nb_1 (avl_blocks_nb_1),
  .avl_blocks_nb_2 (avl_blocks_nb_2),
  .reset (reset_pulse_identifier),
  .pulse_id_0 (pulse_id_0),
  .pulse_id_1 (pulse_id_1),
  .pulse_id_2 (pulse_id_2),
  .polynomial (polynomial),
  .ready (pulse_identifier_ready),
  .block_wanted_number_0 (block_wanted_number_0),
  .block_wanted_number_1 (block_wanted_number_1),
  .block_wanted_number_2 (block_wanted_number_2),
  .sys_ts (sys_ts),
  .state_led (state_led)
  );

reg [67:0] triad_data = 0;
reg triad_data_avl = 0;
wire reset_pulse_identifier;

data_parser PARSER0(
  .clk_72MHz (clk_72MHz),
  .triad_data (triad_data),
  .triad_data_avl (triad_data_avl),
  .reset_parser (reset_parser),
  .sensor_iterations (sensor_iterations),
  .sensor_data_avl (data_avl),
  .reset_pulse_identifier (reset_pulse_identifier)
  );

always @ (posedge clk_72MHz) begin
  if (pulse_identifier_ready) begin
    triad_data_avl <= 1;
    triad_data <= {
      pulse_id_2, pulse_id_1, pulse_id_0, polynomial
    };
  end else begin
    triad_data_avl <= 0;
  end
end

reg [23:0] tmp_counter = 0;

//assign state_led = tmp_counter[23];

always @ (posedge clk_96MHz) begin
  if (avl_blocks_nb_0 == 0) begin
    tmp_counter <= tmp_counter + 1;
  end
end

endmodule // triad_manager
