SHELL := /bin/bash
.DEFAULT_GOAL := help

SIM_DIR   := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
VERIFICATION_ROOT := $(abspath $(SIM_DIR)/..)
AXI4_VIP_ROOT     := $(abspath $(VERIFICATION_ROOT)/..)
MEM_MODEL_ROOT    := $(abspath $(AXI4_VIP_ROOT)/../mem_model)
OUT_DIR   ?= $(VERIFICATION_ROOT)/out
BUILD_DIR := $(OUT_DIR)/build
FILELIST  := $(SIM_DIR)/tb.f
TOP       := tb
SIMV      := $(BUILD_DIR)/simv

SEED     ?= 1
WAVES    ?= fsdb
RUN_ARGS ?=
TEST_NAME := axi_vip_random_test
REQUIRED_MARKER := AXI_VIP_RANDOM_PASS

export LC_ALL := C
export LANG := C

.PHONY: help build run clean

help:
	@echo "AXI VIP four-Agent random verification"
	@echo
	@echo "  make build                 compile the UVM testbench"
	@echo "  make run SEED=1            run random read/write traffic"
	@echo "  make clean                 remove verification/out"
	@echo
	@echo "Optional: WAVES=fsdb RUN_ARGS='+MW_0_WRITE_BURST_COUNT=32'"

build:
	@env AXI4_VIP_ROOT='$(AXI4_VIP_ROOT)' \
		MEM_MODEL_ROOT='$(MEM_MODEL_ROOT)' \
		VERIFICATION_ROOT='$(VERIFICATION_ROOT)' FILELIST='$(FILELIST)' \
		VCS_TOP='$(TOP)' BUILD_DIR='$(BUILD_DIR)' WAVES='$(WAVES)' \
		bash '$(SIM_DIR)/compile_vcs.sh'

run: build
	@env SIMV='$(SIMV)' OUT_DIR='$(OUT_DIR)' CASE_NAME='random' \
		TEST_NAME='$(TEST_NAME)' SEED='$(SEED)' WAVES='$(WAVES)' \
		REQUIRED_MARKER='$(REQUIRED_MARKER)' RUN_ARGS='$(RUN_ARGS)' \
		bash '$(SIM_DIR)/run_vcs.sh'

clean:
	@rm -rf '$(OUT_DIR)'
