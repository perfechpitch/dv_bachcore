// dsa_mmio_library.sv
// DSA MMIO reference model: selector + forwarding only.
//
// This class holds one instance of each sub-block mmio_set and forwards the
// unified MMIO interface to the selected sub-block. All MMIO register/state
// storage belongs to the corresponding mmio_set.

class dsa_mmio_library extends uvm_object;

    `uvm_object_utils(dsa_mmio_library)

    vu_mmio_set vu_mmio;
    mu_mmio_set mu_mmio;
    dte_mmio_set dte_mmio;

    // Try-run default: select VU.
    dsa_mmio_type_e dsa_type = DSA_MMIO_VU;
    int vu_req_log;
    int mu_req_log;
    int dte_req_log;

    function new(string name = "dsa_mmio_library");
        super.new(name);
        vu_mmio = vu_mmio_set::type_id::create("vu_mmio");
        mu_mmio = mu_mmio_set::type_id::create("mu_mmio");
        dte_mmio = dte_mmio_set::type_id::create("dte_mmio");
        vu_req_log = 0;
        mu_req_log = 0;
        dte_req_log = 0;
    endfunction

    function void set_type(dsa_mmio_type_e t);
        dsa_type = t;
    endfunction

    function void open_req_log();
        if(vu_req_log)
            $fclose(vu_req_log);
        if(mu_req_log)
            $fclose(mu_req_log);
        if(dte_req_log)
            $fclose(dte_req_log);

        vu_req_log = $fopen("log/vu_req.log", "w");
        mu_req_log = $fopen("log/mu_req.log", "w");
        dte_req_log = $fopen("log/dte_req.log", "w");
    endfunction

    function void trace_req(dsa_req_s req);
        int req_log;
        string rw_name;

        case(dsa_type)
            DSA_MMIO_VU:  req_log = vu_req_log;
            DSA_MMIO_MU:  req_log = mu_req_log;
            DSA_MMIO_DTE: req_log = dte_req_log;
            default:      req_log = 0;
        endcase

        rw_name = req.rw ? "W" : "R";
        if(req_log)
            $fwrite(req_log, "%s %08h %08h %0d %02h %04h %02h %0d\n",
                rw_name, req.addr, req.wdata, req.stream_id, req.task_id,
                req.user_id, req.path_id, req.vc_id);
    endfunction

    function void reset_mmio();
        vu_mmio.reset_mmio();
        mu_mmio.reset_mmio();
        dte_mmio.reset_mmio();
    endfunction

    function void write(bit [31:0] addr, bit [31:0] data);
        case(dsa_type)
            DSA_MMIO_VU:
                vu_mmio.write(addr, data);
            DSA_MMIO_MU:
                mu_mmio.write(addr, data);
            DSA_MMIO_DTE:
                dte_mmio.write(addr, data);
            default:
                `uvm_error("DSA_MMIO",
                    $sformatf("unknown dsa_type=%0d", dsa_type))
        endcase
    endfunction

    function bit [31:0] read(bit [31:0] addr);
        case(dsa_type)
            DSA_MMIO_VU:
                return vu_mmio.read(addr);
            DSA_MMIO_MU:
                return mu_mmio.read(addr);
            DSA_MMIO_DTE:
                return dte_mmio.read(addr);
            default: begin
                `uvm_error("DSA_MMIO",
                    $sformatf("unknown dsa_type=%0d", dsa_type))
                return 32'h0;
            end
        endcase
    endfunction

    function void set_log(int fd);
        vu_mmio.set_log(fd);
        mu_mmio.set_log(fd);
        dte_mmio.set_log(fd);
    endfunction

endclass