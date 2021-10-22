`default_nettype none

module single_receiver_manager (
  input wire clk_96MHz,
  input wire e_in_0,
  input wire d_in_0,
  input wire d_in_1,
  input wire [23:0] system_timestamp,
  input wire reset,

  output reg envelop_output_enable,
  output reg envelop_output,

  output reg data_output_enable,
  output reg data_output,

  output reg data_availible,
  output reg [16:0] decoded_data,
  output reg [23:0] timestamp_last_data
  );

reg e_in_0_r;
reg d_in_0_r;
reg d_in_1_r;

always @ (posedge clk_96MHz) begin
  e_in_0_r <= e_in_0;
  d_in_0_r <= d_in_0;
  d_in_1_r <= d_in_1;
end

reg configured;
wire state_led;

ts4231_configurator TS4231_CONFIGURATOR (
  .clk_96MHz (clk_96MHz),
  .e_in_0_r (e_in_0_r),
  .envelop_output_enable (envelop_output_enable),
  .envelop_output (envelop_output),
  .d_in_0_r (d_in_0_r),
  .data_output_enable (data_output_enable),
  .data_output (data_output),
  .configured (configured),
  .state_led (state_led)
  );


endmodule // single_receiver_manager
