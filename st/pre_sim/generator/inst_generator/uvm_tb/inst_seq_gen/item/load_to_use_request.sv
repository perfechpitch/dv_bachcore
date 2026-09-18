typedef enum {L2U_CONSUMER_ALU_R, L2U_CONSUMER_ALU_I}
    load_to_use_consumer_type_e;
typedef enum {L2U_USE_RS1, L2U_USE_RS2}
    load_to_use_operand_e;

// Per-block item. The config defines the random space; this request stores one
// resolved producer-consumer dependency and supports optional directed fields.
class load_to_use_request extends uvm_object;
    load_to_use_config                  cfg;

    rand load_to_use_consumer_type_e    consumer_type;
    rand inst_e                         producer_inst;
    rand inst_e                         consumer_inst;
    rand load_to_use_operand_e          dependency_operand;
    rand int unsigned                   gap;
    rand bit[31:0]                      load_data;
    rand bit[11:0]                      consumer_imm;

    bit                                 consumer_valid;
    bit                                 gap_valid;
    bit                                 load_data_valid;
    inst_e                              requested_consumer;
    int unsigned                        requested_gap;
    bit[31:0]                           requested_load_data;
    int unsigned                        gap_budget_max;

    `uvm_object_utils_begin(load_to_use_request)
        `uvm_field_enum(load_to_use_consumer_type_e, consumer_type, UVM_DEFAULT)
        `uvm_field_enum(inst_e, producer_inst, UVM_DEFAULT)
        `uvm_field_enum(inst_e, consumer_inst, UVM_DEFAULT)
        `uvm_field_enum(load_to_use_operand_e, dependency_operand, UVM_DEFAULT)
        `uvm_field_int(gap, UVM_DEFAULT | UVM_DEC)
        `uvm_field_int(load_data, UVM_DEFAULT | UVM_HEX)
        `uvm_field_int(consumer_imm, UVM_DEFAULT | UVM_HEX)
    `uvm_object_utils_end

    function new(string name = "load_to_use_request");
        super.new(name);
        gap_budget_max = '1;
    endfunction

    constraint producer_c {
        producer_inst == LW;
    }

    constraint consumer_type_c {
        consumer_type dist {
            L2U_CONSUMER_ALU_R := cfg.alu_r_consumer_weight,
            L2U_CONSUMER_ALU_I := cfg.alu_i_consumer_weight
        };
        solve consumer_type before consumer_inst;
        solve consumer_type before dependency_operand;
    }

    constraint consumer_inst_c {
        if(consumer_type == L2U_CONSUMER_ALU_R) {
            consumer_inst inside {
                ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
            };
        }
        else {
            consumer_inst inside {
                ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI
            };
        }
        if(consumer_valid) consumer_inst == requested_consumer;
    }

    constraint dependency_operand_c {
        if(consumer_type == L2U_CONSUMER_ALU_I) {
            dependency_operand == L2U_USE_RS1;
        }
        else {
            dependency_operand dist {
                L2U_USE_RS1 := cfg.use_rs1_weight,
                L2U_USE_RS2 := cfg.use_rs2_weight
            };
        }
    }

    constraint request_c {
        if(gap_valid) {
            gap == requested_gap;
        }
        else {
            gap inside {[0:cfg.gap_max]};
            gap <= gap_budget_max;
        }
        if(load_data_valid) load_data == requested_load_data;
        if(consumer_inst inside {SLLI, SRLI, SRAI})
            consumer_imm inside {[0:31]};
    }

    function void set_consumer(inst_e value);
        requested_consumer = value;
        consumer_valid = 1'b1;
    endfunction

    function void set_gap(int unsigned value);
        requested_gap = value;
        gap_valid = 1'b1;
    endfunction

    function void set_load_data(bit[31:0] value);
        requested_load_data = value;
        load_data_valid = 1'b1;
    endfunction
endclass
