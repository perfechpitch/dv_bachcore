# pre_sim scene generator

`hardware_feature.json` is the source of truth for runnable directed scenes.
`--input` may also name a directory; every `*.json` file directly under that
directory is loaded in filename order and validated as one scene set.
Each `scene_name` is also the unique `case_name` written to
`inst_generator/rsim/case_lst/directed.lst`.

## Scene metadata

```json
{
  "scene_id": 1,
  "scene_name": "multicore_directed_test",
  "scenario": {
    "category": "workload",
    "seq_file": "workload/multicore_directed_scenario_seq.sv",
    "seq_name": "multicore_directed",
    "args": {}
  }
}
```

The scenario file must follow `input/scenario/README.md`, register exactly the
configured `seq_name`, and be included by `directed_scenario_list.svh`.

Scenario source declares supported arguments with literal
`$test$plusargs("name")` or `$value$plusargs("name=%h", value)` calls. JSON may
configure any subset. An argument configured in JSON but not used by the
scenario is an error. An omitted argument is not passed, so the scenario or
inst_generator keeps its default behavior.

Generated managed cases include a comment listing every detected plusarg.
Manual cases are never overwritten.

## Commands

```sh
# Validate and synchronize directed.lst only.
python3 st/pre_sim/generator/scene_generator/generate.py \
  --scene multicore_directed_test --mode sync

# Validate and synchronize every JSON file in a test-input directory.
python3 st/pre_sim/generator/scene_generator/generate.py \
  --input st/pre_sim/input/pre_sim_test --all --mode sync

# Generate and publish one scene under output/scene_NNN.
python3 st/pre_sim/generator/scene_generator/generate.py \
  --scene multicore_directed_test --mode inst-gen

# Generate one scene, run core_ref, and publish ref_log.
python3 st/pre_sim/generator/scene_generator/generate.py \
  --scene multicore_directed_test --mode full

# Native verify_tools batch test. It records only native batch output and does
# not replace the formal output/scene_NNN artifacts.
python3 st/pre_sim/generator/scene_generator/generate.py \
  --all --mode inst-gen --batch-times 2
```

Batch logs are copied without rewriting to
`output/batch/YYYY-MM-DD/inst_gen/batch.log`. A later Git-CI retention job may
keep only the latest seven daily directories. Re-running on the same day
replaces that day's batch record.

`program/task_info.log` is currently retained because it is the inst_generator
source used to build `task_info.json`. TODO: after checking all downstream
consumers, decide whether the raw log should remain in published output.
