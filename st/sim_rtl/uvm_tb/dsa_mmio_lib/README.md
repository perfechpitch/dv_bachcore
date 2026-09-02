# DSA MMIO Reference Model

## 目标

`dsa_mmio_lib` 负责 DSA 软件可见 MMIO、Register File state、内部 bypass state，以及 trigger 时产生本次 DSA 宏指令使用的 effective parameter snapshot。

基本边界：

```text
JSON
  描述寄存器、字段、state、static/dynamic关系

Python generator
  机械生成 declaration/reset/read/write/resolve

vu_mmio_set
  MMIO状态
  RF状态
  特殊MMIO行为
  trigger snapshot

vu_inst_lib
  opcode
  operand source语义
  execution
  bypass
  writeback