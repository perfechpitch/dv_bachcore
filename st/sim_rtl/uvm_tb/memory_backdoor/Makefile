SHELL := /bin/bash
export LC_ALL := C
export LANG := C

.DEFAULT_GOAL := help

PROJECT_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
WORK_ROOT  := $(PROJECT_DIR)/work
TESTCASE_DIR := $(PROJECT_DIR)/testcase
CONFIG     ?= $(PROJECT_DIR)/memory_config.yaml
CONFIG_READER := $(PROJECT_DIR)/scripts/read_memory_config.awk
FILE_INIT_VALIDATOR := $(PROJECT_DIR)/scripts/validate_file_init_testcase.awk
BANK_RECORD_VALIDATOR := $(PROJECT_DIR)/scripts/validate_bank_record.awk
REF_CHECK_DATA_VALIDATOR := $(PROJECT_DIR)/scripts/validate_ref_check_data.awk
CHECK_COMPARE_VALIDATOR := $(PROJECT_DIR)/scripts/validate_check_compare.awk
FILE_CHECK_CONFIG_READER := $(PROJECT_DIR)/scripts/read_file_check_testcase_config.awk
CHECK_MODE_READER := $(PROJECT_DIR)/scripts/read_check_mode.awk
TESTCASE_STRING_READER := $(PROJECT_DIR)/scripts/read_testcase_string.awk
TESTCASE_UINT_READER := $(PROJECT_DIR)/scripts/read_testcase_uint.awk
VCS        ?= vcs
VERDI      ?= verdi
VERDI_HOME ?= $(NOVAS_HOME)
VERDI_PLI  := $(VERDI_HOME)/share/PLI/VCS/LINUX64
SIM_TIME_NS ?= 100
RESET_RELEASE_NS ?= 10
SIM_SEED ?= $(shell date +%s)
RANDOM_SEED ?= $(SIM_SEED)
WAVA ?= 1
SRAM_COUNT ?= 1
SRAM_BANK_COUNT ?= 4
DUT_INPUT_DATA_PATH ?= tb_top.dut.check_input_data_i
DUT_INPUT_ADDRESS_PATH ?= tb_top.dut.check_input_word_address_i
DUT_INPUT_VALID_PATH ?= tb_top.dut.check_input_valid_i
DUT_OUTPUT_DATA_PATH ?= tb_top.dut.ref_result_capture_array
DUT_OUTPUT_VALID_PATH ?= tb_top.dut.ref_result_capture_valid
BANK_INDICES := 0 1 2 3
comma := ,

CONFIG_READER_ARGS := -v expected_sram_count=$(SRAM_COUNT) -v expected_bank_count=$(SRAM_BANK_COUNT)
MEM_ACCESS_WIDTH := $(shell awk -v requested_key=access_width $(CONFIG_READER_ARGS) -f "$(CONFIG_READER)" "$(CONFIG)" 2>/dev/null)
MEM_WORD_BYTES   := $(shell expr $(MEM_ACCESS_WIDTH) / 8 2>/dev/null)
MEM_HDL_PATHS    := $(shell awk -v requested_key=hdl_path $(CONFIG_READER_ARGS) -f "$(CONFIG_READER)" "$(CONFIG)" 2>/dev/null)
MEM_TARGET_SPECS := $(shell awk -v requested_key=target_specs $(CONFIG_READER_ARGS) -f "$(CONFIG_READER)" "$(CONFIG)" 2>/dev/null)
MEM_TOTAL_WORDS  := $(shell awk -v requested_key=total_words $(CONFIG_READER_ARGS) -f "$(CONFIG_READER)" "$(CONFIG)" 2>/dev/null)
MEM_CAPACITY_LIST := $(shell awk -v requested_key=capacity_list $(CONFIG_READER_ARGS) -f "$(CONFIG_READER)" "$(CONFIG)" 2>/dev/null)
MEM_BANK_WORDS := $(firstword $(subst $(comma), ,$(MEM_CAPACITY_LIST)))
MEM_SRAM_INDICES  := $(shell awk -v requested_key=sram_indices $(CONFIG_READER_ARGS) -f "$(CONFIG_READER)" "$(CONFIG)" 2>/dev/null)
MEM_BANK_INDICES  := $(shell awk -v requested_key=bank_indices $(CONFIG_READER_ARGS) -f "$(CONFIG_READER)" "$(CONFIG)" 2>/dev/null)
MEM_ADDRESS_INTERLEAVE := $(shell awk -v requested_key=address_interleave $(CONFIG_READER_ARGS) -f "$(CONFIG_READER)" "$(CONFIG)" 2>/dev/null)
MEM_INTERLEAVE_BYTES := $(shell awk -v requested_key=interleave_granularity_bytes $(CONFIG_READER_ARGS) -f "$(CONFIG_READER)" "$(CONFIG)" 2>/dev/null)
MEM_INTERLEAVE_WORDS := $(shell awk -v requested_key=interleave_granularity_words $(CONFIG_READER_ARGS) -f "$(CONFIG_READER)" "$(CONFIG)" 2>/dev/null)
FILE_CHECK_INPUT_REL := $(shell awk -v requested_key=input_file \
	-f "$(FILE_CHECK_CONFIG_READER)" "$(TESTCASE_DIR)/file_check_testcase.sv" 2>/dev/null)
FILE_CHECK_GOLDEN_REL := $(shell awk -v requested_key=golden_file \
	-f "$(FILE_CHECK_CONFIG_READER)" "$(TESTCASE_DIR)/file_check_testcase.sv" 2>/dev/null)
FILE_CHECK_INPUT_FILE := $(PROJECT_DIR)/$(FILE_CHECK_INPUT_REL)
FILE_CHECK_GOLDEN_FILE := $(PROJECT_DIR)/$(FILE_CHECK_GOLDEN_REL)
REF_CHECK_GOLDEN_REL := $(shell awk -v string_key=REF_CHECK_GOLDEN_FILE \
	-f "$(TESTCASE_STRING_READER)" "$(TESTCASE_DIR)/ref_check_testcase.sv" 2>/dev/null)
REF_CHECK_GOLDEN_FILE := $(PROJECT_DIR)/$(REF_CHECK_GOLDEN_REL)
REF_CHECK_MODE := $(shell awk -v mode_key=REF_CHECK_CHECK_MODE \
	-f "$(CHECK_MODE_READER)" "$(TESTCASE_DIR)/ref_check_testcase.sv" 2>/dev/null)
FILE_CHECK_MODE := $(shell awk -v mode_key=FILE_CHECK_CHECK_MODE \
	-f "$(CHECK_MODE_READER)" "$(TESTCASE_DIR)/file_check_testcase.sv" 2>/dev/null)
REF_CHECK_WORD_COUNT_RAW := $(shell awk -v uint_key=REF_CHECK_WORD_COUNT \
	-f "$(TESTCASE_UINT_READER)" "$(TESTCASE_DIR)/ref_check_testcase.sv" 2>/dev/null)
FILE_CHECK_WORD_COUNT_RAW := $(shell awk -v uint_key=FILE_CHECK_WORD_COUNT \
	-f "$(TESTCASE_UINT_READER)" "$(TESTCASE_DIR)/file_check_testcase.sv" 2>/dev/null)
