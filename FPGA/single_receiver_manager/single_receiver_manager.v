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

  output wire data_availible,
  output wire [16:0] decoded_data,
  output wire [23:0] timestamp_last_data,
  );

reg configured;

ts4231_configurator TS4231_CONFIGURATOR (
  .clk_96MHz (clk_96MHz),
  .e_in_0_r (e_in_0),
  .envelop_output_enable (envelop_output_enable),
  .envelop_output (envelop_output),
  .d_in_0_r (d_in_0),
  .data_output_enable (data_output_enable),
  .data_output (data_output),
  .configured (configured)
  );


endmodule // single_receiver_manager
