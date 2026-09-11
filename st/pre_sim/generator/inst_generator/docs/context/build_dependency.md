# Build and Package Dependency

## Responsibility

Record the minimum build, include, package, testcase and simulation navigation needed to diagnose compile failures without rescanning the repository.

## Current Architecture

The `single` command is a thin Python wrapper in `verify_tools/script/single`; it executes `verify_tools/script/regression` with `cmd=single`. The regression machinery reads the rsim configuration/case lists, generates `flist_gen.f`, invokes VCS, and runs `simv` with the selected UVM test, seed, verbosity, and case plusargs.

```text
rsim/env_cfg/flist_gen.cfg
  -> bench/define/define.local.f
  -> uvm_tb/uvm_tb.local.f
  -> uvm_tc/uvm_tc.local.f
  -> bench/bench.local.f

cpu_set_pkg
  -> inst_gen_pkg
  -> inst_seq_type_pkg
  -> inst_seq_pkg
  -> scenario_seq_pkg
  -> directed_registry_pkg
  -> random_registry_pkg
  -> inst_gen_env_pkg
  -> tc_pkg
  -> generator_tb_top
```

## Key Files

- `rsim/env_cfg/flist_gen.cfg` — top-level filelist fragments.
- `uvm_tb/uvm_tb.local.f` — package order and include directories.
- `uvm_tc/uvm_tc.local.f`, `uvm_tc/generator_tc_pkg.sv` — testcase package.
- `bench/bench.local.f`, `bench/generator_tb_top.sv` — simulation top.
- `uvm_tb/{inst_gen_env_pkg,scenario_seq/scenario_seq_pkg}.sv` — key include/package boundaries.
- `uvm_tb/registry/{directed_registry_pkg,random_registry_pkg}.sv` — registry plus scenario include point.
- `rsim/env_cfg/single.cfg` — `FLIST`, `TB_TOP`, VCS defines.
- `rsim/case_lst/{random,directed}.lst` — supported scenario runs.
- `/fastone/users/yi.tian/work/dv_bachcore/verify_tools/script/{single,regression}` — external runner.

## Package / Include Details

- `inst_gen_pkg` includes enums/config, address helpers, register pool, instruction classes, name generators, then `inst_generator`; include order is significant.
- `inst_seq_pkg` imports generator/type packages and includes configs/items before concrete sequences and dispatcher.
- `scenario_seq_pkg` imports generator and sequence packages, then includes `scenario_base_seq`.
- Registry packages define registry/macro first, then include their scenario list; scenario classes therefore compile inside the registry package.
- `inst_gen_env_pkg` imports both registries and includes configuration, environment, virtual sequencer, and vsequences.
- `tc_pkg` imports environment/scenario/registry packages and includes test classes.

## Testcase Entry

- `rand_inst_test`: common environment/config base test; does not start a scenario itself.
- `random_scenario_test`: starts `scenario_base_vsequence`; selection uses `+random_scenario_name`.
- `directed_inst_test`: starts the same sequence; selection uses `+directed_seq_name`.
- The two scenario-name plusargs are mutually exclusive and one is required.

Current targeted commands from `rsim`:

```text
single case=mu_safe_random_scenario_test lst=random.lst seed=1 uvm=UVM_LOW
single case=mu_c_random_scenario_test lst=random.lst seed=1 uvm=UVM_LOW
single case=multicore_directed_test lst=directed.lst seed=1 uvm=UVM_LOW
```

## Outputs and Logs

The run directory is `rsim/sim_single`. VCS compilation writes `compile.log`; simulation writes `sim.log`. Scenario output includes per-core `.S/.vmem` files and `log/task_info.log`; configuration and sequence logs are under `log/`. The generated `rsim/flist_gen.f`, build products and logs are run artifacts, not source dependencies.

## Dependencies

Adding an instruction class normally requires inclusion through `inst_gen_pkg`; adding a sequence requires inclusion through `inst_seq_pkg`; adding a scenario requires its scenario list only. Moving a class across packages requires checking imports and compile order before changing filelists.

## Current Status

- Simulator: Synopsys VCS S-2021.09-SP2; UVM 1.2 paths are supplied by the runner environment.
- Top: `generator_tb_top`.
- Scenario random and directed targeted cases compile/run successfully in the current working tree.
- The server lacks `rg`; use `find`/`grep` for focused diagnostics.

## Known Limitations

- `flist_gen.f` contains absolute paths and is regenerated; do not treat it as the canonical filelist.
- Build tooling lives in sibling `verify_tools`, outside the generator directory.
- `scenario/README.md` names obsolete vsequences and `random_scenario.lst`; current source uses one common executor and `random.lst`.
- `rand_flush_except_test.sv` remains compiled although its old `all_rand_test` list entry was removed.
- Server clock skew warnings may appear during incremental VCS compilation; targeted runs still completed in the verified state.

## Recommended Read Scope

### Diagnose missing class/type/include

Read:

1. Package containing the reference
2. Package expected to define the type
3. `uvm_tb/uvm_tb.local.f`
4. One registry scenario list if the missing type is a scenario

### Add a new scenario file

Read:

1. Relevant random/directed scenario list
2. Relevant registry package
3. Matching case list only if adding a runnable case

### Diagnose `single` invocation or plusarg

Read:

1. `rsim/env_cfg/single.cfg`
2. Selected case list
3. `verify_tools/script/single` wrapper
4. Focused section of `regression` only if parsing/execution fails

## Do Not Read By Default

Do not read generated VCS C/C++ files, `simv.daidir`, full regression script, every package body, all case lists, or instruction implementation when diagnosing an isolated include/order issue.

## Expansion Conditions

- Read implementation only when the compiler points to a real symbol/API mismatch.
- Read the regression script beyond focused option parsing only for a runner defect.
- Read generated flist/log output to confirm resolution, not as architecture source.
- Run more than one targeted case only when the change crosses random/directed or package boundaries.

## Last Verified

Repository state: commit `4723233`, dirty working tree, analyzed 2026-09-09.

Verified areas: filelist chain, package order/imports/includes, tests, case arguments, runner location, outputs.

Needs re-verification if packages move, filelist fragments change, runner config changes, or testcase selection changes.