REF_CHECK_WORD_COUNT := $(if $(filter MEM_BKDR_ADDRESS_AUTO,$(REF_CHECK_WORD_COUNT_RAW)),$(MEM_TOTAL_WORDS),$(REF_CHECK_WORD_COUNT_RAW))
FILE_CHECK_WORD_COUNT := $(if $(filter MEM_BKDR_ADDRESS_AUTO,$(FILE_CHECK_WORD_COUNT_RAW)),$(MEM_TOTAL_WORDS),$(FILE_CHECK_WORD_COUNT_RAW))
REF_CHECK_EXPECTED_SOURCE := $(if $(filter reference,$(REF_CHECK_MODE)),reference_component,golden_file)
REF_CHECK_EXPECTED_KIND := $(if $(filter reference,$(REF_CHECK_MODE)),reference_output,golden_data)
FILE_CHECK_EXPECTED_SOURCE := $(if $(filter reference,$(FILE_CHECK_MODE)),reference_component,golden_file)
FILE_CHECK_EXPECTED_KIND := $(if $(filter reference,$(FILE_CHECK_MODE)),reference_output,golden_data)
FILE_INIT_QUERY_ARGS := -v capacity_list='$(MEM_CAPACITY_LIST)' -v sram_count='$(SRAM_COUNT)' -v bank_count='$(SRAM_BANK_COUNT)' -v access_width='$(MEM_ACCESS_WIDTH)' -v project_dir='$(PROJECT_DIR)'
FILE_INIT_COMPARE_ENABLE := $(shell awk $(FILE_INIT_QUERY_ARGS) -v requested_key=compare_enable -f "$(FILE_INIT_VALIDATOR)" "$(TESTCASE_DIR)/file_init_testcase.sv" 2>/dev/null | tail -1)
FILE_INIT_WORDS := $(shell awk $(FILE_INIT_QUERY_ARGS) -v requested_key=total_words -f "$(FILE_INIT_VALIDATOR)" "$(TESTCASE_DIR)/file_init_testcase.sv" 2>/dev/null | tail -1)
FILE_INIT_BANK_FILES := $(shell awk $(FILE_INIT_QUERY_ARGS) -v requested_key=bank_files -f "$(FILE_INIT_VALIDATOR)" "$(TESTCASE_DIR)/file_init_testcase.sv" 2>/dev/null | tail -1)
FILE_INIT_BANK_START_ROWS := $(shell awk $(FILE_INIT_QUERY_ARGS) -v requested_key=bank_start_rows -f "$(FILE_INIT_VALIDATOR)" "$(TESTCASE_DIR)/file_init_testcase.sv" 2>/dev/null | tail -1)
FILE_INIT_BANK_WORD_COUNTS := $(shell awk $(FILE_INIT_QUERY_ARGS) -v requested_key=bank_word_counts -f "$(FILE_INIT_VALIDATOR)" "$(TESTCASE_DIR)/file_init_testcase.sv" 2>/dev/null | tail -1)
ZERO_INIT_START := $(shell awk '/^[[:space:]]*localparam[[:space:]]+int[[:space:]]+unsigned[[:space:]]+ZERO_INIT_START_ADDRESS[[:space:]]*=/ { value=$$0; sub(/^[^=]*=[[:space:]]*/, "", value); sub(/[[:space:]]*;.*/, "", value); print value; exit }' "$(TESTCASE_DIR)/zero_init_testcase.sv")
ZERO_INIT_END := $(shell awk '/^[[:space:]]*localparam[[:space:]]+int[[:space:]]+unsigned[[:space:]]+ZERO_INIT_END_ADDRESS[[:space:]]*=/ { value=$$0; sub(/^[^=]*=[[:space:]]*/, "", value); sub(/[[:space:]]*;.*/, "", value); print value; exit }' "$(TESTCASE_DIR)/zero_init_testcase.sv")
ZERO_INIT_WORDS := $(shell awk -v start='$(ZERO_INIT_START)' -v finish='$(ZERO_INIT_END)' -v total='$(MEM_TOTAL_WORDS)' 'BEGIN { if (finish == "MEM_BKDR_ADDRESS_AUTO") finish=total-1; print finish-start+1 }')
RANDOM_INIT_START := $(shell awk '/^[[:space:]]*localparam[[:space:]]+int[[:space:]]+unsigned[[:space:]]+RANDOM_INIT_START_ADDRESS[[:space:]]*=/ { value=$$0; sub(/^[^=]*=[[:space:]]*/, "", value); sub(/[[:space:]]*;.*/, "", value); print value; exit }' "$(TESTCASE_DIR)/random_init_testcase.sv")
RANDOM_INIT_END := $(shell awk '/^[[:space:]]*localparam[[:space:]]+int[[:space:]]+unsigned[[:space:]]+RANDOM_INIT_END_ADDRESS[[:space:]]*=/ { value=$$0; sub(/^[^=]*=[[:space:]]*/, "", value); sub(/[[:space:]]*;.*/, "", value); print value; exit }' "$(TESTCASE_DIR)/random_init_testcase.sv")
RANDOM_INIT_WORDS := $(shell awk -v start='$(RANDOM_INIT_START)' -v finish='$(RANDOM_INIT_END)' -v total='$(MEM_TOTAL_WORDS)' 'BEGIN { if (finish == "MEM_BKDR_ADDRESS_AUTO") finish=total-1; print finish-start+1 }')
ZERO_INIT_COMPARE_ENABLE := $(shell awk '/^[[:space:]]*localparam[[:space:]]+bit[[:space:]]+ZERO_INIT_COMPARE_ENABLE[[:space:]]*=/ { print ($$0 ~ /1.b1/) ? 1 : 0; exit }' "$(TESTCASE_DIR)/zero_init_testcase.sv")
RANDOM_INIT_COMPARE_ENABLE := $(shell awk '/^[[:space:]]*localparam[[:space:]]+bit[[:space:]]+RANDOM_INIT_COMPARE_ENABLE[[:space:]]*=/ { print ($$0 ~ /1.b1/) ? 1 : 0; exit }' "$(TESTCASE_DIR)/random_init_testcase.sv")
SRAM_GEOMETRY_GENERATOR := $(PROJECT_DIR)/scripts/generate_sram_geometry.awk
SRAM_GEOMETRY_PACKAGE = $(WORK_ROOT)/$(CASE)/generated/sram_geometry_pkg.sv

FILE_INIT_DATA_DIR := $(WORK_ROOT)/file_init/data
FILE_INIT_RECORD_PREFIX := $(FILE_INIT_DATA_DIR)/file_init
ZERO_INIT_DATA_DIR := $(WORK_ROOT)/zero_init/data
ZERO_INIT_RECORD_PREFIX := $(ZERO_INIT_DATA_DIR)/zero_init
RANDOM_INIT_DATA_DIR := $(WORK_ROOT)/random_init/data
RANDOM_INIT_RECORD_PREFIX := $(RANDOM_INIT_DATA_DIR)/random_init
REF_CHECK_DATA_DIR := $(WORK_ROOT)/ref_check/data
REF_CHECK_RECORD_PREFIX := $(REF_CHECK_DATA_DIR)/ref_check
REF_CHECK_DUT_INPUT_INTERFACE_FILE := $(REF_CHECK_RECORD_PREFIX)_dut_input_interface.txt
REF_CHECK_REFERENCE_OUTPUT_FILE := $(REF_CHECK_RECORD_PREFIX)_reference_output.txt
REF_CHECK_GOLDEN_OUTPUT_FILE := $(REF_CHECK_RECORD_PREFIX)_golden_data.txt
REF_CHECK_EXPECTED_OUTPUT_FILE := $(if $(filter reference,$(REF_CHECK_MODE)),$(REF_CHECK_REFERENCE_OUTPUT_FILE),$(REF_CHECK_GOLDEN_OUTPUT_FILE))
REF_CHECK_DUT_OUTPUT_FILE := $(REF_CHECK_RECORD_PREFIX)_dut_output_backdoor.txt
REF_CHECK_COMPARE_FILE := $(REF_CHECK_RECORD_PREFIX)_dut_reference_compare.txt
REF_CHECK_DATA_FILES := $(REF_CHECK_DUT_INPUT_INTERFACE_FILE) \
	$(REF_CHECK_EXPECTED_OUTPUT_FILE) $(REF_CHECK_DUT_OUTPUT_FILE)
