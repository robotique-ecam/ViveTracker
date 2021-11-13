`include "../uart_tx_module/baudgen.vh"

module baudgen (
  input wire clk_in,
  input wire clk_ena,
  output wire clk_out
  );

parameter M = `B230400;

localparam  N = $clog2(M);

reg [N-1:0] divcounter = 0;

always @ ( posedge clk_in ) begin
  if (clk_ena) begin
    divcounter <= (divcounter == M -1) ? 0 : divcounter + 1;
  end else begin
    divcounter <= M-1;
  end

end

assign clk_out = (divcounter == 0) ? clk_ena : 0;

endmodule // baudgen
