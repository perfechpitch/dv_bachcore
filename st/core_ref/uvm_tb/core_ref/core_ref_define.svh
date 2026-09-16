typedef struct {
    bit [31:0]       start_pc;
    bit [3:0]        stream_id;
    bit [5:0]        task_id;
    bit [15:0]       user_id;
    bit [5:0]        path_id;
    bit [1:0]        vc_id;
    dsa_mmio_type_e  dsa_type;
} task_info_s;

// TODO(memory-map-confirm): temporary per-core global TCM bases.
// Keep the existing VU map for smoke compatibility. MU/DTE use separate
// 32KB slots until the architectural address map is published.
function automatic bit [31:0] core_itcm_base(dsa_mmio_type_e dsa_type);
    case(dsa_type)
        DSA_MMIO_VU:  return 32'h0000_0000;
        DSA_MMIO_MU:  return 32'h0010_0000;
        DSA_MMIO_DTE: return 32'h0011_0000;
        default:      return 32'hxxxx_xxxx;
    endcase
endfunction

function automatic bit [31:0] core_dtcm_base(dsa_mmio_type_e dsa_type);
    case(dsa_type)
        DSA_MMIO_VU:  return 32'h0000_1000;
        DSA_MMIO_MU:  return 32'h0010_8000;
        DSA_MMIO_DTE: return 32'h0011_8000;
        default:      return 32'hxxxx_xxxx;
    endcase
endfunction
