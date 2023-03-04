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
    logic [15:0] tx_0, tx_1, tx_2, tx_3;
    logic [15:0] ty_0, ty_1, ty_2, ty_3;
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
            x_reg <= tx_3;
            y_reg <= ty_3;
            z_reg <= tz;
            valid_reg <= valid;
        end
    end

    always_comb begin 
        d = ($signed(z) >= 0) ? 16'h0000 : 16'hFFFF;
        tx_0 = $signed(y) >>> k;
        tx_1 = tx_0 ^ d;
        tx_2 = tx_1 - d;
        tx_3 = x - tx_2; 
        ty_0 = $signed(x) >>> k;
        ty_1 = ty_0 ^ d;
        ty_2 = ty_1 - d;
        ty_3 = y + ty_2;
        tz = $signed($signed(z) - $signed($signed(c ^ d) - $signed(d)));
    end

    assign x_out = x_reg;
    assign y_out = y_reg;
    assign z_out = z_reg;
    assign valid_out = valid_reg;

endmodule