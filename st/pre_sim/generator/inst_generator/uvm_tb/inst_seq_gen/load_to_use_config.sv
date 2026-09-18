// Configuration policy for one Load-to-Use request.
// ls_seq_config decides whether LOAD_TO_USE is selected; this object controls
// how the selected Load-to-Use block is randomized.
class load_to_use_config extends uvm_object;
    rand int unsigned gap_max;
    rand int unsigned alu_r_consumer_weight;
    rand int unsigned alu_i_consumer_weight;
    rand int unsigned use_rs1_weight;
    rand int unsigned use_rs2_weight;

    `uvm_object_utils_begin(load_to_use_config)
        `uvm_field_int(gap_max, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int(alu_r_consumer_weight, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int(alu_i_consumer_weight, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int(use_rs1_weight, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int(use_rs2_weight, UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end

    function new(string name = "load_to_use_config");
        super.new(name);
    endfunction

    constraint gap_c {
        gap_max inside {[0:16]};
    }

    constraint consumer_weight_c {
        alu_r_consumer_weight inside {[0:100]};
        alu_i_consumer_weight inside {[0:100]};
        (alu_r_consumer_weight + alu_i_consumer_weight) == 100;
    }

    constraint operand_weight_c {
        use_rs1_weight inside {[0:100]};
        use_rs2_weight inside {[0:100]};
        (use_rs1_weight + use_rs2_weight) == 100;
    }
endclass
