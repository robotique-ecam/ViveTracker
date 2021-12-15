`default_nettype none

`include "../ts4231_configurator/ts4231Configurator.v"

module ts4231_configurator (
  input wire clk_96MHz,

  input wire e_in_0_r,
  output reg envelop_output_enable,
  output reg envelop_output,

  input wire d_in_0_r,
  output reg data_output_enable,
  output reg data_output,

  output reg configured
  );


// configuration management
reg reconfigure = 1'b1;

always @ (posedge clk_96MHz) begin
  if (configured) begin
    reconfigure <= 1'b0;
  end else begin
    reconfigure <= 1'b1;
  end
end



// ts4231Configurator instanciation
ts4231Configurator CONFIGURATOR (
  .clk (clk_96MHz),
  .reconfigure (reconfigure),
  .configured (configured),
  .d_in (d_in_0_r),
  .d_out (data_output),
  .d_oe (data_output_enable),
  .e_in (e_in_0_r),
  .e_out (envelop_output),
  .e_oe (envelop_output_enable)
  );

endmodule // ts4231_configurator
