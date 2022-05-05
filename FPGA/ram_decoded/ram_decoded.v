`default_nettype none

module ram_decoded (
  input wire clk_96MHz,
  input wire [16:0] decoded_data,
  input wire [23:0] ts_decoded_data,
  input wire decoded_data_avl,
  input wire [7:0] block_wanted_number,

  output reg [40:0] block_wanted,
  output reg data_ready,
  output reg reset_bmc_decoder,
  output reg [7:0] avl_blocks_nb
  );

parameter dump_ticks = 96000; //1ms in a 96MHz clock
parameter max_block_nb = 20;

reg [40:0] ram [max_block_nb-1:0]; //max_block_nb blocks of 41 bits

// first machine: storing data

localparam  IDLE1 = 0;
localparam  RESET_BMC_DECODER = 1;
localparam  STORE = 2;
localparam  WAIT_FOR_DUMP = 3;
localparam  DUMP = 4;

initial begin
  state_1 = IDLE1;
  block_to_store = 0;
  ena_counter = 0;
  counter = 0;
  state_2 = IDLE2;
  block_wanted = 0;
  data_ready = 0;
  reset_bmc_decoder = 0;
  avl_blocks_nb = 0;
end

reg [2:0] state_1 = IDLE1;
reg [40:0] block_to_store;
reg ena_counter;
reg [16:0] counter;

always @ (posedge clk_96MHz) begin
  if (ena_counter) begin
    counter <= counter + 1;
  end else begin
    counter <= 0;
  end
end

always @ (posedge clk_96MHz) begin
  case (state_1)

    IDLE1: begin
      if (decoded_data_avl) begin
        state_1 <= RESET_BMC_DECODER;
        ena_counter <= 1;
      end
      avl_blocks_nb = 0;
    end

    RESET_BMC_DECODER: begin
      block_to_store <= {decoded_data, ts_decoded_data};
      reset_bmc_decoder <= 1;
      state_1 <= STORE;
    end

    STORE: begin
      if (avl_blocks_nb < max_block_nb) begin
        ram[avl_blocks_nb] <= block_to_store;
        avl_blocks_nb <= avl_blocks_nb + 1;
      end
      state_1 <= WAIT_FOR_DUMP;
    end

    WAIT_FOR_DUMP: begin
      if (decoded_data_avl) begin
        state_1 <= RESET_BMC_DECODER;
      end else if (counter >= dump_ticks) begin
        state_1 <= DUMP;
      end
      reset_bmc_decoder <= 0;
    end

    DUMP: begin
      ena_counter <= 0;
      avl_blocks_nb <= 0;
      state_1 <= IDLE1;
    end
  endcase
end

//second machine: getting data

localparam  IDLE2 = 0;
localparam  FETCHING_DATA = 1;
localparam  DATA_READY = 2;

reg [1:0] state_2;

always @ (posedge clk_96MHz) begin
  case (state_2)
    IDLE2: begin
      if (block_wanted_number != 0) begin
        state_2 <= FETCHING_DATA;
      end
    end

    FETCHING_DATA: begin
      block_wanted <= ram[block_wanted_number - 1];
      state_2 <= DATA_READY;
    end

    DATA_READY: begin
      if (block_wanted_number != 0) begin
        data_ready <= 1;
      end else begin
        data_ready <= 0;
        state_2 <= IDLE2;
      end
    end
  endcase
end

endmodule // ram_decoded
