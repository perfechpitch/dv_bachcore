PYTHON ?= $(shell command -v python3 >/dev/null 2>&1 && echo python3 || echo python)
export PYTHONDONTWRITEBYTECODE := 1
TEST   ?= axi4_doc_test
SEQ    ?=

VCS    ?= vcs
VERDI  ?= verdi
MODULECMD ?= /fastone/softwares/modules/bin/modulecmd
VCS_MODULE ?= vcs/S-2021.09-SP2
VERDI_MODULE ?= verdi/T-2022.06
LOAD_VCS := eval `$(MODULECMD) sh load $(VCS_MODULE)` &&
LOAD_VERDI := eval `$(MODULECMD) sh load $(VERDI_MODULE)` &&

FILELIST := filelist.f
PLAN     := docs/seq/seq_plan.json
SEQ_WORKBOOK := docs/seq/seq_table.xlsx
BASE_SEQ_SHEET ?= BASE_SEQ
USER_SEQ_SHEET ?= USER_SEQ
TABLE_USAGE_SHEET ?= TABLE_USAGE
MAKE_USAGE_SHEET ?= MAKE_USAGE
SEG_USAGE_SHEET ?= $(TABLE_USAGE_SHEET)
BASE_SEQ_TABLE := $(SEQ_WORKBOOK)::$(BASE_SEQ_SHEET)
USER_SEQ_TABLE := $(SEQ_WORKBOOK)::$(USER_SEQ_SHEET)
IRQ_SEQ_TXT := docs/txt/irq_seq.txt
VIP_WORKBOOK ?= docs/vip/vip_cfg.xlsx
BASE_VIP_LOCK ?= docs/vip/base_vip_cfg.lock.json
BASE_VIP_SHEET ?= BASE_VIP_CFG
DUT_VIP_SHEET ?= DUT_BUFF_FEATURE
FINAL_VIP_SHEET ?= FINAL_FEATURE
BASE_VIP_CFG := $(VIP_WORKBOOK)::$(BASE_VIP_SHEET)
DUT_VIP_CFG := $(VIP_WORKBOOK)::$(DUT_VIP_SHEET)
FINAL_VIP_CFG := $(VIP_WORKBOOK)::$(FINAL_VIP_SHEET)
ACTIVE_VIP_JSON ?= tb/generated/axi4_vip_cfg.json
SEG_USAGE := $(SEQ_WORKBOOK)::$(SEG_USAGE_SHEET)
MAKE_USAGE := $(SEQ_WORKBOOK)::$(MAKE_USAGE_SHEET)
GEN_CFG  := tb/generated/axi4_vip_cfg_pkg.sv
GEN_VIP_FILELIST := tb/generated/axi4_vip_filelist.f
GEN_SEQ_CFG := tb/generated/axi4_seq_cfg_pkg.sv
GEN_SEQ  := tb/generated/axi4_generated_seq_pkg.sv
GEN_SEQ_DIR := tb/generated/seqs
GEN_IRQ_SEQ := tb/generated/axi4_irq_handler_seq.svh
IRQ_EN ?= 0
write_mode ?=
range_write_mode ?=
write_tr_mode ?=
tr_write_mode ?=
RUN_AFTER_USER_SEQ ?= 1
WAVE ?= 1
WORK_ROOT ?= work
SEQ_ALL_WORK_DIR ?= $(WORK_ROOT)/SEQ_ALL
SEQ_ALL_REQUESTED = $(filter SEQ_ALL seq_all,$(MAKECMDGOALS))
SEQ_ALL_VERDI_SEQ = $(strip $(if $(and $(SEQ_ALL_REQUESTED),$(filter verdi,$(MAKECMDGOALS))),$(filter-out SEQ_ALL seq_all verdi,$(MAKECMDGOALS))))
RUN_WORK_DIR ?= $(if $(strip $(SEQ)),$(WORK_ROOT)/$(strip $(SEQ)),$(if $(strip $(SEQ_ALL_VERDI_SEQ)),$(SEQ_ALL_WORK_DIR)/$(SEQ_ALL_VERDI_SEQ),$(SEQ_ALL_WORK_DIR)))
RUN_SIMV ?= $(RUN_WORK_DIR)/simv
RUN_CSRC_DIR ?= $(RUN_WORK_DIR)/csrc
COMPILE_LOG ?= $(RUN_WORK_DIR)/compile.log
WAVE_FILE ?= $(RUN_WORK_DIR)/axi4_bfm.fsdb
RUN_LOG ?= $(RUN_WORK_DIR)/sim.log
VERDI_ARGS ?=
NOVAS_PLI_DIR ?=
CLEAN_DIRS := csrc simv.daidir DVEfiles verdiLog novas_dump.log $(WORK_ROOT)
CLEAN_FILES := simv ucli.key vc_hdrs.h inter.vpd novas.conf novas.rc *.fsdb *.vcd *.vpd *.vdb *.log

