`default_nettype none
`include "../polynomial_finder/polynomial_finder.v"
`include "../offset_finder/offset_finder.v"

module pulse_identifier (
  input wire clk_96MHz,
  input wire data_availible,
  input wire data_availible1,
  input wire data_availible2,
  input wire [23:0] ts_data,
  input wire [23:0] ts_data1,
  input wire [23:0] ts_data2,
  input wire [16:0] decoded_data,
  input wire [16:0] decoded_data1,
  input wire [16:0] decoded_data2,
  input wire reset,

  output reg [16:0] pulse_id_0,
  output reg [16:0] pulse_id_1,
  output reg [16:0] pulse_id_2,
  output wire [16:0] polynomial,
  output reg reset_bmc_decoder_0,
  output reg reset_bmc_decoder_1,
  output reg reset_bmc_decoder_2,
  output reg ready,

  output wire state_led,
  input wire [23:0] sys_ts
  );

parameter timeout_ticks = 50000; //~1ms in a 96MHz clock frequency

localparam  WAITING_FOR_DATA = 0;
localparam  STORING_NEW_DATA = 1;
localparam  START_THIRD_SENSOR_WAIT = 2;
localparam  POLYNOMIAL_IDENTIFICATION = 3;
localparam  WAITING_FOR_LAST_DATA = 4;
localparam  OFFSET_IDENTIFICATION = 5;
localparam  DATA_READY = 6;
localparam  ERROR_OR_RESET = 7;

reg [3:0] state = ERROR_OR_RESET;

reg [1:0] number_of_data_received_this_pulse;

reg [16:0] first_data, second_data;
reg [23:0] ts_first_data, ts_second_data, ts_third_data;
reg [1:0] first_sensor;
reg [1:0] second_sensor;
reg [1:0] third_sensor;

reg [16:0] waiting_timer;
reg enable_waiting_timer;

always @ (posedge clk_96MHz) begin
  if (enable_waiting_timer == 1 && waiting_timer != timeout_ticks) begin
    waiting_timer <= waiting_timer + 1;
  end else if (enable_waiting_timer == 0) begin
    waiting_timer <= 0;
  end
end

reg enable_polynomial_finder;
wire [16:0] iteration_between_first_second;
reg [16:0] iteration_between_first_third;
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
  if (third_sensor == 0 && data_availible && waiting_timer != timeout_ticks) begin
    ts_third_data <= ts_data;
  end else if (third_sensor == 1 && data_availible1 && waiting_timer != timeout_ticks) begin
    ts_third_data <= ts_data1;
  end else if (third_sensor == 2 && data_availible2 && waiting_timer != timeout_ticks) begin
    ts_third_data <= ts_data2;
  end else if (third_sensor == 3) begin
    ts_third_data <= 0;
  end
end

always @ (posedge clk_96MHz) begin
  case (state)
    WAITING_FOR_DATA: begin
      if (waiting_timer == timeout_ticks) begin
        state <= ERROR_OR_RESET;
      end else if ((data_availible || data_availible1 || data_availible2)
        && (reset_bmc_decoder_0 == 0 && reset_bmc_decoder_1 == 0 && reset_bmc_decoder_2 == 0) ) begin
          state <= STORING_NEW_DATA;
      end
      ready <= 0;
      reset_bmc_decoder_0 <= 0;
      reset_bmc_decoder_1 <= 0;
      reset_bmc_decoder_2 <= 0;
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
        end else if (data_availible2 == 1) begin
          first_data <= decoded_data2;
          ts_first_data <= ts_data2;
          reset_bmc_decoder_2 <= 1;
          first_sensor <= 2;
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
        end else if (data_availible2 == 1) begin
          second_data <= decoded_data2;
          ts_second_data <= ts_data2;
          reset_bmc_decoder_2 <= 1;
          second_sensor <= 2;
        end
        wait_for_module_activation <= 1;
        state <= START_THIRD_SENSOR_WAIT;
      end
    end

    START_THIRD_SENSOR_WAIT: begin
      if ((first_sensor == 0 || first_sensor == 1)
      && (second_sensor == 0 || second_sensor == 1)) begin
        third_sensor <= 2;
      end else if ((first_sensor == 0 || first_sensor == 2)
      && (second_sensor == 0 || second_sensor == 2)) begin
        third_sensor <= 1;
      end else begin
        third_sensor <= 0;
      end
      state <= POLYNOMIAL_IDENTIFICATION;
    end

    POLYNOMIAL_IDENTIFICATION: begin
      reset_bmc_decoder_0 <= 0;
      reset_bmc_decoder_1 <= 0;
      reset_bmc_decoder_2 <= 0;
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
      if (ts_third_data != 0) begin
        enable_waiting_timer <= 0;
        if (ts_first_data < ts_third_data) begin
          iteration_between_first_third <= (ts_third_data-ts_first_data)>>4;
        end else begin
          iteration_between_first_third <= (24'hffffff - ts_first_data + ts_third_data)>>4;
        end
        wait_for_module_activation <= 1;
        state <= OFFSET_IDENTIFICATION;
      end else if (waiting_timer == timeout_ticks) begin
        state <= ERROR_OR_RESET;
      end
    end

    OFFSET_IDENTIFICATION: begin
      offset_finder_enable <= 1;
      if (offset_finder_ready == 1) begin
        if (wait_for_module_activation) begin
        end else if (offset_first_pulse != 0) begin

          if (first_sensor == 0) begin
            pulse_id_0 <= offset_first_pulse;
          end else if (second_sensor == 0) begin
            pulse_id_0 <= offset_first_pulse + iteration_between_first_second;
          end else begin
            pulse_id_0 <= offset_first_pulse + iteration_between_first_third;
          end

          if (first_sensor == 1) begin
            pulse_id_1 <= offset_first_pulse;
          end else if (second_sensor == 1) begin
            pulse_id_1 <= offset_first_pulse + iteration_between_first_second;
          end else begin
            pulse_id_1 <= offset_first_pulse + iteration_between_first_third;
          end

          if (first_sensor == 2) begin
            pulse_id_2 <= offset_first_pulse;
          end else if (second_sensor == 2) begin
            pulse_id_2 <= offset_first_pulse + iteration_between_first_second;
          end else begin
            pulse_id_2 <= offset_first_pulse + iteration_between_first_third;
          end

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
      enable_waiting_timer <= 0;
      first_sensor <= 0;
      second_sensor <= 0;
      third_sensor <= 3;
      enable_polynomial_finder <= 0;
      offset_finder_enable <= 0;
      pulse_id_0 <= 0;
      pulse_id_1 <= 0;
      pulse_id_2 <= 0;
      iteration_between_first_third <= 0;
      state <= WAITING_FOR_DATA;
    end

    default: ;
  endcase
end

reg [23:0] tmp_counter = 0;

assign state_led = tmp_counter[5];

always @ (posedge clk_96MHz) begin
  if (state == POLYNOMIAL_IDENTIFICATION && polynomial == 0 && wait_for_module_activation == 0) begin
    tmp_counter <= tmp_counter + 1;
  end
end

endmodule // pulse_identifier
