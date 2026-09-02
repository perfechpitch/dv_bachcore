// dsa_mmio_define.svh
// DSA MMIO reference model (try-run) -- shared type/define header.
//
// REUSE CHECK: a project-wide grep for the tokens (VU|MU|DTE|DSA) found no
// existing enum/parameter describing the DSA sub-block selector, so the
// selector enum below is intentionally defined here. It is the single source
// of truth for dsa_mmio_type_e and is shared by dsa_mmio_library (selector)
// and the three mmio_set classes.
typedef enum {
    DSA_MMIO_VU,
    DSA_MMIO_MU,
    DSA_MMIO_DTE
} dsa_mmio_type_e;

typedef struct {
    bit         rw;
    bit [31:0]  addr;
    bit [31:0]  wdata;
    bit [3:0]   stream_id;
    bit [5:0]   task_id;
    bit [15:0]  user_id;
    bit [5:0]   path_id;
    bit [1:0]   vc_id;
} dsa_req_s;