SEQ_ARG :=
ifneq ($(strip $(SEQ)),)
SEQ_ARG += +SEQ=$(SEQ)
endif

IRQ_ARG := +IRQ_EN=$(IRQ_EN)

WRITE_MODE_VALUE := $(strip $(if $(write_mode),$(write_mode),$(WRITE_MODE)))
RANGE_WRITE_MODE_VALUE := $(strip $(if $(range_write_mode),$(range_write_mode),$(RANGE_WRITE_MODE)))
WRITE_TR_MODE_VALUE := $(strip $(if $(write_tr_mode),$(write_tr_mode),$(WRITE_TR_MODE)))
TR_WRITE_MODE_VALUE := $(strip $(if $(tr_write_mode),$(tr_write_mode),$(TR_WRITE_MODE)))

WRITE_MODE_ARGS :=
ifneq ($(WRITE_MODE_VALUE),)
WRITE_MODE_ARGS += +write_mode=$(WRITE_MODE_VALUE)
endif
ifneq ($(RANGE_WRITE_MODE_VALUE),)
WRITE_MODE_ARGS += +range_write_mode=$(RANGE_WRITE_MODE_VALUE)
endif
ifneq ($(WRITE_TR_MODE_VALUE),)
WRITE_MODE_ARGS += +write_tr_mode=$(WRITE_TR_MODE_VALUE)
endif
ifneq ($(TR_WRITE_MODE_VALUE),)
WRITE_MODE_ARGS += +tr_write_mode=$(TR_WRITE_MODE_VALUE)
endif

FSDB_ARGS :=
ifeq ($(strip $(WAVE)),1)
FSDB_ARGS += +FSDB_FILE=$(WAVE_FILE)
endif

SIM_ARGS := $(strip $(IRQ_ARG) $(WRITE_MODE_ARGS) $(FSDB_ARGS))

WAVE_COMPILE_FLAGS :=
ifeq ($(strip $(WAVE)),1)
WAVE_COMPILE_FLAGS += +define+DUMP_FSDB -debug_access+all -kdb
endif

.DEFAULT_GOAL := default

.PHONY: default vip_cfg seq_gen user_seq clear_user_seq SEQ_ALL seq_all run verdi clean help _gen_cfg _gen_vip_cfg _gen_seq_cfg _gen_seg_usage _gen_plan _gen_irq_seq _check_seq _check_seq_in_plan _compile_current _run_each_user_seq _run_one_from_all _run_seq _open_wave vip_cfg_lock

default:
ifeq ($(strip $(SEQ)),)
	@$(PYTHON) scripts/show_help.py --plan $(PLAN) --base-seq-table $(BASE_SEQ_TABLE) --user-seq-table $(USER_SEQ_TABLE) --table-usage $(SEG_USAGE) --make-usage $(MAKE_USAGE) --vip-workbook $(VIP_WORKBOOK) --base-vip-cfg $(BASE_VIP_CFG) --dut-vip-cfg $(DUT_VIP_CFG) --final-vip-cfg $(FINAL_VIP_CFG) --test $(TEST)
	@echo ""
	@echo "ERROR: specify a seq with 'make SEQ=<seq_name>' or run all with 'make SEQ_ALL'."
	@exit 2
else
	$(MAKE) run
endif

_gen_cfg: _gen_vip_cfg _gen_seq_cfg

