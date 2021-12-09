`default_nettype none

module receivers_top_level (
  input wire clk_12MHz,
  inout wire envelop,
  inout wire data,
  inout wire envelop1,
  inout wire data1,
  output wire tx,
  output wire state_led,
  output wire state_led1,
  output wire state_led2,
  output wire state_led3,
  output wire state_led4
  );

wire clk_96MHz;
wire clk_48MHz;
wire lock;

pll_module PLL (
  .clock_in (clk_12MHz),
  .clock_out (clk_96MHz),
  .locked (lock)
  );

reg [0:0] counter = 0;
always @ (posedge clk_96MHz) begin
  counter <= counter + 1;
end

assign clk_48MHz = counter == 0;

reg [23:0] system_timestamp = 0;
always @ (posedge clk_96MHz) begin
  if (&system_timestamp) begin
    system_timestamp <= 0;
  end else begin
    system_timestamp <= system_timestamp + 1;
  end
end



// inout pin definition using primitive SB_IO
wire envelop_output_enable;
wire envelop_output;
wire e_in_0;

SB_IO #(
    .PIN_TYPE(6'b 1010_00),
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
    .PIN_TYPE(6'b 1010_00),
    .PULLUP(1'b 0)
) data_io (
    .INPUT_CLK (clk_48MHz),
    .PACKAGE_PIN(data),
    .OUTPUT_ENABLE(data_output_enable),
    .D_OUT_0(data_output),
    .D_IN_0(d_in_0),
    .D_IN_1(d_in_1),
    .LATCH_INPUT_VALUE(1'b0)
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
  .reset (reset_bmc_decoder_0),
  .envelop_output_enable (envelop_output_enable),
  .envelop_output (envelop_output),
  .data_output_enable (data_output_enable),
  .data_output (data_output),
  .data_availible (data_availible),
  .decoded_data (decoded_data),
  .timestamp_last_data (timestamp_last_data),
  .state_led (state_led)
  );





// inout pin definition using primitive SB_IO
wire envelop1_output_enable;
wire envelop1_output;
wire e1_in_0;

SB_IO #(
    .PIN_TYPE(6'b 1010_00),
    .PULLUP(1'b 0)
) envelop1_io (
    .PACKAGE_PIN(envelop1),
    .OUTPUT_ENABLE(envelop1_output_enable),
    .D_OUT_0(envelop1_output),
    .D_IN_0(e1_in_0)
);

wire data1_output_enable;
wire data1_output;
wire d1_in_0, d1_in_1;

SB_IO #(
    .PIN_TYPE(6'b 1010_00),
    .PULLUP(1'b 0)
) data1_io (
    .INPUT_CLK (clk_48MHz),
    .PACKAGE_PIN(data1),
    .OUTPUT_ENABLE(data1_output_enable),
    .D_OUT_0(data1_output),
    .D_IN_0(d1_in_0),
    .D_IN_1(d1_in_1),
    .LATCH_INPUT_VALUE(1'b0)
);

wire reset1;
wire data1_availible;
wire [16:0] decoded_data1;
wire [23:0] timestamp_last_data1;

single_receiver_manager RECV1(
  .clk_96MHz (clk_96MHz),
  .e_in_0 (e1_in_0),
  .d_in_0 (d1_in_0),
  .d_in_1 (d1_in_1),
  .system_timestamp (system_timestamp),
  .reset (reset_bmc_decoder_1),
  .envelop_output_enable (envelop1_output_enable),
  .envelop_output (envelop1_output),
  .data_output_enable (data1_output_enable),
  .data_output (data1_output),
  .data_availible (data1_availible),
  .decoded_data (decoded_data1),
  .timestamp_last_data (timestamp_last_data1),
  .state_led (state_led1)
  );

wire reset_pulse_identifier;
wire [16:0] pulse_id_0;
wire [16:0] pulse_id_1;
wire [16:0] polynomial;
wire reset_bmc_decoder_0;
wire reset_bmc_decoder_1;
wire pulse_identifier_ready;

pulse_identifier PULSE_IDENTIFIER0 (
  .clk_96MHz (clk_96MHz),
  .data_availible (data_availible),
  .data_availible1 (data1_availible),
  .ts_data (timestamp_last_data),
  .ts_data1 (timestamp_last_data1),
  .decoded_data (decoded_data),
  .decoded_data1 (decoded_data1),
  .reset (reset_pulse_identifier),
  .pulse_id_0 (pulse_id_0),
  .pulse_id_1 (pulse_id_1),
  .polynomial (polynomial),
  .reset_bmc_decoder_0 (reset_bmc_decoder_0),
  .reset_bmc_decoder_1 (reset_bmc_decoder_1),
  .ready (pulse_identifier_ready)
  );

serial_transmitter UART (
  .clk_12MHz (clk_12MHz),
  .data_availible (pulse_identifier_ready),
  .pulse_id_0 (pulse_id_0),
  .pulse_id_1 (pulse_id_1),
  .polynomial (polynomial),
  .tx (tx),
  .reset_pulse_identifier (reset_pulse_identifier)
  );

endmodule // receivers_top_level
