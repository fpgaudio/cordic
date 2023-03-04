import uvm_pkg::*;


// Reads data from output fifo to scoreboard
class my_uvm_monitor_output extends uvm_monitor;
    `uvm_component_utils(my_uvm_monitor_output)

    uvm_analysis_port#(my_uvm_transaction) mon_ap_output;

    virtual my_uvm_if vif;
    int sin_out_file, cos_out_file;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        void'(uvm_resource_db#(virtual my_uvm_if)::read_by_name
            (.scope("ifs"), .name("vif"), .val(vif)));
        mon_ap_output = new(.name("mon_ap_output"), .parent(this));

        sin_out_file = $fopen(SIN_OUT_NAME, "wb");
        cos_out_file = $fopen(COS_OUT_NAME, "wb");
        if ( !sin_out_file ) begin
            `uvm_fatal("MON_OUT_BUILD", $sformatf("Failed to open output file %s...", SIN_OUT_NAME));
        end

        if ( !cos_out_file ) begin
            `uvm_fatal("MON_OUT_BUILD", $sformatf("Failed to open output file %s...", COS_OUT_NAME));
        end
    endfunction: build_phase

    virtual task run_phase(uvm_phase phase);
        int n_bytes;
        
        my_uvm_transaction tx_out;

        // wait for reset
        @(posedge vif.reset)
        @(negedge vif.reset)

        tx_out = my_uvm_transaction::type_id::create(.name("tx_out"), .contxt(get_full_name()));

        vif.sin_rd_en = 1'b0;
        vif.cos_rd_en = 1'b0;

        forever begin
            @(negedge vif.clock)
            begin
                if (vif.sin_empty == 1'b0 && vif.cos_empty == 1'b0) begin
                    $fwrite(sin_out_file, "%04h\n", $unsigned(vif.sin_out));
                    tx_out.data = vif.sin_out;
                    mon_ap_output.write(tx_out);
                    vif.sin_rd_en = 1'b1;
                    $fwrite(cos_out_file, "%04h\n", $unsigned(vif.cos_out));
                    tx_out.data = vif.cos_out;
                    mon_ap_output.write(tx_out);
                    vif.cos_rd_en = 1'b1;
                end else begin
                    vif.sin_rd_en = 1'b0;
                    vif.cos_rd_en = 1'b0;
                end

            end
        end
    endtask: run_phase

    virtual function void final_phase(uvm_phase phase);
        super.final_phase(phase);
        `uvm_info("MON_OUT_FINAL", $sformatf("Closing file %s...", SIN_OUT_NAME), UVM_LOW);
        $fclose(sin_out_file);
        `uvm_info("MON_OUT_FINAL", $sformatf("Closing file %s...", COS_OUT_NAME), UVM_LOW);
        $fclose(cos_out_file);
    endfunction: final_phase

endclass: my_uvm_monitor_output


// Reads data from compare file to scoreboard
class my_uvm_monitor_compare extends uvm_monitor;
    `uvm_component_utils(my_uvm_monitor_compare)

    uvm_analysis_port#(my_uvm_transaction) mon_ap_compare;
    virtual my_uvm_if vif;
    int sin_cmp_file, cos_cmp_file, n_bytes;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        void'(uvm_resource_db#(virtual my_uvm_if)::read_by_name
            (.scope("ifs"), .name("vif"), .val(vif)));
        mon_ap_compare = new(.name("mon_ap_compare"), .parent(this));

        sin_cmp_file = $fopen(SIN_CMP_NAME, "rb");
        if ( !sin_cmp_file ) begin
            `uvm_fatal("MON_CMP_BUILD", $sformatf("Failed to open file %s...", SIN_CMP_NAME));
        end

        cos_cmp_file = $fopen(COS_CMP_NAME, "rb");
        if ( !cos_cmp_file ) begin
            `uvm_fatal("MON_CMP_BUILD", $sformatf("Failed to open file %s...", COS_CMP_NAME));
        end


    endfunction: build_phase

    virtual task run_phase(uvm_phase phase);
        int sin_bytes=0, cos_bytes=0, i=0, j=0, total_bytes=721;
        logic [15:0] sin_dout, cos_dout;
        my_uvm_transaction tx_cmp;

        // extend the run_phase 20 clock cycles
        phase.phase_done.set_drain_time(this, (CLOCK_PERIOD*20));

        // notify that run_phase has started
        phase.raise_objection(.obj(this));

        // wait for reset
        @(posedge vif.reset)
        @(negedge vif.reset)

        tx_cmp = my_uvm_transaction::type_id::create(.name("tx_cmp"), .contxt(get_full_name()));

        // syncronize file read with fifo data
        while ( i < total_bytes ) begin
            @(negedge vif.clock)
            begin
                if ( vif.sin_empty == 1'b0  && vif.cos_empty == 1'b0 ) begin
                    sin_bytes = $fscanf(sin_cmp_file, "%04h", sin_dout);
                    tx_cmp.data = sin_dout;
                    mon_ap_compare.write(tx_cmp);
                    cos_bytes = $fscanf(cos_cmp_file, "%04h", cos_dout);
                    tx_cmp.data = cos_dout;
                    mon_ap_compare.write(tx_cmp);
                    i++;
                end
            end
        end  

        // notify that run_phase has completed
        phase.drop_objection(.obj(this));
    endtask: run_phase

    virtual function void final_phase(uvm_phase phase);
        super.final_phase(phase);
        `uvm_info("MON_CMP_FINAL", $sformatf("Closing file %s...", SIN_CMP_NAME), UVM_LOW);
        $fclose(sin_cmp_file);
        `uvm_info("MON_CMP_FINAL", $sformatf("Closing file %s...", COS_CMP_NAME), UVM_LOW);
        $fclose(cos_cmp_file);
    endfunction: final_phase

endclass: my_uvm_monitor_compare
 