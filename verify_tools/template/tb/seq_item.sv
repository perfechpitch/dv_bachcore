// ============================================================================
// Filename             : $(CLASSNAME)_seq_item.sv
// Author               : $(USER)
// Created On           : $(Date)
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef $(FILENAME)_SEQ_ITEM_SV
`define $(FILENAME)_SEQ_ITEM_SV
class $(CLASSNAME)_base_seq_item extends uvm_sequence_item;                                  
    //
    // Random variable declare
    //
    //rand bit [39:0]   addr; 
    //rand bit          cc;

    $(CLASSNAME)_config           $(CLASSNAME)_cfg;

    `uvm_object_utils_begin($(CLASSNAME)_base_seq_item)
        //`uvm_field_int        (addr,                       UVM_DEFAULT)
        //`uvm_field_int        (cc  ,                       UVM_DEFAULT)
        //`uvm_field_int        (no_compare_signal,          UVM_DEFAULT | UVM_NOCOMPARE)
    `uvm_object_utils_end
    
    // new - constructor
    function new (string name = "$(CLASSNAME)_base_seq_item");
        super.new(name);
    endfunction : new

    //
    // User constraints
    //
    // constraint cc_c {
    //     cc dist {
    //         0 := 100 - $(CLASSNAME)_cfg.cc_weight,
    //         1 := $(CLASSNAME)_cfg.cc_weight
    //     };
    // }
endclass : $(CLASSNAME)_base_seq_item

class $(CLASSNAME)_seq_item extends $(CLASSNAME)_base_seq_item;                                  
    //
    // Enum define 
    //
    //typedef enum {MIN,LOW,AVR,HIGH,MAX} delay_e;
    //typedef enum {READ,WRITE} access_e;

    //
    // Random variable declare
    //
    //rand delay_e                delay_type; 
    //rand int                    delay;

    `uvm_object_utils_begin($(CLASSNAME)_seq_item)
        //`uvm_field_enum       (delay_e,delay_type,          UVM_DEFAULT)
        //`uvm_field_int        (delay,                       UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end
    
    // new - constructor
    function new (string name = "$(CLASSNAME)_seq_item");
        super.new(name);
    endfunction : new

    //
    // User constraints
    //
    // constraint solve_order {
    //     solve delay_type before delay;
    // }

    // constraint delay_type_c {
    //     delay_type dist {
    //         MIN     :=  $(CLASSNAME)_cfg.delay_dist[MIN],
    //         LOW     :=  $(CLASSNAME)_cfg.delay_dist[LOW],
    //         AVR     :=  $(CLASSNAME)_cfg.delay_dist[AVR],
    //         HIGH    :=  $(CLASSNAME)_cfg.delay_dist[HIGH],
    //         MAX     :=  $(CLASSNAME)_cfg.delay_dist[MAX]
    //     };
    // }

    // constraint delay_c {
    //     (delay_type == MIN)     ->  delay == 0 ;
    //     (delay_type == LOW)     ->  delay inside {[1:10]} ;
    //     (delay_type == AVR)     ->  delay inside {[11:20]} ;
    //     (delay_type == HIGH)    ->  delay inside {[21:50]} ;
    //     (delay_type == MAX)     ->  delay inside {[51:100]} ;
    // }
endclass : $(CLASSNAME)_seq_item
`endif