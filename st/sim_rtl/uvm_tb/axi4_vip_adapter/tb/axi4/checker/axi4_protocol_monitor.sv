// Passive AXI4 INCR monitor. No driver state, UVM dependency, or signal writes.
// Sample pre-NBA values at the clock edge. Testbench drivers must avoid active-region races.
module axi4_protocol_monitor #(
  parameter int ADDR_WIDTH=32, DATA_WIDTH=256, ID_WIDTH=8, LEN_WIDTH=4,
  parameter int MAX_BURST_BEATS=(1 << LEN_WIDTH),
  parameter int MAX_OUTSTANDING_READS=128, MAX_OUTSTANDING_WRITES=128,
  parameter int MAX_OUTSTANDING_TOTAL=128, MAX_TRACKED=4096,
  parameter bit ENABLE_PROTOCOL_CHECKS=1, ENABLE_X_CHECKS=1,
  parameter bit ENABLE_ALIGNMENT_CHECKS=1, ENABLE_STROBE_CHECKS=1,
  parameter bit ENABLE_RESPONSE_CHECKS=1, ENABLE_TIMEOUT_CHECKS=1,
  parameter bit ENABLE_COVERAGE=0, ENABLE_TRANSACTION_COVERAGE=0,
  parameter bit ENABLE_PROTOCOL_COVERAGE=0, ENABLE_ERROR_COVERAGE=0,
  // Actual monitor capability: INCR, normal access, narrow and unaligned decoding.
  parameter bit SUPPORT_INCREMENTING_BURST=1, SUPPORT_FIXED_BURST=0,
  parameter bit SUPPORT_WRAPPING_BURST=0, SUPPORT_EXCLUSIVE_ACCESS=0,
  parameter bit SUPPORT_LOCKED_ACCESS=0, SUPPORT_NARROW_BURST=1,
  parameter bit SUPPORT_UNALIGNED_ACCESS=1, SUPPORT_BYTE_STROBE=1,
  // Traffic policy is independent of capability and checker enables.
  parameter bit ENFORCE_TRAFFIC_POLICY=1, ALLOW_NARROW_BURST=1,
  parameter bit ALLOW_NARROW_SINGLE=1, ALLOW_UNALIGNED_ACCESS=1,
  parameter bit REQUIRE_ALIGNED_ACCESS=0,
  parameter int READ_TIMEOUT_CYCLES=1000, WRITE_TIMEOUT_CYCLES=1000,
  parameter int READY_TIMEOUT_CYCLES=1000,
  parameter bit REPORT_ERRORS=1, FATAL_ON_ERROR=0
)(axi4_if bus);
  import axi4_checker_pkg::*;
  localparam int LANES=DATA_WIDTH/8;
  localparam int FULL_SIZE=$clog2(LANES);
  typedef logic [ADDR_WIDTH-1:0] addr_t;
  typedef logic [ID_WIDTH-1:0] id_t;
  typedef logic [LANES-1:0] strb_t;

  class request;
    id_t id;
    addr_t addr;
    int beats, size, beat;
    bit decodable, w_done, timed_out, response_timer_started;
    longint unsigned progress;
  endclass
  typedef struct packed {strb_t strb; logic last; longint unsigned accepted_cycle;} wbeat_t;
  request reads[$], writes[$];
  wbeat_t pending_w[$];
  longint unsigned cycle=0;
  int unsigned protocol_errors=0, x_errors=0, alignment_errors=0,
    strobe_errors=0, response_errors=0, timeout_errors=0, policy_errors=0;
  int current_reads=0, current_writes=0;
  int max_reads_seen=0, max_writes_seen=0, max_total_seen=0;
  longint unsigned aw_count=0, ar_count=0, w_count=0, b_count=0, r_count=0;
  longint unsigned transaction_samples=0, protocol_samples=0, error_samples=0;
  longint unsigned length_hits[257], id_hits[1<<ID_WIDTH];
  longint unsigned stall_cycles[5], response_hits[4], depth_hits[4];
  bit was_stalled[5];
  bit aw_checked=0, ar_checked=0, unpaired_w_timed_out=0;
  int wait_cycles[5];
  bit wait_reported[5];
  // $bits includes safe storage for optional disabled signals.
  localparam int AW_BITS=$bits({bus.awid,bus.awaddr,bus.awlen,bus.awsize,bus.awburst,
    bus.awlock,bus.awcache,bus.awprot,bus.awqos,bus.awregion,bus.awuser});
  localparam int AR_BITS=$bits({bus.arid,bus.araddr,bus.arlen,bus.arsize,bus.arburst,
    bus.arlock,bus.arcache,bus.arprot,bus.arqos,bus.arregion,bus.aruser});
  localparam int W_BITS=$bits({bus.wdata,bus.wstrb,bus.wlast,bus.wuser});
  localparam int B_BITS=$bits({bus.bid,bus.bresp,bus.buser});
  localparam int R_BITS=$bits({bus.rid,bus.rdata,bus.rresp,bus.rlast,bus.ruser});
  logic [AW_BITS-1:0] prev_aw;
  logic [AR_BITS-1:0] prev_ar;
  logic [W_BITS-1:0] prev_w;
  logic [B_BITS-1:0] prev_b;
  logic [R_BITS-1:0] prev_r;

  covergroup transaction_cg with function sample(bit rd, int width, int beats, id_t id);
    option.per_instance=1;
    direction: coverpoint rd;
    data_width: coverpoint width {bins target256={256}; bins other=default;}
    length: coverpoint beats {bins one={1}; bins two={2}; bins four={4};
      bins sixteen={16}; bins others[]={[3:3],[5:15],[17:256]};}
    transaction_id: coverpoint id {option.auto_bin_max=256;}
    direction_length: cross direction,length;
  endgroup
  covergroup protocol_cg with function sample(int channel, bit stalled, int rd, int wr);
    option.per_instance=1;
    channels: coverpoint channel {bins aw={0}; bins w={1}; bins b={2}; bins ar={3}; bins r={4};}
    backpressure: coverpoint stalled;
    read_depth: coverpoint rd {bins idle={0}; bins one={1}; bins mid={[2:126]}; bins near_full={127}; bins full={128}; bins over={[129:4096]};}
    write_depth: coverpoint wr {bins idle={0}; bins one={1}; bins mid={[2:126]}; bins near_full={127}; bins full={128}; bins over={[129:4096]};}
    total_depth: coverpoint (rd+wr) {bins idle={0}; bins one={1}; bins mid={[2:126]}; bins near_full={127}; bins full={128}; bins over={[129:8192]};}
    channel_stall: cross channels,backpressure;
  endgroup
  covergroup error_cg with function sample(int kind, int response);
    option.per_instance=1;
    category: coverpoint kind {bins checks[]={[0:6]}; bins bus_response={7};}
    response_code: coverpoint response iff (kind==7) {bins okay={0}; bins exokay={1}; bins slverr={2}; bins decerr={3};}
  endgroup
  transaction_cg tx_cov=new;
  protocol_cg proto_cov=new;
  error_cg err_cov=new;

  function automatic int error_count();
    return protocol_errors+x_errors+alignment_errors+strobe_errors+
      response_errors+timeout_errors+policy_errors;
  endfunction
  function automatic void violation(axi4_check_kind kind, string msg);
    bit enabled;
    case(kind)
      AXI_PROTOCOL: enabled=ENABLE_PROTOCOL_CHECKS;
      AXI_X: enabled=ENABLE_X_CHECKS;
      AXI_ALIGNMENT: enabled=ENABLE_ALIGNMENT_CHECKS;
      AXI_STROBE: enabled=ENABLE_STROBE_CHECKS;
      AXI_RESPONSE: enabled=ENABLE_RESPONSE_CHECKS;
      AXI_TIMEOUT: enabled=ENABLE_TIMEOUT_CHECKS;
      AXI_POLICY: enabled=ENFORCE_TRAFFIC_POLICY;
    endcase
    if (!enabled) return;
    case(kind)
      AXI_PROTOCOL: protocol_errors++;
      AXI_X: x_errors++;
      AXI_ALIGNMENT: alignment_errors++;
      AXI_STROBE: strobe_errors++;
      AXI_RESPONSE: response_errors++;
      AXI_TIMEOUT: timeout_errors++;
      AXI_POLICY: policy_errors++;
    endcase
    if (ENABLE_COVERAGE && ENABLE_ERROR_COVERAGE) begin
      err_cov.sample(int'(kind),0); error_samples++;
    end
    if (FATAL_ON_ERROR) $fatal(1,"AXI_CHECK[%s] cycle=%0d %s",kind.name(),cycle,msg);
    else if (REPORT_ERRORS) $error("AXI_CHECK[%s] cycle=%0d %s",kind.name(),cycle,msg);
  endfunction

  function automatic void sample_transaction(bit rd, request q);
    if (ENABLE_COVERAGE && ENABLE_TRANSACTION_COVERAGE) begin
      tx_cov.sample(rd,DATA_WIDTH,q.beats,q.id); transaction_samples++;
      if (q.beats<=256) length_hits[q.beats]++;
      id_hits[q.id]++;
    end
  endfunction
  function automatic void sample_response(logic [1:0] resp);
    if (ENABLE_COVERAGE && ENABLE_ERROR_COVERAGE && !$isunknown(resp)) begin
      response_hits[resp]++; err_cov.sample(7,int'(resp)); error_samples++;
    end
  endfunction

  function automatic request new_request(id_t id, addr_t addr, int beats, int size,
                                          logic [1:0] burst, logic lock, bit validate=1);
    request q=new;
    longint unsigned bytes, aligned, last_byte;
    q.id=id; q.addr=addr; q.beats=beats; q.size=size; q.beat=0;
    q.progress=cycle; q.w_done=0; q.timed_out=0; q.response_timer_started=0;
    q.decodable=(burst==2'b01 && size<=FULL_SIZE);
    if (!validate) return q;
    if (burst!=2'b01) violation(AXI_POLICY,"monitor supports INCR traffic only");
    if (!SUPPORT_INCREMENTING_BURST && burst==2'b01)
      violation(AXI_POLICY,"INCR disabled by support capability");
    if (lock!=0) violation(AXI_POLICY,"exclusive/locked access unsupported");
    if (size>FULL_SIZE) violation(AXI_PROTOCOL,"AxSIZE exceeds data bus width");
    if (beats>MAX_BURST_BEATS) violation(AXI_POLICY,"burst exceeds configured maximum beats");
    if (burst==2'b11) violation(AXI_PROTOCOL,"reserved AxBURST");
    if (size<=FULL_SIZE) begin
      bytes=64'd1<<size; aligned=(longint'(addr)/bytes)*bytes;
      last_byte=aligned+bytes*beats-1;
      if (burst==2'b01 && ((longint'(addr)>>12)!=(last_byte>>12)))
        violation(AXI_PROTOCOL,"INCR burst crosses 4KB boundary");
      if (size<FULL_SIZE && beats>1 && (!SUPPORT_NARROW_BURST || !ALLOW_NARROW_BURST))
        violation(AXI_POLICY,"narrow multi-beat traffic disabled");
      if (size<FULL_SIZE && beats==1 && !ALLOW_NARROW_SINGLE)
        violation(AXI_POLICY,"narrow single-beat traffic disabled");
      if ((longint'(addr)%bytes)!=0) begin
        if (!SUPPORT_UNALIGNED_ACCESS || !ALLOW_UNALIGNED_ACCESS)
          violation(AXI_POLICY,"unaligned traffic disabled");
        if (REQUIRE_ALIGNED_ACCESS) violation(AXI_ALIGNMENT,"address violates explicit alignment policy");
      end
    end
    return q;
  endfunction

  function automatic strb_t legal_strobe(request q);
    longint unsigned bytes, base, first, last, bus_base;
    strb_t result='0;
    bytes=64'd1<<q.size; base=(longint'(q.addr)/bytes)*bytes+q.beat*bytes;
    first=(q.beat==0)?longint'(q.addr):base;
    last=base+bytes-1; bus_base=(first/LANES)*LANES;
    for (int lane=0;lane<LANES;lane++)
      if ((bus_base+lane>=first) && (bus_base+lane<=last)) result[lane]=1;
    return result;
  endfunction

  function automatic void check_wbeat(request q, wbeat_t wb);
    strb_t allowed;
    if (!$isunknown(wb.last) && wb.last !== (q.beat==q.beats-1))
      violation(AXI_PROTOCOL,"WLAST does not match AWLEN");
    if (q.decodable && !$isunknown(wb.strb)) begin
      allowed=legal_strobe(q);
      if ((wb.strb & ~allowed)!='0) violation(AXI_STROBE,"WSTRB asserts byte outside transfer lanes");
      if (!SUPPORT_BYTE_STROBE && wb.strb!=allowed)
        violation(AXI_POLICY,"partial/zero WSTRB disabled by support capability");
    end
  endfunction

  function automatic bit write_data_unknown();
    for (int lane=0;lane<LANES;lane++)
      if (bus.wstrb[lane]===1'b1 && $isunknown(bus.wdata[lane*8+:8])) return 1;
    return 0;
  endfunction
  function automatic bit read_data_unknown();
    strb_t mask;
    foreach(reads[i]) if (reads[i].id===bus.rid) begin
      if (!reads[i].decodable) return 0;
      mask=legal_strobe(reads[i]);
      for (int lane=0;lane<LANES;lane++)
        if (mask[lane] && $isunknown(bus.rdata[lane*8+:8])) return 1;
      return 0;
    end
    return 0;
  endfunction

  function automatic void check_channel(int ch, logic valid, logic ready, bit unknown_payload,
                                         bit changed);
    if ($isunknown({valid,ready})) violation(AXI_X,$sformatf("channel %0d control X/Z",ch));
    if (valid===1'b1 && unknown_payload) violation(AXI_X,$sformatf("channel %0d payload X/Z",ch));
    if (was_stalled[ch] && (valid!==1'b1 || changed))
      violation(AXI_PROTOCOL,$sformatf("channel %0d VALID/payload changed under backpressure",ch));
    if (valid===1'b1 && ready===1'b0) begin
      wait_cycles[ch]++;
      if (READY_TIMEOUT_CYCLES>0 && wait_cycles[ch]>=READY_TIMEOUT_CYCLES && !wait_reported[ch]) begin
        violation(AXI_TIMEOUT,$sformatf("channel %0d ready timeout",ch)); wait_reported[ch]=1;
      end
    end else begin wait_cycles[ch]=0; wait_reported[ch]=0; end
    was_stalled[ch]=(valid===1'b1 && ready!==1'b1);
    if (ENABLE_COVERAGE && ENABLE_PROTOCOL_COVERAGE) begin
      proto_cov.sample(ch,valid===1'b1 && ready===1'b0,current_reads,current_writes);
      protocol_samples++;
      if (valid===1'b1 && ready===1'b0) stall_cycles[ch]++;
    end
  endfunction

  // reset clears pending transactions and per-episode timers; cumulative evidence survives reset.
  task automatic reset_tracking();
    reads.delete(); writes.delete(); pending_w.delete();
    current_reads=0; current_writes=0; aw_checked=0; ar_checked=0; unpaired_w_timed_out=0;
    for (int ch=0;ch<5;ch++) begin
      was_stalled[ch]=0; wait_cycles[ch]=0; wait_reported[ch]=0;
    end
  endtask

  initial begin
    if (ADDR_WIDTH<12 || ADDR_WIDTH>63 || DATA_WIDTH<8 || DATA_WIDTH>1024 ||
        LANES!=(1<<FULL_SIZE) || ID_WIDTH<1 || ID_WIDTH>16 || LEN_WIDTH<1 || LEN_WIDTH>8)
      $fatal(1,"unsupported checker dimensions");
    if ($bits(bus.awaddr)!=ADDR_WIDTH || $bits(bus.wdata)!=DATA_WIDTH ||
        $bits(bus.awid)!=ID_WIDTH || $bits(bus.awlen)!=LEN_WIDTH)
      $fatal(1,"checker parameters must match connected axi4_if");
    if (SUPPORT_FIXED_BURST || SUPPORT_WRAPPING_BURST || SUPPORT_EXCLUSIVE_ACCESS || SUPPORT_LOCKED_ACCESS)
      $fatal(1,"checker implements normal INCR only; unsupported capability requested");
    if (MAX_BURST_BEATS<1 || MAX_BURST_BEATS>(1<<LEN_WIDTH) || MAX_TRACKED<1 ||
        MAX_OUTSTANDING_READS<1 || MAX_OUTSTANDING_WRITES<1 || MAX_OUTSTANDING_TOTAL<1 ||
        READ_TIMEOUT_CYCLES<0 || WRITE_TIMEOUT_CYCLES<0 || READY_TIMEOUT_CYCLES<0)
      $fatal(1,"invalid checker limits");
    foreach(length_hits[i]) length_hits[i]=0;
    foreach(id_hits[i]) id_hits[i]=0;
    foreach(stall_cycles[i]) stall_cycles[i]=0;
    foreach(response_hits[i]) response_hits[i]=0;
    foreach(depth_hits[i]) depth_hits[i]=0;
    reset_tracking();
  end

  always @(posedge bus.aclk or negedge bus.aresetn) begin : observe
    request q;
    wbeat_t wb;
    int idx;
    if (bus.aresetn===1'b0) reset_tracking();
    else if (bus.aresetn!==1'b1) violation(AXI_X,"reset X/Z");
    else begin
      cycle++;
      // Address/control validity is independent of READY. Check once per
      // offered transfer; stalled stability detects any subsequent mutation.
      if (bus.awvalid===1'b1 && !aw_checked &&
          !$isunknown({bus.awid,bus.awaddr,bus.awlen,bus.awsize,bus.awburst,bus.awlock})) begin
        q=new_request(bus.awid,bus.awaddr,int'(bus.awlen)+1,int'(bus.awsize),bus.awburst,bus.awlock);
        aw_checked=1;
      end
      if (bus.arvalid===1'b1 && !ar_checked &&
          !$isunknown({bus.arid,bus.araddr,bus.arlen,bus.arsize,bus.arburst,bus.arlock})) begin
        q=new_request(bus.arid,bus.araddr,int'(bus.arlen)+1,int'(bus.arsize),bus.arburst,bus.arlock);
        ar_checked=1;
      end
      if (bus.awvalid!==1'b1 || bus.awready===1'b1) aw_checked=0;
      if (bus.arvalid!==1'b1 || bus.arready===1'b1) ar_checked=0;
      check_channel(0,bus.awvalid,bus.awready,
        $isunknown({bus.awid,bus.awaddr,bus.awlen,bus.awsize,bus.awburst,bus.awlock,bus.awcache,bus.awprot,((bus.QOS_WIDTH>0)?bus.awqos:'0),((bus.REGION_WIDTH>0)?bus.awregion:'0),((bus.AWUSER_WIDTH>0)?bus.awuser:'0)}),
        prev_aw!=={bus.awid,bus.awaddr,bus.awlen,bus.awsize,bus.awburst,bus.awlock,bus.awcache,bus.awprot,((bus.QOS_WIDTH>0)?bus.awqos:'0),((bus.REGION_WIDTH>0)?bus.awregion:'0),((bus.AWUSER_WIDTH>0)?bus.awuser:'0)});
      check_channel(1,bus.wvalid,bus.wready,write_data_unknown() || $isunknown({bus.wstrb,bus.wlast,((bus.WUSER_WIDTH>0)?bus.wuser:'0)}),
        prev_w!=={bus.wdata,bus.wstrb,bus.wlast,((bus.WUSER_WIDTH>0)?bus.wuser:'0)});
      check_channel(2,bus.bvalid,bus.bready,$isunknown({bus.bid,bus.bresp,((bus.BUSER_WIDTH>0)?bus.buser:'0)}),
        prev_b!=={bus.bid,bus.bresp,((bus.BUSER_WIDTH>0)?bus.buser:'0)});
      check_channel(3,bus.arvalid,bus.arready,
        $isunknown({bus.arid,bus.araddr,bus.arlen,bus.arsize,bus.arburst,bus.arlock,bus.arcache,bus.arprot,((bus.QOS_WIDTH>0)?bus.arqos:'0),((bus.REGION_WIDTH>0)?bus.arregion:'0),((bus.ARUSER_WIDTH>0)?bus.aruser:'0)}),
        prev_ar!=={bus.arid,bus.araddr,bus.arlen,bus.arsize,bus.arburst,bus.arlock,bus.arcache,bus.arprot,((bus.QOS_WIDTH>0)?bus.arqos:'0),((bus.REGION_WIDTH>0)?bus.arregion:'0),((bus.ARUSER_WIDTH>0)?bus.aruser:'0)});
      check_channel(4,bus.rvalid,bus.rready,read_data_unknown() || $isunknown({bus.rid,bus.rresp,bus.rlast,((bus.RUSER_WIDTH>0)?bus.ruser:'0)}),
        prev_r!=={bus.rid,bus.rdata,bus.rresp,bus.rlast,((bus.RUSER_WIDTH>0)?bus.ruser:'0)});
      prev_aw={bus.awid,bus.awaddr,bus.awlen,bus.awsize,bus.awburst,bus.awlock,bus.awcache,bus.awprot,((bus.QOS_WIDTH>0)?bus.awqos:'0),((bus.REGION_WIDTH>0)?bus.awregion:'0),((bus.AWUSER_WIDTH>0)?bus.awuser:'0)};
      prev_w={bus.wdata,bus.wstrb,bus.wlast,((bus.WUSER_WIDTH>0)?bus.wuser:'0)};
      prev_b={bus.bid,bus.bresp,((bus.BUSER_WIDTH>0)?bus.buser:'0)};
      prev_ar={bus.arid,bus.araddr,bus.arlen,bus.arsize,bus.arburst,bus.arlock,bus.arcache,bus.arprot,((bus.QOS_WIDTH>0)?bus.arqos:'0),((bus.REGION_WIDTH>0)?bus.arregion:'0),((bus.ARUSER_WIDTH>0)?bus.aruser:'0)};
      prev_r={bus.rid,bus.rdata,bus.rresp,bus.rlast,((bus.RUSER_WIDTH>0)?bus.ruser:'0)};

      // Validate VALID itself, even if READY is low. Only previously accepted
      // requests/data authorize a response, never a same-edge handshake.
      if (bus.bvalid===1'b1 && !$isunknown({bus.bid,bus.bresp})) begin
        idx=-1;
        foreach(writes[i]) if (idx<0 && writes[i].id==bus.bid) idx=i;
        if (idx<0) violation(AXI_RESPONSE,"BID has no outstanding write");
        else if (!writes[idx].w_done) violation(AXI_RESPONSE,"B precedes complete W or same-ID oldest write");
        if (bus.bresp!=2'b00) violation(AXI_RESPONSE,"non-OKAY BRESP (normal access)");
        if (bus.bready===1'b1) begin
          b_count++; sample_response(bus.bresp);
          if (idx>=0) writes.delete(idx);
        end
      end
      if (bus.rvalid===1'b1 && !$isunknown({bus.rid,bus.rresp,bus.rlast})) begin
        idx=-1;
        foreach(reads[i]) if (idx<0 && reads[i].id==bus.rid) idx=i;
        if (idx<0) violation(AXI_RESPONSE,"RID has no outstanding read");
        else if (bus.rlast !== (reads[idx].beat==reads[idx].beats-1))
          violation(AXI_PROTOCOL,"RLAST does not match oldest same-ID ARLEN");
        if (bus.rresp!=2'b00) violation(AXI_RESPONSE,"non-OKAY RRESP (normal access)");
        if (bus.rready===1'b1) begin
          r_count++; sample_response(bus.rresp);
          if (idx>=0) begin
            q=reads[idx]; q.beat++; q.progress=cycle; q.timed_out=0;
            // Recover by advertised length after malformed LAST, not by observed LAST.
            if (q.beat==q.beats) reads.delete(idx);
          end
        end
      end
      if (bus.awvalid===1'b1 && bus.awready===1'b1 &&
          !$isunknown({bus.awid,bus.awaddr,bus.awlen,bus.awsize,bus.awburst,bus.awlock})) begin
        q=new_request(bus.awid,bus.awaddr,int'(bus.awlen)+1,int'(bus.awsize),bus.awburst,bus.awlock,0);
        writes.push_back(q); aw_count++; sample_transaction(0,q);
      end
      if (bus.arvalid===1'b1 && bus.arready===1'b1 &&
          !$isunknown({bus.arid,bus.araddr,bus.arlen,bus.arsize,bus.arburst,bus.arlock})) begin
        q=new_request(bus.arid,bus.araddr,int'(bus.arlen)+1,int'(bus.arsize),bus.arburst,bus.arlock,0);
        reads.push_back(q); ar_count++; sample_transaction(1,q);
      end
      // If AW is already known, LAST/lane validity is required while VALID,
      // even when READY never arrives. W before AW is checked when paired.
      if (bus.wvalid===1'b1 && bus.wready!==1'b1 && pending_w.size()==0) begin
        idx=-1;
        foreach(writes[i]) if (idx<0 && !writes[i].w_done) idx=i;
        if (idx>=0) check_wbeat(writes[idx],'{bus.wstrb,bus.wlast,cycle});
      end
      if (bus.wvalid===1'b1 && bus.wready===1'b1) begin
        pending_w.push_back('{bus.wstrb,bus.wlast,cycle}); w_count++;
      end
      // AXI4 W has no ID: accepted data belongs to global AW order. W may
      // legally arrive before AW, so defer address-dependent checks until paired.
      idx=0;
      while (pending_w.size()>0 && idx<writes.size()) begin
        q=writes[idx];
        if (q.w_done) idx++;
        else begin
          wb=pending_w.pop_front(); unpaired_w_timed_out=0;
          check_wbeat(q,wb);
          q.beat++; q.progress=cycle; q.timed_out=0;
          if (q.beat==q.beats) q.w_done=1;
        end
      end
      current_reads=reads.size(); current_writes=writes.size();
      if (current_reads>MAX_OUTSTANDING_READS) violation(AXI_POLICY,"read outstanding limit exceeded");
      if (current_writes>MAX_OUTSTANDING_WRITES) violation(AXI_POLICY,"write outstanding limit exceeded");
      if (current_reads+current_writes>MAX_OUTSTANDING_TOTAL) violation(AXI_POLICY,"total outstanding limit exceeded");
      if (current_reads>max_reads_seen) max_reads_seen=current_reads;
      if (current_writes>max_writes_seen) max_writes_seen=current_writes;
      if (current_reads+current_writes>max_total_seen) max_total_seen=current_reads+current_writes;
      if (ENABLE_COVERAGE && ENABLE_PROTOCOL_COVERAGE) begin
        if (current_reads+current_writes==0) depth_hits[0]++;
        if (current_reads+current_writes==1) depth_hits[1]++;
        if (current_reads+current_writes==127) depth_hits[2]++;
        if (current_reads+current_writes==128) depth_hits[3]++;
      end
      // Response budgets start only when this request is eligible for a
      // response. Waiting behind the same ID or the global W FIFO is not
      // inactivity of this response channel. This matches the queued driver.
      foreach(reads[i]) begin
        bit head;
        head=1;
        for (int j=0;j<i;j++) if (reads[j].id==reads[i].id) head=0;
        if (head) begin
          if (!reads[i].response_timer_started) begin
            reads[i].response_timer_started=1; reads[i].progress=cycle;
          end else if (READ_TIMEOUT_CYCLES>0 && !reads[i].timed_out &&
                       cycle-reads[i].progress>=READ_TIMEOUT_CYCLES) begin
            violation(AXI_TIMEOUT,"read response inactivity timeout"); reads[i].timed_out=1;
          end
        end
      end
      foreach(writes[i]) begin
        bit head;
        head=1;
        for (int j=0;j<i;j++) if (writes[j].id==writes[i].id) head=0;
        if (head && writes[i].w_done) begin
          if (!writes[i].response_timer_started) begin
            writes[i].response_timer_started=1; writes[i].progress=cycle;
          end else if (WRITE_TIMEOUT_CYCLES>0 && !writes[i].timed_out &&
                       cycle-writes[i].progress>=WRITE_TIMEOUT_CYCLES) begin
            violation(AXI_TIMEOUT,"write response inactivity timeout"); writes[i].timed_out=1;
          end
        end
      end
      if (pending_w.size()==0) unpaired_w_timed_out=0;
      else if (READY_TIMEOUT_CYCLES>0 && !unpaired_w_timed_out &&
               cycle-pending_w[0].accepted_cycle>=READY_TIMEOUT_CYCLES) begin
        violation(AXI_TIMEOUT,"accepted W waiting for AW timeout"); unpaired_w_timed_out=1;
      end
      if (reads.size()>MAX_TRACKED || writes.size()>MAX_TRACKED || pending_w.size()>MAX_TRACKED*MAX_BURST_BEATS)
        $fatal(1,"checker tracking resource exhausted; reset or raise MAX_TRACKED");
    end
  end

  function automatic void check_quiescent();
    if (reads.size()!=0 || writes.size()!=0 || pending_w.size()!=0)
      violation(AXI_PROTOCOL,$sformatf("unfinished traffic: reads=%0d writes=%0d unpaired_W=%0d",
        reads.size(),writes.size(),pending_w.size()));
  endfunction
endmodule
