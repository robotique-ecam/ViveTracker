`default_nettype none

module single_inout_manager (
  input wire clk_96MHz,

  inout wire data_wire_0,
  input wire d_0_oe,
  input wire d_0_out,
  output reg d_0_in_0,
  output reg d_0_in_1,

  inout wire envelop_wire_0,
  input wire e_0_oe,
  input wire e_0_out,
  output reg e_0_in,
  );

wire d_in_0_no_reg;
wire e_in_0_no_reg;

reg buffer_0;

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
  inout_envelop_0 (
    .B(envelop_wire_0),
    .I(e_0_out),
    .O(e_in_0_no_reg),
    .T(!e_0_oe)
    );


always @ (posedge clk_96MHz) begin
  d_0_in_0 <= d_in_0_no_reg;
  d_0_in_1 <= buffer_0;

  e_0_in <= e_in_0_no_reg;
end

always @ (negedge clk_96MHz) begin
  buffer_0 <= d_0_in_0;
end

endmodule // single_inout_manager_sim
