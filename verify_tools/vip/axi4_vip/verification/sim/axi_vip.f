# Reusable source closure. UVM itself is selected by the simulator command.
+incdir+$MEM_MODEL_ROOT
+incdir+$AXI4_VIP_ROOT/axi_common
+incdir+$AXI4_VIP_ROOT/axi_master_uvc/axi_master_read_uvc
+incdir+$AXI4_VIP_ROOT/axi_master_uvc/axi_master_write_uvc
+incdir+$AXI4_VIP_ROOT/axi_slaver_uvc/axi_slaver_read_uvc
+incdir+$AXI4_VIP_ROOT/axi_slaver_uvc/axi_slaver_write_uvc
+incdir+$AXI4_VIP_ROOT/axi_vip_uvc

$MEM_MODEL_ROOT/mem_model_pkg.sv
$AXI4_VIP_ROOT/axi_common/axi_param_rules_pkg.sv
$AXI4_VIP_ROOT/axi_common/axi_read_if.sv
$AXI4_VIP_ROOT/axi_common/axi_write_if.sv
$AXI4_VIP_ROOT/axi_common/axi_common_pkg.sv
$AXI4_VIP_ROOT/axi_master_uvc/axi_master_read_uvc/axi_master_read_pkg.sv
$AXI4_VIP_ROOT/axi_master_uvc/axi_master_write_uvc/axi_master_write_pkg.sv
$AXI4_VIP_ROOT/axi_slaver_uvc/axi_slaver_read_uvc/axi_slaver_read_pkg.sv
$AXI4_VIP_ROOT/axi_slaver_uvc/axi_slaver_write_uvc/axi_slaver_write_pkg.sv
$AXI4_VIP_ROOT/axi_vip_uvc/axi_vip_pkg.sv
