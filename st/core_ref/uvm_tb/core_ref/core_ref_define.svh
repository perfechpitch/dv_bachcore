typedef struct {
    bit [31:0]       start_pc;
    bit [3:0]        stream_id;
    bit [5:0]        task_id;
    bit [15:0]       user_id;
    bit [5:0]        path_id;
    bit [1:0]        vc_id;
    dsa_mmio_type_e  dsa_type;
} task_info_s;
