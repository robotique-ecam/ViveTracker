`default_nettype none

module pll_module_sim(
	input wire clk_25MHz,
	output reg clk_96MHz,
	output reg clk_12MHz
	);

reg [3:0] counter = 0;
initial begin
	clk_96MHz = 0;
	clk_12MHz = 0;
end

always @ ( clk_25MHz) begin
	if (~|counter) begin
		clk_12MHz <= ~clk_12MHz;
	end
	counter <= counter + 1;
	clk_96MHz <= ~clk_96MHz;
end

endmodule
