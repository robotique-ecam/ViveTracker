`default_nettype none
`include "../polynomial_manager/polynomial_manager.v"
`include "../offset_finder/offset_finder.v"

module pulse_identifier (
  input wire clk_72MHz,
  input wire [40:0] block_wanted_0,
  input wire [40:0] block_wanted_1,
  input wire [40:0] block_wanted_2,
  input wire data_ready_0,
  input wire data_ready_1,
  input wire data_ready_2,
  input wire [7:0] avl_blocks_nb_0,
  input wire [7:0] avl_blocks_nb_1,
  input wire [7:0] avl_blocks_nb_2,
  input wire reset,

  output reg [16:0] pulse_id_0,
  output reg [16:0] pulse_id_1,
  output reg [16:0] pulse_id_2,
  output wire [16:0] polynomial,
  output reg ready,
  output reg [7:0] block_wanted_number_0,
  output reg [7:0] block_wanted_number_1,
  output reg [7:0] block_wanted_number_2,

  input wire [23:0] sys_ts
  );

parameter timeout_ticks = 72000; //~1ms in a 72MHz clock frequency
parameter waiting_ticks_after_second_pulses = 3750; //~50µs in a 72MHz clock frequency

localparam  WAITING_FOR_DATA = 0;
localparam  STORING_NEW_DATA = 1;
localparam  START_THIRD_SENSOR_WAIT = 2;
localparam  WAIT_FOR = 3;
localparam  POLYNOMIAL_IDENTIFICATION = 4;
localparam  WAITING_FOR_LAST_DATA = 5;
localparam  OFFSET_IDENTIFICATION = 6;
localparam  DATA_READY = 7;
localparam  WAIT_FOR_LAST_DUMP = 8;
localparam  ERROR_OR_RESET = 9;
localparam  WAIT_FOR_ALL_RAM_DUMP = 10;

reg [3:0] state = ERROR_OR_RESET;

reg [1:0] number_of_data_received_this_pulse;

reg [2:0] data_spotted;
reg [23:0] ts_third_data;
reg [1:0] first_sensor;
reg [1:0] second_sensor;
reg [1:0] third_sensor;

reg [16:0] waiting_timer;
reg enable_waiting_timer;
reg [12:0] wait_for_timer = 0;

always @ (posedge clk_72MHz) begin
  if (enable_waiting_timer == 1 && waiting_timer != timeout_ticks) begin
    waiting_timer <= waiting_timer + 1;
  end else if (enable_waiting_timer == 0) begin
    waiting_timer <= 0;
  end
end

reg [7:0] avl_blocks_nb [2:0];
reg [7:0] avl_blocks_nb_first, avl_blocks_nb_second;

always @ (posedge clk_72MHz) begin
  avl_blocks_nb[0] <= avl_blocks_nb_0;
  avl_blocks_nb[1] <= avl_blocks_nb_1;
  avl_blocks_nb[2] <= avl_blocks_nb_2;
  avl_blocks_nb_first <= avl_blocks_nb[first_sensor];
  avl_blocks_nb_second <= avl_blocks_nb[second_sensor];
end

reg [40:0] block_wanted [2:0];
reg [40:0] block_wanted_first, block_wanted_second;

always @ (posedge clk_72MHz) begin
  block_wanted[0] <= block_wanted_0;
  block_wanted[1] <= block_wanted_1;
  block_wanted[2] <= block_wanted_2;
  block_wanted_first <= block_wanted[first_sensor];
  block_wanted_second <= block_wanted[second_sensor];
end


reg [2:0] ram_data_ready;
reg ram_data_ready_first, ram_data_ready_second;

always @ (posedge clk_72MHz) begin
  ram_data_ready[0] <= data_ready_0;
  ram_data_ready[1] <= data_ready_1;
  ram_data_ready[2] <= data_ready_2;
  ram_data_ready_first <= ram_data_ready[first_sensor];
  ram_data_ready_second <= ram_data_ready[second_sensor];
end

reg [7:0] block_wanted_nb [2:0];
wire [7:0] poly_mana_block_wanted_nb_0;
wire [7:0] poly_mana_block_wanted_nb_1;

always @ (posedge clk_72MHz) begin
  if (first_sensor != second_sensor && second_sensor != third_sensor
    && third_sensor != first_sensor && third_sensor !=3) begin
      block_wanted_nb[first_sensor] <= poly_mana_block_wanted_nb_0;
      block_wanted_nb[second_sensor] <= poly_mana_block_wanted_nb_1;
      block_wanted_nb[third_sensor] <= 0;
  end else begin
    block_wanted_nb[0] <= 0;
    block_wanted_nb[1] <= 0;
    block_wanted_nb[2] <= 0;
  end
  block_wanted_number_0 <= block_wanted_nb[0];
  block_wanted_number_1 <= block_wanted_nb[1];
  block_wanted_number_2 <= block_wanted_nb[2];
end


reg enable_polynomial_manager;
wire [16:0] iteration_between_first_second;
reg [16:0] iteration_between_first_third;
wire polynomial_manager_ready;
reg wait_for_module_activation = 0;
wire [16:0] first_data;
wire [23:0] ts_first_data;

polynomial_manager POLY_MANAGER(
  .clk_72MHz (clk_72MHz),
  .ram_block_wanted_0 (block_wanted_first),
  .ram_block_wanted_1 (block_wanted_second),
  .ram_data_ready_0 (ram_data_ready_first),
  .ram_data_ready_1 (ram_data_ready_second),
  .avl_blocks_nb_0 (avl_blocks_nb_first),
  .avl_blocks_nb_1 (avl_blocks_nb_second),
  .enable (enable_polynomial_manager),

  .block_wanted_number_0 (poly_mana_block_wanted_nb_0),
  .block_wanted_number_1 (poly_mana_block_wanted_nb_1),
  .polynomial (polynomial),
  .iteration_number (iteration_between_first_second),
  .first_data (first_data),
  .ts_first_data (ts_first_data),
  .ready (polynomial_manager_ready)
  );

reg offset_finder_enable;
wire [16:0] offset_first_pulse;
wire offset_finder_ready;

offset_finder OFFSET_FINDER0(
  .clk_72MHz (clk_72MHz),
  .polynomial (polynomial),
  .data (first_data),
  .enable (offset_finder_enable),
  .offset (offset_first_pulse),
  .ready (offset_finder_ready)
  );

always @ (posedge clk_72MHz) begin
  if (third_sensor == 0 && (|avl_blocks_nb_0 && ts_third_data == 0) && waiting_timer != timeout_ticks) begin
    ts_third_data <= sys_ts;
  end else if (third_sensor == 1 && (|avl_blocks_nb_1 && ts_third_data == 0) && waiting_timer != timeout_ticks) begin
    ts_third_data <= sys_ts;
  end else if (third_sensor == 2 && (|avl_blocks_nb_2 && ts_third_data == 0) && waiting_timer != timeout_ticks) begin
    ts_third_data <= sys_ts;
  end else if (third_sensor == 3) begin
    ts_third_data <= 0;
  end
end

always @ (posedge clk_72MHz) begin
  case (state)
    WAITING_FOR_DATA: begin
      if (waiting_timer == timeout_ticks) begin
        state <= ERROR_OR_RESET;
      end else if (( (|avl_blocks_nb_0 && ~data_spotted[0]) || (|avl_blocks_nb_1 && ~data_spotted[1])
       || (|avl_blocks_nb_2 && ~data_spotted[2]))) begin
          state <= STORING_NEW_DATA;
      end
      ready <= 0;
    end

    STORING_NEW_DATA: begin
      if (number_of_data_received_this_pulse == 0) begin
        if (|avl_blocks_nb_0 && ~data_spotted[0]) begin
          data_spotted[0] <= 1;
          first_sensor <= 0;
        end else if (|avl_blocks_nb_1 && ~data_spotted[1]) begin
          data_spotted[1] <= 1;
          first_sensor <= 1;
        end else if (|avl_blocks_nb_2 && ~data_spotted[2]) begin
          data_spotted[2] <= 1;
          first_sensor <= 2;
        end
        number_of_data_received_this_pulse <= 1;
        enable_waiting_timer <= 1;
        state <= WAITING_FOR_DATA;
      end else begin
        if (|avl_blocks_nb_0 && ~data_spotted[0]) begin
          data_spotted[0] <= 1;
          second_sensor <= 0;
        end else if (|avl_blocks_nb_1 && ~data_spotted[1]) begin
          data_spotted[1] <= 1;
          second_sensor <= 1;
        end else if (|avl_blocks_nb_2 && ~data_spotted[2]) begin
          data_spotted[2] <= 1;
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
      state <= WAIT_FOR;
    end

    WAIT_FOR: begin
      if (wait_for_timer < waiting_ticks_after_second_pulses) begin
        wait_for_timer <= wait_for_timer + 1;
      end else begin
        if (first_sensor != second_sensor) begin
          state <= POLYNOMIAL_IDENTIFICATION;
        end else begin
          state <= ERROR_OR_RESET;
        end
      end
    end

    POLYNOMIAL_IDENTIFICATION: begin
      enable_polynomial_manager <= 1;
      if (polynomial_manager_ready == 1) begin
        if (wait_for_module_activation) begin
        end else if (polynomial == 0) begin
          state <= WAIT_FOR_ALL_RAM_DUMP;
        end else begin
          state <= WAITING_FOR_LAST_DATA;
        end
      end else if (wait_for_module_activation == 1 && polynomial_manager_ready == 0) begin
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
        state <= WAIT_FOR_ALL_RAM_DUMP;
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
          state <= WAIT_FOR_ALL_RAM_DUMP;
        end
      end else if (wait_for_module_activation == 1 && offset_finder_ready == 0) begin
        wait_for_module_activation <= 0;
      end
    end

    DATA_READY: begin
      ready <= 1;
      if (reset == 1) begin
        ready <= 0;
        state <= WAIT_FOR_LAST_DUMP;
      end
    end

    WAIT_FOR_LAST_DUMP: begin
      if (avl_blocks_nb[third_sensor] == 0) begin
        state <= ERROR_OR_RESET;
      end
    end

    ERROR_OR_RESET: begin
      number_of_data_received_this_pulse <= 0;
      enable_waiting_timer <= 0;
      first_sensor <= 0;
      second_sensor <= 0;
      third_sensor <= 3;
      offset_finder_enable <= 0;
      pulse_id_0 <= 0;
      pulse_id_1 <= 0;
      pulse_id_2 <= 0;
      iteration_between_first_third <= 0;
      enable_polynomial_manager <= 0;
      data_spotted <= 0;
      wait_for_timer <= 0;
      state <= WAITING_FOR_DATA;
    end

    WAIT_FOR_ALL_RAM_DUMP: begin
      if (third_sensor != 3) begin
        if (avl_blocks_nb[first_sensor] == 0 && avl_blocks_nb[second_sensor] == 0 && avl_blocks_nb[third_sensor] == 0) begin
          state <= ERROR_OR_RESET;
        end
      end else if (avl_blocks_nb[first_sensor] == 0 && avl_blocks_nb[second_sensor] == 0) begin
        state <= ERROR_OR_RESET;
      end
    end

    default: ;
  endcase
end

endmodule // pulse_identifier
