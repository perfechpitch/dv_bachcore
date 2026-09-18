module rst_gen (
    output logic rst_n
);

    initial begin
        rst_n = 1'b0;
        #100ns;
        rst_n = 1'b1;
    end

endmodule