vip_cfg:
	$(PYTHON) scripts/check_base_vip_cfg.py --cfg $(VIP_WORKBOOK)::$(BASE_VIP_SHEET) --lock $(BASE_VIP_LOCK)
	$(PYTHON) scripts/gen_dut_vip_cfg.py --workbook $(VIP_WORKBOOK) --base-sheet $(BASE_VIP_SHEET) --dut-sheet $(DUT_VIP_SHEET) --final-sheet $(FINAL_VIP_SHEET)
	$(PYTHON) scripts/vip_table_to_json.py --cfg $(FINAL_VIP_CFG) --out $(ACTIVE_VIP_JSON)
	$(PYTHON) scripts/gen_vip_cfg.py --cfg $(ACTIVE_VIP_JSON) --out $(GEN_CFG)
	$(PYTHON) scripts/gen_axi_vip_filelist.py --cfg $(ACTIVE_VIP_JSON) --out $(GEN_VIP_FILELIST) --project-root .

vip_cfg_lock:
	$(PYTHON) scripts/check_base_vip_cfg.py --cfg $(VIP_WORKBOOK)::$(BASE_VIP_SHEET) --lock $(BASE_VIP_LOCK) --refresh

_gen_vip_cfg: vip_cfg

_gen_seq_cfg: _gen_seg_usage
	$(PYTHON) scripts/gen_seq_cfg.py --usage $(SEG_USAGE) --out $(GEN_SEQ_CFG)

_gen_seg_usage: _gen_plan
	$(PYTHON) scripts/gen_seg_usage.py --plan $(PLAN) --out $(SEG_USAGE) --make-out $(MAKE_USAGE) --base-seq-table $(BASE_SEQ_TABLE) --user-seq-table $(USER_SEQ_TABLE) --vip-workbook $(VIP_WORKBOOK) --base-vip-cfg $(BASE_VIP_CFG) --dut-vip-cfg $(DUT_VIP_CFG) --final-vip-cfg $(FINAL_VIP_CFG) --test $(TEST)

_gen_plan:
	$(PYTHON) scripts/update_user_seq_table.py --base-table $(BASE_SEQ_TABLE) --user-table $(USER_SEQ_TABLE) --normalize-only
	$(PYTHON) scripts/table_to_seq_plan.py --table $(BASE_SEQ_TABLE) --table $(USER_SEQ_TABLE) --vip-cfg $(ACTIVE_VIP_JSON) --out $(PLAN)

_gen_irq_seq:
	$(PYTHON) scripts/gen_irq_seq.py --txt $(IRQ_SEQ_TXT) --out $(GEN_IRQ_SEQ)

seq_gen: _gen_vip_cfg _gen_plan _gen_seg_usage _gen_seq_cfg _gen_irq_seq
	$(PYTHON) scripts/gen_axi4_seq.py --plan $(PLAN) --out $(GEN_SEQ) --seq-dir $(GEN_SEQ_DIR)

