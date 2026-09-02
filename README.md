# dv_bachcore

st/core_ref is the common reference-model implementation shared by pre-simulation and RTL simulation flows. It contains the instruction, CSR, memory, and DSA reference models; st/core_ref/ref_sim is its standalone local simulation environment.

st/sim_rtl is the RTL/UVM simulation platform skeleton:

- uvm_tc: UVM testcases.
- uvm_tb: UVM testbench components.
- rsim: RTL simulation scripts and configuration.
- bench: simulation bench integration.

st/inst_generator is responsible for instruction generation and the main pre-simulation flow, and can be tested independently when present in the working branch.

Dependency direction: inst_generator and sim_rtl may depend on core_ref; core_ref depends on neither.
