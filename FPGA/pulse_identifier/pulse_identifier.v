`default_nettype none
`include "../polynomial_manager/polynomial_manager.v"
`include "../offset_finder/offset_finder.v"

module pulse_identifier (
  input wire clk_72MHz,
  input wire [40:0] block_wanted_0,
  input wire [40:0] block_wanted_1,
  input wire [40:0] block_wanted_2,
  input wire [40:0] block_wanted_3,
  input wire [40:0] block_wanted_4,
  input wire [40:0] block_wanted_5,
  input wire [40:0] block_wanted_6,
  input wire [40:0] block_wanted_7,
  input wire data_ready_0,
  input wire data_ready_1,
  input wire data_ready_2,
  input wire data_ready_3,
  input wire data_ready_4,
  input wire data_ready_5,
  input wire data_ready_6,
  input wire data_ready_7,
  input wire [7:0] avl_blocks_nb_0,
  input wire [7:0] avl_blocks_nb_1,
  input wire [7:0] avl_blocks_nb_2,
  input wire [7:0] avl_blocks_nb_3,
  input wire [7:0] avl_blocks_nb_4,
  input wire [7:0] avl_blocks_nb_5,
  input wire [7:0] avl_blocks_nb_6,
  input wire [7:0] avl_blocks_nb_7,
  input wire reset,

  output wire [16:0] polynomial,
  output reg ready,
  output reg [7:0] block_wanted_number_0,
  output reg [7:0] block_wanted_number_1,
  output reg [7:0] block_wanted_number_2,
  output reg [7:0] block_wanted_number_3,
  output reg [7:0] block_wanted_number_4,
  output reg [7:0] block_wanted_number_5,
  output reg [7:0] block_wanted_number_6,
  output reg [7:0] block_wanted_number_7,
  output wire [16:0] iteration_0,
  output wire [16:0] iteration_1,
  output wire [16:0] iteration_2,
  output wire [16:0] iteration_3,
  output wire [16:0] iteration_4,
  output wire [16:0] iteration_5,
  output wire [16:0] iteration_6,
  output wire [16:0] iteration_7,

  input wire [23:0] sys_ts
  );

parameter timeout_ticks = 72000; //~1ms in a 72MHz clock frequency

localparam  WAITING_FOR_DATA = 0;
localparam  POLYNOMIAL_IDENTIFICATION = 1;
localparam  FIRST_OFFSET_IDENTIFICATION = 2;
localparam  WAITING_FOR_LAST_DATA = 3;
localparam  OFFSET_IDENTIFICATION = 4;
localparam  DATA_READY = 5;
localparam  WAIT_FOR_ALL_RAM_DUMP = 6;
localparam  ERROR_OR_RESET = 7;

reg [3:0] state;

reg [23:0] ts_third_data, ts_fourth_data;
reg [3:0] first_sensor, second_sensor, third_sensor, fourth_sensor;

reg [7:0] avl_blocks_nb [7:0];
reg [7:0] avl_blocks_nb_first, avl_blocks_nb_second;

always @ (posedge clk_72MHz) begin
  avl_blocks_nb[0] <= avl_blocks_nb_0;
  avl_blocks_nb[1] <= avl_blocks_nb_1;
  avl_blocks_nb[2] <= avl_blocks_nb_2;
  avl_blocks_nb[3] <= avl_blocks_nb_3;
  avl_blocks_nb[4] <= avl_blocks_nb_4;
  avl_blocks_nb[5] <= avl_blocks_nb_5;
  avl_blocks_nb[6] <= avl_blocks_nb_6;
  avl_blocks_nb[7] <= avl_blocks_nb_7;
  avl_blocks_nb_first <= avl_blocks_nb[first_sensor];
  avl_blocks_nb_second <= avl_blocks_nb[second_sensor];
end

reg [40:0] block_wanted [7:0];
reg [40:0] block_wanted_first, block_wanted_second;

always @ (posedge clk_72MHz) begin
  block_wanted[0] <= block_wanted_0;
  block_wanted[1] <= block_wanted_1;
  block_wanted[2] <= block_wanted_2;
  block_wanted[3] <= block_wanted_3;
  block_wanted[4] <= block_wanted_4;
  block_wanted[5] <= block_wanted_5;
  block_wanted[6] <= block_wanted_6;
  block_wanted[7] <= block_wanted_7;
  block_wanted_first <= block_wanted[first_sensor];
  block_wanted_second <= block_wanted[second_sensor];
end

reg [7:0] ram_data_ready;
reg ram_data_ready_first, ram_data_ready_second;

always @ (posedge clk_72MHz) begin
  ram_data_ready[0] <= data_ready_0;
  ram_data_ready[1] <= data_ready_1;
  ram_data_ready[2] <= data_ready_2;
  ram_data_ready[3] <= data_ready_3;
  ram_data_ready[4] <= data_ready_4;
  ram_data_ready[5] <= data_ready_5;
  ram_data_ready[6] <= data_ready_6;
  ram_data_ready[7] <= data_ready_7;
  ram_data_ready_first <= ram_data_ready[first_sensor];
  ram_data_ready_second <= ram_data_ready[second_sensor];
end

reg [7:0] block_wanted_nb [7:0];
wire [7:0] poly_mana_block_wanted_nb_0;
wire [7:0] poly_mana_block_wanted_nb_1;

always @ (posedge clk_72MHz) begin
  if (enable_polynomial_manager) begin
      block_wanted_nb[first_sensor] <= poly_mana_block_wanted_nb_0;
      block_wanted_nb[second_sensor] <= poly_mana_block_wanted_nb_1;
  end else begin
    block_wanted_nb[0] <= 0;
    block_wanted_nb[1] <= 0;
    block_wanted_nb[2] <= 0;
    block_wanted_nb[3] <= 0;
    block_wanted_nb[4] <= 0;
    block_wanted_nb[5] <= 0;
    block_wanted_nb[6] <= 0;
    block_wanted_nb[7] <= 0;
  end
  block_wanted_number_0 <= block_wanted_nb[0];
  block_wanted_number_1 <= block_wanted_nb[1];
  block_wanted_number_2 <= block_wanted_nb[2];
  block_wanted_number_3 <= block_wanted_nb[3];
  block_wanted_number_4 <= block_wanted_nb[4];
  block_wanted_number_5 <= block_wanted_nb[5];
  block_wanted_number_6 <= block_wanted_nb[6];
  block_wanted_number_7 <= block_wanted_nb[7];
end

reg enable_polynomial_manager;
wire [16:0] iteration_between_first_second;
wire polynomial_manager_ready;
reg wait_for_module_activation;
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

reg [7:0] avl_block, avl_block_recovered;
reg [2:0] last_changed;
reg reset_needed;

always @ (posedge clk_72MHz) begin
  if (reset_done) begin
    avl_block <= 0;
    last_changed <= 0;
  end else if ((|avl_blocks_nb[0]) && avl_block[0]==0) begin
    avl_block[0] <= 1;
    last_changed <= 0;
  end else if ((|avl_blocks_nb[1]) && avl_block[1]==0) begin
    avl_block[1] <= 1;
    last_changed <= 1;
  end else if ((|avl_blocks_nb[2]) && avl_block[2]==0) begin
    avl_block[2] <= 1;
    last_changed <= 2;
  end else if ((|avl_blocks_nb[3]) && avl_block[3]==0) begin
    avl_block[3] <= 1;
    last_changed <= 3;
  end else if ((|avl_blocks_nb[4]) && avl_block[4]==0) begin
    avl_block[4] <= 1;
    last_changed <= 4;
  end else if ((|avl_blocks_nb[5]) && avl_block[5]==0) begin
    avl_block[5] <= 1;
    last_changed <= 5;
  end else if ((|avl_blocks_nb[6]) && avl_block[6]==0) begin
    avl_block[6] <= 1;
    last_changed <= 6;
  end else if ((|avl_blocks_nb[7]) && avl_block[7]==0) begin
    avl_block[7] <= 1;
    last_changed <= 7;
  end
end

reg processing;
reg [4:0] sensor_nb_recovered;

always @ (posedge clk_72MHz) begin
  if (reset_done) begin
    avl_block_recovered <= 0;
    sensor_nb_recovered <= 0;
    first_sensor <= 0;
    second_sensor <= 0;
    third_sensor <= 0;
    fourth_sensor <= 0;
    ts_third_data <= 0;
    ts_fourth_data <= 0;
  end else if ( |(avl_block ^ avl_block_recovered) ) begin
    avl_block_recovered[last_changed] <= 1;
    sensor_nb_recovered <= sensor_nb_recovered + 1;
    case (sensor_nb_recovered)
      0: begin
        first_sensor <= last_changed;
      end
      1: begin
        second_sensor <= last_changed;
      end
      2: begin
        third_sensor <= last_changed;
        ts_third_data <= sys_ts;
      end
      3: begin
        fourth_sensor <= last_changed;
        ts_fourth_data <= sys_ts;
      end
      default: ;
    endcase
  end
end

reg [4:0] previous_sensor_nb_recovered;

always @ (posedge clk_72MHz) begin
  previous_sensor_nb_recovered <= sensor_nb_recovered;
end

reg all_ram_dump, previous_all_ram_dump;
reg [7:0] all_ram_dump_reg;
reg reset_done;
reg [16:0] offset_second_pulse, offset_third_pulse, offset_fourth_pulse;

always @ (posedge clk_72MHz) begin
  all_ram_dump_reg[0] <= |avl_blocks_nb[0];
  all_ram_dump_reg[1] <= |avl_blocks_nb[1];
  all_ram_dump_reg[2] <= |avl_blocks_nb[2];
  all_ram_dump_reg[3] <= |avl_blocks_nb[3];
  all_ram_dump_reg[4] <= |avl_blocks_nb[4];
  all_ram_dump_reg[5] <= |avl_blocks_nb[5];
  all_ram_dump_reg[6] <= |avl_blocks_nb[6];
  all_ram_dump_reg[7] <= |avl_blocks_nb[7];
  all_ram_dump <= !(|all_ram_dump_reg);
  previous_all_ram_dump <= all_ram_dump;
  if (reset_done) begin
    reset_needed <= 0;
  end else if (previous_all_ram_dump == 0 && all_ram_dump == 1) begin
    reset_needed <= 1;
  end
end

initial begin
  processing = 0;
  reset_needed = 1;
  wait_for_module_activation = 0;
  state = ERROR_OR_RESET;
  avl_block = 0;
  avl_block_recovered = 0;
end

reg [16:0] iteration_buffer [7:0];
assign iteration_0 = iteration_buffer[0];
assign iteration_1 = iteration_buffer[1];
assign iteration_2 = iteration_buffer[2];
assign iteration_3 = iteration_buffer[3];
assign iteration_4 = iteration_buffer[4];
assign iteration_5 = iteration_buffer[5];
assign iteration_6 = iteration_buffer[6];
assign iteration_7 = iteration_buffer[7];

always @ (posedge clk_72MHz) begin
  case (state)
    WAITING_FOR_DATA: begin
      reset_done <= 0;
      if (sensor_nb_recovered == 2 && previous_sensor_nb_recovered == 1) begin
        state <= POLYNOMIAL_IDENTIFICATION;
        processing <= 1;
      end else if (reset_needed) begin
        state <= ERROR_OR_RESET;
      end
    end

    POLYNOMIAL_IDENTIFICATION: begin
      enable_polynomial_manager <= 1;
      if (polynomial_manager_ready == 1) begin
        if (wait_for_module_activation) begin
        end else if (polynomial == 0) begin
          state <= WAIT_FOR_ALL_RAM_DUMP;
          processing <= 0;
        end else begin
          state <= FIRST_OFFSET_IDENTIFICATION;
          wait_for_module_activation <= 1;
        end
      end else if (wait_for_module_activation == 1 && polynomial_manager_ready == 0) begin
        wait_for_module_activation <= 0;
      end
    end

    FIRST_OFFSET_IDENTIFICATION: begin
      offset_finder_enable <= 1;
      if (offset_finder_ready == 1) begin
        if (wait_for_module_activation) begin
        end else if (offset_first_pulse != 0) begin
          state <= WAITING_FOR_LAST_DATA;
        end else begin
          state <= WAIT_FOR_ALL_RAM_DUMP;
          processing <= 0;
        end
      end else if (wait_for_module_activation == 1 && offset_finder_ready == 0) begin
        wait_for_module_activation <= 0;
      end
    end

    WAITING_FOR_LAST_DATA: begin
      if (sensor_nb_recovered > 3 || reset_needed) begin
        state <= OFFSET_IDENTIFICATION;
      end
    end

    OFFSET_IDENTIFICATION: begin
      iteration_buffer[first_sensor] <= offset_first_pulse;
      iteration_buffer[second_sensor] <= offset_first_pulse + iteration_between_first_second;
      if (ts_third_data != 0) begin
        if (ts_first_data < ts_third_data) begin
          iteration_buffer[third_sensor] <= offset_first_pulse + ( (ts_third_data - ts_first_data) >> 4 );
        end else begin
          iteration_buffer[third_sensor] <= offset_first_pulse + ( (24'hffffff - ts_first_data + ts_third_data) >> 4 );
        end
      end
      if (ts_fourth_data != 0) begin
        if (ts_first_data < ts_fourth_data) begin
          iteration_buffer[fourth_sensor] <= offset_first_pulse + ( (ts_fourth_data - ts_first_data) >> 4 );
        end else begin
          iteration_buffer[fourth_sensor] <= offset_first_pulse + ( (24'hffffff - ts_first_data + ts_fourth_data) >> 4 );
        end
      end
      state <= DATA_READY;
    end

    DATA_READY: begin
      processing <= 0;
      ready <= 1;
      if (reset == 1) begin
        ready <= 0;
        state <= WAIT_FOR_ALL_RAM_DUMP;
      end
    end

    WAIT_FOR_ALL_RAM_DUMP: begin
      if (reset_needed) begin
        state <= ERROR_OR_RESET;
      end
    end

    ERROR_OR_RESET: begin
      reset_done <= 1;
      offset_finder_enable <= 0;
      enable_polynomial_manager <= 0;
      iteration_buffer[0] <= 0;
      iteration_buffer[1] <= 0;
      iteration_buffer[2] <= 0;
      iteration_buffer[3] <= 0;
      iteration_buffer[4] <= 0;
      iteration_buffer[5] <= 0;
      iteration_buffer[6] <= 0;
      iteration_buffer[7] <= 0;
      wait_for_module_activation <= 1;
      if (reset_needed == 0) begin
        state <= WAITING_FOR_DATA;
      end
    end

    default: ;
  endcase
end

endmodule // pulse_identifier
