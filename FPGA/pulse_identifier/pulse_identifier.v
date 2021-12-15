`default_nettype none
`include "../polynomial_finder/polynomial_finder.v"
`include "../offset_finder/offset_finder.v"

module pulse_identifier (
  input wire clk_96MHz,
  input wire data_availible,
  input wire data_availible1,
  input wire [23:0] ts_data,
  input wire [23:0] ts_data1,
  input wire [16:0] decoded_data,
  input wire [16:0] decoded_data1,
  input wire reset,

  output reg [16:0] pulse_id_0,
  output reg [16:0] pulse_id_1,
  output wire [16:0] polynomial,
  output reg reset_bmc_decoder_0,
  output reg reset_bmc_decoder_1,
  output reg ready
  );

parameter timeout_ticks = 100000; //~1ms in a 96MHz clock frequency

localparam  WAITING_FOR_DATA = 0;
localparam  STORING_NEW_DATA = 1;
localparam  POLYNOMIAL_IDENTIFICATION = 2;
localparam  WAITING_FOR_LAST_DATA = 3;
localparam  OFFSET_IDENTIFICATION = 4;
localparam  DATA_READY = 5;
localparam  ERROR_OR_RESET = 6;

reg [3:0] state = ERROR_OR_RESET;

reg [1:0] number_of_data_received_this_pulse;

reg [16:0] first_data, second_data;
reg [23:0] ts_first_data, ts_second_data;
reg [1:0] first_sensor;
reg [1:0] second_sensor;

reg [16:0] waiting_timer;
reg enable_waiting_timer;

always @ (posedge clk_96MHz) begin
  if (enable_waiting_timer == 1) begin
    waiting_timer <= waiting_timer + 1;
  end
end

reg enable_polynomial_finder;
wire [16:0] iteration_between_first_second;
wire polynomial_finder_ready;
reg wait_for_module_activation = 0;

polynomial_finder POLY_FINDER(
  .clk_96MHz (clk_96MHz),
  .ts_last_data (ts_first_data),
  .ts_last_data1 (ts_second_data),
  .decoded_data (first_data),
  .decoded_data1 (second_data),
  .enable (enable_polynomial_finder),
  .polynomial (polynomial),
  .iteration_number (iteration_between_first_second),
  .ready (polynomial_finder_ready)
  );

reg offset_finder_enable;
wire [16:0] offset_first_pulse;
wire offset_finder_ready;

offset_finder OFFSET_FINDER0(
  .clk_96MHz (clk_96MHz),
  .polynomial (polynomial),
  .data (first_data),
  .enable (offset_finder_enable),
  .offset (offset_first_pulse),
  .ready (offset_finder_ready)
  );

always @ (posedge clk_96MHz) begin
  case (state)
    WAITING_FOR_DATA: begin
      if (waiting_timer == timeout_ticks) begin
        state <= ERROR_OR_RESET;
      end else if ((data_availible || data_availible1) && (reset_bmc_decoder_0 == 0 && reset_bmc_decoder_1 == 0) ) begin
        state <= STORING_NEW_DATA;
      end
      ready <= 0;
      reset_bmc_decoder_0 <= 0;
      reset_bmc_decoder_1 <= 0;
    end

    STORING_NEW_DATA: begin
      if (number_of_data_received_this_pulse == 0) begin
        if (data_availible == 1) begin
          first_data <= decoded_data;
          ts_first_data <= ts_data;
          reset_bmc_decoder_0 <= 1;
          first_sensor <= 0;
        end else if (data_availible1 == 1) begin
          first_data <= decoded_data1;
          ts_first_data <= ts_data1;
          reset_bmc_decoder_1 <= 1;
          first_sensor <= 1;
        end
        number_of_data_received_this_pulse <= 1;
        enable_waiting_timer <= 1;
        state <= WAITING_FOR_DATA;
      end else begin
        if (data_availible == 1) begin
          second_data <= decoded_data;
          ts_second_data <= ts_data;
          reset_bmc_decoder_0 <= 1;
          second_sensor <= 0;
        end else if (data_availible1 == 1) begin
          second_data <= decoded_data1;
          ts_second_data <= ts_data1;
          reset_bmc_decoder_1 <= 1;
          second_sensor <= 1;
        end
        wait_for_module_activation <= 1;
        state <= POLYNOMIAL_IDENTIFICATION;
      end
    end

    POLYNOMIAL_IDENTIFICATION: begin
      reset_bmc_decoder_0 <= 0;
      reset_bmc_decoder_1 <= 0;
      enable_polynomial_finder <= 1;
      if (polynomial_finder_ready == 1) begin
        if (wait_for_module_activation) begin
        end else if (polynomial == 0) begin
          state <= ERROR_OR_RESET;
        end else begin
          state <= WAITING_FOR_LAST_DATA;
        end
      end else if (wait_for_module_activation == 1 && polynomial_finder_ready == 0) begin
        wait_for_module_activation <= 0;
      end
    end

    WAITING_FOR_LAST_DATA: begin
      enable_waiting_timer <= 0;
      wait_for_module_activation <= 1;
      state <= OFFSET_IDENTIFICATION;
    end

    OFFSET_IDENTIFICATION: begin
      offset_finder_enable <= 1;
      if (offset_finder_ready == 1) begin
        if (wait_for_module_activation) begin
        end else if (offset_first_pulse != 0) begin
          pulse_id_0 <= (first_sensor == 0) ? offset_first_pulse : offset_first_pulse + iteration_between_first_second;
          pulse_id_1 <= (first_sensor == 1) ? offset_first_pulse : offset_first_pulse + iteration_between_first_second;
          state <= DATA_READY;
        end else begin
          state <= ERROR_OR_RESET;
        end
      end else if (wait_for_module_activation == 1 && offset_finder_ready == 0) begin
        wait_for_module_activation <= 0;
      end
    end

    DATA_READY: begin
      ready <= 1;
      if (reset == 1) begin
        ready <= 0;
        state <= ERROR_OR_RESET;
      end
    end

    ERROR_OR_RESET: begin
      number_of_data_received_this_pulse <= 0;
      first_data <= 0;
      second_data <= 0;
      ts_first_data <= 0;
      ts_second_data <= 0;
      waiting_timer <= 0;
      enable_waiting_timer <= 0;
      first_sensor <= 0;
      second_sensor <= 0;
      enable_polynomial_finder <= 0;
      offset_finder_enable <= 0;
      pulse_id_0 <= 0;
      pulse_id_1 <= 0;
      state <= WAITING_FOR_DATA;
    end

    default: ;
  endcase
end

endmodule // pulse_identifier
