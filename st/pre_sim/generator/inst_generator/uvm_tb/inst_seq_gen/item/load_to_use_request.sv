typedef enum {L2U_CONSUMER_ADD, L2U_CONSUMER_ADDI}
    load_to_use_consumer_e;

// One request type serves directed and random generation.  A valid flag means
// the caller fixes that field; every unspecified field remains constrained-rand.
class load_to_use_request extends uvm_object;
    rand load_to_use_consumer_e consumer;
    rand int unsigned           gap;
    rand bit[31:0]              load_data;
    rand bit[11:0]              addi_imm;

    bit                         consumer_valid;
    bit                         gap_valid;
    bit                         load_data_valid;
    load_to_use_consumer_e      requested_consumer;
    int unsigned                requested_gap;
    bit[31:0]                   requested_load_data;
    int unsigned                gap_max = 5;

    `uvm_object_utils_begin(load_to_use_request)
        `uvm_field_enum(load_to_use_consumer_e, consumer, UVM_DEFAULT)
        `uvm_field_int(gap, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int(load_data, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int(addi_imm, UVM_DEFAULT | UVM_HEX)
    `uvm_object_utils_end

    function new(string name = "load_to_use_request");
        super.new(name);
    endfunction

    constraint request_c {
        gap inside {[0:gap_max]};
        if(consumer_valid) consumer == requested_consumer;
        if(gap_valid) gap == requested_gap;
        if(load_data_valid) load_data == requested_load_data;
    }

    function void set_consumer(load_to_use_consumer_e value);
        requested_consumer = value;
        consumer_valid = 1'b1;
    endfunction

    function void set_gap(int unsigned value);
        requested_gap = value;
        gap_valid = 1'b1;
        if(value > gap_max)
            gap_max = value;
    endfunction

    function void set_load_data(bit[31:0] value);
        requested_load_data = value;
        load_data_valid = 1'b1;
    endfunction
endclass
