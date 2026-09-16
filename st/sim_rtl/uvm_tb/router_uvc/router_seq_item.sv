// ============================================================================
// Filename             : router_seq_item.sv
// Author               : duanwenhui
// Created On           : 2026-9-16 6:29
// Last Modified        :
// Update Count         :
// Description          :
// ============================================================================
`ifndef ROUTER_SEQ_ITEM_SV
`define ROUTER_SEQ_ITEM_SV
class router_base_seq_item extends uvm_sequence_item;
    //
    // Random variable declare
    //
    //rand bit [39:0]   addr;
    //rand bit          cc;

    router_config           router_cfg;

    `uvm_object_utils_begin(router_base_seq_item)
        //`uvm_field_int        (addr,                       UVM_DEFAULT)
        //`uvm_field_int        (cc  ,                       UVM_DEFAULT)
        //`uvm_field_int        (no_compare_signal,          UVM_DEFAULT | UVM_NOCOMPARE)
    `uvm_object_utils_end

    // new - constructor
    function new (string name = "router_base_seq_item");
        super.new(name);
    endfunction : new

    //
    // User constraints
    //
    // constraint cc_c {
    //     cc dist {
    //         0 := 100 - router_cfg.cc_weight,
    //         1 := router_cfg.cc_weight
    //     };
    // }
endclass : router_base_seq_item

class router_seq_item extends router_base_seq_item;
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

    `uvm_object_utils_begin(router_seq_item)
        //`uvm_field_enum       (delay_e,delay_type,          UVM_DEFAULT)
        //`uvm_field_int        (delay,                       UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end

    // new - constructor
    function new (string name = "router_seq_item");
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
    //         MIN     :=  router_cfg.delay_dist[MIN],
    //         LOW     :=  router_cfg.delay_dist[LOW],
    //         AVR     :=  router_cfg.delay_dist[AVR],
    //         HIGH    :=  router_cfg.delay_dist[HIGH],
    //         MAX     :=  router_cfg.delay_dist[MAX]
    //     };
    // }

    // constraint delay_c {
    //     (delay_type == MIN)     ->  delay == 0 ;
    //     (delay_type == LOW)     ->  delay inside {[1:10]} ;
    //     (delay_type == AVR)     ->  delay inside {[11:20]} ;
    //     (delay_type == HIGH)    ->  delay inside {[21:50]} ;
    //     (delay_type == MAX)     ->  delay inside {[51:100]} ;
    // }
endclass : router_seq_item
`endif