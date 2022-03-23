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
  output wire [101:0] sensor_iterations
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
  .avl_blocks_nb (avl_blocks_nb_0)
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
  .avl_blocks_nb (avl_blocks_nb_1)
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
  .avl_blocks_nb (avl_blocks_nb_2)
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
  .sys_ts (sys_ts)
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

endmodule // triad_manager
