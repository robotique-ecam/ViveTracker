`default_nettype none

module bmc_decoder #(
  parameter bit_considered = 17
  ) (
  input wire clk_96MHz,
  input wire d_in_0,
  input wire d_in_1,
  input wire e_in_0,
  input wire enabled,
  input wire [23:0] sys_ts,
  input wire reset,

  output reg [bit_considered-1:0] decoded_data,
  output reg data_availible,
  output reg [23:0] ts_last_data

  );

parameter too_fast_counter = 2;
parameter fast_counter = 11;
parameter slow_counter = 11;
parameter timeout_counter = 24;
parameter skip_bits = 2;

localparam  SAMPLE = 0;
localparam  FAST_STATE = 1;
localparam  SLOW_STATE = 2;
localparam  ERROR = 3;
localparam  DATA_AVAILIBLE = 4;


reg [4:0] tick_counter = 0;
reg [4:0] nb_bits_recovered = 0;
reg nb_fast_state = 0;
reg slow_state_detected = 0;
reg [2:0] state = SAMPLE;
reg [bit_considered-1:0] data_buffer = 0;


always @ (posedge clk_96MHz) begin
  if (enabled) begin
    if (reset == 1) begin
      data_availible <= 0;
    end
    case (state)

      SAMPLE: begin
        if (tick_counter > timeout_counter) begin
          state <= ERROR;
        end else if (d_in_0 != d_in_1 && tick_counter > too_fast_counter && !e_in_0) begin
          if (tick_counter <= fast_counter) begin
            state <= FAST_STATE;
          end else if (tick_counter <= timeout_counter && tick_counter > slow_counter) begin
            state <= SLOW_STATE;
          end else begin
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
        tick_counter <= 2;
        nb_fast_state <= 0;
        nb_bits_recovered <= 0;
        slow_state_detected <= 0;
        state <= SAMPLE;
      end

      DATA_AVAILIBLE: begin
        data_availible <= 1;
        decoded_data <= data_buffer;
        ts_last_data <= sys_ts;
        tick_counter <= 2;
        nb_bits_recovered <= bit_considered - skip_bits;
        state <= SAMPLE;
      end

      default: ;
    endcase
  end
end

endmodule // bmc_decoder
