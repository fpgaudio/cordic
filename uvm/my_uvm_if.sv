import uvm_pkg::*;

interface my_uvm_if;
    logic           clock;
    logic           reset;
    logic [31:0]    in_din;
    logic           in_wr_en;
    logic           in_full;
    logic [15:0]    sin_out;
    logic [15:0]    cos_out;  
    logic           sin_empty;
    logic           cos_empty;
    logic           sin_rd_en;
    logic           cos_rd_en;
    
endinterface
 