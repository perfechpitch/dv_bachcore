#!/usr/bin/env bash

set -euo pipefail

export LC_ALL=C
export LANG=C

: "${SIMV:?SIMV is required}"
: "${OUT_DIR:?OUT_DIR is required}"
: "${CASE_NAME:?CASE_NAME is required}"
: "${TEST_NAME:?TEST_NAME is required}"
SEED="${SEED:-1}"
WAVES="${WAVES:-none}"
RUN_ARGS="${RUN_ARGS:-}"
REQUIRED_MARKERS="${REQUIRED_MARKERS:-${REQUIRED_MARKER:-}}"

if [[ ! -x "${SIMV}" ]]; then
    echo "[error] compiled simulator not found: ${SIMV}" >&2
    exit 2
fi
if ! [[ "${SEED}" =~ ^[0-9]+$ ]]; then
    echo "[error] SEED must be an unsigned decimal integer" >&2
    exit 2
fi
for value in "${CASE_NAME}" "${TEST_NAME}"; do
    if ! [[ "${value}" =~ ^[A-Za-z0-9_][A-Za-z0-9_.-]*$ ]]; then
        echo "[error] invalid case, test or marker name: ${value}" >&2
        exit 2
    fi
done
if [[ -z "${REQUIRED_MARKERS}" ]]; then
    echo "[error] REQUIRED_MARKER or REQUIRED_MARKERS is required" >&2
    exit 2
fi

run_stamp="$(date +%Y%m%d_%H%M%S)_$$"
run_dir="${OUT_DIR}/runs/${CASE_NAME}/${run_stamp}"
sim_log="${run_dir}/sim.log"
wave_file="${run_dir}/waves.fsdb"
mkdir -p "${run_dir}"

sim_args=(
    "+UVM_TESTNAME=${TEST_NAME}"
    +UVM_VERBOSITY=UVM_LOW
    "+ntb_random_seed=${SEED}"
)
if [[ "${WAVES}" == "fsdb" ]]; then
    sim_args+=("+AXI_WAVE_FILE=${wave_file}")
fi
if [[ -n "${RUN_ARGS}" ]]; then
    read -r -a extra_args <<< "${RUN_ARGS}"
    sim_args+=("${extra_args[@]}")
fi

echo "[run] case=${CASE_NAME} test=${TEST_NAME} seed=${SEED}"
echo "[run] output=${run_dir}"
cd "${run_dir}"
set +e
"${SIMV}" "${sim_args[@]}" -l "${sim_log}"
sim_status=$?
set -e

if (( sim_status != 0 )); then
    echo "[error] simv exited with status ${sim_status}: ${sim_log}" >&2
    exit 1
fi
if ! grep -Eq 'UVM_ERROR[[:space:]]*:[[:space:]]*0' "${sim_log}"; then
    echo "[error] UVM_ERROR summary is not zero: ${sim_log}" >&2
    exit 1
fi
if ! grep -Eq 'UVM_FATAL[[:space:]]*:[[:space:]]*0' "${sim_log}"; then
    echo "[error] UVM_FATAL summary is not zero: ${sim_log}" >&2
    exit 1
fi
for marker in ${REQUIRED_MARKERS}; do
    if ! [[ "${marker}" =~ ^[A-Za-z0-9_][A-Za-z0-9_.-]*$ ]]; then
        echo "[error] invalid completion marker: ${marker}" >&2
        exit 2
    fi
    if ! grep -q "${marker}" "${sim_log}"; then
        echo "[error] completion marker ${marker} is missing" >&2
        exit 1
    fi
done
if [[ "${WAVES}" == "fsdb" && ! -s "${wave_file}" ]]; then
    echo "[error] FSDB waveform was not generated: ${wave_file}" >&2
    exit 1
fi

echo "[run] PASS: ${sim_log}"
if [[ -s "${wave_file}" ]]; then
    echo "[run] WAVE: ${wave_file}"
fi
