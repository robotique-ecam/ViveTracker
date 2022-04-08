`default_nettype none
`include "../uart_tx_module/uart_tx.v"

module serial_transmitter (
  input wire clk_12MHz,
  input wire data_availible,
  input wire [271:0] sensor_iterations,
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

reg [23:0] iteration0_sensor0, iteration1_sensor0,
  iteration0_sensor1, iteration1_sensor1,
  iteration0_sensor2, iteration1_sensor2,
  iteration0_sensor3, iteration1_sensor3,
  iteration0_sensor4, iteration1_sensor4,
  iteration0_sensor5, iteration1_sensor5,
  iteration0_sensor6, iteration1_sensor6,
  iteration0_sensor7, iteration1_sensor7;

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

reg [5:0] car_count = 0;

always @ ( posedge clk_12MHz ) begin
  case (car_count)
    8'd0: data <= 8'hff;
    8'd1: data <= 8'hff;
    8'd2: data <= 8'hff;

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

    8'd21: data <= iteration0_sensor3[23:16];
    8'd22: data <= iteration0_sensor3[15:8];
    8'd23: data <= iteration0_sensor3[7:0];

    8'd24: data <= iteration1_sensor3[23:16];
    8'd25: data <= iteration1_sensor3[15:8];
    8'd26: data <= iteration1_sensor3[7:0];

    8'd27: data <= iteration0_sensor4[23:16];
    8'd28: data <= iteration0_sensor4[15:8];
    8'd29: data <= iteration0_sensor4[7:0];

    8'd30: data <= iteration1_sensor4[23:16];
    8'd31: data <= iteration1_sensor4[15:8];
    8'd32: data <= iteration1_sensor4[7:0];

    8'd33: data <= iteration0_sensor5[23:16];
    8'd34: data <= iteration0_sensor5[15:8];
    8'd35: data <= iteration0_sensor5[7:0];

    8'd36: data <= iteration1_sensor5[23:16];
    8'd37: data <= iteration1_sensor5[15:8];
    8'd38: data <= iteration1_sensor5[7:0];

    8'd39: data <= iteration0_sensor6[23:16];
    8'd40: data <= iteration0_sensor6[15:8];
    8'd41: data <= iteration0_sensor6[7:0];

    8'd42: data <= iteration1_sensor6[23:16];
    8'd43: data <= iteration1_sensor6[15:8];
    8'd44: data <= iteration1_sensor6[7:0];

    8'd45: data <= iteration0_sensor7[23:16];
    8'd46: data <= iteration0_sensor7[15:8];
    8'd47: data <= iteration0_sensor7[7:0];

    8'd48: data <= iteration1_sensor7[23:16];
    8'd49: data <= iteration1_sensor7[15:8];
    8'd50: data <= iteration1_sensor7[7:0];

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
          iteration0_sensor0 <= { 7'b0000000, sensor_iterations[271:255]};
          iteration1_sensor0 <= { 7'b0000000, sensor_iterations[254:238]};
          iteration0_sensor1 <= { 7'b0000000, sensor_iterations[237:221]};
          iteration1_sensor1 <= { 7'b0000000, sensor_iterations[220:204]};
          iteration0_sensor2 <= { 7'b0000000, sensor_iterations[203:187]};
          iteration1_sensor2 <= { 7'b0000000, sensor_iterations[186:170]};
          iteration0_sensor3 <= { 7'b0000000, sensor_iterations[169:153]};
          iteration1_sensor3 <= { 7'b0000000, sensor_iterations[152:136]};
          iteration0_sensor4 <= { 7'b0000000, sensor_iterations[135:119]};
          iteration1_sensor4 <= { 7'b0000000, sensor_iterations[118:102]};
          iteration0_sensor5 <= { 7'b0000000, sensor_iterations[101:85]};
          iteration1_sensor5 <= { 7'b0000000, sensor_iterations[84:68]};
          iteration0_sensor6 <= { 7'b0000000, sensor_iterations[67:51]};
          iteration1_sensor6 <= { 7'b0000000, sensor_iterations[50:34]};
          iteration0_sensor7 <= { 7'b0000000, sensor_iterations[33:17]};
          iteration1_sensor7 <= { 7'b0000000, sensor_iterations[16:0]};
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
          if (car_count < 50) begin
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
