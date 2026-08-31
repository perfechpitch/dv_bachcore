######################################################################
#### tb_top setting(for dual top) 
TB_TOP              ?= 
TB_TOPS				= $(patsubst %,-top %,$(TB_TOP))
######################################################################
#### file lists
FLIST				?= flist_rtl.f
######################################################################
####UPF_FILE
UPF_FILE_PATH  ?=   
UPF_TOP	  	   ?=
######################################################################
#### generic simulation control+memcbk
VCS_OPTS			+=vcs -sverilog -full64 -debug_access+all -debug_region+cell+encrypt +vpi +lint=TFIPC-L,PCWM +vcs+lic+wait -assert svaext
VCS_OPTS_VERDI 		= -P $(VERDI_HOME)/share/PLI/VCS/LINUX64/novas.tab \
						$(VERDI_HOME)/share/PLI/VCS/LINUX64/pli.a 
VCS_OPTS_UVM		= +incdir+$(UVM_HOME)/src \
						$(UVM_HOME)/src/uvm.sv \
						$(UVM_HOME)/src/dpi/uvm_dpi.cc \
						$(UVM_HOME)/src/uvm_pkg.sv \
						-CFLAGS -DVCS  
######################################################################
#####default options
VCS_COMP_LOG		?= compile.log
VCS_SIMV_NAME		?= ./simv
VCS_TIMESCALE		?= 1ns/1ps
VCS_TB_DEFINES    	?=  
VCS_TB_ARGS         ?=
CMP_OTHERS			?=
CMP_FULL			?=
SIM_VERBOSITY		?= UVM_LOW
SIM_TESTNAME		?= test_dut 
SIM_LOG				?= sim.log
SIM_OTHERS			?=
SIM_FULL			?=
UVM_ARGS            ?= +UVM_NO_RELNOTES 
COV_DB_NAME         ?= simv
SOLVER_ERR          ?= +ntb_stop_on_constraint_solver_error=1
######################################################################
PARALLEL_NUM ?= 0
ifeq ($(PARALLEL_NUM),0)
    PARALLELCOMP =
else
    PARALLELCOMP = -parallelcomp=j$(PARALLEL_NUM) 
endif
######################################################################
#### debug control
DEBUG ?= 0
#DVE_DEBUG = -debug_acc+pp+f+dmptf -debug_region+cell+encrypt -R -gui -kdb
ifeq ($(DEBUG),1)
    DVE_DEBUG = -gui -kdb
else
    DVE_DEBUG =  
endif
######################################################################
#VCS_glitch
#+fsdb+glitch=num,0表示所有的glitch都保存，1表示最近的glitch保存，2表示最近两个glitch被保存
#+fsdb+glitch=0 +fsdb+dumpoff_glitch+time,表示停止dump glitch的时间，+fsdb+dumpoff_glitch+30
#+fsdb+delta 等价于 +fsdb+glitch=0 +fsdb+sequential +fsdb+region
GLITCH ?= 0
ifeq ($(GLITCH),1)
    VCS_GLITCH = +fsdb+glitch=0 +fsdb+sequential +fsdb_region
else
    VCS_GLITCH =  
endif
######################################################################
#### PROFILE setting
PROFILE ?= 0
ifeq ($(PROFILE), 0)
    VCS_OPTS_PROFILE		=
    SIM_OPTS_PROFILE		=  
endif
ifeq ($(PROFILE), 1)
    VCS_OPTS_PROFILE		= -simprofile
    SIM_OPTS_PROFILE		= -simprofile time
endif
ifeq ($(PROFILE), 2)
    VCS_OPTS_PROFILE		= -simprofile
    SIM_OPTS_PROFILE		= -simprofile mem
endif
######################################################################
#### waveform dump control
WAVE ?= 0
ifeq ($(WAVE), 1)
    SIM_OPTS_WAVE		= +dump
else
    SIM_OPTS_WAVE		=  
endif
######################################################################
#### COV setting
COV ?= 0            # Switch on file based coverage if 1
ifeq ($(COV), 1)
    VCS_OPTS_COV		= -lca -cm line+cond+fsm+branch+tgl+assert -cm_tgl structarr  -cm_tgl mda -cm_cond tf+for
    SIM_OPTS_COV		= -cm line+cond+fsm+branch+tgl+assert -cm_name $(COV_DB_NAME)
