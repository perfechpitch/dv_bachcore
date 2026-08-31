// ============================================================================
// Filename             : reset_seq_item.sv
// Author               : $(USER)
// Created On           : $(Date)
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================

`ifndef RESET_SEQ_ITEM_SV
`define RESET_SEQ_ITEM_SV

class reset_seq_item extends uvm_sequence_item;                                  
    rand delay_e                delay_type; 
    rand delay_e                next_reset_delay_type; 
    rand int                    delay;
    rand int                    next_reset_delay;

    reset_config           reset_cfg;

    `uvm_object_utils_begin(reset_seq_item)
        `uvm_field_enum       (delay_e,delay_type,           UVM_DEFAULT)
        `uvm_field_int        (delay,                        UVM_DEFAULT | UVM_DEC)
        `uvm_field_enum       (delay_e,next_reset_delay_type,UVM_DEFAULT)
        `uvm_field_int        (next_reset_delay,             UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end
    
    // new - constructor
    function new (string name = "reset_seq_item");
      super.new(name);
    endfunction : new

    constraint solve_order {
    solve delay_type            before delay;
    solve next_reset_delay_type before next_reset_delay;
    }

    constraint delay_type_c {
        delay_type dist {
            MIN     :=  reset_cfg.delay_dist[MIN],
            LOW     :=  reset_cfg.delay_dist[LOW],
            AVR     :=  reset_cfg.delay_dist[AVR],
            HIGH    :=  reset_cfg.delay_dist[HIGH],
            MAX     :=  reset_cfg.delay_dist[MAX]
        };
    }

    constraint delay_c {
        (delay_type == MIN)     ->  delay == 2 ;
        (delay_type == LOW)     ->  delay inside {[2:5]} ;
        (delay_type == AVR)     ->  delay inside {[6:10]} ;
        (delay_type == HIGH)    ->  delay inside {[11:20]} ;
        (delay_type == MAX)     ->  delay inside {[21:50]} ;
    }

    constraint next_reset_delay_type_c {
        next_reset_delay_type dist {
            MIN     :=  reset_cfg.next_reset_delay_dist[MIN],
            LOW     :=  reset_cfg.next_reset_delay_dist[LOW],
            AVR     :=  reset_cfg.next_reset_delay_dist[AVR],
            HIGH    :=  reset_cfg.next_reset_delay_dist[HIGH],
            MAX     :=  reset_cfg.next_reset_delay_dist[MAX]
        };
    }

    constraint next_reset_delay_c {
        (next_reset_delay_type == MIN)     ->  next_reset_delay == 50 ;
        (next_reset_delay_type == LOW)     ->  next_reset_delay inside {[51:100]} ;
        (next_reset_delay_type == AVR)     ->  next_reset_delay inside {[101:500]} ;
        (next_reset_delay_type == HIGH)    ->  next_reset_delay inside {[501:2000]} ;
        (next_reset_delay_type == MAX)     ->  next_reset_delay inside {[2001:5000]} ;
    }

endclass : reset_seq_item

`endif