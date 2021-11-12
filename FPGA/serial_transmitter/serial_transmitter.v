`default_nettype none

module serial_transmitter (
  input wire clk_12MHz,
  input wire data_availible,
  input wire [16:0] decoded_data,
  input wire [23:0] timestamp_last_data,
  output wire tx,
  output reg reset_decoder
  );

reg rstn = 0;

wire ready;

reg [7:0] data;

reg last_tx = 0;

//µ_orders
reg start;




// DATA PATH

reg [23:0] decoded_data_transmit, timestamp_transmit;

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

reg [2:0] car_count = 0;

always @ ( posedge clk_12MHz ) begin
  case (car_count)
    8'd0: data <= decoded_data_transmit[23:16];
    8'd1: data <= decoded_data_transmit[15:8];
    8'd2: data <= decoded_data_transmit[7:0];
    8'd3: data <= 8'h00;
    8'd4: data <= timestamp_last_data[23:16];
    8'd5: data <= timestamp_last_data[15:8];
    8'd6: data <= timestamp_last_data[7:0];
    8'd7: data <= 8'h00;
    default: data <= 8'hff;
  endcase
end




// CONTROLLER

localparam IDLE = 0;
localparam LOAD_DATA = 1;
localparam TXCAR = 2;
localparam NEXT = 3;
localparam END = 4;

reg [2:0] state;

always @ (posedge clk_12MHz) begin
  if (rstn==0) begin
    state <= IDLE;
    reset_decoder <= 0;
  end else begin
    case (state)
      IDLE: begin
          if (data_availible == 1) begin
            state <= LOAD_DATA;
            reset_decoder <= 1;
          end
        end

      LOAD_DATA: begin
          decoded_data_transmit <= { 7'b0000000 ,decoded_data};
          timestamp_transmit <= timestamp_last_data;
          reset_decoder <= 0;
          state <= TXCAR;
        end

      TXCAR: begin
          if (ready) begin
            start <= 1;
            state <= NEXT;
          end
        end

      NEXT: begin
          start <= 0;
          if (car_count < 7) begin
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
