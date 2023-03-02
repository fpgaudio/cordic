module cordic_stage(
    input logic         clock,
    input logic         reset,
    input logic [31:0]  k,
    input logic [15:0]  c,
    input logic [15:0]  x,
    input logic [15:0]  y,
    input logic [15:0]  z,
    input logic         valid,

    output logic [15:0] x_out,
    output logic [15:0] y_out,
    output logic [15:0] z_out,
    output logic        valid_out
);

    logic [15:0] d;
    logic [15:0] tx;
    logic [15:0] ty;
    logic [15:0] tz;

    logic [15:0] x_reg;
    logic [15:0] y_reg;
    logic [15:0] z_reg;
    logic        valid_reg;

    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            x_reg <= 0;
            y_reg <= 0;
            z_reg <= 0;
            valid_reg <= 0;
        end else begin
            x_reg <= tx;
            y_reg <= ty;
            z_reg <= tz;
            valid_reg <= valid;
        end
    end

    always_comb begin 
        d = (z >= 0) ? 0 : -1;
        tx = x - (((y >> k) ^ d) - d);
        ty = y + (((x >> k) ^ d) - d);
        tz = z - ((c ^ d) - d);
    end

    assign x_out <= x_reg;
    assign y_out <= y_reg;
    assign z_out <= z_reg;
    assign valid_out <= valid_reg;

endmodule