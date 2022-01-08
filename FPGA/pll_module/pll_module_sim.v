`default_nettype none

module pll_module_sim(
	input wire clk_25MHz,
	output reg clk_96MHz,
	output reg clk_12MHz,
	output reg clk_72MHz
	);

reg [4:0] counter_12 = 0;
reg [2:0] counter_72 = 0;
reg [1:0] counter_96 = 0;

initial begin
	clk_96MHz = 0;
	clk_12MHz = 0;
	clk_72MHz = 0;
end

always @ (clk_25MHz) begin
	if (counter_96 == 2) begin
		clk_96MHz <= ~clk_96MHz;
		counter_96 <= 0;
	end else begin
		counter_96 <= counter_96 + 1;
	end
end

always @ (clk_25MHz) begin
	if (counter_72 == 3) begin
		clk_72MHz <= ~clk_72MHz;
		counter_72 <= 0;
	end else begin
		counter_72 <= counter_72 + 1;
	end
end

always @ (clk_25MHz) begin
	if (counter_12 == 23) begin
		clk_12MHz <= ~clk_12MHz;
		counter_12 <= 0;
	end else begin
		counter_12 <= counter_12 + 1;
	end
end

endmodule
