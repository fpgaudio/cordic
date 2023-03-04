
import uvm_pkg::*;
import my_uvm_package::*;

`include "my_uvm_if.sv"

`timescale 1 ns / 1 ns

module my_uvm_tb;

    my_uvm_if vif();

    cordic_top dut (
    .clock(vif.clock),
    .reset(vif.reset),
    .p_fixed(vif.in_din),
    .in_wr_en(vif.in_wr_en),
    .in_full(vif.in_full),
    .sin_out(vif.sin_out),
    .cos_out(vif.cos_out),
    .sin_empty(vif.sin_empty),
    .cos_empty(vif.cos_empty),
    .sin_rd_en(vif.sin_rd_en),
    .cos_rd_en(vif.cos_rd_en)
    );

    initial begin
        // store the vif so it can be retrieved by the driver & monitor
        uvm_resource_db#(virtual my_uvm_if)::set
            (.scope("ifs"), .name("vif"), .val(vif));

        // run the test
        run_test("my_uvm_test");        
    end

    // reset
    initial begin
        vif.clock <= 1'b1;
        vif.reset <= 1'b0;
        @(posedge vif.clock);
        vif.reset <= 1'b1;
        @(posedge vif.clock);
        vif.reset <= 1'b0;
    end

    // 10ns clock
    always
        #(CLOCK_PERIOD/2) vif.clock = ~vif.clock;
endmodule





 
