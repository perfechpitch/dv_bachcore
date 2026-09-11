#!/usr/bin/env csh
# Define verification environment variables here.
setenv VERIFY_TOOL_PATH $LOCAL/dv_bachcore/verify_tools;
setenv PATH             $VERIFY_TOOL_PATH/script:$PATH;

# Synopsys VCS / Verdi
setenv APP_PATH /fastone/softwares
setenv SNPSLMD_LICENSE_FILE 27000@172.22.1.15
setenv LM_LICENSE_FILE      ${SNPSLMD_LICENSE_FILE}
source /fastone/softwares/modules/init/csh
module load vcs/S-2021.09-SP2
module load verdi/T-2022.06
setenv UVM_HOME ${VCS_HOME}/etc/uvm-1.2
