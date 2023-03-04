import uvm_pkg::*;


class my_uvm_transaction extends uvm_sequence_item;
    logic [31:0] data;

    function new(string name = "");
        super.new(name);
    endfunction: new

    `uvm_object_utils_begin(my_uvm_transaction)
        `uvm_field_int(data, UVM_ALL_ON)
    `uvm_object_utils_end
endclass: my_uvm_transaction


class my_uvm_sequence extends uvm_sequence#(my_uvm_transaction);
    `uvm_object_utils(my_uvm_sequence)

    function new(string name = "");
        super.new(name);
    endfunction: new

    task body();        
        my_uvm_transaction tx;
        // int in_file, n_bytes=0, i=0;

        int i, j, count;
        int n_bytes=721;
        int in_file;
        logic [31:0] din;

        `uvm_info("SEQ_RUN", $sformatf("Loading file %s...", P_FIXED_NAME), UVM_LOW);

        in_file = $fopen(P_FIXED_NAME, "rb");
  

        if ( !in_file ) begin
            `uvm_fatal("SEQ_RUN", $sformatf("Failed to open file %s...", P_FIXED_NAME));
        end



        while ( i < n_bytes ) begin
            tx = my_uvm_transaction::type_id::create(.name("tx"), .contxt(get_full_name()));
            start_item(tx);
            count = $fscanf(in_file, "%08h", din);
            tx.data = din;
            finish_item(tx);
            i++;
        end

        `uvm_info("SEQ_RUN", $sformatf("Closing file %s...", P_FIXED_NAME), UVM_LOW);
        $fclose(in_file);
    endtask: body
endclass: my_uvm_sequence

typedef uvm_sequencer#(my_uvm_transaction) my_uvm_sequencer;
 