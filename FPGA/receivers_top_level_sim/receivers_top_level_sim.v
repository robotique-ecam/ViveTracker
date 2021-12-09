`default_nettype none

`include "../single_receiver_manager_sim/single_receiver_manager.v"
`include "../serial_transmitter/serial_transmitter.v"

module receivers_top_level_sim (
  input wire clk_12MHz,
  input wire clk_96MHz,
  input wire e_in_0,
  input wire d_in_0,
  input wire d_in_1,
  output wire tx
  );

reg [23:0] system_timestamp = 0;
always @ (posedge clk_96MHz) begin
  system_timestamp <= system_timestamp + 1;
end

wire envelop_output_enable;
wire envelop_output;

wire data_output_enable;
wire data_output;

wire reset;
wire data_availible;
wire [16:0] decoded_data;
wire [23:0] timestamp_last_data;

single_receiver_manager RECV0(
  .clk_96MHz (clk_96MHz),
  .e_in_0 (e_in_0),
  .d_in_0 (d_in_0),
  .d_in_1 (d_in_1),
  .system_timestamp (system_timestamp),
  .reset (reset),
  .envelop_output_enable (envelop_output_enable),
  .envelop_output (envelop_output),
  .data_output_enable (data_output_enable),
  .data_output (data_output),
  .data_availible (data_availible),
  .decoded_data (decoded_data),
  .timestamp_last_data (timestamp_last_data)
  );

serial_transmitter UART (
  .clk_12MHz (clk_12MHz),
  .data_availible (data_availible),
  .decoded_data (decoded_data),
  .timestamp_last_data (timestamp_last_data),
  .tx (tx),
  .reset_decoder (reset)
  );

endmodule // receivers_top_level