user_seq:
	@backup="$(SEQ_WORKBOOK).bak.$$$$"; \
	had_seq_workbook=0; \
	if [ -f "$(SEQ_WORKBOOK)" ]; then \
	  cp "$(SEQ_WORKBOOK)" "$$backup" || exit $$?; \
	  had_seq_workbook=1; \
	fi; \
	rollback_user_seq() { \
	  status=$$1; \
	  echo "ERROR: user_seq flow failed; rolling back $(SEQ_WORKBOOK)."; \
	  if [ "$$had_seq_workbook" = "1" ]; then \
	    cp "$$backup" "$(SEQ_WORKBOOK)" || exit $$status; \
	  else \
	    rm -f "$(SEQ_WORKBOOK)"; \
	  fi; \
	  rm -f "$$backup"; \
	  echo "Regenerating previous generated seq files after rollback..."; \
	  $(MAKE) seq_gen PYTHON=$(PYTHON) || true; \
	  exit $$status; \
	}; \
	BASE_SEQ="$(BASE_SEQ)" \
	NEW_SEQ="$(NEW_SEQ)" \
	SEQ_DESCRIPTION="$(SEQ_DESCRIPTION)" \
	seq_description="$(seq_description)" \
	SEQ_DESC="$(SEQ_DESC)" \
	seq_desc="$(seq_desc)" \
	SEQ_GAP="$(SEQ_GAP)" \
	seq_gap="$(seq_gap)" \
	ADDR="$(ADDR)" \
	addr="$(addr)" \
	BASE_ADDR="$(BASE_ADDR)" \
	base_addr="$(base_addr)" \
	RANGE_BASE_ADDR="$(RANGE_BASE_ADDR)" \
	range_base_addr="$(range_base_addr)" \
	ADDR_LIST="$(ADDR_LIST)" \
	addr_list="$(addr_list)" \
	ADDRS="$(ADDRS)" \
	addrs="$(addrs)" \
	SINGLE_ADDR_LIST="$(SINGLE_ADDR_LIST)" \
	single_addr_list="$(single_addr_list)" \
	DATA="$(DATA)" \
	data="$(data)" \
	DATA_LIST="$(DATA_LIST)" \
	data_list="$(data_list)" \
	DATAS="$(DATAS)" \
	datas="$(datas)" \
	SINGLE_DATA_LIST="$(SINGLE_DATA_LIST)" \
	single_data_list="$(single_data_list)" \
	EXPECT="$(EXPECT)" \
	expect="$(expect)" \
	EXPECT_LIST="$(EXPECT_LIST)" \
	expect_list="$(expect_list)" \
	EXPECTS="$(EXPECTS)" \
	expects="$(expects)" \
	SINGLE_EXPECT_LIST="$(SINGLE_EXPECT_LIST)" \
	single_expect_list="$(single_expect_list)" \
	TR_GAP="$(TR_GAP)" \
	tr_gap="$(tr_gap)" \
	RANGE_GAP="$(RANGE_GAP)" \
	range_gap="$(range_gap)" \
	ADDR_STRIDE="$(ADDR_STRIDE)" \
	addr_stride="$(addr_stride)" \
	RANGE_ADDR_STRIDE="$(RANGE_ADDR_STRIDE)" \
	range_addr_stride="$(range_addr_stride)" \
	COUNT="$(COUNT)" \
	count="$(count)" \
	RANGE_COUNT="$(RANGE_COUNT)" \
	range_count="$(range_count)" \
	DATA_FILE="$(DATA_FILE)" \
	data_file="$(data_file)" \
	RANGE_DATA_FILE="$(RANGE_DATA_FILE)" \
	range_data_file="$(range_data_file)" \
	DATA_START="$(DATA_START)" \
	data_start="$(data_start)" \
	RANGE_DATA_START="$(RANGE_DATA_START)" \
	range_data_start="$(range_data_start)" \
	READBACK="$(READBACK)" \
	readback="$(readback)" \
	RANGE_READBACK="$(RANGE_READBACK)" \
	range_readback="$(range_readback)" \
	OVERRIDES="$(OVERRIDES)" \
	WRITE_MODE="$(WRITE_MODE)" \
	write_mode="$(write_mode)" \
	RANGE_WRITE_MODE="$(RANGE_WRITE_MODE)" \
	range_write_mode="$(range_write_mode)" \
	WRITE_TR_MODE="$(WRITE_TR_MODE)" \
	write_tr_mode="$(write_tr_mode)" \
	TR_WRITE_MODE="$(TR_WRITE_MODE)" \
	tr_write_mode="$(tr_write_mode)" \
	$(PYTHON) scripts/update_user_seq_table.py --base-table $(BASE_SEQ_TABLE) --user-table $(USER_SEQ_TABLE) || rollback_user_seq $$?; \
	$(MAKE) seq_gen PYTHON=$(PYTHON) || rollback_user_seq $$?; \
	if [ "$(strip $(RUN_AFTER_USER_SEQ))" = "1" ]; then \
	  $(MAKE) SEQ="$(NEW_SEQ)" run PYTHON=$(PYTHON) IRQ_EN=$(IRQ_EN) || rollback_user_seq $$?; \
	else \
	  echo "Generated user seq $(NEW_SEQ). RUN_AFTER_USER_SEQ=0, skip compile and run."; \
	fi; \
	rm -f "$$backup"

clear_user_seq:
	@CLEAR_SEQ="$(CLEAR_SEQ)" \
	USER_SEQ="$(USER_SEQ)" \
	REMOVE_SEQ="$(REMOVE_SEQ)" \
	NEW_SEQ="$(NEW_SEQ)" \
	$(PYTHON) scripts/update_user_seq_table.py --base-table $(BASE_SEQ_TABLE) --user-table $(USER_SEQ_TABLE) --clear-user-table
	$(MAKE) seq_gen PYTHON=$(PYTHON)

