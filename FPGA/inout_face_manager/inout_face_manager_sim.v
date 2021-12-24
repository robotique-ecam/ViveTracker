`default_nettype none

module inout_face_manager_sim (
  input wire clk_96MHz,


  input wire data_wire_0,
  output reg d_0_in_0,
  output reg d_0_in_1,

  input wire data_wire_1,
  output reg d_1_in_0,
  output reg d_1_in_1,

  input wire data_wire_2,
  output reg d_2_in_0,
  output reg d_2_in_1,


  input wire envelop_wire_0,
  output reg e_0_in,

  input wire envelop_wire_1,
  output reg e_1_in,

  input wire envelop_wire_2,
  output reg e_2_in
  );

reg buffer_0;
reg buffer_1;
reg buffer_2;


always @ (posedge clk_96MHz) begin
  d_0_in_0 <= data_wire_0;
  d_0_in_1 <= buffer_0;

  d_1_in_0 <= data_wire_1;
  d_1_in_1 <= buffer_1;

  d_2_in_0 <= data_wire_2;
  d_2_in_1 <= buffer_2;

  e_0_in <= envelop_wire_0;

  e_1_in <= envelop_wire_1;

  e_2_in <= envelop_wire_2;
end

always @ (negedge clk_96MHz) begin
  buffer_0 <= d_0_in_0;
  buffer_1 <= d_1_in_0;
  buffer_2 <= d_2_in_0;
end

endmodule // inout_face_manager
