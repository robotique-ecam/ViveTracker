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
  output wire [23:0] timestamp_last_data
  );

reg configured = 1;

bmc_decoder #(.bit_considered (17))
  BMC_DECODER (
    .clk_96MHz (clk_96MHz),
    .d_in_0 (d_in_0),
    .d_in_1 (d_in_1),
    .e_in_0 (e_in_0),
    .enabled (configured),
    .system_timestamp (system_timestamp),
    .reset (reset),
    .decoded_data (decoded_data),
    .data_availible (data_availible),
    .timestamp_last_data (timestamp_last_data)
    );

endmodule // single_receiver_manager
