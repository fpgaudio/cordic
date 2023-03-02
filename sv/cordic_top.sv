module cordic_top (
    input  logic            clock,
    input  logic            reset,

    input  logic [31:0]     p_fixed,
    input  logic            in_wr_en,
    output logic            in_full,

    output logic [15:0]     sin_out,
    output logic [15:0]     cos_out,
    output logic            sin_empty,
    output logic            cos_empty,
    input  logic            sin_rd_en,
    input  logic            cos_rd_en
);

logic p_fixed_rd_en;
logic p_fixed_empty;
logic [31:0] rad;
logic [15:0] s_out;
logic [15:0] c_out;
logic cord_valid_out;
logic sin_full, cos_full;

assign p_fixed_rd_en = ~p_fixed_empty;

fifo #(
    .FIFO_BUFFER_SIZE(1024),
    .FIFO_DATA_WIDTH(32)
) p_fixed (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(in_wr_en),
    .din(p_fixed),
    .full(in_full),
    .rd_clk(clock),
    .rd_en(p_fixed_rd_en),
    .dout(rad),
    .empty(p_fixed_empty)
);


cordic cordic_inst (
    .clock(clock),
    .reset(reset),
    .rad(rad),
    .valid_in(p_fixed_rd_en),
    .s_out(s_out),
    .c_out(c_out),
    .valid_out(cord_valid_out)
);

fifo #(
    .FIFO_BUFFER_SIZE(1024),
    .FIFO_DATA_WIDTH(16)
) sin_fifo (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(cord_valid_out),
    .full(sin_full),
    .rd_clk(clock),
    .rd_en(sin_rd_en),
    .dout(sin_out),
    .empty(sin_empty)
);

fifo #(
    .FIFO_BUFFER_SIZE(1024),
    .FIFO_DATA_WIDTH(16),
) cos_fifo (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(cord_valid_out),
    .full(cos_full),
    .rd_clk(clock),
    .rd_en(cos_rd_en),
    .dout(cos_out),
    .empty(cos_empty)
);

endmodule