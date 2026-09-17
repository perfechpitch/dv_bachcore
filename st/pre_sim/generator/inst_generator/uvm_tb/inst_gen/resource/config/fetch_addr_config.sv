class fetch_addr_config extends uvm_object;
    bit [63:0] itcm_start[3];
    bit [63:0] itcm_size[3];
    int unsigned ialign_bytes;
    bit          allow_exception;
    rand fetch_exception_weight_e start_exception_weight;
    rand fetch_exception_weight_e control_exception_weight;
    rand fetch_exception_weight_e end_exception_weight;

    `uvm_object_utils_begin(fetch_addr_config)
        `uvm_field_enum(fetch_exception_weight_e, start_exception_weight, UVM_DEFAULT)
        `uvm_field_enum(fetch_exception_weight_e, control_exception_weight, UVM_DEFAULT)
        `uvm_field_enum(fetch_exception_weight_e, end_exception_weight, UVM_DEFAULT)
    `uvm_object_utils_end

    constraint exception_weight_c {
        start_exception_weight inside {
            FETCH_EXCEPTION_WEIGHT_LOW,
            FETCH_EXCEPTION_WEIGHT_MEDIUM,
            FETCH_EXCEPTION_WEIGHT_HIGH
        };
        control_exception_weight inside {
            FETCH_EXCEPTION_WEIGHT_LOW,
            FETCH_EXCEPTION_WEIGHT_MEDIUM,
            FETCH_EXCEPTION_WEIGHT_HIGH
        };
        end_exception_weight inside {
            FETCH_EXCEPTION_WEIGHT_LOW,
            FETCH_EXCEPTION_WEIGHT_MEDIUM,
            FETCH_EXCEPTION_WEIGHT_HIGH
        };
    }

    function new(string name = "fetch_addr_config");
        super.new(name);
        foreach(itcm_start[i]) begin
            itcm_start[i] = '0;
            itcm_size[i]  = `ITCM_SIZE;
        end
        ialign_bytes          = 4;
        allow_exception       = 1'b1;
        start_exception_weight   = FETCH_EXCEPTION_WEIGHT_LOW;
        control_exception_weight = FETCH_EXCEPTION_WEIGHT_LOW;
        end_exception_weight     = FETCH_EXCEPTION_WEIGHT_LOW;
    endfunction

    function int unsigned weight_percent(fetch_exception_weight_e weight);
        case(weight)
            FETCH_EXCEPTION_WEIGHT_LOW:    return 10;
            FETCH_EXCEPTION_WEIGHT_MEDIUM: return 50;
            FETCH_EXCEPTION_WEIGHT_HIGH:   return 90;
            default:                       return 0;
        endcase
    endfunction

    function void check();
        if(!(ialign_bytes inside {2, 4}))
            `uvm_fatal("FETCH_ADDR_CFG", "ialign_bytes must be 2 or 4")
    endfunction
endclass