FILE_CHECK_DATA_DIR := $(WORK_ROOT)/file_check/data
FILE_CHECK_RECORD_PREFIX := $(FILE_CHECK_DATA_DIR)/file_check
FILE_CHECK_WORK_INPUT_FILE := $(FILE_CHECK_RECORD_PREFIX)_dut_input_interface.txt
FILE_CHECK_WORK_GOLDEN_FILE := $(FILE_CHECK_RECORD_PREFIX)_golden_data.txt
FILE_CHECK_WORK_REFERENCE_FILE := $(FILE_CHECK_RECORD_PREFIX)_reference_output.txt
FILE_CHECK_WORK_EXPECTED_FILE := $(if $(filter reference,$(FILE_CHECK_MODE)),$(FILE_CHECK_WORK_REFERENCE_FILE),$(FILE_CHECK_WORK_GOLDEN_FILE))
FILE_CHECK_WORK_DUT_OUTPUT_FILE := $(FILE_CHECK_RECORD_PREFIX)_dut_output_backdoor.txt
FILE_CHECK_COMPARE_FILE := $(FILE_CHECK_RECORD_PREFIX)_dut_reference_compare.txt
FILE_CHECK_DATA_FILES := $(FILE_CHECK_WORK_INPUT_FILE) \
	$(FILE_CHECK_WORK_EXPECTED_FILE) $(FILE_CHECK_WORK_DUT_OUTPUT_FILE)

TESTCASE_SOURCE  = $(TESTCASE_DIR)/$(CASE)_testcase.sv
TESTCASE_PACKAGE = $(CASE)_testcase_pkg
TESTCASE_CLASS   = $(CASE)_testcase

SV_SOURCES = \
	$(PROJECT_DIR)/src/memory_backdoor_pkg.sv \
	$(SRAM_GEOMETRY_PACKAGE) \
	$(PROJECT_DIR)/third_party/tech_cells_generic/tc_sram.sv \
	$(PROJECT_DIR)/examples/interleaved_sram.sv \
	$(PROJECT_DIR)/src/memory_reference_component_pkg.sv \
	$(PROJECT_DIR)/src/memory_scoreboard_component_pkg.sv \
	$(PROJECT_DIR)/src/memory_backdoor_operation_pkg.sv \
	$(PROJECT_DIR)/examples/dut.sv \
	$(TESTCASE_SOURCE) \
	$(PROJECT_DIR)/examples/tb_top.sv

VCS_FLAGS := \
	-full64 \
	-sverilog \
	-ntb_opts uvm-1.2 \
	-debug_access+all \
	-kdb \
	-P $(VERDI_PLI)/novas.tab $(VERDI_PLI)/pli.a \
	+define+MEMORY_TESTCASE_PACKAGE=$(TESTCASE_PACKAGE) \
	+define+MEMORY_TESTCASE_CLASS=$(TESTCASE_CLASS) \
	-timescale=1ns/1ps \
	+incdir+$(PROJECT_DIR)/src \
	+incdir+$(TESTCASE_DIR)

COMMON_PLUSARGS := \
	+UVM_NO_RELNOTES \
	+ntb_random_seed=$(SIM_SEED) \
	+MEM_BKDR_TARGET_SPECS=$(MEM_TARGET_SPECS) \
	+MEM_BKDR_SRAM_INDICES=$(MEM_SRAM_INDICES) \
	+MEM_BKDR_BANK_INDICES=$(MEM_BANK_INDICES) \
	+MEM_BKDR_SRAM_COUNT=$(SRAM_COUNT) \
	+MEM_BKDR_BANK_COUNT=$(SRAM_BANK_COUNT) \
	+MEM_BKDR_ADDRESS_INTERLEAVE=$(MEM_ADDRESS_INTERLEAVE) \
	+MEM_BKDR_INTERLEAVE_BYTES=$(MEM_INTERLEAVE_BYTES) \
	+MEM_BKDR_INTERLEAVE_WORDS=$(MEM_INTERLEAVE_WORDS) \
	+MEM_BKDR_PROJECT_DIR=$(PROJECT_DIR) \
	+MEM_BKDR_DUT_INPUT_DATA_PATH=$(DUT_INPUT_DATA_PATH) \
	+MEM_BKDR_DUT_INPUT_ADDRESS_PATH=$(DUT_INPUT_ADDRESS_PATH) \
	+MEM_BKDR_DUT_INPUT_VALID_PATH=$(DUT_INPUT_VALID_PATH) \
	+MEM_BKDR_DUT_OUTPUT_DATA_PATH=$(DUT_OUTPUT_DATA_PATH) \
	+MEM_BKDR_DUT_OUTPUT_VALID_PATH=$(DUT_OUTPUT_VALID_PATH) \
	+SIM_TIME_NS=$(SIM_TIME_NS) \
	+RESET_RELEASE_NS=$(RESET_RELEASE_NS)

FILE_INIT_ARGS := \
	$(COMMON_PLUSARGS) \
	+MEM_BKDR_DATA_RECORD_PREFIX=$(FILE_INIT_RECORD_PREFIX)

ZERO_INIT_ARGS := \
	$(COMMON_PLUSARGS) \
	+MEM_BKDR_DATA_RECORD_PREFIX=$(ZERO_INIT_RECORD_PREFIX)

RANDOM_INIT_ARGS := \
	$(COMMON_PLUSARGS) \
	+MEM_BKDR_RANDOM_DUMP_FILE=$(RANDOM_INIT_DATA_DIR)/random_init \
	+MEM_BKDR_DATA_RECORD_PREFIX=$(RANDOM_INIT_RECORD_PREFIX) \
	+MEM_BKDR_RANDOM_SEED=$(RANDOM_SEED)

REF_CHECK_ARGS := \
	$(COMMON_PLUSARGS) \
	+MEM_BKDR_DATA_RECORD_PREFIX=$(REF_CHECK_RECORD_PREFIX) \
	+MEM_BKDR_RANDOM_SEED=$(RANDOM_SEED) \
	+MEM_BKDR_TB_INPUT_WORD_COUNT=$(REF_CHECK_WORD_COUNT) \
	+MEM_BKDR_TB_INPUT_MODE=RANDOM

FILE_CHECK_ARGS := \
	$(COMMON_PLUSARGS) \
	+MEM_BKDR_DATA_RECORD_PREFIX=$(FILE_CHECK_RECORD_PREFIX) \
	+MEM_BKDR_TB_INPUT_WORD_COUNT=$(FILE_CHECK_WORD_COUNT) \
	+MEM_BKDR_TB_INPUT_MODE=FILE \
	+MEM_BKDR_TB_INPUT_FILE=$(FILE_CHECK_INPUT_FILE)

ALL_CASES      := file_init zero_init random_init ref_check file_check
REQUESTED_CASES := $(filter $(ALL_CASES),$(MAKECMDGOALS))
VERDI_CASE      := $(firstword $(REQUESTED_CASES))
OPEN_WAVE_ONLY  := $(if $(filter verdi,$(MAKECMDGOALS)),1,0)

.PHONY: help check_config show_config check_file_init_data check_ref_check_data check_file_check_data check_vcs check_verdi check_wave_option check_tools \
	generate_sram_geometry generate_data validate_bank_records validate_file_init_bank_records cleanup_case_logs compile_case run_case $(ALL_CASES) \
	all regression verdi clean clean_logs list ll

