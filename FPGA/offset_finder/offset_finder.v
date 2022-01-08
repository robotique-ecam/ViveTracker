`default_nettype none
`include "../lfsr/lfsr.v"

module offset_finder (
  input wire clk_72MHz,
  input wire [16:0] polynomial,
  input wire [16:0] data,
  input wire enable,

  output reg [16:0] offset,
  output reg ready
  );

parameter iteration_timeout = 29970; //=( lfsr_frequency(6e6)/moteur_frequency(48e6/959e3) ) / 4


localparam  IDLE = 0;
localparam  LOAD = 1;
localparam  RUN = 2;
localparam  DATA_READY = 3;

reg [1:0] state = IDLE;

reg [16:0] start_data_1;
reg [16:0] start_data_2;
reg [16:0] start_data_3;

wire [16:0] value_LFSR_0;
wire [16:0] value_LFSR_1;
wire [16:0] value_LFSR_2;
wire [16:0] value_LFSR_3;

wire [16:0] iteration_number_0;
wire [16:0] iteration_number_1;
wire [16:0] iteration_number_2;
wire [16:0] iteration_number_3;

reg enable_LFSRs = 0;

lfsr LFSR_0 (
  .clk_72MHz (clk_72MHz),
  .polynomial (polynomial),
  .start_data (17'h1),
  .enable (enable_LFSRs),
  .value (value_LFSR_0),
  .iteration_number (iteration_number_0)
  );

lfsr LFSR_1 (
  .clk_72MHz (clk_72MHz),
  .polynomial (polynomial),
  .start_data (start_data_1),
  .enable (enable_LFSRs),
  .value (value_LFSR_1),
  .iteration_number (iteration_number_1)
  );

lfsr LFSR_2 (
  .clk_72MHz (clk_72MHz),
  .polynomial (polynomial),
  .start_data (start_data_2),
  .enable (enable_LFSRs),
  .value (value_LFSR_2),
  .iteration_number (iteration_number_2)
  );

lfsr LFSR_3 (
  .clk_72MHz (clk_72MHz),
  .polynomial (polynomial),
  .start_data (start_data_3),
  .enable (enable_LFSRs),
  .value (value_LFSR_3),
  .iteration_number (iteration_number_3)
  );


always @ (posedge clk_72MHz) begin
  case (state)
    IDLE: begin
      if (enable == 1) begin
        ready <= 0;
        state <= LOAD;
      end else begin
        ready <= 1;
      end
    end

    LOAD: begin
      if (polynomial == 17'h1d258) begin
        start_data_1 <= 17'he844;
        start_data_2 <= 17'h1f555;
        start_data_3 <= 17'h13786;
      end else begin
        start_data_1 <= 17'h14e50;
        start_data_2 <= 17'h1e295;
        start_data_3 <= 17'h8c4b;
      end
      state <= RUN;
    end

    RUN: begin
      enable_LFSRs <= 1;
      if (value_LFSR_0 == data) begin
        offset <= iteration_number_0;
        state <= DATA_READY;
      end else if (value_LFSR_1 == data) begin
        offset <= iteration_number_1 + iteration_timeout;
        state <= DATA_READY;
      end else if (value_LFSR_2 == data) begin
        offset <= iteration_number_2 + iteration_timeout * 2;
        state <= DATA_READY;
      end else if (value_LFSR_3 == data) begin
        offset <= iteration_number_3 + iteration_timeout * 3;
        state <= DATA_READY;
      end else if (iteration_number_0 == iteration_timeout) begin
        offset <= 0;
        state <= DATA_READY;
      end
    end

    DATA_READY: begin
      enable_LFSRs <= 0;
      ready <= 1;
      if (enable == 0) begin
        state <= IDLE;
      end
    end

    default: ;
  endcase
end

endmodule // offset_finder
