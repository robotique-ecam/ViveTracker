`default_nettype none

`include "../pll_module/pll_module_100.v"
`include "../pll_module/pll_module_96_12.v"

module pll_module(
	input wire clk_25MHz,
	output wire clk_96MHz,
	output wire clk_12MHz
	);

wire clk_100MHz;
wire locked_pll_0;
wire locked_pll_1;

pll_module_100 PLL0(
	.clk_25MHz (clk_25MHz),
	.clk_100MHz (clk_100MHz),
	.locked (locked_pll_0)
	);

pll_module_96_12 PLL1(
	.clk_100MHz (clk_100MHz),
	.clk_96MHz (clk_96MHz),
	.clk_12MHz (clk_12MHz),
	.locked (locked_pll_1)
	);

endmodule