help:
	@echo "Memory backdoor VCS targets:"
	@echo "  make file_init       - initialize four physical banks from four files"
	@echo "  make zero_init       - zero initialization (comparison selected in testcase)"
	@echo "  make random_init     - random initialization (comparison selected in testcase)"
	@echo "  make ref_check       - check mode is selected in ref_check_testcase.sv"
	@echo "  make file_check      - check mode is selected in file_check_testcase.sv"
	@echo "  make all             - run every testcase listed in ALL_CASES"
	@echo "  make regression      - run make all and print the regression marker"
	@echo "  make ll              - list every executable testcase"
	@echo "  make <case> verdi    - only open an existing FSDB; do not run simulation"
	@echo "  make show_config     - validate and print memory_config.yaml"
	@echo "  CONFIG=<yaml>        - select another memory YAML configuration"
	@echo "  Topology is 1 SRAM x 4 banks"
	@echo "  YAML items 0-3 are SRAM0 banks 0-3"
	@echo "  YAML capacity is total SRAM capacity; each bank receives one quarter"
	@echo "  YAML address_interleave=1 selects block interleave; 0 selects contiguous banks"
	@echo "  YAML data_width sets the structural SRAM word width"
	@echo "  YAML interleave_granularity controls block size only when address_interleave=1"
	@echo "  testcase/*.sv uses SRAM-local logical word addresses"
	@echo "  REF_CHECK_WORD_COUNT/FILE_CHECK_WORD_COUNT select 1..SRAM words or AUTO"
	@echo "  SIM_TIME_NS=<ns>     - set the minimum simulation end time (default: 100 ns)"
	@echo "  RESET_RELEASE_NS=<ns>- set rst_n deassertion time (default: 10 ns)"
	@echo "  RANDOM_SEED=<value>  - override the default current Unix timestamp"
	@echo "  SIM_SEED=<value>     - set the simulator seed (default: current timestamp)"
	@echo "  WAVA=0               - run without generating an FSDB (default: WAVA=1)"
	@echo "  make list            - list generated work directories"
	@echo "  make clean           - remove generated case directories"
	@echo "  With WAVA=1, each case writes a Verdi FSDB to work/<case>/<case>.fsdb"
	@echo "  Each testcase implementation is in testcase/<case>_testcase.sv"
	@echo "  Successful runs delete compile.log and sim.log; failed runs keep them"
	@echo
	@echo "Run 'module load vcs/S-2021.09-SP2 verdi/T-2022.06' before invoking make."

check_config:
	@awk -v validate=1 $(CONFIG_READER_ARGS) \
		-f "$(CONFIG_READER)" "$(CONFIG)" >/dev/null

show_config: check_config
	@echo "CONFIG=$(CONFIG)"
	@awk $(CONFIG_READER_ARGS) \
		-f "$(CONFIG_READER)" "$(CONFIG)"

check_file_init_data: check_config
	@if [[ "$(CASE)" == "file_init" ]]; then \
		awk -v capacity_list='$(MEM_CAPACITY_LIST)' \
			-v sram_count='$(SRAM_COUNT)' \
			-v bank_count='$(SRAM_BANK_COUNT)' \
			-v access_width='$(MEM_ACCESS_WIDTH)' \
			-v project_dir='$(PROJECT_DIR)' \
			-f "$(FILE_INIT_VALIDATOR)" \
			"$(TESTCASE_DIR)/file_init_testcase.sv" || exit 1; \
	fi

check_ref_check_data: check_config
	@test "$(REF_CHECK_MODE)" = "reference" -o "$(REF_CHECK_MODE)" = "file" || { \
		echo "ERROR: invalid or missing REF_CHECK_CHECK_MODE"; exit 1; }
	@test -n "$(REF_CHECK_WORD_COUNT_RAW)" && \
		test "$(REF_CHECK_WORD_COUNT)" -ge 1 && \
		test "$(REF_CHECK_WORD_COUNT)" -le "$(MEM_TOTAL_WORDS)" || { \
		echo "ERROR: REF_CHECK_WORD_COUNT must resolve into 1..$(MEM_TOTAL_WORDS)"; exit 1; }
	@if [[ "$(CASE)" == "ref_check" && "$(REF_CHECK_MODE)" == "file" ]]; then \
		test -f "$(REF_CHECK_GOLDEN_FILE)" || { \
			echo "ERROR: missing ref_check golden data $(REF_CHECK_GOLDEN_FILE)"; exit 1; }; \
		awk -v expected_count='$(REF_CHECK_WORD_COUNT)' \
			-v access_width='$(MEM_ACCESS_WIDTH)' \
			-f "$(REF_CHECK_DATA_VALIDATOR)" "$(REF_CHECK_GOLDEN_FILE)" || exit 1; \
	fi

check_file_check_data: check_config
	@test "$(FILE_CHECK_MODE)" = "reference" -o "$(FILE_CHECK_MODE)" = "file" || { \
		echo "ERROR: invalid or missing FILE_CHECK_CHECK_MODE"; exit 1; }
	@test -n "$(FILE_CHECK_WORD_COUNT_RAW)" && \
		test "$(FILE_CHECK_WORD_COUNT)" -ge 1 && \
		test "$(FILE_CHECK_WORD_COUNT)" -le "$(MEM_TOTAL_WORDS)" || { \
		echo "ERROR: FILE_CHECK_WORD_COUNT must resolve into 1..$(MEM_TOTAL_WORDS)"; exit 1; }
	@if [[ "$(CASE)" == "file_check" ]]; then \
		awk -f "$(FILE_CHECK_CONFIG_READER)" \
			"$(TESTCASE_DIR)/file_check_testcase.sv" || exit 1; \
		data_files=("$(FILE_CHECK_INPUT_FILE)"); \
		if [[ "$(FILE_CHECK_MODE)" == "file" ]]; then \
			data_files+=("$(FILE_CHECK_GOLDEN_FILE)"); \
		fi; \
		for data_file in "$${data_files[@]}"; do \
			test -f "$$data_file" || { \
				echo "ERROR: missing file_check config data $$data_file"; exit 1; }; \
			awk -v expected_count='$(FILE_CHECK_WORD_COUNT)' \
				-v access_width='$(MEM_ACCESS_WIDTH)' \
				-f "$(REF_CHECK_DATA_VALIDATOR)" "$$data_file" || exit 1; \
		done; \
	fi

check_vcs:
	@command -v "$(VCS)" >/dev/null 2>&1 || { \
		echo "ERROR: vcs is not in PATH"; \
		echo "Run: module load vcs/S-2021.09-SP2"; \
		exit 1; \
	}

check_verdi:
	@command -v "$(VERDI)" >/dev/null 2>&1 || { \
		echo "ERROR: verdi is not in PATH"; \
		echo "Run: module load verdi/T-2022.06"; \
		exit 1; \
	}
	@test -n "$(VERDI_HOME)" && \
		test -f "$(VERDI_PLI)/novas.tab" && \
		test -f "$(VERDI_PLI)/pli.a" || { \
		echo "ERROR: Verdi FSDB PLI is not available"; \
		echo "Run: module load verdi/T-2022.06"; \
		exit 1; \
		}

check_wave_option:
	@case "$(WAVA)" in \
		0|1) ;; \
		*) echo "ERROR: WAVA must be 0 or 1, got '$(WAVA)'"; exit 1 ;; \
	esac

check_tools: check_config check_vcs check_verdi check_wave_option

