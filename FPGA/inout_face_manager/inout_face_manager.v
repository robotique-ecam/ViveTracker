`default_nettype none

module inout_face_manager (
  input wire clk_96MHz,


  inout wire data_wire_0,
  input wire d_0_oe,
  input wire d_0_out,
  output reg d_0_in_0,
  output reg d_0_in_1,

  inout wire data_wire_1,
  input wire d_1_oe,
  input wire d_1_out,
  output reg d_1_in_0,
  output reg d_1_in_1,

  inout wire data_wire_2,
  input wire d_2_oe,
  input wire d_2_out,
  output reg d_2_in_0,
  output reg d_2_in_1,


  inout wire envelop_wire_0,
  input wire e_0_oe,
  input wire e_0_out,
  output reg e_0_in,

  inout wire envelop_wire_1,
  input wire e_1_oe,
  input wire e_1_out,
  output reg e_1_in,

  inout wire envelop_wire_2,
  input wire e_2_oe,
  input wire e_2_out,
  output reg e_2_in
  );

wire d_in_0_no_reg;
wire e_in_0_no_reg;

wire d_in_1_no_reg;
wire e_in_1_no_reg;

wire d_in_2_no_reg;
wire e_in_2_no_reg;

reg buffer_0;
reg buffer_1;
reg buffer_2;

(* IO_TYPE="LVCMOS33" *)
TRELLIS_IO #(.DIR("BIDIR"))
  inout_data_0 (
    .B(data_wire_0),
    .I(d_0_out),
    .O(d_in_0_no_reg),
    .T(!d_0_oe)
    );

(* IO_TYPE="LVCMOS33" *)
TRELLIS_IO #(.DIR("BIDIR"))
  inout_data_1 (
    .B(data_wire_1),
    .I(d_1_out),
    .O(d_in_1_no_reg),
    .T(!d_1_oe)
    );

(* IO_TYPE="LVCMOS33" *)
TRELLIS_IO #(.DIR("BIDIR"))
  inout_data_2 (
    .B(data_wire_2),
    .I(d_2_out),
    .O(d_in_2_no_reg),
    .T(!d_2_oe)
    );



(* IO_TYPE="LVCMOS33" *)
TRELLIS_IO #(.DIR("BIDIR"))
  inout_envelop_0 (
    .B(envelop_wire_0),
    .I(e_0_out),
    .O(e_in_0_no_reg),
    .T(!e_0_oe)
    );

(* IO_TYPE="LVCMOS33" *)
TRELLIS_IO #(.DIR("BIDIR"))
  inout_envelop_1 (
    .B(envelop_wire_1),
    .I(e_1_out),
    .O(e_in_1_no_reg),
    .T(!e_1_oe)
    );
    
(* IO_TYPE="LVCMOS33" *)
TRELLIS_IO #(.DIR("BIDIR"))
  inout_envelop_2 (
    .B(envelop_wire_2),
    .I(e_2_out),
    .O(e_in_2_no_reg),
    .T(!e_2_oe)
    );


always @ (posedge clk_96MHz) begin
  d_0_in_0 <= d_in_0_no_reg;
  d_0_in_1 <= buffer_0;

  d_1_in_0 <= d_in_1_no_reg;
  d_1_in_1 <= buffer_1;

  d_2_in_0 <= d_in_2_no_reg;
  d_2_in_1 <= buffer_2;

  e_0_in <= e_in_0_no_reg;

  e_1_in <= e_in_1_no_reg;

  e_2_in <= e_in_2_no_reg;
end

always @ (negedge clk_96MHz) begin
  buffer_0 <= d_0_in_0;
  buffer_1 <= d_1_in_0;
  buffer_2 <= d_2_in_0;
end

endmodule // inout_face_manager
