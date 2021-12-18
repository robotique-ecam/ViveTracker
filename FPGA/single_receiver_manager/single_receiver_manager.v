`default_nettype none

`include "../bmc_decoder/bmc_decoder.v"
`include "../ts4231_configurator/ts4231_configurator.v"

module single_receiver_manager (
  input wire clk_96MHz,
  input wire e_in_0,
  input wire d_in_0,
  input wire d_in_1,
  input wire [23:0] sys_ts,
  input wire reset,

  output reg envelop_output_enable,
  output reg envelop_output,

  output reg data_output_enable,
  output reg data_output,

  output wire data_availible,
  output wire [16:0] decoded_data,
  output wire [23:0] ts_last_data,

  output wire state_led
  );

wire configured;

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

bmc_decoder #(.bit_considered (17))
  BMC_DECODER (
    .clk_96MHz (clk_96MHz),
    .d_in_0 (d_in_0),
    .d_in_1 (d_in_1),
    .e_in_0 (e_in_0),
    .enabled (configured),
    .sys_ts (sys_ts),
    .reset (reset),
    .decoded_data (decoded_data),
    .data_availible (data_availible),
    .ts_last_data (ts_last_data),
    .state_led (state_led)
    );

endmodule // single_receiver_manager