generate_sram_geometry: check_config
	@test -n "$(CASE)" || { echo "ERROR: CASE is empty"; exit 1; }
	@mkdir -p "$(dir $(SRAM_GEOMETRY_PACKAGE))"
	@tmp_file="$(SRAM_GEOMETRY_PACKAGE).tmp"; \
		rm -f -- "$$tmp_file"; \
		awk \
			-v hdl_paths='$(MEM_HDL_PATHS)' \
			-v capacity_list='$(MEM_CAPACITY_LIST)' \
			-v sram_indices='$(MEM_SRAM_INDICES)' \
			-v bank_indices='$(MEM_BANK_INDICES)' \
			-v sram_count='$(SRAM_COUNT)' \
			-v bank_count='$(SRAM_BANK_COUNT)' \
			-v access_width='$(MEM_ACCESS_WIDTH)' \
			-v address_interleave='$(MEM_ADDRESS_INTERLEAVE)' \
			-v interleave_bytes='$(MEM_INTERLEAVE_BYTES)' \
			-v interleave_words='$(MEM_INTERLEAVE_WORDS)' \
			-f "$(SRAM_GEOMETRY_GENERATOR)" > "$$tmp_file" || { \
			rm -f -- "$$tmp_file"; exit 1; \
		}; \
		mv -f -- "$$tmp_file" "$(SRAM_GEOMETRY_PACKAGE)"

generate_data: check_config
	@test -n "$(CASE)" || { echo "ERROR: CASE is empty"; exit 1; }
	@data_dir="$(WORK_ROOT)/$(CASE)/data"; \
		case "$(CASE)" in \
			file_init|zero_init|random_init|ref_check|file_check) ;; \
			*) echo "ERROR: unsupported CASE=$(CASE)"; exit 1 ;; \
		esac; \
		mkdir -p "$$data_dir"; \
		rm -f -- "$$data_dir/$(CASE)_record.txt" \
			"$$data_dir"/"$(CASE)"_bank*_record.txt; \
		case "$(CASE)" in \
			random_init) \
				rm -f -- "$$data_dir"/random_init_sram*.hex ;; \
			ref_check) \
				rm -f -- "$$data_dir"/ref_check_dut_input_backdoor.txt \
					"$$data_dir"/ref_check_dut_input_interface.txt \
					"$$data_dir"/ref_check_reference_output.txt \
					"$$data_dir"/ref_check_golden_data.txt \
					"$$data_dir"/ref_check_dut_output_backdoor.txt \
					"$$data_dir"/ref_check_dut_reference_compare.txt ;; \
			file_check) \
				rm -f -- "$$data_dir"/file_check_dut_input_backdoor.txt \
					"$$data_dir"/file_check_dut_input_interface.txt \
					"$$data_dir"/file_check_golden_data.txt \
					"$$data_dir"/file_check_reference_output.txt \
					"$$data_dir"/file_check_dut_output_backdoor.txt \
					"$$data_dir"/file_check_dut_reference_compare.txt ;; \
			file_init|zero_init) ;; \
		esac

validate_bank_records: check_config
	@test -n "$(RECORD_PREFIX)$(RECORD_DIRECTORY)" || { echo "ERROR: RECORD_PREFIX and RECORD_DIRECTORY are both empty"; exit 1; }
	@test -n "$(RECORD_WORDS)" || { echo "ERROR: RECORD_WORDS is empty"; exit 1; }
	@total_rows=0; \
		for bank in $(BANK_INDICES); do \
			read -r start_row bank_words <<< "$$(awk \
				-v start='$(or $(RECORD_START),0)' \
				-v count='$(RECORD_WORDS)' \
				-v expected_bank="$$bank" \
				-v bank_count='$(SRAM_BANK_COUNT)' \
				-v interleave_words='$(MEM_INTERLEAVE_WORDS)' \
				-v address_interleave='$(MEM_ADDRESS_INTERLEAVE)' \
				-v bank_capacity='$(MEM_BANK_WORDS)' \
				'BEGIN { first=-1; words=0; for (offset=0; offset<count; offset++) { address=start+offset; if (address_interleave) { bank=int(address/interleave_words)%bank_count; row=int(address/(interleave_words*bank_count))*interleave_words+(address%interleave_words) } else { bank=int(address/bank_capacity); row=address%bank_capacity } if (bank==expected_bank) { if (first<0) first=row; words++ } } if (first<0) first=0; print first, words }')"; \
			if [[ -n "$(RECORD_DIRECTORY)" ]]; then \
				record_file="$(RECORD_DIRECTORY)/bank$${bank}.txt"; \
			else \
				record_file="$(RECORD_PREFIX)_bank$${bank}_record.txt"; \
			fi; \
			test -f "$$record_file" || { echo "ERROR: missing bank record $$record_file"; exit 1; }; \
			awk \
				-v expected_count="$$bank_words" \
				-v expected_bank="$$bank" \
				-v start_row="$$start_row" \
				-v word_bytes='$(MEM_WORD_BYTES)' \
				-v sram_index='0' \
				-v bank_count='$(SRAM_BANK_COUNT)' \
				-v interleave_words='$(MEM_INTERLEAVE_WORDS)' \
				-v address_interleave='$(MEM_ADDRESS_INTERLEAVE)' \
				-v bank_words='$(MEM_BANK_WORDS)' \
				-v allow_skip='$(or $(RECORD_ALLOW_SKIP),0)' \
				-v expected_equals_input='$(or $(RECORD_EXPECTED_EQUALS_INPUT),0)' \
				-f "$(BANK_RECORD_VALIDATOR)" "$$record_file" || exit 1; \
			total_rows=$$((total_rows + bank_words)); \
		done; \
		test "$$total_rows" -eq '$(RECORD_WORDS)' || { \
			echo "ERROR: bank record total $$total_rows != $(RECORD_WORDS)"; exit 1; }; \
		if [[ -n "$(RECORD_PREFIX)" ]]; then \
			test ! -e "$(RECORD_PREFIX)_record.txt" || { \
				echo "ERROR: legacy combined record still exists"; exit 1; }; \
		fi

validate_file_init_bank_records: check_config
	@test -n "$(RECORD_PREFIX)" || { echo "ERROR: RECORD_PREFIX is empty"; exit 1; }
	@IFS=',' read -r -a source_files <<< '$(FILE_INIT_BANK_FILES)'; \
		IFS=',' read -r -a start_rows <<< '$(FILE_INIT_BANK_START_ROWS)'; \
		IFS=',' read -r -a word_counts <<< '$(FILE_INIT_BANK_WORD_COUNTS)'; \
		total_rows=0; \
		for bank in $(BANK_INDICES); do \
			record_file="$(RECORD_PREFIX)_bank$${bank}_record.txt"; \
			test -f "$$record_file" || { echo "ERROR: missing bank record $$record_file"; exit 1; }; \
			awk \
				-v expected_count="$${word_counts[$$bank]}" \
				-v expected_bank="$$bank" \
				-v start_row="$${start_rows[$$bank]}" \
				-v word_bytes='$(MEM_WORD_BYTES)' \
				-v sram_index='0' \
				-v bank_count='$(SRAM_BANK_COUNT)' \
				-v interleave_words='$(MEM_INTERLEAVE_WORDS)' \
				-v address_interleave='$(MEM_ADDRESS_INTERLEAVE)' \
				-v bank_words='$(MEM_BANK_WORDS)' \
				-v allow_skip='$(or $(RECORD_ALLOW_SKIP),0)' \
				-v expected_equals_input='1' \
				-v source_file="$${source_files[$$bank]}" \
				-f "$(BANK_RECORD_VALIDATOR)" "$$record_file" || exit 1; \
			total_rows=$$((total_rows + $${word_counts[$$bank]})); \
		done; \
		test "$$total_rows" -eq '$(FILE_INIT_WORDS)' || { \
			echo "ERROR: file_init bank record total $$total_rows != $(FILE_INIT_WORDS)"; exit 1; }; \
		test ! -e "$(RECORD_PREFIX)_record.txt" || { \
			echo "ERROR: legacy combined file_init record still exists"; exit 1; }

