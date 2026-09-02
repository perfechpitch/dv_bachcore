interface axi4_irq_if (
  input logic aclk,
  input logic aresetn,
  input logic irq
);
  modport monitor (
    input aclk,
    input aresetn,
    input irq
  );
endinterface
