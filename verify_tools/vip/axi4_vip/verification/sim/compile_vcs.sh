#!/usr/bin/env bash

set -euo pipefail

export LC_ALL=C
export LANG=C

: "${AXI4_VIP_ROOT:?AXI4_VIP_ROOT is required}"
: "${MEM_MODEL_ROOT:?MEM_MODEL_ROOT is required}"
: "${VERIFICATION_ROOT:?VERIFICATION_ROOT is required}"
: "${FILELIST:?FILELIST is required}"
: "${VCS_TOP:?VCS_TOP is required}"
: "${BUILD_DIR:?BUILD_DIR is required}"

WAVES="${WAVES:-none}"

if [[ -n "${VIP_TOOL_SETUP:-}" ]]; then
    if [[ ! -f "${VIP_TOOL_SETUP}" ]]; then
        echo "[error] VIP_TOOL_SETUP not found: ${VIP_TOOL_SETUP}" >&2
        exit 2
    fi
    # The user owns this explicit simulator setup script.
    source "${VIP_TOOL_SETUP}"
fi

if ! command -v vcs >/dev/null 2>&1; then
    echo "[error] vcs is not available on PATH" >&2
    echo "[hint] source the simulator environment, or set VIP_TOOL_SETUP" >&2
    exit 2
fi
if [[ ! -f "${FILELIST}" ]]; then
    echo "[error] filelist not found: ${FILELIST}" >&2
    exit 2
fi
if [[ ! -d "${AXI4_VIP_ROOT}" ]]; then
    echo "[error] AXI4 VIP source directory not found: ${AXI4_VIP_ROOT}" >&2
    exit 2
fi
if [[ ! -d "${MEM_MODEL_ROOT}" ]]; then
    echo "[error] Memory Model source directory not found: ${MEM_MODEL_ROOT}" >&2
    exit 2
fi
if [[ ! -d "${VERIFICATION_ROOT}" ]]; then
    echo "[error] Verification directory not found: ${VERIFICATION_ROOT}" >&2
    exit 2
fi

case "${WAVES}" in
    none|fsdb) ;;
    *)
        echo "[error] WAVES must be 'none' or 'fsdb', got: ${WAVES}" >&2
        exit 2
        ;;
esac

mkdir -p "${BUILD_DIR}"
compile_log="${BUILD_DIR}/compile.log"
vcs_args=(
    -full64
    -sverilog
    -timescale=1ns/1ps
    +define+UVM_HDL_MAX_WIDTH=4096
    -ntb_opts uvm-1.2
    -lca
    -kdb
    -debug_access+all
)

if [[ -n "${VCS_DEFINES:-}" ]]; then
    IFS=',' read -r -a requested_defines <<< "${VCS_DEFINES}"
    for requested_define in "${requested_defines[@]}"; do
        if ! [[ "${requested_define}" =~ ^[A-Za-z_][A-Za-z0-9_]*(=[A-Za-z0-9_]+)?$ ]]; then
            echo "[error] invalid VCS define: ${requested_define}" >&2
            exit 2
        fi
        vcs_args+=("+define+${requested_define}")
    done
fi

if [[ "${WAVES}" == "fsdb" ]]; then
    : "${VERDI_HOME:?VERDI_HOME is required when WAVES=fsdb}"
    vcs_args+=(
        +define+AXI_FSDB
        -P "${VERDI_HOME}/share/PLI/VCS/linux64/novas.tab"
           "${VERDI_HOME}/share/PLI/VCS/linux64/pli.a"
    )
fi

echo "[build] top=${VCS_TOP} waves=${WAVES}"
echo "[build] output=${BUILD_DIR}"
cd "${BUILD_DIR}"
vcs "${vcs_args[@]}" \
    -f "${FILELIST}" \
    -top "${VCS_TOP}" \
    -o simv \
    -l "${compile_log}"

if [[ ! -x "${BUILD_DIR}/simv" || ! -s "${compile_log}" ]]; then
    echo "[error] VCS did not generate simv and compile.log" >&2
    exit 1
fi
if grep -Eiq 'ICPSD|Illegal combination of drivers' "${compile_log}"; then
    echo "[error] illegal DUT/VIP driver combination detected" >&2
    exit 1
fi
echo "[build] PASS: ${compile_log}"
