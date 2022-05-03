`default_nettype none

module data_parser (
  input wire clk_72MHz,
  input wire pulse_identifier_ready,
  input wire [16:0] iteration_0,
  input wire [16:0] iteration_1,
  input wire [16:0] iteration_2,
  input wire [16:0] iteration_3,
  input wire [16:0] iteration_4,
  input wire [16:0] iteration_5,
  input wire [16:0] iteration_6,
  input wire [16:0] iteration_7,
  input wire [16:0] polynomial,
  input wire reset_parser,
  output reg [271:0] sensor_iterations,
  output reg sensor_data_avl,
  output reg reset_pulse_identifier
  );

parameter min_diff_between_iteration = 7500;
parameter half_iteration_nb = 60000;

localparam  WAIT_FOR_DATA = 0;
localparam  IS_VALID = 1;
localparam  CHECK_0 = 2;
localparam  CHECK_1 = 3;
localparam  CHECK_2 = 4;
localparam  CHECK_3 = 5;
localparam  CHECK_4 = 6;
localparam  CHECK_5 = 7;
localparam  CHECK_6 = 8;
localparam  CHECK_7 = 9;
localparam  CHECK_NO_PASS = 10;
localparam  STORE = 11;
localparam  PARSE = 12;
localparam  DATA_AVAILIBLE = 13;
localparam  WAIT_FOR_PULSE_IDENTIFIER_RESET = 14;

initial begin
  state = WAIT_FOR_DATA;
  sensor_iterations = 0;
  reset_pulse_identifier = 0;
  stored_triad_data = 0;
  stored_octo_data = 0;
  sensor_data_avl = 0;
end

reg [3:0] state;
reg [67:0] stored_triad_data;
reg reset_parser_reg;
reg stored_octo_data;

reg [16:0] stored_iteration_0;
reg [16:0] stored_iteration_1;
reg [16:0] stored_iteration_2;
reg [16:0] stored_iteration_3;
reg [16:0] stored_iteration_4;
reg [16:0] stored_iteration_5;
reg [16:0] stored_iteration_6;
reg [16:0] stored_iteration_7;
reg [16:0] stored_polynomial;

always @ (posedge clk_72MHz) begin
  reset_parser_reg <= reset_parser;
end

always @ (posedge clk_72MHz) begin
  case (state)
    WAIT_FOR_DATA: begin
      if (pulse_identifier_ready) begin
        state <= IS_VALID;
      end
    end

    IS_VALID: begin
      if (stored_octo_data == 0) begin
        state <= STORE;
      end else if (stored_polynomial == polynomial) begin
        state <= CHECK_0;
      end else begin
        state <= STORE;
      end
    end

    CHECK_0: begin
      if (stored_iteration_0 == 0 && iteration_0 == 0) begin
        state <= CHECK_1;
      end else if (stored_iteration_0 + min_diff_between_iteration < iteration_0) begin
        state <= CHECK_1;
      end else if (iteration_0 > half_iteration_nb) begin
        state <= CHECK_NO_PASS;
      end else begin
        state <= WAIT_FOR_PULSE_IDENTIFIER_RESET;
      end
    end

    CHECK_1: begin
      if (stored_iteration_1 == 0 && iteration_1 == 0) begin
        state <= CHECK_2;
      end else if (stored_iteration_1 + min_diff_between_iteration < iteration_1) begin
        state <= CHECK_2;
      end else if (iteration_1 > half_iteration_nb) begin
        state <= CHECK_NO_PASS;
      end else begin
        state <= WAIT_FOR_PULSE_IDENTIFIER_RESET;
      end
    end

    CHECK_2: begin
      if (stored_iteration_2 == 0 && iteration_2 == 0) begin
        state <= CHECK_3;
      end else if (stored_iteration_2 + min_diff_between_iteration < iteration_2) begin
        state <= CHECK_3;
      end else if (iteration_2 > half_iteration_nb) begin
        state <= CHECK_NO_PASS;
      end else begin
        state <= WAIT_FOR_PULSE_IDENTIFIER_RESET;
      end
    end

    CHECK_3: begin
      if (stored_iteration_3 == 0 && iteration_3 == 0) begin
        state <= CHECK_4;
      end else if (stored_iteration_3 + min_diff_between_iteration < iteration_3) begin
        state <= CHECK_4;
      end else if (iteration_3 > half_iteration_nb) begin
        state <= CHECK_NO_PASS;
      end else begin
        state <= WAIT_FOR_PULSE_IDENTIFIER_RESET;
      end
    end

    CHECK_4: begin
      if (stored_iteration_4 == 0 && iteration_4 == 0) begin
        state <= CHECK_5;
      end else if (stored_iteration_4 + min_diff_between_iteration < iteration_4) begin
        state <= CHECK_5;
      end else if (iteration_4 > half_iteration_nb) begin
        state <= CHECK_NO_PASS;
      end else begin
        state <= WAIT_FOR_PULSE_IDENTIFIER_RESET;
      end
    end

    CHECK_5: begin
      if (stored_iteration_5 == 0 && iteration_5 == 0) begin
        state <= CHECK_6;
      end else if (stored_iteration_5 + min_diff_between_iteration < iteration_5) begin
        state <= CHECK_6;
      end else if (iteration_5 > half_iteration_nb) begin
        state <= CHECK_NO_PASS;
      end else begin
        state <= WAIT_FOR_PULSE_IDENTIFIER_RESET;
      end
    end

    CHECK_6: begin
      if (stored_iteration_6 == 0 && iteration_6 == 0) begin
        state <= CHECK_7;
      end else if (stored_iteration_6 + min_diff_between_iteration < iteration_6) begin
        state <= CHECK_7;
      end else if (iteration_6 > half_iteration_nb) begin
        state <= CHECK_NO_PASS;
      end else begin
        state <= WAIT_FOR_PULSE_IDENTIFIER_RESET;
      end
    end

    CHECK_7: begin
      if (stored_iteration_7 == 0 && iteration_7 == 0) begin
        state <= PARSE;
      end else if (stored_iteration_7 + min_diff_between_iteration < iteration_7) begin
        state <= PARSE;
      end else if (iteration_7 > half_iteration_nb) begin
        state <= CHECK_NO_PASS;
      end else begin
        state <= WAIT_FOR_PULSE_IDENTIFIER_RESET;
      end
    end

    CHECK_NO_PASS: begin
      stored_octo_data <= 0;
      state <= WAIT_FOR_PULSE_IDENTIFIER_RESET;
    end

    STORE: begin
      stored_octo_data <= 1;
      stored_iteration_0 <= iteration_0;
      stored_iteration_1 <= iteration_1;
      stored_iteration_2 <= iteration_2;
      stored_iteration_3 <= iteration_3;
      stored_iteration_4 <= iteration_4;
      stored_iteration_5 <= iteration_5;
      stored_iteration_6 <= iteration_6;
      stored_iteration_7 <= iteration_7;
      stored_polynomial <= polynomial;
      state <= WAIT_FOR_PULSE_IDENTIFIER_RESET;
    end

    PARSE: begin
      sensor_iterations <= {stored_iteration_0, iteration_0,
        stored_iteration_1, iteration_1,
        stored_iteration_2, iteration_2,
        stored_iteration_3, iteration_3,
        stored_iteration_4, iteration_4,
        stored_iteration_5, iteration_5,
        stored_iteration_6, iteration_6,
        stored_iteration_7, iteration_7 };
      state <= DATA_AVAILIBLE;
    end

    DATA_AVAILIBLE: begin
      stored_octo_data <= 0;
      if (reset_parser_reg) begin
        sensor_data_avl <= 0;
        state <= WAIT_FOR_PULSE_IDENTIFIER_RESET;
      end else begin
        sensor_data_avl <= 1;
      end
    end

    WAIT_FOR_PULSE_IDENTIFIER_RESET: begin
      if (~pulse_identifier_ready) begin
        reset_pulse_identifier <= 0;
        state <= WAIT_FOR_DATA;
      end else begin
        reset_pulse_identifier <= 1;
      end
    end

    default: ;
  endcase
end

endmodule // data_parser
