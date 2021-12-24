`default_nettype none

`include "../bmc_decoder/bmc_decoder.v"
`include "../ts4231_configurator/ts4231_configurator.v"
`include "../ram_decoded/ram_decoded.v"

module single_receiver_manager (
  input wire clk_96MHz,
  input wire e_in_0,
  input wire d_in_0,
  input wire d_in_1,
  input wire [23:0] sys_ts,
  input wire [7:0] block_wanted_number,

  output reg envelop_output_enable,
  output reg envelop_output,

  output reg data_output_enable,
  output reg data_output,

  output wire [40:0] block_wanted,
  output wire data_ready,
  output wire [7:0] avl_blocks_nb,

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

wire [16:0] decoded_data;
wire [23:0] ts_last_data;
wire reset;
wire data_availible;

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
    .ts_last_data (ts_last_data)
    );

ram_decoded RAM(
  .clk_96MHz (clk_96MHz),
  .decoded_data (decoded_data),
  .ts_decoded_data (ts_last_data),
  .decoded_data_avl (data_availible),
  .block_wanted_number (block_wanted_number),

  .block_wanted (block_wanted),
  .data_ready (data_ready),
  .reset_bmc_decoder (reset),
  .avl_blocks_nb (avl_blocks_nb)
  );

reg [23:0] tmp_counter = 0;

//assign state_led = tmp_counter[23];

always @ (posedge clk_96MHz) begin
  if (avl_blocks_nb == 0) begin
    tmp_counter <= tmp_counter + 1;
  end
end

endmodule // single_receiver_manager
