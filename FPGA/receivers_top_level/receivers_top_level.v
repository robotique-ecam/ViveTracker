`default_nettype none

module receivers_top_level (
  input wire clk_12MHz,
  inout wire envelop,
  inout wire data,
  output wire state_led,
  );

wire clk_96MHz;
wire lock;

pll_module PLL (
  .clock_in (clk_12MHz),
  .clock_out (clk_96MHz),
  .locked (lock)
  );

reg [23:0] system_timestamp = 0;
always @ (posedge clk_96MHz) begin
  system_timestamp <= system_timestamp + 1;
end

// inout pin definition using primitive SB_IO
wire envelop_output_enable;
wire envelop_output;
wire e_in_0;

SB_IO #(
    .PIN_TYPE(6'b 1010_01),
    .PULLUP(1'b 0)
) envelop_io (
    .PACKAGE_PIN(envelop),
    .OUTPUT_ENABLE(envelop_output_enable),
    .D_OUT_0(envelop_output),
    .D_IN_0(e_in_0)
);

wire data_output_enable;
wire data_output;
wire d_in_0, d_in_1;

SB_IO #(
    .PIN_TYPE(6'b 1010_01),
    .PULLUP(1'b 0)
) data_io (
    .PACKAGE_PIN(data),
    .OUTPUT_ENABLE(data_output_enable),
    .D_OUT_0(data_output),
    .D_IN_0(d_in_0),
    .D_IN_1(d_in_1)
);

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
  .timestamp_last_data (timestamp_last_data),
  .state_led (state_led),
  );

endmodule // receivers_top_level
