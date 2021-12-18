`default_nettype none

`include "../inout_face_manager/inout_face_manager.v"
`include "../single_receiver_manager/single_receiver_manager.v"
`include "../pulse_identifier/pulse_identifier.v"

module triad_manager (
  input wire clk_96MHz,

  inout wire envelop_wire_0,
  inout wire envelop_wire_1,
  inout wire envelop_wire_2,

  inout wire data_wire_0,
  inout wire data_wire_1,
  inout wire data_wire_2,

  input wire [23:0] sys_ts,
  input wire reset_pulse_identifier,

  output reg data_avl,
  output reg [67:0] triad_data,

  output wire state_led
  );
wire state_led1;
wire state_led2;
wire state_led3;

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

wire reset_bmc_decoder_0;
wire data_avl_0;
wire [16:0] decoded_data_0;
wire [23:0] ts_last_data_0;

single_receiver_manager RECV0 (
  .clk_96MHz (clk_96MHz),
  .e_in_0 (e_0_in),
  .d_in_0 (d_0_in_0),
  .d_in_1 (d_0_in_1),
  .sys_ts (sys_ts),
  .reset (reset_bmc_decoder_0),
  .envelop_output_enable (e_0_oe),
  .envelop_output (e_0_out),
  .data_output_enable (d_0_oe),
  .data_output (d_0_out),
  .data_availible (data_avl_0),
  .decoded_data (decoded_data_0),
  .ts_last_data (ts_last_data_0),
  .state_led (state_led1)
  );

wire reset_bmc_decoder_1;
wire data_avl_1;
wire [16:0] decoded_data_1;
wire [23:0] ts_last_data_1;

single_receiver_manager RECV1 (
  .clk_96MHz (clk_96MHz),
  .e_in_0 (e_1_in),
  .d_in_0 (d_1_in_0),
  .d_in_1 (d_1_in_1),
  .sys_ts (sys_ts),
  .reset (reset_bmc_decoder_1),
  .envelop_output_enable (e_1_oe),
  .envelop_output (e_1_out),
  .data_output_enable (d_1_oe),
  .data_output (d_1_out),
  .data_availible (data_avl_1),
  .decoded_data (decoded_data_1),
  .ts_last_data (ts_last_data_1),
  .state_led (state_led2)
  );

wire reset_bmc_decoder_2;
wire data_avl_2;
wire [16:0] decoded_data_2;
wire [23:0] ts_last_data_2;

single_receiver_manager RECV2 (
  .clk_96MHz (clk_96MHz),
  .e_in_0 (e_2_in),
  .d_in_0 (d_2_in_0),
  .d_in_1 (d_2_in_1),
  .sys_ts (sys_ts),
  .reset (reset_bmc_decoder_2),
  .envelop_output_enable (e_2_oe),
  .envelop_output (e_2_out),
  .data_output_enable (d_2_oe),
  .data_output (d_2_out),
  .data_availible (data_avl_2),
  .decoded_data (decoded_data_2),
  .ts_last_data (ts_last_data_2),
  .state_led (state_led3)
  );

wire [16:0] pulse_id_0;
wire [16:0] pulse_id_1;
wire [16:0] pulse_id_2;
wire [16:0] polynomial;
wire pulse_identifier_ready;

pulse_identifier PULSE_IDENTIFIER0 (
  .clk_96MHz (clk_96MHz),
  .data_availible (data_avl_0),
  .data_availible1 (data_avl_1),
  .data_availible2 (data_avl_2),
  .ts_data (ts_last_data_0),
  .ts_data1 (ts_last_data_1),
  .ts_data2 (ts_last_data_2),
  .decoded_data (decoded_data_0),
  .decoded_data1 (decoded_data_1),
  .decoded_data2 (decoded_data_2),
  .reset (reset_pulse_identifier),
  .pulse_id_0 (pulse_id_0),
  .pulse_id_1 (pulse_id_1),
  .pulse_id_2 (pulse_id_2),
  .polynomial (polynomial),
  .reset_bmc_decoder_0 (reset_bmc_decoder_0),
  .reset_bmc_decoder_1 (reset_bmc_decoder_1),
  .reset_bmc_decoder_2 (reset_bmc_decoder_2),
  .ready (pulse_identifier_ready),
  .state_led (state_led),
  .sys_ts (sys_ts)
  );


always @ (posedge clk_96MHz) begin
  if (pulse_identifier_ready) begin
    data_avl <= 1;
    triad_data <= {
      pulse_id_2, pulse_id_1, pulse_id_0, polynomial
    };
  end else begin
    data_avl <= 0;
  end
end

endmodule // triad_manager
