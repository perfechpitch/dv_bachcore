module vu_wrapper(
    reset_if    reset_if
   ,inst_gen_if inst_gen_if
);

    assign inst_gen_if.rdy = 1;
endmodule