cleanup_case_logs:
	@test -n "$(CASE)" || { echo "ERROR: CASE is empty"; exit 1; }
	@case " $(ALL_CASES) " in \
		*" $(CASE) "*) ;; \
		*) echo "ERROR: unsupported CASE=$(CASE)"; exit 1 ;; \
	esac
	@find "$(WORK_ROOT)/$(CASE)" -type f -name '*.log' -delete

clean_logs:
	@mkdir -p "$(WORK_ROOT)"
	@find "$(WORK_ROOT)" -type f -name '*.log' -delete
	@echo "Removed generated log files under $(WORK_ROOT)"

compile_case: check_file_init_data check_ref_check_data check_file_check_data check_tools generate_sram_geometry
	@test -n "$(CASE)" || { echo "ERROR: CASE is empty"; exit 1; }
	@test -f "$(TESTCASE_SOURCE)" || { \
		echo "ERROR: testcase source not found: $(TESTCASE_SOURCE)"; \
		exit 1; \
	}
	@mkdir -p "$(WORK_ROOT)/$(CASE)"
	@cd "$(WORK_ROOT)/$(CASE)" && \
		$(VCS) $(VCS_FLAGS) $(SV_SOURCES) -o simv -l compile.log

run_case: compile_case generate_data
	@test -n "$(PLUSARGS)" || { echo "ERROR: PLUSARGS is empty"; exit 1; }
	@rm -f -- "$(WORK_ROOT)/$(CASE)/$(CASE).fsdb"
	@cd "$(WORK_ROOT)/$(CASE)" && \
		./simv $(PLUSARGS) +FSDB_ENABLE=$(WAVA) \
			+FSDB_FILE=$(CASE).fsdb -l sim.log
	@grep -q "MEMORY_BACKDOOR_EXAMPLE_PASS" "$(WORK_ROOT)/$(CASE)/sim.log"
	@! grep -Eq "UVM_(ERROR|FATAL)" "$(WORK_ROOT)/$(CASE)/sim.log"
	@if [[ "$(WAVA)" == "1" ]]; then \
		test -s "$(WORK_ROOT)/$(CASE)/$(CASE).fsdb"; \
	else \
		test ! -e "$(WORK_ROOT)/$(CASE)/$(CASE).fsdb"; \
	fi
	@echo "PASS $(CASE) -> $(WORK_ROOT)/$(CASE) (WAVA=$(WAVA))"
ifeq ($(OPEN_WAVE_ONLY),0)
file_init:
	@$(MAKE) --no-print-directory run_case \
		CASE=file_init PLUSARGS='$(FILE_INIT_ARGS)'
	@grep -q "FILE_INIT_PASS" "$(WORK_ROOT)/file_init/sim.log"
	@test "$$(grep -c "MEMORY_BACKDOOR_BANK_FILE_INIT_ZERO_TIME_PASS" \
		"$(WORK_ROOT)/file_init/sim.log")" -eq "$(SRAM_BANK_COUNT)"
	@$(MAKE) --no-print-directory validate_file_init_bank_records \
		RECORD_PREFIX='$(FILE_INIT_RECORD_PREFIX)' \
		RECORD_ALLOW_SKIP='$(if $(filter 0,$(FILE_INIT_COMPARE_ENABLE)),1,0)'
	@$(MAKE) --no-print-directory cleanup_case_logs CASE=file_init

zero_init:
	@$(MAKE) --no-print-directory run_case \
		CASE=zero_init PLUSARGS='$(ZERO_INIT_ARGS)'
	@grep -q "ZERO_INIT_PASS" "$(WORK_ROOT)/zero_init/sim.log"
	@grep -q "MEMORY_BACKDOOR_INIT_ZERO_TIME_PASS" \
		"$(WORK_ROOT)/zero_init/sim.log"
	@$(MAKE) --no-print-directory validate_bank_records \
		RECORD_PREFIX='$(ZERO_INIT_RECORD_PREFIX)' RECORD_WORDS='$(ZERO_INIT_WORDS)' \
		RECORD_START='$(ZERO_INIT_START)' \
		RECORD_ALLOW_SKIP='$(if $(filter 0,$(ZERO_INIT_COMPARE_ENABLE)),1,0)' \
		RECORD_EXPECTED_EQUALS_INPUT=1
	@$(MAKE) --no-print-directory cleanup_case_logs CASE=zero_init

random_init:
	@$(MAKE) --no-print-directory run_case \
		CASE=random_init PLUSARGS='$(RANDOM_INIT_ARGS)'
	@grep -q "RANDOM_INIT_PASS" "$(WORK_ROOT)/random_init/sim.log"
	@grep -q "MEMORY_BACKDOOR_INIT_ZERO_TIME_PASS" \
		"$(WORK_ROOT)/random_init/sim.log"
	@test "$$(find "$(RANDOM_INIT_DATA_DIR)" -name 'random_init_sram*.hex' -type f | wc -l | tr -d ' ')" \
		-eq "$(SRAM_COUNT)"
	@test "$$(awk '{ words++ } END { print words + 0 }' \
		"$(RANDOM_INIT_DATA_DIR)"/random_init_sram*.hex)" -eq "$(RANDOM_INIT_WORDS)"
	@$(MAKE) --no-print-directory validate_bank_records \
		RECORD_PREFIX='$(RANDOM_INIT_RECORD_PREFIX)' RECORD_WORDS='$(RANDOM_INIT_WORDS)' \
		RECORD_START='$(RANDOM_INIT_START)' \
		RECORD_ALLOW_SKIP='$(if $(filter 0,$(RANDOM_INIT_COMPARE_ENABLE)),1,0)' \
		RECORD_EXPECTED_EQUALS_INPUT=1
	@$(MAKE) --no-print-directory cleanup_case_logs CASE=random_init

