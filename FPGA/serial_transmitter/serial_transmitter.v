`default_nettype none
`include "../uart_tx_module/uart_tx.v"

module serial_transmitter (
  input wire clk_12MHz,
  input wire data_availible,
  input wire [101:0] sensor_iterations,
  output wire tx,
  output reg reset_parser
  );

reg rstn = 0;

wire ready;

reg [7:0] data;

reg last_tx = 0;

//µ_orders
reg start;




// DATA PATH

reg [23:0] iteration0_sensor0, iteration1_sensor0, iteration0_sensor1,
  iteration1_sensor1, iteration0_sensor2, iteration1_sensor2;

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

reg [4:0] car_count = 0;

always @ ( posedge clk_12MHz ) begin
  case (car_count)
    8'd0: data <= 8'h00;
    8'd1: data <= 8'h00;
    8'd2: data <= 8'h00;

    8'd3: data <= iteration0_sensor0[23:16];
    8'd4: data <= iteration0_sensor0[15:8];
    8'd5: data <= iteration0_sensor0[7:0];

    8'd6: data <= iteration1_sensor0[23:16];
    8'd7: data <= iteration1_sensor0[15:8];
    8'd8: data <= iteration1_sensor0[7:0];

    8'd9: data <= iteration0_sensor1[23:16];
    8'd10: data <= iteration0_sensor1[15:8];
    8'd11: data <= iteration0_sensor1[7:0];

    8'd12: data <= iteration1_sensor1[23:16];
    8'd13: data <= iteration1_sensor1[15:8];
    8'd14: data <= iteration1_sensor1[7:0];

    8'd15: data <= iteration0_sensor2[23:16];
    8'd16: data <= iteration0_sensor2[15:8];
    8'd17: data <= iteration0_sensor2[7:0];

    8'd18: data <= iteration1_sensor2[23:16];
    8'd19: data <= iteration1_sensor2[15:8];
    8'd20: data <= iteration1_sensor2[7:0];
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
    reset_parser <= 0;
  end else begin
    case (state)
      IDLE: begin
          if (data_availible == 1) begin
            state <= LOAD_DATA;
          end
        end

      LOAD_DATA: begin
          iteration0_sensor0 <= { 7'b0000000, sensor_iterations[101:85]};
          iteration1_sensor0 <= { 7'b0000000, sensor_iterations[84:68]};
          iteration0_sensor1 <= { 7'b0000000, sensor_iterations[67:51]};
          iteration1_sensor1 <= { 7'b0000000, sensor_iterations[50:34]};
          iteration0_sensor2 <= { 7'b0000000, sensor_iterations[33:17]};
          iteration1_sensor2 <= { 7'b0000000, sensor_iterations[16:0]};
          state <= RESET_PULSE_IDENTIFIER;
        end

      RESET_PULSE_IDENTIFIER: begin
        reset_parser <= 1;
        state <= TXCAR;
      end

      TXCAR: begin
        reset_parser <= 0;
          if (ready) begin
            start <= 1;
            state <= NEXT;
          end
        end

      NEXT: begin
          start <= 0;
          if (car_count < 20) begin
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
