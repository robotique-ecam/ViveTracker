`default_nettype none

`include "../uart_tx_module/baudgen.vh"
`include "../uart_tx_module/baudgen.v"

// Serial emmitter module
// tx output is registered
module uart_tx (
  input wire clk,         // system clock (12MHz)
  input wire start,       // 1 to transmit
  input wire rstn,        // 0 to global reset
  input wire [0:7] data,  // byte to transmit
  output reg tx,          // serial output
  output wire ready       // ready (1) / busy (0)
  );

// baudrate of the transmission
parameter BAUD = 12;//`B115200;

// start register
reg start_r;

// clock of the transmission
wire clk_baud;

// bit counter
reg [3:0] bit_c;

// data register
reg [7:0] data_r;

// µ_order
wire load;
wire baud_ena;



// #########
// DATA PATH
// #########

// 10 bits register containing bit to send
// 1 start bit + 8 data bits + 1 stop bit
reg [9:0] shifter;

// registration of start into start_r
always @ (posedge clk) begin
  start_r <= start;
end

// registration of data when start and IDLE
always @ (posedge clk) begin
  if (start == 1 && state == IDLE) begin
    data_r <= data;
  end
end

/*
 * if load == 1 (START state), shifter is loader with data_r
 * if load == 0 AND clk_baud ticks (TRANS state),
 * (shifter >> 1) || 10'b10_0000_0000
*/
always @ (posedge clk) begin
  if (rstn == 0) begin
    shifter <= 10'b11_1111_1111;
  end

  else if (load == 1) begin
    shifter <= {data_r, 2'b01};
  end

  else if (load == 0 && clk_baud ==1) begin
    shifter <= {1'b1, shifter[9:1]};
  end
end

// bit_c is set to 0 if load = 1 (START state)
// and incremented if clk_baud ticks (TRANS state)
always @ (posedge clk) begin
  if (load) begin
    bit_c <= 0;
  end else if (clk_baud) begin
    bit_c <= bit_c + 1;
  end
end

// tx is connected to the least significant bit of shifter
always @ (posedge clk) begin
  tx <= shifter[0];
end

// divider to obtain the clock of transmission
baudgen #(.M (BAUD))
  BAUD0(
    .clk_in (clk),
    .clk_ena (baud_ena),
    .clk_out (clk_baud)
    );



// ##########
// CONTROLLER
// ##########

// machine states of the controller
localparam IDLE = 0;
localparam START = 1;
localparam TRANS = 2;

// actual machine state of the controller
reg [1:0] state;

// transition between states
always @ (posedge clk) begin

  // reset of the machine state
  if (rstn == 0) begin
    state <= IDLE;
  end

  else begin
    case (state)
      // when start_r is 1, goes to START state
      // else remain to IDLE state
      IDLE:
        if (start) begin
          state <= START;
        end else begin
          state <= IDLE;
        end

      // START state, switch to TRANS state
      START:
        state <= TRANS;

      // if bit_c is 11 return to IDLE state
      // else remain to TRANS state
      TRANS:
        if (bit_c == 11) begin
          state <= IDLE;
        end else begin
          state <= TRANS;
        end

      default:
        state <= IDLE;

   endcase
  end
end

// µ_order generation
assign load = (state == START) ? 1 : 0;
assign baud_ena = (state == IDLE) ? 0: 1;
assign ready = (state == IDLE) ? 1 : 0;

endmodule // uart_tx