ref_check:
	@$(MAKE) --no-print-directory run_case \
		CASE=ref_check PLUSARGS='$(REF_CHECK_ARGS)'
	@test "$$(grep -c '^REF_CHECK_MODE_SELECTED mode=$(if $(filter reference,$(REF_CHECK_MODE)),REFERENCE,FILE) expected_source=$(REF_CHECK_EXPECTED_SOURCE)$$' \
		"$(WORK_ROOT)/ref_check/sim.log")" -eq 1
	@test "$$(grep -c '^TB_DUT_INPUT_SOURCE_READY testcase=ref_check source=random words=$(REF_CHECK_WORD_COUNT)$$' \
		"$(WORK_ROOT)/ref_check/sim.log")" -eq 1
	@test "$$(grep -c '^TB_DUT_INPUT_STREAM_DONE testcase=ref_check source=random words=$(REF_CHECK_WORD_COUNT)$$' \
		"$(WORK_ROOT)/ref_check/sim.log")" -eq 1
	@test "$$(grep -c '^MEMORY_DUT_INPUT_INTERFACE_CAPTURE_READY testcase=ref_check words=$(REF_CHECK_WORD_COUNT) source=uvm_hdl_read data_path=$(DUT_INPUT_DATA_PATH) address_path=$(DUT_INPUT_ADDRESS_PATH) valid_path=$(DUT_INPUT_VALID_PATH)$$' \
		"$(WORK_ROOT)/ref_check/sim.log")" -eq 1
	@test "$$(grep -c '^REF_CHECK_DUT_INPUT_INTERFACE_ARRAY_READY words=$(REF_CHECK_WORD_COUNT) data_path=$(DUT_INPUT_DATA_PATH) address_path=$(DUT_INPUT_ADDRESS_PATH) valid_path=$(DUT_INPUT_VALID_PATH)$$' \
		"$(WORK_ROOT)/ref_check/sim.log")" -eq 1
	@test "$$(grep -c '^REF_CHECK_DUT_RESULT_BACKDOOR_ARRAY_READY words=$(REF_CHECK_WORD_COUNT) path=$(DUT_OUTPUT_DATA_PATH)$$' \
		"$(WORK_ROOT)/ref_check/sim.log")" -eq 1
	@if [[ "$(REF_CHECK_MODE)" == "reference" ]]; then \
		test "$$(grep -c '^MEMORY_REFERENCE_COMPONENT_ARRAY_READY testcase=ref_check words=$(REF_CHECK_WORD_COUNT) operation=pass_through$$' \
			"$(WORK_ROOT)/ref_check/sim.log")" -eq 1; \
		! grep -q '^REF_CHECK_GOLDEN_FILE_LOAD_PASS ' \
			"$(WORK_ROOT)/ref_check/sim.log"; \
	else \
		test "$$(grep -c '^REF_CHECK_GOLDEN_FILE_LOAD_PASS .* words=$(REF_CHECK_WORD_COUNT)$$' \
			"$(WORK_ROOT)/ref_check/sim.log")" -eq 1; \
		! grep -q '^MEMORY_REFERENCE_COMPONENT_ARRAY_READY testcase=ref_check ' \
			"$(WORK_ROOT)/ref_check/sim.log"; \
	fi
	@test "$$(grep -c '^MEMORY_SCOREBOARD_PASS testcase=ref_check words=$(REF_CHECK_WORD_COUNT) mismatches=0 expected_source=$(REF_CHECK_EXPECTED_SOURCE)$$' \
		"$(WORK_ROOT)/ref_check/sim.log")" -eq 1
	@test "$$(grep -c '^MEMORY_SCOREBOARD_COMPARE_FILE_READY testcase=ref_check file=.* words=$(REF_CHECK_WORD_COUNT) mismatches=0 expected_source=$(REF_CHECK_EXPECTED_SOURCE)$$' \
		"$(WORK_ROOT)/ref_check/sim.log")" -eq 1
	@test "$$(grep -c '^TEST_PASS testcase=ref_check words=$(REF_CHECK_WORD_COUNT) mismatches=0 operation=pass_through expected_source=$(REF_CHECK_EXPECTED_SOURCE)$$' \
		"$(WORK_ROOT)/ref_check/sim.log")" -eq 1
	@test "$$(grep -c '^REF_CHECK_DATA_FILE_READY kind=dut_input_interface .* words=$(REF_CHECK_WORD_COUNT)$$' \
		"$(WORK_ROOT)/ref_check/sim.log")" -eq 1
	@test "$$(grep -c '^REF_CHECK_DATA_FILE_READY kind=$(REF_CHECK_EXPECTED_KIND) .* words=$(REF_CHECK_WORD_COUNT)$$' \
		"$(WORK_ROOT)/ref_check/sim.log")" -eq 1
	@test "$$(grep -c '^REF_CHECK_DATA_FILE_READY kind=dut_output_backdoor .* words=$(REF_CHECK_WORD_COUNT)$$' \
		"$(WORK_ROOT)/ref_check/sim.log")" -eq 1
	@for data_file in $(REF_CHECK_DATA_FILES); do \
		test -f "$$data_file" || { echo "ERROR: missing ref_check data file $$data_file"; exit 1; }; \
		awk -v expected_count='$(REF_CHECK_WORD_COUNT)' \
			-v access_width='$(MEM_ACCESS_WIDTH)' \
			-f "$(REF_CHECK_DATA_VALIDATOR)" "$$data_file" || exit 1; \
	done
	@if [[ "$(REF_CHECK_MODE)" == "file" ]]; then \
		awk -v expected_count='$(REF_CHECK_WORD_COUNT)' \
			-v access_width='$(MEM_ACCESS_WIDTH)' \
			-v source_file='$(REF_CHECK_GOLDEN_FILE)' \
			-f "$(REF_CHECK_DATA_VALIDATOR)" "$(REF_CHECK_GOLDEN_OUTPUT_FILE)" || exit 1; \
	fi
	@cmp -s "$(REF_CHECK_EXPECTED_OUTPUT_FILE)" "$(REF_CHECK_DUT_OUTPUT_FILE)" || { \
		echo "ERROR: saved expected and DUT output files differ"; exit 1; }
	@test -f "$(REF_CHECK_COMPARE_FILE)" || { \
		echo "ERROR: missing ref_check comparison file $(REF_CHECK_COMPARE_FILE)"; exit 1; }
	@awk -v expected_count='$(REF_CHECK_WORD_COUNT)' \
		-v access_width='$(MEM_ACCESS_WIDTH)' \
		-f "$(CHECK_COMPARE_VALIDATOR)" "$(REF_CHECK_COMPARE_FILE)"
	@! grep -Eq '^REF_CHECK_REFERENCE_(STARTED|BACKDOOR_INPUT_READY|ARRAY_READY)' \
		"$(WORK_ROOT)/ref_check/sim.log"
	@! grep -Eq 'MEMORY_DUT_INPUT_COMPONENT_ARRAY_READY|DUT_INPUT_BACKDOOR_ARRAY_READY' \
		"$(WORK_ROOT)/ref_check/sim.log"
	@test ! -e "$(REF_CHECK_DATA_DIR)/ref_check_dut_input_backdoor.txt"
	@! grep -q '^TEST_FAIL testcase=ref_check' \
		"$(WORK_ROOT)/ref_check/sim.log"
	@$(MAKE) --no-print-directory cleanup_case_logs CASE=ref_check

