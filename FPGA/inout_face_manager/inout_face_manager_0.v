`default_nettype none

module inout_face_manager_0 (
  input wire clk_96MHz,


  inout wire data_wire_0,
  input wire d_oe_0,
  input wire d_out_0,
  output reg d_in_first_0,
  output reg d_in_second_0,

  inout wire envelop_wire_0,
  input wire e_oe_0,
  input wire e_out_0,
  output reg e_in_0,


  inout wire data_wire_1,
  input wire d_oe_1,
  input wire d_out_1,
  output reg d_in_first_1,
  output reg d_in_second_1,

  inout wire envelop_wire_1,
  input wire e_oe_1,
  input wire e_out_1,
  output reg e_in_1

  );

wire d_in_0_no_reg;
wire e_in_0_no_reg;

wire d_in_1_no_reg;
wire e_in_1_no_reg;

reg buffer_0;
reg buffer_1;

(* LOC="D20" *) (* IO_TYPE="LVCMOS33" *)
TRELLIS_IO #(.DIR("BIDIR"))
  inout_data_0 (
    .B(data_wire_0),
    .I(d_out_0),
    .O(d_in_0_no_reg),
    .T(!d_oe_0)
    );

(* LOC="B19" *) (* IO_TYPE="LVCMOS33" *)
TRELLIS_IO #(.DIR("BIDIR"))
  inout_envelop_0 (
    .B(envelop_wire_0),
    .I(e_out_0),
    .O(e_in_0_no_reg),
    .T(!e_oe_0)
    );



(* LOC="A19" *) (* IO_TYPE="LVCMOS33" *)
TRELLIS_IO #(.DIR("BIDIR"))
  inout_data_1 (
    .B(data_wire_1),
    .I(d_out_1),
    .O(d_in_1_no_reg),
    .T(!d_oe_1)
    );

(* LOC="A18" *) (* IO_TYPE="LVCMOS33" *)
TRELLIS_IO #(.DIR("BIDIR"))
  inout_envelop_1 (
    .B(envelop_wire_1),
    .I(e_out_1),
    .O(e_in_1_no_reg),
    .T(!e_oe_1)
    );

always @ (posedge clk_96MHz) begin
  d_in_first_0 <= d_in_0_no_reg;
  d_in_second_0 <= buffer_0;

  d_in_first_1 <= d_in_1_no_reg;
  d_in_second_1 <= buffer_1;

  e_in_0 <= e_in_0_no_reg;

  e_in_1 <= e_in_1_no_reg;
end

always @ (negedge clk_96MHz) begin
  buffer_0 <= d_in_first_0;
  buffer_1 <= d_in_first_1;
end

endmodule // inout_face_manager
