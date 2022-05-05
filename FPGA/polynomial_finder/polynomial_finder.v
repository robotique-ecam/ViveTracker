`default_nettype none

module polynomial_finder (
  input wire clk_72MHz,
  input wire [23:0] ts_last_data,
  input wire [23:0] ts_last_data1,
  input wire [16:0] decoded_data,
  input wire [16:0] decoded_data1,
  input wire enable,

  output reg [16:0] polynomial,
  output reg [16:0] iteration_number,
  output reg ready
  );

parameter iteration_approx = 2;
parameter lfsr_loading_cycle = 4;

localparam  IDLE = 0;
localparam  ESTIMATE_ITERATION = 1;
localparam  RUN_LFSR = 2;
localparam  IDENTIFY_POLYNOMIAL = 3;
localparam  WAIT_FOR_RESET = 4;

reg [2:0] state = IDLE;

reg enable_LFSRs = 0;

reg [1:0] timer_loading_cycle = 0;

wire [16:0] value_1D258, value_17E04;
wire [16:0] iteration_number_1D258, iteration_number_17E04;

lfsr lfsr1(
  .clk_72MHz (clk_72MHz),
  .polynomial (17'h1d258),
  .start_data (decoded_data),
  .enable (enable_LFSRs),
  .value (value_1D258),
  .iteration_number (iteration_number_1D258)
  );

lfsr lfsr2(
  .clk_72MHz (clk_72MHz),
  .polynomial (17'h17e04),
  .start_data (decoded_data),
  .enable (enable_LFSRs),
  .value (value_17E04),
  .iteration_number (iteration_number_17E04)
  );

reg [16:0] estimated_iteration; //17 bits is for security but it's way to much

always @ (posedge clk_72MHz) begin
  if (enable_LFSRs && !(&timer_loading_cycle)) begin
    timer_loading_cycle <= timer_loading_cycle + 1;
  end else if (!enable_LFSRs) begin
    timer_loading_cycle <= 0;
  end
end

always @ (posedge clk_72MHz) begin
  case (state)
    IDLE: begin
      if (enable == 1) begin
        ready <= 0;
        state <= ESTIMATE_ITERATION;
      end else begin
        ready <= 1;
        polynomial <= 0;
        iteration_number <= 0;
      end
    end

    ESTIMATE_ITERATION: begin
      if (decoded_data == decoded_data1 || ts_last_data == ts_last_data1) begin
        state <= WAIT_FOR_RESET;
      end else begin
        if (ts_last_data < ts_last_data1) begin
          estimated_iteration <= (ts_last_data1-ts_last_data)>>4;
        end else begin
          estimated_iteration <= (24'hffffff - ts_last_data + ts_last_data1)>>4;
        end
        state <= RUN_LFSR;
      end
    end

    RUN_LFSR: begin
      enable_LFSRs <= 1;
      if (~enable) begin
        state <= WAIT_FOR_RESET;
      end else if (iteration_number_1D258 > (estimated_iteration - iteration_approx - 1) && &timer_loading_cycle) begin
        state <= IDENTIFY_POLYNOMIAL;
      end
    end

    IDENTIFY_POLYNOMIAL: begin
      if (~enable) begin
        enable_LFSRs <= 0;
        state <= WAIT_FOR_RESET;
      end else if (value_1D258 == decoded_data1) begin
        polynomial <= 17'h1d258;
        iteration_number <= iteration_number_1D258;
        enable_LFSRs <= 0;
        state <= WAIT_FOR_RESET;
      end else if (value_17E04 == decoded_data1) begin
        polynomial <= 17'h17e04;
        iteration_number <= iteration_number_17E04;
        enable_LFSRs <= 0;
        state <= WAIT_FOR_RESET;
      end else if (iteration_number_1D258 > (estimated_iteration + iteration_approx) ) begin
        enable_LFSRs <= 0;
        state <= WAIT_FOR_RESET;
      end
    end

    WAIT_FOR_RESET: begin
      if (enable == 0) begin
        state <= IDLE;
      end else begin
        ready <= 1;
      end
    end

    default: ;
  endcase
end

endmodule // polynomial_finder
