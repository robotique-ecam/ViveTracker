module pulse_identifier_tb ();

reg clk = 0;
reg data_availible = 0;
reg data_availible1 = 0;
reg [23:0] ts_data = 24'h9c388;
reg [23:0] ts_data1 = 24'h9de58;
reg [16:0] decoded_data = 17'h2955;
reg [16:0] decoded_data1 = 17'h17b3d;
reg reset = 0;

wire [16:0] pulse_id_0;
wire [16:0] pulse_id_1;
wire [16:0] polynomial;
wire reset_bmc_decoder_0;
wire reset_bmc_decoder_1;
wire ready;

pulse_identifier dut(
  .clk_96MHz (clk),
  .data_availible (data_availible),
  .data_availible1 (data_availible1),
  .ts_data (ts_data),
  .ts_data1 (ts_data1),
  .decoded_data (decoded_data),
  .decoded_data1 (decoded_data1),
  .reset (reset),
  .pulse_id_0 (pulse_id_0),
  .pulse_id_1 (pulse_id_1),
  .polynomial (polynomial),
  .reset_bmc_decoder_0 (reset_bmc_decoder_0),
  .reset_bmc_decoder_1 (reset_bmc_decoder_1),
  .ready (ready)
  );

always #1 clk <= ~clk;

always @ (posedge clk) begin
  if (reset_bmc_decoder_0 == 1) begin
    data_availible <= 0;
  end
end

always @ (posedge clk) begin
  if (reset_bmc_decoder_1 == 1) begin
    data_availible1 <= 0;
  end
end

always @ (posedge clk) begin
  if (ready == 1) begin
    reset <= 1;
  end else if (ready == 0 && reset == 1) begin
    reset <= 0;
  end
end

initial begin
  $dumpfile("pulse_identifier_tb.vcd");
  $dumpvars(0, pulse_identifier_tb);

  #0 $display("start of simulation");
  #5 data_availible <= 1;
  #(6864*2) data_availible1 <= 1;
  #50 ts_data <= 24'h9de58;
  ts_data1 <= 24'h9c388;
  decoded_data <= 17'h17b3d;
  decoded_data1 <= 17'h2955;
  #32000 data_availible1 <= 1;
  #(6864*2) data_availible <= 1;
  #32000 $finish;
end

endmodule // pulse_identifier_tb
