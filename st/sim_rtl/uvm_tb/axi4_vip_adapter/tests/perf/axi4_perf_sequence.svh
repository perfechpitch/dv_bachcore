// Sustained sliding-window traffic through the feature04 sequence API.
package axi4_perf_sequence_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import axi4_vip_adapter_pkg::*;

  class axi4_perf_sequence extends axi4_sequence_base;
    `uvm_object_utils(axi4_perf_sequence)
    string mode = "mixed";
    bit half_strb = 0, stop_requested = 0;
    longint unsigned submitted_writes = 0, submitted_reads = 0;
    longint unsigned expected_write_bytes = 0, expected_read_bytes = 0;
    int unsigned serial = 0;
    axi4_completion handles[$];
    axi4_burst_request requests[$];
    bit directions[$];

    function new(string name = "axi4_perf_sequence");
      super.new(name);
    endfunction

    function automatic logic [AXI_DATA_WIDTH-1:0] pattern(
      input bit [AXI_ADDR_WIDTH-1:0] addr
    );
      logic [AXI_DATA_WIDTH-1:0] value;
      bit [AXI_ADDR_WIDTH-1:0] byte_addr;
      for (int lane = 0; lane < AXI_STRB_WIDTH; lane++) begin
        byte_addr = addr + lane;
        value[8*lane +: 8] = byte_addr ^ (byte_addr >> 8) ^
                             (byte_addr >> 16) ^ (byte_addr >> 24) ^ 8'ha5;
      end
      return value;
    endfunction

    task submit_next();
      axi4_burst_request req;
      axi4_completion handle;
      bit is_write;
      is_write = mode == "write" || (mode == "mixed" && serial % 2 == 0);
      req = new("perf_request");
      // 32-byte aligned, varying low address bits, maximum offset 3296;
      // every 512-byte burst remains within this synthetic 4KB test page.
      req.addr = 'h1000 + (serial % 7) * 512 + ((serial / 7) % 8) * 32;
      req.id = serial % 256;
      req.beat_count = 16;
      req.size = 5;
      req.burst = 1;
      req.lock = 0;
      if (is_write) begin
        req.data = new[16]; req.strb = new[16];
        foreach (req.data[i]) begin
          req.data[i] = pattern(req.addr + i * 32);
          req.strb[i] = half_strb ? 32'h0000ffff : 32'hffffffff;
        end
        axi_submit_write(req, handle);
        submitted_writes++;
        expected_write_bytes += half_strb ? 256 : 512;
      end else begin
        axi_submit_read(req, handle);
        submitted_reads++;
        expected_read_bytes += 512;
      end
      if (handle == null) `uvm_fatal("PERF_HANDLE", "Submission returned null completion")
      handles.push_back(handle);
      requests.push_back(req);
      directions.push_back(is_write);
      serial++;
    endtask

    task retire_oldest();
      axi4_completion handle;
      axi4_burst_request req;
      axi4_burst_response rsp;
      bit is_write;
      handle = handles.pop_front();
      req = requests.pop_front();
      is_write = directions.pop_front();
      axi_wait_completion(handle, rsp);
      if (!handle.done || handle.status != AXI_COMPLETION_OK)
        `uvm_fatal("PERF_COMPLETION", "Burst aborted or failed")
      if (rsp == null || rsp.completed_beats != 16)
        `uvm_fatal("PERF_COMPLETION", "Missing or incomplete burst response")
      if (is_write) begin
        if (rsp.bid !== req.id || rsp.bresp !== AXI_RESP_OKAY)
          `uvm_fatal("PERF_WRITE", "Write response mismatch")
      end else begin
        if (rsp.data.size() != 16 || rsp.rid.size() != 16 ||
            rsp.rresp.size() != 16 || rsp.rlast.size() != 16)
          `uvm_fatal("PERF_READ", "Read response array length mismatch")
        foreach (rsp.data[i]) begin
          if (rsp.data[i] !== pattern(req.addr + i * 32) ||
              rsp.rid[i] !== req.id || rsp.rresp[i] !== AXI_RESP_OKAY ||
              rsp.rlast[i] !== (i == 15))
            `uvm_fatal("PERF_READ", $sformatf("Read payload mismatch addr=%h beat=%0d", req.addr, i))
        end
      end
    endtask

    virtual task body();
      // This is a submission window. The passive monitor measures the actual
      // accepted-address / not-yet-responded outstanding depth independently.
      repeat (128) submit_next();
      while (!stop_requested) begin
        retire_oldest();
        if (!stop_requested) submit_next();
      end
      while (handles.size() != 0) retire_oldest();
    endtask
  endclass
endpackage
