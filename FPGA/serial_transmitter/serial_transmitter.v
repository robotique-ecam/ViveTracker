`default_nettype none
`include "../uart_tx_module/uart_tx.v"

module serial_transmitter (
  input wire clk_12MHz,
  input wire data_availible,
  input wire [67:0] triad_data,
  output wire tx,
  output reg reset_pulse_identifier
  );

reg rstn = 0;

wire ready;

reg [7:0] data;

reg last_tx = 0;

//µ_orders
reg start;




// DATA PATH

reg [23:0] decoded_data0_transmit, decoded_data1_transmit, decoded_data2_transmit, decoded_polynomial_transmit;

always @ (posedge clk_12MHz) begin
  rstn <= 1;
end

uart_tx TX0 (
    .clk (clk_12MHz),
    .start (start),
    .rstn (rstn),
    .data (data),
    .tx (tx),
    .ready (ready)
    );

reg [3:0] car_count = 0;

always @ ( posedge clk_12MHz ) begin
  case (car_count)
    8'd0: data <= 8'h00;
    8'd1: data <= 8'h00;
    8'd2: data <= 8'h00;
    8'd3: data <= 8'h00;
    8'd4: data <= decoded_data0_transmit[23:16];
    8'd5: data <= decoded_data0_transmit[15:8];
    8'd6: data <= decoded_data0_transmit[7:0];
    8'd7: data <= decoded_data1_transmit[23:16];
    8'd8: data <= decoded_data1_transmit[15:8];
    8'd9: data <= decoded_data1_transmit[7:0];
    8'd10: data <= decoded_data2_transmit[23:16];
    8'd11: data <= decoded_data2_transmit[15:8];
    8'd12: data <= decoded_data2_transmit[7:0];
    8'd13: data <= decoded_polynomial_transmit[23:16];
    8'd14: data <= decoded_polynomial_transmit[15:8];
    8'd15: data <= decoded_polynomial_transmit[7:0];
    default: data <= 8'hff;
  endcase
end


// CONTROLLER

localparam IDLE = 0;
localparam LOAD_DATA = 1;
localparam RESET_PULSE_IDENTIFIER = 2;
localparam TXCAR = 3;
localparam NEXT = 4;
localparam END = 5;

reg [2:0] state;

always @ (posedge clk_12MHz) begin
  if (rstn==0) begin
    state <= IDLE;
    reset_pulse_identifier <= 0;
  end else begin
    case (state)
      IDLE: begin
          if (data_availible == 1) begin
            state <= LOAD_DATA;
          end
        end

      LOAD_DATA: begin
          decoded_data2_transmit <= { 7'b0000000, triad_data[67:51]};
          decoded_data1_transmit <= { 7'b0000000, triad_data[50:34]};
          decoded_data0_transmit <= { 7'b0000000, triad_data[33:17]};
          decoded_polynomial_transmit <= { 7'b0000000, triad_data[16:0]};
          state <= RESET_PULSE_IDENTIFIER;
        end

      RESET_PULSE_IDENTIFIER: begin
        reset_pulse_identifier <= 1;
        state <= TXCAR;
      end

      TXCAR: begin
        reset_pulse_identifier <= 0;
          if (ready) begin
            start <= 1;
            state <= NEXT;
          end
        end

      NEXT: begin
          start <= 0;
          if (car_count < 15) begin
            car_count <= car_count + 1;
            state <= TXCAR;
          end else begin
            state <= END;
          end
        end

      END: begin
          if (last_tx == 1 && ready) begin
            car_count <= 0;
            last_tx <= 0;
            state <= IDLE;
          end else if (last_tx == 0) begin
            last_tx <= 1;
          end
        end

      default:
        state <= IDLE;
    endcase
  end
end

endmodule // serial_transmitter
