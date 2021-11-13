module divider (
  input wire clk_in,
  output wire clk_out
  );

parameter M = 96000000; //0.5 Hz on a 48 MHz clock

localparam  N = $clog2(M);

reg [N-1:0] divcounter = 0;

always @ ( posedge clk_in ) begin
  divcounter <= (divcounter == M -1) ? 0 : divcounter + 1;
end

assign clk_out = divcounter[N-1];

endmodule // divider
