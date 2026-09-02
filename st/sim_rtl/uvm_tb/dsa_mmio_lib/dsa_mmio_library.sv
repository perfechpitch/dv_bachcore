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

    function new(string name = "dsa_mmio_library");
        super.new(name);
        vu_mmio = vu_mmio_set::type_id::create("vu_mmio");
        mu_mmio = mu_mmio_set::type_id::create("mu_mmio");
        dte_mmio = dte_mmio_set::type_id::create("dte_mmio");
    endfunction

    function void set_type(dsa_mmio_type_e t);
        dsa_type = t;
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