`default_nettype none
//`define SIMULATION

module ts4231_configurator (
  input wire clk,
  inout wire envelop,
  inout wire data,
  output wire state_led
  );

wire clk_48MHz;
wire lock;
/*
`ifdef SIMULATION
  assign clk_48MHz = clk;
`endif*/
pll_module PLL (
  .clock_in (clk),
  .clock_out (clk_48MHz),
  .locked (lock)
  );

wire clk_24MHz;

divider #(.M (2))
  DIV0 (
    .clk_in (clk_48MHz),
    .clk_out (clk_24MHz)
    );

reg envelop_output_enable;
reg envelop_output;
reg envelop_input;

SB_IO #(
    .PIN_TYPE(6'b 1010_01),
    .PULLUP(1'b 0)
) envelop_io (
    .PACKAGE_PIN(envelop),
    .OUTPUT_ENABLE(envelop_output_enable),
    .D_OUT_0(envelop_output),
    .D_IN_0(envelop_input)
);

reg data_output_enable;
reg data_output;
reg data_input;

SB_IO #(
    .PIN_TYPE(6'b 1010_01),
    .PULLUP(1'b 0)
) data_io (
    .PACKAGE_PIN(data),
    .OUTPUT_ENABLE(data_output_enable),
    .D_OUT_0(data_output),
    .D_IN_0(data_input)
);

reg data_r;
reg envelop_r;

always @ (posedge clk_48MHz) begin
  data_r <= data_input;
  envelop_r <= envelop_input;
end

reg reconfigure = 1'b1;
reg configured;

always @ (posedge clk_48MHz) begin
  if (configured) begin
    reconfigure <= 1'b0;
  end else begin
    reconfigure <= 1'b1;
  end
end

ts4231Configurator CONFIGURATOR (
  .clk (clk_24MHz),
  .reconfigure (reconfigure),
  .configured (configured),
  .d_in (data_r),
  .d_out (data_output),
  .d_oe (data_output_enable),
  .e_in (envelop_r),
  .e_out (envelop_output),
  .e_oe (envelop_output_enable)
  );

  divider #(.M (96000000))
    DIV1 (
      .clk_in (clk_48MHz),
      .clk_out (state_led)
      );

endmodule // ts4231_configurator
