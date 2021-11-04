`default_nettype none

module bmc_decoder #(
  parameter bit_considered = 17
  ) (
  input wire clk_96MHz,
  input wire d_in_0,
  input wire d_in_1,
  input wire e_in_0,
  input wire enabled,
  input wire [23:0] system_timestamp,
  input wire reset,

  output reg [bit_considered-1:0] decoded_data,
  output reg data_availible,
  output reg [23:0] timestamp_last_data,

  output wire state_led,
  output wire state_led1,
  output wire state_led2,
  output wire state_led3,
  output wire state_led4
  );

parameter too_fast_counter = 3;
parameter fast_counter = 11;
parameter slow_counter = 11;
parameter timeout_counter = 24;
parameter waiting_ticks = 5000; // 40µs

localparam  IDLE = 0;
localparam  START_SAMPLING = 1;
localparam  SAMPLE = 2;
localparam  FAST_STATE = 3;
localparam  SLOW_STATE = 4;
localparam  ERROR = 5;
localparam  DATA_AVAILIBLE = 6;
localparam  WAITING_TIME = 7;


reg sampling_ena = 0;
reg [4:0] tick_counter = 0;
reg [12:0] wait_counter = 0;
reg [4:0] nb_bits_recovered = 0;
reg nb_fast_state = 0;
reg slow_state_detected = 0;
reg [2:0] state = IDLE;
reg [bit_considered-1:0] data_buffer = 0;

reg [4:0] fast_counter_error = 0;
reg [4:0] slow_counter_error = 0;
reg [4:0] between_counter_error = 0;

assign state_led1 = fast_counter_error[4];
assign state_led3 = slow_counter_error[4];
assign state_led4 = between_counter_error[4];

reg [4:0] tmp = 0;
always @ (posedge clk_96MHz) begin
  if (state == 5) begin
    tmp <= tmp + 1;
  end
end

assign state_led2 = tmp[4];


always @ (posedge clk_96MHz) begin
  if (enabled) begin
    if (reset == 1) begin
      data_availible <= 0;
    end
    case (state)

      IDLE: begin
        sampling_ena <= 0;
        if (e_in_0 == 0) begin
          state <= START_SAMPLING;
        end
      end

      START_SAMPLING: begin
        tick_counter <= 1;
        nb_bits_recovered <= 0;
        nb_fast_state <= 0;
        slow_state_detected <= 0;
        if (d_in_0 != d_in_1 || sampling_ena) begin
          if (sampling_ena) begin
            state <= SAMPLE;
          end
          sampling_ena <= 1;
        end
        if (e_in_0 == 1) begin
          state <= ERROR;
        end
      end

      SAMPLE: begin
        if (e_in_0 == 1) begin
          state <= ERROR;
        end else if (d_in_0 != d_in_1 && tick_counter > too_fast_counter/* || tick_counter > timeout_counter*/) begin
          if (tick_counter <= fast_counter /*&& tick_counter > too_fast_counter*/) begin
            state <= FAST_STATE;
          end else if (tick_counter <= timeout_counter && tick_counter > slow_counter) begin
            state <= SLOW_STATE;
          end else if (tick_counter > timeout_counter) begin
            slow_counter_error <= slow_counter_error + 1;
            state <= ERROR;
          end else if (tick_counter < too_fast_counter) begin
            fast_counter_error <= fast_counter_error + 1;
            state <= ERROR;
          end else begin
            between_counter_error <= between_counter_error + 1;
            state <= ERROR;
          end
        end else begin
          tick_counter <= tick_counter + 1;
        end
      end

      FAST_STATE: begin
        if (nb_fast_state == 1) begin
          data_buffer <= {data_buffer[15:0], 1'b1};
          nb_fast_state <= 0;
          if (nb_bits_recovered == bit_considered - 1) begin
            state <= DATA_AVAILIBLE;
          end else begin
            nb_bits_recovered <= nb_bits_recovered + 1;
            tick_counter <= 1;
            state <= SAMPLE;
          end
        end else begin
          nb_fast_state <= nb_fast_state + 1;
          tick_counter <= 1;
          state <= SAMPLE;
        end
      end

      SLOW_STATE: begin
        if (nb_fast_state > 0 && slow_state_detected == 1) begin
          state <= ERROR;
        end else begin
          data_buffer <= {data_buffer[15:0], 1'b0};
          slow_state_detected <= 1;
          if (nb_bits_recovered == bit_considered - 1) begin
            state <= DATA_AVAILIBLE;
          end else begin
            nb_bits_recovered <= nb_bits_recovered +1;
            nb_fast_state <= 0;
            tick_counter <= 1;
            state <= SAMPLE;
          end
        end
      end

      ERROR: begin
        sampling_ena <= 0;
        state <= IDLE;
      end

      DATA_AVAILIBLE: begin
        data_availible <= 1;
        decoded_data <= data_buffer;
        timestamp_last_data <= system_timestamp;
        sampling_ena <= 0;
        tick_counter <= 0;
        state <= WAITING_TIME;
      end

      WAITING_TIME: begin
        if (wait_counter == waiting_ticks) begin
          wait_counter <= 0;
          //data_availible = 0;
          state <= IDLE;
        end else begin
          wait_counter <= wait_counter + 1;
        end
      end

      default: ;
    endcase
  end
end

endmodule // bmc_decoder
