`default_nettype none

`include "../polynomial_finder/polynomial_finder.v"

module polynomial_manager (
  input wire clk_72MHz,
  input wire [40:0] ram_block_wanted_0,
  input wire [40:0] ram_block_wanted_1,
  input wire ram_data_ready_0,
  input wire ram_data_ready_1,
  input wire [7:0] avl_blocks_nb_0,
  input wire [7:0] avl_blocks_nb_1,
  input wire enable,

  output reg [7:0] block_wanted_number_0,
  output reg [7:0] block_wanted_number_1,
  output reg [16:0] polynomial,
  output reg [16:0] iteration_number,
  output reg [16:0] first_data,
  output reg [23:0] ts_first_data,
  output reg ready
  );

parameter init_array_file = "../polynomial_manager/init_array.list";
parameter init_array_file_1 = "../polynomial_manager/init_array1.list";
parameter wait_for_ticks = 7;
parameter timeout_ticks = 72000; // 1ms

reg [2:0] wait_for_counter = 0;
reg [16:0] timeout_counter = 0;
reg ena_timeout_counter = 0;

localparam  IDLE = 0;
localparam  HOW_MANY_TO_FETCH = 1;
localparam  WHAT_TO_FETCH = 2;
localparam  WAIT_FOR_DATA_READY = 3;
localparam  FETCHING_DATA = 4;
localparam  ACTIVATE_POLYNOMIAL_FINDERS = 5;
localparam  RUN_POLYNOMIAL_FINDERS = 6;
localparam  WAIT_FOR_RESET = 7;

initial begin
  block_wanted_number_0 = 0;
  block_wanted_number_1 = 0;
end

reg [2:0] state = IDLE;

reg [16:0] decoded_data_0 [0:3];
reg [23:0] ts_decoded_data_0 [0:3];
reg [16:0] decoded_data_1 [0:3];
reg [23:0] ts_decoded_data_1 [0:3];

reg enable_polynomial_finders = 0;
reg [7:0] nb_of_fetched_blocks = 0;
reg [7:0] block_nb_to_fetch = 0;
reg [7:0] smallest_blocks_avl = 0;
reg [1:0] blocks_fetched_this_try = 0;
reg [1:0] retrieved_poly_index = 0;


reg [16:0] polynomials [3:0];
reg [16:0] iteration_numbers [3:0];
reg [3:0] polynomial_finders_ready;

reg [23:0] ts_decoded_data_0_0;
reg [23:0] ts_decoded_data_1_0;
reg [16:0] decoded_data_0_0;
reg [16:0] decoded_data_1_0;
wire [16:0] polynomial_0;
wire [16:0] iteration_number_0;
wire polynomial_finder_ready_0;

always @ (posedge clk_72MHz) begin
  ts_decoded_data_0_0 <= ts_decoded_data_0[0];
  ts_decoded_data_1_0 <= ts_decoded_data_1[0];
  decoded_data_0_0 <= decoded_data_0[0];
  decoded_data_1_0 <= decoded_data_1[0];
  polynomials[0] <= polynomial_0;
  iteration_numbers[0] <= iteration_number_0;
  polynomial_finders_ready[0] <= polynomial_finder_ready_0;
end

polynomial_finder POLY_FINDERS0 (
  .clk_72MHz (clk_72MHz),
  .ts_last_data (ts_decoded_data_0_0),
  .ts_last_data1 (ts_decoded_data_1_0),
  .decoded_data (decoded_data_0_0),
  .decoded_data1 (decoded_data_1_0),
  .enable (enable_polynomial_finders),

  .polynomial (polynomial_0),
  .iteration_number (iteration_number_0),
  .ready (polynomial_finder_ready_0)
  );

wire [16:0] polynomial_1;
wire [16:0] iteration_number_1;
wire polynomial_finder_ready_1;

always @ (posedge clk_72MHz) begin
  polynomials[1] <= polynomial_1;
  iteration_numbers[1] <= iteration_number_1;
  polynomial_finders_ready[1] <= polynomial_finder_ready_1;
end

