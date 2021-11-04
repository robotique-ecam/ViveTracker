`include "../uart_tx_module/baudgen.vh"

module serial_transmitter_tb ();

localparam BAUD = `B115200;

localparam BITRATE = (BAUD << 1);

localparam FRAME = (BITRATE * 11);

localparam FRAME_WAIT = (BITRATE * 4);

reg clk = 0;

wire tx;

reg data_availible = 0;

reg [16:0] decoded_data = 17'b10101010101010101;

reg [23:0] timestamp_last_data = 24'b101010101010101010101010;

wire reset_decoder;

serial_transmitter dut(
    .clk_12MHz (clk),
    .data_availible (data_availible),
    .decoded_data (decoded_data),
    .timestamp_last_data (timestamp_last_data),
    .tx (tx),
    .reset_decoder (reset_decoder)
  );

always @ (posedge clk) begin
  if (reset_decoder == 1) begin
    data_availible <= 0;
  end
end

always #1 clk <= ~clk;

initial begin

  $dumpfile("serial_transmitter_tb.vcd");
  $dumpvars(0, serial_transmitter_tb);

  #FRAME data_availible <= 1;
  #(FRAME * 6) decoded_data = 17'b11111111111111111;
  data_availible <= 1;
  #(FRAME * 40) $display("END of simulation");
  $finish;

end

endmodule
