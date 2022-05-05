`default_nettype none

module lfsr (
  input wire clk_72MHz,
  input wire [16:0] polynomial,
  input wire [16:0] start_data,
  input wire enable,

  output reg [16:0] value,
  output reg [16:0] iteration_number
  );

localparam  IDLE = 0;
localparam  LOAD = 1;
localparam  ITERATE = 2;

reg [1:0] state = IDLE;
reg binary_bit;

always @ (posedge clk_72MHz) begin
  case (state)
    IDLE: begin
      if (enable == 1) begin
        iteration_number <= 0;
        state <= LOAD;
      end
    end

    LOAD: begin
      value <= start_data;
      state <= ITERATE;
    end

    ITERATE: begin
      if (enable == 1) begin
        value <= {value, ^(value & polynomial)};
        iteration_number <= iteration_number + 1;
      end else begin
        state <= IDLE;
      end
    end

    default: ;
  endcase

end

endmodule // lfsr