polynomial_finder POLY_FINDERS1 (
  .clk_72MHz (clk_72MHz),
  .ts_last_data (ts_decoded_data_0[1]),
  .ts_last_data1 (ts_decoded_data_1[1]),
  .decoded_data (decoded_data_0[1]),
  .decoded_data1 (decoded_data_1[1]),
  .enable (enable_polynomial_finders),

  .polynomial (polynomial_1),
  .iteration_number (iteration_number_1),
  .ready (polynomial_finder_ready_1)
);

wire [16:0] polynomial_2;
wire [16:0] iteration_number_2;
wire polynomial_finder_ready_2;

always @ (posedge clk_72MHz) begin
  polynomials[2] <= polynomial_2;
  iteration_numbers[2] <= iteration_number_2;
  polynomial_finders_ready[2] <= polynomial_finder_ready_2;
end

polynomial_finder POLY_FINDERS2 (
  .clk_72MHz (clk_72MHz),
  .ts_last_data (ts_decoded_data_0[2]),
  .ts_last_data1 (ts_decoded_data_1[2]),
  .decoded_data (decoded_data_0[2]),
  .decoded_data1 (decoded_data_1[2]),
  .enable (enable_polynomial_finders),

  .polynomial (polynomial_2),
  .iteration_number (iteration_number_2),
  .ready (polynomial_finder_ready_2)
);

wire [16:0] polynomial_3;
wire [16:0] iteration_number_3;
wire polynomial_finder_ready_3;

always @ (posedge clk_72MHz) begin
  polynomials[3] <= polynomial_3;
  iteration_numbers[3] <= iteration_number_3;
  polynomial_finders_ready[3] <= polynomial_finder_ready_3;
end

polynomial_finder POLY_FINDERS3 (
  .clk_72MHz (clk_72MHz),
  .ts_last_data (ts_decoded_data_0[3]),
  .ts_last_data1 (ts_decoded_data_1[3]),
  .decoded_data (decoded_data_0[3]),
  .decoded_data1 (decoded_data_1[3]),
  .enable (enable_polynomial_finders),

  .polynomial (polynomial_3),
  .iteration_number (iteration_number_3),
  .ready (polynomial_finder_ready_3)
  );

initial begin
  $readmemh(init_array_file, decoded_data_0);
  $readmemh(init_array_file, decoded_data_1);
  $readmemh(init_array_file, ts_decoded_data_0);
  $readmemh(init_array_file_1, ts_decoded_data_1);
end

always @ (posedge clk_72MHz) begin
  if (avl_blocks_nb_0 <= avl_blocks_nb_1) begin
    smallest_blocks_avl <= avl_blocks_nb_0;
  end else begin
    smallest_blocks_avl <= avl_blocks_nb_1;
  end
end

always @ (posedge clk_72MHz) begin
  if (ena_timeout_counter) begin
    timeout_counter <= timeout_counter + 1;
  end else begin
    timeout_counter <= 0;
  end
end

