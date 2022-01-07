`default_nettype none

module data_parser (
  input wire clk_72MHz,
  input wire [67:0] triad_data,
  input wire triad_data_avl,
  input wire reset_parser,
  output reg [101:0] sensor_iterations,
  output reg sensor_data_avl,
  output reg reset_pulse_identifier
  );

parameter min_diff_between_iteration = 7500;

localparam  WAIT_FOR_DATA = 0;
localparam  IS_VALID = 1;
localparam  STORE = 2;
localparam  PARSE = 3;
localparam  DATA_AVAILIBLE = 4;
localparam  WAIT_FOR_PULSE_IDENTIFIER_RESET = 5;

initial begin
  state = WAIT_FOR_DATA;
  sensor_iterations = 0;
  reset_pulse_identifier = 0;
  stored_triad_data = 0;
  sensor_data_avl = 0;
end

reg [2:0] state;
reg [67:0] stored_triad_data;
reg reset_parser_reg;

always @ (posedge clk_72MHz) begin
  reset_parser_reg <= reset_parser;
end

always @ (posedge clk_72MHz) begin
  case (state)
    WAIT_FOR_DATA: begin
      if (triad_data_avl) begin
        state <= IS_VALID;
      end
    end

    IS_VALID: begin
      if (stored_triad_data == 0) begin
        state <= STORE;
      end else if (triad_data[16:0] == stored_triad_data[16:0] &&
        stored_triad_data[33:17] + min_diff_between_iteration < triad_data[33:17] &&
        stored_triad_data[50:34] + min_diff_between_iteration < triad_data[50:34] &&
        stored_triad_data[67:51] + min_diff_between_iteration < triad_data[67:51] ) begin
        state <= PARSE;
      end else if (triad_data[16:0] != stored_triad_data[16:0]) begin
        state <= STORE;
      end else begin
        state <= WAIT_FOR_PULSE_IDENTIFIER_RESET;
      end
    end

    STORE: begin
      stored_triad_data <= triad_data;
      state <= WAIT_FOR_PULSE_IDENTIFIER_RESET;
    end

    PARSE: begin
      sensor_iterations <= {stored_triad_data[33:17], triad_data[33:17],
        stored_triad_data[50:34], triad_data[50:34],
        stored_triad_data[67:51], triad_data[67:51] };
      state <= DATA_AVAILIBLE;
    end

    DATA_AVAILIBLE: begin
      stored_triad_data <= 0;
      if (reset_parser_reg) begin
        sensor_data_avl <= 0;
        state <= WAIT_FOR_PULSE_IDENTIFIER_RESET;
      end else begin
        sensor_data_avl <= 1;
      end
    end

    WAIT_FOR_PULSE_IDENTIFIER_RESET: begin
      if (~triad_data_avl) begin
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