ifneq ($(and $(SEQ_ALL_REQUESTED),$(filter verdi,$(MAKECMDGOALS))),)
SEQ_ALL:
	@test "$(words $(SEQ_ALL_VERDI_SEQ))" -eq 1 || { \
	  echo "ERROR: use 'make SEQ_ALL <seq_name> verdi' to open one existing SEQ_ALL waveform."; \
	  exit 2; \
	}
	@$(PYTHON) scripts/check_seq_in_plan.py --plan $(PLAN) --seq "$(SEQ_ALL_VERDI_SEQ)" --run-all-only
	@echo "SEQ_ALL + $(SEQ_ALL_VERDI_SEQ) + verdi: skip simulation and open existing $(WAVE_FILE)."
else
SEQ_ALL: seq_gen _run_each_user_seq
endif

seq_all: SEQ_ALL

ifneq ($(strip $(SEQ_ALL_VERDI_SEQ)),)
.PHONY: $(SEQ_ALL_VERDI_SEQ)
$(SEQ_ALL_VERDI_SEQ):
	@:
endif

run: _check_seq seq_gen _check_seq_in_plan _compile_current _run_seq

_check_seq:
	@test -n "$(strip $(SEQ))" || { echo "ERROR: use 'make SEQ=<seq_name>' for one seq, or 'make SEQ_ALL' for all seq."; exit 2; }

_check_seq_in_plan:
	$(PYTHON) scripts/check_seq_in_plan.py --plan $(PLAN) --seq "$(SEQ)"

_run_each_user_seq:
	@seqs="$$($(PYTHON) scripts/check_seq_in_plan.py --plan "$(PLAN)" --list-run-all)"; \
	if [ -z "$$seqs" ]; then \
	  echo "ERROR: SEQ_ALL has no user sequences. Add entries to $(USER_SEQ_TABLE) first."; \
	  exit 2; \
	fi; \
	set -- $$seqs; \
	total=$$#; \
	index=0; \
	mkdir -p "$(SEQ_ALL_WORK_DIR)"; \
	for seq in $$seqs; do \
	  index=$$((index + 1)); \
	  echo ""; \
	  echo "================================================================"; \
	  echo "SEQ_ALL [$$index/$$total]: $$seq"; \
	  echo "Output directory: $(SEQ_ALL_WORK_DIR)/$$seq"; \
	  echo "================================================================"; \
	  $(MAKE) --no-print-directory SEQ="$$seq" RUN_WORK_DIR="$(SEQ_ALL_WORK_DIR)/$$seq" _run_one_from_all || exit $$?; \
	done; \
	echo ""; \
	echo "SEQ_ALL completed: $$total independent simulation(s) under $(SEQ_ALL_WORK_DIR)."

_run_one_from_all: _check_seq_in_plan _compile_current _run_seq

