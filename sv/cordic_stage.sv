module cordic_stage(
    input logic         clock,
    input logic         reset,
    input logic [15:0]  k,
    input logic [15:0]  c,
    input logic [15:0]  x,
    input logic [15:0]  y,
    input logic [15:0]  z,
    input logic         valid,

    output logic [15:0] k_out,
    output logic [15:0] c_out,
    output logic [15:0] x_out,
    output logic [15:0] y_out,
    output logic [15:0] z_out,
    output logic        valid_out
);

    logic [15:0] d;
    logic [15:0] tx;
    logic [15:0] ty;
    logic [15:0] tz;

    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            k_out <= 0;
            c_out <= 0;
            x_out <= 0;
            y_out <= 0;
            z_out <= 0;
            valid_out <= 0;
        end else begin
            k_out <= k;
            c_out <= c;
            x_out <= tx;
            y_out <= ty;
            z_out <= tz;
            valid_out <= valid;
        end
    end

    always_comb begin 
        d = (z >= 0) ? 0 : -1;
        tx = x - (((y >> k) ^ d) - d);
        ty = y + (((x >> k) ^ d) - d);
        tz = z - ((c ^ d) - d);
    end
endmodule