always @ (posedge clk_72MHz) begin
  case (state)

    IDLE: begin
      if (enable) begin
        ena_timeout_counter <= 1;
        ready <= 0;
        state <= HOW_MANY_TO_FETCH;
      end else begin
        ready <= 1;
        polynomial <= 0;
        iteration_number <= 0;
      end
    end

    HOW_MANY_TO_FETCH: begin
      blocks_fetched_this_try <= 0;
      if (nb_of_fetched_blocks >= smallest_blocks_avl) begin
        state <= WAIT_FOR_RESET;
      end else if (smallest_blocks_avl >= nb_of_fetched_blocks + 4) begin
        block_nb_to_fetch <= block_nb_to_fetch + 4;
        state <= WHAT_TO_FETCH;
      end else begin
        block_nb_to_fetch <= smallest_blocks_avl;
        state <= WHAT_TO_FETCH;
      end
    end

    WHAT_TO_FETCH: begin
      if (nb_of_fetched_blocks == block_nb_to_fetch) begin
        state <= ACTIVATE_POLYNOMIAL_FINDERS;
      end else if (nb_of_fetched_blocks < block_nb_to_fetch) begin
        nb_of_fetched_blocks <= nb_of_fetched_blocks + 1;
        state <= WAIT_FOR_DATA_READY;
      end
    end

    WAIT_FOR_DATA_READY: begin
      block_wanted_number_0 <= nb_of_fetched_blocks;
      block_wanted_number_1 <= nb_of_fetched_blocks;
      if (smallest_blocks_avl == 0) begin
        state <= WAIT_FOR_RESET;
      end else if (ram_data_ready_0 && ram_data_ready_1) begin
        if (wait_for_counter >= wait_for_ticks) begin
          wait_for_counter <= 0;
          state <= FETCHING_DATA;
        end else begin
          wait_for_counter <= wait_for_counter + 1;
        end
      end else begin
        wait_for_counter <= 0;
      end
    end

    FETCHING_DATA: begin
      if (smallest_blocks_avl == 0) begin
        state <= WAIT_FOR_RESET;
      end else begin
        decoded_data_0[blocks_fetched_this_try] <= ram_block_wanted_0[40:24];
        ts_decoded_data_0[blocks_fetched_this_try] <= ram_block_wanted_0[23:0];
        decoded_data_1[blocks_fetched_this_try] <= ram_block_wanted_1[40:24];
        ts_decoded_data_1[blocks_fetched_this_try] <= ram_block_wanted_1[23:0];
        blocks_fetched_this_try <= blocks_fetched_this_try + 1;
        block_wanted_number_0 <= 0;
        block_wanted_number_1 <= 0;
        state <= WHAT_TO_FETCH;
      end
    end

    ACTIVATE_POLYNOMIAL_FINDERS: begin
      enable_polynomial_finders <= 1;
      if (polynomial_finders_ready == 0) begin
        state <= RUN_POLYNOMIAL_FINDERS;
      end
    end

    RUN_POLYNOMIAL_FINDERS: begin
      if (polynomials[0] == 0 && polynomials[1] == 0 && polynomials[2] == 0 && polynomials[3] == 0
        && polynomial_finders_ready[0] && polynomial_finders_ready[1] && polynomial_finders_ready[2] && polynomial_finders_ready[3]) begin
        enable_polynomial_finders <= 0;
        state <= HOW_MANY_TO_FETCH;
      end else if (polynomials[0] != 0 && polynomial_finders_ready[0]) begin
        retrieved_poly_index <= 0;
        state <= WAIT_FOR_RESET;
      end else if (polynomials[1] != 0 && polynomial_finders_ready[1]) begin
        retrieved_poly_index <= 1;
        state <= WAIT_FOR_RESET;
      end else if (polynomials[2] != 0 && polynomial_finders_ready[2]) begin
        retrieved_poly_index <= 2;
        state <= WAIT_FOR_RESET;
      end else if (polynomials[3] != 0 && polynomial_finders_ready[3]) begin
        retrieved_poly_index <= 3;
        state <= WAIT_FOR_RESET;
      end else if (timeout_counter > timeout_ticks) begin
        state <= WAIT_FOR_RESET;
      end
    end

    WAIT_FOR_RESET: begin
      if (enable == 0) begin
        state <= IDLE;
        nb_of_fetched_blocks <= 0;
        block_nb_to_fetch <= 0;
        enable_polynomial_finders <= 0;
        blocks_fetched_this_try <= 0;
        $readmemh(init_array_file, decoded_data_0);
        $readmemh(init_array_file, decoded_data_1);
        $readmemh(init_array_file, ts_decoded_data_0);
        $readmemh(init_array_file_1, ts_decoded_data_1);
      end else begin
        ready <= 1;
        ena_timeout_counter <= 0;
        polynomial <= polynomials[retrieved_poly_index];
        iteration_number <= iteration_numbers[retrieved_poly_index];
        first_data <= decoded_data_0[retrieved_poly_index];
        ts_first_data <= ts_decoded_data_0[retrieved_poly_index];
      end
    end

    default: begin
      state <= IDLE;
    end
  endcase
end

endmodule // polynomial_manager
