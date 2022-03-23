`default_nettype none

module single_inout_manager_sim (
  input wire clk_96MHz,

  input wire data_wire_0,
  output reg d_0_in_0,
  output reg d_0_in_1,

  input wire envelop_wire_0,
  output reg e_0_in
  );

reg buffer_0;

always @ (posedge clk_96MHz) begin
  d_0_in_0 <= data_wire_0;
  d_0_in_1 <= buffer_0;

  e_0_in <= envelop_wire_0;
end

always @ (negedge clk_96MHz) begin
  buffer_0 <= d_0_in_0;
end

endmodule // inout_face_manager
