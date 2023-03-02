`include "cordic_config.sv"

module cordic (
    input  logic        clock;
    input  logic        reset;
     
    input  logic [31:0] rad,
    input  logic        valid_in

    output logic [15:0] s_out,
    output logic [15:0] c_out,
    output logic        valid_out
);

localparam logic [15:0][15:0] CORDIC_TABLE = '{
    16'h3243, 16'h1DAC, 16'h0FAD, 16'h07F5, 16'h03FE, 16'h01FF, 16'h00FF, 16'h007F, 
    16'h003F, 16'h001F, 16'h000F, 16'h0007, 16'h0003, 16'h0001, 16'h0000, 16'h0000
};

logic [15:0] x;
logic [15:0] y;
logic [31:0] r;
logic [15:0] z;

logic [16:0][15:0] x_stage;
logic [16:0][15:0] y_stage;
logic [16:0][15:0] z_stage;
logic [16:0] valid_stage;

always_comb begin 
    x = `CORDIC_1K[15:0];
    y = '0;
    r = rad;

    if ( r > `PI ) begin
        r -= `TWO_PI;
    end else if (r < -`PI) begin
        r += `TWO_PI;
    end

    if ( r > `HALF_PI ) begin
        r -= `PI;
        x = -x;
    end else if ( r < `HALF_PI ) begin
        r += `PI;
        x = -x;
    end

    z = r[15:0];

    x_stage[0] = x;
    y_stage[0] = y;
    z_stage[0] = z;
    valid_stage[0] = valid_in;

end

genvar k;
generate
    for (k = 0; k < `CORDIC_NTAB; k++) begin
        cordic_stage stage (
            .clock(clock),
            .reset(reset),
            .k(integer'(k)),
            .c(CORDIC_TABLE[k]),
            .x(x_stage[k]),
            .y(y_stage[k]),
            .z(z_stage[k]),
            .valid(valid_stage[k]),
            .x_out(x_stage[k+1]),
            .y_out(y_stage[k+1]),
            .z_out(z_stage[k+1]),
            .valid_out(valid_stage[k+1])
        );
    end
endgenerate

assign s_out = y_stage[16];
assign c_out = x_stage[16];

endmodule