else
    VCS_OPTS_COV		=
    SIM_OPTS_COV		=  
endif
######################################################################
COV_RPT ?= 0
ifeq ($(COV_RPT), 1)
    URG_OPTS  			= urg -dir $(VCS_SIMV_NAME).vdb -report $(VCS_SIMV_NAME)_cov_rpt 
else
    URG_OPTS            = 
endif
######################################################################
MASK_COV ?= 0
ifeq ($(MASK_COV), 1)
    VCS_OPTS_COV	   += -cm_hier $(MASK_COV_NAME)
endif
######################################################################
#### SEED setting
ifdef SEED
    SIM_OPTS_SEED 		= +ntb_random_seed=$(SEED)
else
    SIM_OPTS_SEED 		= +ntb_random_seed_automatic
endif
######################################################################
####Low Power setting 
LP ?= 0
ifeq ($(LP),1)
    UPF_OPTS = -power=pst_state_msg+dump_hvp+coverage+src_off_clamp_check  -power_top $(UPF_TOP)  +define+UPF +warn=noUPF_CONYI,noIWNF,noTFIPC -upf $(UPF_FILE_PATH)
else
    UPF_OPTS =  
endif
######################################################################
####C program path 
C_PROG_DIR      ?=
C_PROG_PATH      = $(C_PROG_DIR)
FLOAT_PROG_PATH ?= $(CLIB_HOME)/softfloat/*.c
JTAG_PROG_PATH  ?= $(CLIB_HOME)/jtag/*.c
######################################################################
####GCC setting 
GCC_FLAG        ?= 0
CPP_FLAG        ?= 0
SYSC_FLAG       ?= 0
JTAG_GCC_FLAG   ?= 0
FLOAT_GCC_FLAG  ?= 0
C_HEAD_DIR      ?=
C_LIB_DIR       ?=
C_STD_NUM       ?= 11
######################################################################
ifeq ($(JTAG_GCC_FLAG),1)
    GCC_FLAG      = 1
    C_PROG_PATH  += $(JTAG_PROG_PATH)
endif
ifeq ($(FLOAT_GCC_FLAG),1)
    GCC_FLAG      = 1
    C_PROG_PATH  += $(FLOAT_PROG_PATH)
endif
######################################################################
GCC_OPTS ?=  
ifeq ($(GCC_FLAG),1)
    GCC_OPTS      = $(C_HEAD_DIR) -CFLAGS -g $(C_PROG_PATH) -CFLAGS -std=c99
endif
ifeq ($(CPP_FLAG),1)
    GCC_OPTS      = -cc g++ -cpp g++ -CFLAGS "-std=c++$(C_STD_NUM)" $(C_HEAD_DIR) -LDFLAGS "-lstdc++" $(C_PROG_PATH) 
endif
ifeq ($(SYSC_FLAG),1)
    GCC_OPTS      =  -CFLAGS "-std=c++$(C_STD_NUM)" $(C_LIB_DIR) -LDFLAGS "-lsystemc" $(C_HEAD_DIR) $(C_PROG_PATH)  
endif
######################################################################
XPROP_FLAG = 1
ifeq ($(XPROP_FLAG),1)
    XPROP_OPTS = -xprop=tmerge
else
    XPROP_OPTS =  
endif
######################################################################
### VCS LOG setting
#0：用于rtl仿真（默认选项）
#1：用于0延迟网表仿真
#2：用于功耗分析，不做时序检查
#3：用于功耗后仿
TIMING_MODE = 0
ifeq ($(TIMING_MODE),0) 
    #+delay_mode_zero : ignore assign #xns xxx_delay = xxx;
    #VCS_TIMING_MODE = +delay_mode_zero +notimingcheck +nospecify
    VCS_TIMING_MODE = +notimingcheck +nospecify
endif
ifeq ($(TIMING_MODE),1) 
    VCS_TIMING_MODE = +delay_mode_zero +notimingcheck +nospecify +no_notifier
endif
ifeq ($(TIMING_MODE),2) 
    VCS_TIMING_MODE = +neg_tchk +notimingcheck -negdelay +sdfverbose -sdfretain +optconfigfile+no_timing.cfg +transport_path_delays  +pulse_e/50 +pulse_r/50
endif
ifeq ($(TIMING_MODE),3) 
    #VCS_TIMING_MODE = +neg_tchk +sdfverbose -negdelay +optconfigfile+no_timing.cfg
    VCS_TIMING_MODE = +neg_tchk -negdelay +sdfverbose -sdfretain +optconfigfile+no_timing.cfg +transport_path_delays  +pulse_e/50 +pulse_r/50
endif
######################################################################
DPO_MODE = 0
ifeq ($(DPO_MODE),0) 
    VCS_DPO_OPTS		=
endif
ifeq ($(DPO_MODE),1) 
    VCS_DPO_OPTS		= -lca -dpo -dpo_opts mode=learn+apps=default,lint
endif
ifeq ($(DPO_MODE),2) 
    VCS_DPO_OPTS		= -lca -dpo -dpo_opts mode=apply+apps=default,lint
endif
######################################################################
#### local variables and final compilation/simulation option
COMPOPTS			 = $(VCS_OPTS) $(CMP_FULL) $(PARALLELCOMP) $(VCS_OPTS_VERDI) $(VCS_OPTS_UVM)
COMPOPTS            += $(VCS_DPO_OPTS)
COMPOPTS            += $(VCS_TIMING_MODE)
COMPOPTS			+= -o $(VCS_SIMV_NAME) 
COMPOPTS			+= -timescale=$(VCS_TIMESCALE) 
COMPOPTS			+= $(VCS_TB_DEFINES) 
COMPOPTS            += $(CMP_OTHERS)
COMPOPTS			+= $(TB_TOPS)
COMPOPTS			+= -f $(FLIST)
COMPOPTS			+= $(DVE_DEBUG)
COMPOPTS			+= $(VCS_OPTS_COV) 
COMPOPTS			+= $(VCS_OPTS_PROFILE) 
COMPOPTS			+= $(UPF_OPTS) 
COMPOPTS			+= $(GCC_OPTS) 
COMPOPTS			+= $(XPROP_OPTS) 
SIMOPTS				 = $(VCS_SIMV_NAME)
SIMOPTS				+= +UVM_TESTNAME=$(SIM_TESTNAME) 
SIMOPTS				+= +UVM_VERBOSITY=$(SIM_VERBOSITY)
SIMOPTS				+= $(VCS_GLITCH) $(DVE_DEBUG) $(SIM_OPTS_WAVE) $(SIM_OPTS_COV) $(SIM_OPTS_SEED) 
SIMOPTS             += $(SIM_OPTS_PROFILE)
SIMOPTS			    += $(VCS_TB_ARGS) 
SIMOPTS				+= $(SIM_OTHERS)
SIMOPTS				+= $(SIM_FULL)
SIMOPTS				+= $(UVM_ARGS)
SIMOPTS				+= $(SOLVER_ERR)
####### 
######################################################################
#look log in race.unique.out
MULTI_DRV       = 0
ifeq ($(MULTI_DRV),1)
    COMPOPTS            += -race
endif
######################################################################
### VCS LOG setting
VCS_LOG = 0
ifeq ($(VCS_LOG),1) 
    COMPOPTS			+= -l $(VCS_COMP_LOG) 
    SIMOPTS				+= -l $(SIM_LOG)
else
    COMPOPTS			+=  
    SIMOPTS				+=  
endif
######################################################################
#### global rule
all : compile sim 
compile : 
	$(COMPOPTS)
sim :
	@	echo "======================================================="; 
	@	echo "          Current test: $(SIM_TESTNAME)       	     ";
	@	echo "======================================================="; 
	$(SIMOPTS)
    
urg :

	$(URG_OPTS)  			 
clean :
	rm -rf simv* log/* *.log core* csrc vc_hdrs.h ucli.key urg* vcdplus.vpd sfh 
deepclean :
	rm -rf simv* log/* *.log core* 
	rm -rf csrc novas* *.fsdb *.h *.key verdiLog transcript  
	rm -rf vsim.wlf work *.vpd  DVEfiles   
show:
	@echo "#### Makefile VAR show ####"
	@echo TB_TOP			= $(TB_TOPS)
	@echo FLIST				= $(FLIST)
	@echo VCS_HOME			= $(VCS_HOME)
	@echo VERDI_HOME		= $(VERDI_HOME)
	@echo UVM_HOME			= $(UVM_HOME)
	@echo C_PROG_PATH	    = $(C_PROG_PATH)