_compile_current:
	@mkdir -p "$(RUN_WORK_DIR)" "$(RUN_CSRC_DIR)" "$$(dirname "$(COMPILE_LOG)")"
	$(LOAD_VCS) \
	if [ "$(WAVE)" = "1" ]; then eval `$(MODULECMD) sh load $(VERDI_MODULE)` || exit $$?; fi; \
	PLI_FLAGS=""; \
	if [ "$(WAVE)" = "1" ]; then \
	  for d in "$(NOVAS_PLI_DIR)" "$${NOVAS_HOME:-}/share/PLI/VCS/LINUX64" "$${VERDI_HOME:-}/share/PLI/VCS/LINUX64" "$$(dirname "$$(dirname "$$(command -v $(VERDI) 2>/dev/null)")")/share/PLI/VCS/LINUX64" /fastone/softwares/synopsys/verdi/*/share/PLI/VCS/LINUX64 /fastone/softwares/synopsys/verdi*/share/PLI/VCS/LINUX64 /fastone/softwares/synopsys/*/share/PLI/VCS/LINUX64; do \
	    if [ -f "$$d/novas.tab" ] && [ -f "$$d/pli.a" ]; then \
	      PLI_FLAGS="-P $$d/novas.tab $$d/pli.a"; \
	      echo "Using FSDB PLI: $$d"; \
	      break; \
	    fi; \
	  done; \
	  if [ -z "$$PLI_FLAGS" ]; then \
	    echo "ERROR: cannot find Verdi FSDB PLI. Set NOVAS_PLI_DIR=<path-to-PLI/VCS/LINUX64>."; \
	    exit 2; \
	  fi; \
	fi; \
	$(VCS) -full64 -sverilog -ntb_opts uvm -timescale=1ns/1ps +define+USE_SIMPLE_AXI4_BFM $(WAVE_COMPILE_FLAGS) $$PLI_FLAGS -f $(FILELIST) -Mdir=$(RUN_CSRC_DIR) -o $(RUN_SIMV) -l $(COMPILE_LOG); \
	compile_status=$$?; \
	for artifact in ucli.key vc_hdrs.h inter.vpd novas.conf novas.rc novas_dump.log; do \
	  if [ -e "$$artifact" ]; then mv -f "$$artifact" "$(RUN_WORK_DIR)/"; fi; \
	done; \
	for artifact_dir in DVEfiles verdiLog; do \
	  if [ -e "$$artifact_dir" ]; then rm -rf "$(RUN_WORK_DIR)/$$artifact_dir"; mv "$$artifact_dir" "$(RUN_WORK_DIR)/"; fi; \
	done; \
	exit $$compile_status

_run_seq:
	@test -x "$(RUN_SIMV)" || { echo "Missing $(RUN_SIMV). Run make SEQ=<seq_name> first."; exit 1; }
	@mkdir -p "$(RUN_WORK_DIR)" "$$(dirname "$(RUN_LOG)")" "$$(dirname "$(WAVE_FILE)")"; \
	echo "Run output dir: $(RUN_WORK_DIR)"; \
	echo "Simulator     : $(RUN_SIMV)"; \
	echo "Compile log   : $(COMPILE_LOG)"; \
	echo "Run log       : $(RUN_LOG)"; \
	if [ "$(WAVE)" = "1" ]; then echo "Waveform      : $(WAVE_FILE)"; fi; \
	collect_artifacts() { \
	  for artifact in ucli.key vc_hdrs.h inter.vpd novas.conf novas.rc novas_dump.log; do \
	    if [ -e "$$artifact" ]; then mv -f "$$artifact" "$(RUN_WORK_DIR)/"; fi; \
	  done; \
	  for artifact_dir in DVEfiles verdiLog; do \
	    if [ -e "$$artifact_dir" ]; then rm -rf "$(RUN_WORK_DIR)/$$artifact_dir"; mv "$$artifact_dir" "$(RUN_WORK_DIR)/"; fi; \
	  done; \
	}; \
	run_log="$(RUN_LOG)"; \
	"$(RUN_SIMV)" +UVM_TESTNAME=$(TEST) $(SEQ_ARG) $(SIM_ARGS) > "$$run_log" 2>&1; \
	sim_status=$$?; \
	collect_artifacts; \
	cat "$$run_log"; \
	if [ $$sim_status -ne 0 ]; then exit $$sim_status; fi; \
	if grep -E 'UVM_(ERROR|FATAL)[[:space:]]*:[[:space:]]*[1-9][0-9]*' "$$run_log" >/dev/null; then \
	  echo "ERROR: UVM_ERROR or UVM_FATAL count is non-zero. See $$run_log."; \
	  exit 1; \
	fi

verdi: _open_wave

_open_wave:
	@test -f "$(WAVE_FILE)" || { echo "Missing $(WAVE_FILE). Run 'make SEQ_ALL' or 'make SEQ=<seq_name>' first to generate it."; exit 1; }
	@echo "Opening $(WAVE_FILE) with $(VERDI)..."
	$(LOAD_VERDI) \
	mkdir -p "$(RUN_WORK_DIR)"; \
	ssf_dir="$$(cd "$$(dirname "$(WAVE_FILE)")" && pwd)"; \
	ssf_file="$$ssf_dir/$$(basename "$(WAVE_FILE)")"; \
	cd "$(RUN_WORK_DIR)" && $(VERDI) -ssf "$$ssf_file" $(VERDI_ARGS) &

clean:
	rm -rf $(CLEAN_DIRS) $(CLEAN_FILES)
	@echo "Cleaned simulator, log, and waveform outputs."

help:
	@$(PYTHON) scripts/show_help.py --plan $(PLAN) --base-seq-table $(BASE_SEQ_TABLE) --user-seq-table $(USER_SEQ_TABLE) --table-usage $(SEG_USAGE) --make-usage $(MAKE_USAGE) --vip-workbook $(VIP_WORKBOOK) --base-vip-cfg $(BASE_VIP_CFG) --dut-vip-cfg $(DUT_VIP_CFG) --final-vip-cfg $(FINAL_VIP_CFG) --test $(TEST)
