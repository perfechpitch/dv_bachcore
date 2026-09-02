typedef struct packed {
    bit[31:0][31:0] reg_data;
} reg_data_s;

typedef struct packed {
    bit[31:0][511:0] vreg_data;
} vreg_data_s;
typedef struct {
    bit [4:0]  reg_idx;
    bit [31:0] data;
} reg_update_s;