file_check:
	@$(MAKE) --no-print-directory run_case \
		CASE=file_check PLUSARGS='$(FILE_CHECK_ARGS)'
	@test "$$(grep -c '^FILE_CHECK_MODE_SELECTED mode=$(if $(filter reference,$(FILE_CHECK_MODE)),REFERENCE,FILE) expected_source=$(FILE_CHECK_EXPECTED_SOURCE)$$' \
		"$(WORK_ROOT)/file_check/sim.log")" -eq 1
	@test "$$(grep -c '^FILE_CHECK_INPUT_FILE_LOAD_PASS .* words=$(FILE_CHECK_WORD_COUNT)$$' \
		"$(WORK_ROOT)/file_check/sim.log")" -eq 1
	@test "$$(grep -c '^TB_DUT_INPUT_SOURCE_READY testcase=file_check source=file words=$(FILE_CHECK_WORD_COUNT) file=$(FILE_CHECK_INPUT_FILE)$$' \
		"$(WORK_ROOT)/file_check/sim.log")" -eq 1
	@test "$$(grep -c '^TB_DUT_INPUT_STREAM_DONE testcase=file_check source=file words=$(FILE_CHECK_WORD_COUNT)$$' \
		"$(WORK_ROOT)/file_check/sim.log")" -eq 1
	@if [[ "$(FILE_CHECK_MODE)" == "reference" ]]; then \
		test "$$(grep -c '^MEMORY_REFERENCE_COMPONENT_ARRAY_READY testcase=file_check words=$(FILE_CHECK_WORD_COUNT) operation=pass_through$$' \
			"$(WORK_ROOT)/file_check/sim.log")" -eq 1; \
		! grep -q '^FILE_CHECK_GOLDEN_FILE_LOAD_PASS ' \
			"$(WORK_ROOT)/file_check/sim.log"; \
	else \
		test "$$(grep -c '^FILE_CHECK_GOLDEN_FILE_LOAD_PASS .* words=$(FILE_CHECK_WORD_COUNT)$$' \
			"$(WORK_ROOT)/file_check/sim.log")" -eq 1; \
		! grep -q '^MEMORY_REFERENCE_COMPONENT_ARRAY_READY testcase=file_check ' \
			"$(WORK_ROOT)/file_check/sim.log"; \
	fi
	@test "$$(grep -c '^MEMORY_DUT_INPUT_INTERFACE_CAPTURE_READY testcase=file_check words=$(FILE_CHECK_WORD_COUNT) source=uvm_hdl_read data_path=$(DUT_INPUT_DATA_PATH) address_path=$(DUT_INPUT_ADDRESS_PATH) valid_path=$(DUT_INPUT_VALID_PATH)$$' \
		"$(WORK_ROOT)/file_check/sim.log")" -eq 1
	@test "$$(grep -c '^FILE_CHECK_DUT_INPUT_INTERFACE_ARRAY_READY words=$(FILE_CHECK_WORD_COUNT) data_path=$(DUT_INPUT_DATA_PATH) address_path=$(DUT_INPUT_ADDRESS_PATH) valid_path=$(DUT_INPUT_VALID_PATH)$$' \
		"$(WORK_ROOT)/file_check/sim.log")" -eq 1
	@test "$$(grep -c '^FILE_CHECK_DUT_RESULT_BACKDOOR_ARRAY_READY words=$(FILE_CHECK_WORD_COUNT) path=$(DUT_OUTPUT_DATA_PATH)$$' \
		"$(WORK_ROOT)/file_check/sim.log")" -eq 1
	@test "$$(grep -c '^MEMORY_SCOREBOARD_PASS testcase=file_check words=$(FILE_CHECK_WORD_COUNT) mismatches=0 expected_source=$(FILE_CHECK_EXPECTED_SOURCE)$$' \
		"$(WORK_ROOT)/file_check/sim.log")" -eq 1
	@test "$$(grep -c '^MEMORY_SCOREBOARD_COMPARE_FILE_READY testcase=file_check file=.* words=$(FILE_CHECK_WORD_COUNT) mismatches=0 expected_source=$(FILE_CHECK_EXPECTED_SOURCE)$$' \
		"$(WORK_ROOT)/file_check/sim.log")" -eq 1
	@test "$$(grep -c '^TEST_PASS testcase=file_check words=$(FILE_CHECK_WORD_COUNT) mismatches=0 expected_source=$(FILE_CHECK_EXPECTED_SOURCE)$$' \
		"$(WORK_ROOT)/file_check/sim.log")" -eq 1
	@test "$$(grep -c '^FILE_CHECK_DATA_FILE_READY kind=dut_input_interface .* words=$(FILE_CHECK_WORD_COUNT)$$' \
		"$(WORK_ROOT)/file_check/sim.log")" -eq 1
	@test "$$(grep -c '^FILE_CHECK_DATA_FILE_READY kind=$(FILE_CHECK_EXPECTED_KIND) .* words=$(FILE_CHECK_WORD_COUNT)$$' \
		"$(WORK_ROOT)/file_check/sim.log")" -eq 1
	@test "$$(grep -c '^FILE_CHECK_DATA_FILE_READY kind=dut_output_backdoor .* words=$(FILE_CHECK_WORD_COUNT)$$' \
		"$(WORK_ROOT)/file_check/sim.log")" -eq 1
	@for data_file in $(FILE_CHECK_DATA_FILES); do \
		test -f "$$data_file" || { echo "ERROR: missing file_check data file $$data_file"; exit 1; }; \
		awk -v expected_count='$(FILE_CHECK_WORD_COUNT)' \
			-v access_width='$(MEM_ACCESS_WIDTH)' \
			-f "$(REF_CHECK_DATA_VALIDATOR)" "$$data_file" || exit 1; \
	done
	@awk -v expected_count='$(FILE_CHECK_WORD_COUNT)' \
		-v access_width='$(MEM_ACCESS_WIDTH)' \
		-v source_file='$(FILE_CHECK_INPUT_FILE)' \
		-f "$(REF_CHECK_DATA_VALIDATOR)" "$(FILE_CHECK_WORK_INPUT_FILE)"
	@if [[ "$(FILE_CHECK_MODE)" == "file" ]]; then \
		awk -v expected_count='$(FILE_CHECK_WORD_COUNT)' \
			-v access_width='$(MEM_ACCESS_WIDTH)' \
			-v source_file='$(FILE_CHECK_GOLDEN_FILE)' \
			-f "$(REF_CHECK_DATA_VALIDATOR)" "$(FILE_CHECK_WORK_GOLDEN_FILE)" || exit 1; \
	fi
	@cmp -s "$(FILE_CHECK_WORK_EXPECTED_FILE)" "$(FILE_CHECK_WORK_DUT_OUTPUT_FILE)" || { \
		echo "ERROR: saved expected and DUT output files differ"; exit 1; }
	@test -f "$(FILE_CHECK_COMPARE_FILE)" || { \
		echo "ERROR: missing file_check comparison file $(FILE_CHECK_COMPARE_FILE)"; exit 1; }
	@awk -v expected_count='$(FILE_CHECK_WORD_COUNT)' \
		-v access_width='$(MEM_ACCESS_WIDTH)' \
		-f "$(CHECK_COMPARE_VALIDATOR)" "$(FILE_CHECK_COMPARE_FILE)"
	@! grep -Eq 'MEMORY_DUT_INPUT_COMPONENT_ARRAY_READY|DUT_INPUT_BACKDOOR_ARRAY_READY' \
		"$(WORK_ROOT)/file_check/sim.log"
	@test ! -e "$(FILE_CHECK_DATA_DIR)/file_check_dut_input_backdoor.txt"
	@! grep -q '^TEST_FAIL testcase=file_check' \
		"$(WORK_ROOT)/file_check/sim.log"
	@$(MAKE) --no-print-directory cleanup_case_logs CASE=file_check

else
$(ALL_CASES):
	@:
endif

all: $(ALL_CASES)
	@echo "MEMORY_BACKDOOR_ALL_PASS cases=$(words $(ALL_CASES))"

regression: all
	@echo "MEMORY_BACKDOOR_REGRESSION_PASS"

verdi: check_verdi
	@test "$(words $(REQUESTED_CASES))" -eq 1 || { \
		echo "ERROR: specify exactly one case before verdi"; \
		echo "Example: make file_init verdi"; \
		exit 1; \
	}
	@wave_file="$(WORK_ROOT)/$(VERDI_CASE)/$(VERDI_CASE).fsdb"; \
		test -s "$$wave_file" || { \
			echo "ERROR: waveform not found: $$wave_file"; \
			exit 1; \
		}; \
		echo "Opening $$wave_file"; \
		cd "$(WORK_ROOT)/$(VERDI_CASE)"; \
		nohup "$(VERDI)" -ssf "$$wave_file" >/dev/null 2>&1 &

ll:
	@echo "+----+--------------------+------------------------------------------+"
	@printf "| %-2s | %-18s | %-40s |\n" "#" "TESTCASE" "SOURCE"
	@echo "+----+--------------------+------------------------------------------+"
	@index=0; \
	for case_name in $(ALL_CASES); do \
		index=$$((index + 1)); \
		source_file="testcase/$${case_name}_testcase.sv"; \
		test -f "$(PROJECT_DIR)/$$source_file" || { \
			echo "ERROR: missing testcase source: $$source_file"; \
			exit 1; \
		}; \
		printf "| %-2d | %-18s | %-40s |\n" \
			"$$index" "$$case_name" "$$source_file"; \
	done
	@echo "+----+--------------------+------------------------------------------+"
	@echo "Total executable testcases: $(words $(ALL_CASES))"

list:
	@mkdir -p "$(WORK_ROOT)"
	@find "$(WORK_ROOT)" -mindepth 1 -maxdepth 1 -type d -print | sort

clean:
	@for case_name in $(ALL_CASES); do \
		case_dir="$(WORK_ROOT)/$$case_name"; \
		if [[ -d "$$case_dir" ]]; then rm -rf -- "$$case_dir"; fi; \
	done
	@echo "Removed generated case directories under $(WORK_ROOT)"
