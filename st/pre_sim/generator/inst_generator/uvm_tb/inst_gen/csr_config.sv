typedef struct packed{
    bit[2:0] fs;
    bit[2:0] vs;
    bit      mie;
    bit      msie;/*TODO: not sure*/
}csr_cfg_s;
class csr_config extends uvm_object;
typedef enum{VSTART_MIN,VSTART_LOW,VSTART_AVR,VSTART_HIGH,VSTART_MAX} vstart_val_e;
typedef enum{VL_MIN,VL_LOW,VL_AVR,VL_HIGH,VL_MAX} vl_val_e;
 parameter VLEN = 256;
    rand mode_e program_mode;
    rand mode_e ls_mode;
    string ls_mode_string;
    string program_mode_string;

    //configuarable in mstatus
    rand bit [1:0] fs;
    rand bit [1:0] vs;
    rand bit mie;
    rand bit sie;
    rand bit msie;
    rand bit [2:0] frm;
    rand bit mprv;
    rand bit [1:0] mpp;
    rand bit mstatus_sum;
    rand bit mstatus_tsr;
    rand bit[63:0] mideleg;
    rand bit[63:0] medeleg;

    rand bit [3:0] map_mode;

    bit [11:0] csr_cfg_addr[$];
    bit [63:0] csr_cfg_val[$];

    bit except_disable,int_ack_disable;
    rand bit s_except_handle_en;
    rand bit mret_config;




    int cfg_file;


    csr_cfg_s csr_s;

    `uvm_object_utils_begin(csr_config)
        `uvm_field_int(fs, UVM_DEFAULT|UVM_HEX)
        `uvm_field_int(vs, UVM_DEFAULT|UVM_HEX)
        `uvm_field_int(frm, UVM_DEFAULT|UVM_HEX)
        `uvm_field_int(mie, UVM_DEFAULT|UVM_HEX)
        `uvm_field_int(msie, UVM_DEFAULT|UVM_HEX)
        `uvm_field_int(mprv, UVM_DEFAULT|UVM_HEX)
        `uvm_field_int(mpp, UVM_DEFAULT|UVM_HEX)
        `uvm_field_int(mstatus_sum,UVM_DEFAULT|UVM_HEX)
        `uvm_field_int(mstatus_tsr,UVM_DEFAULT|UVM_HEX)
        `uvm_field_int(medeleg, UVM_DEFAULT |UVM_HEX)
        `uvm_field_int(mideleg, UVM_DEFAULT |UVM_HEX)

        `uvm_field_enum(mode_e,program_mode, UVM_DEFAULT)
        `uvm_field_enum(mode_e,ls_mode, UVM_DEFAULT)
        `uvm_field_int(except_disable,  UVM_DEFAULT)
        `uvm_field_int(int_ack_disable,  UVM_DEFAULT)
        `uvm_field_int(s_except_handle_en, UVM_DEFAULT)
    `uvm_object_utils_end
    // new - constructor
  function new (string name = "csr_config");
      super.new(name);
      cfg_file = $fopen("./csr_cfg.dat","w");
    endfunction : new

    function void pre_randomize();
        csr_cfg_addr.push_back('h180); //satp_addr
        csr_cfg_addr.push_back('h300); //mstatus_addr
        csr_cfg_addr.push_back('h303); //mideleg_addr
        csr_cfg_addr.push_back('h302); //medeleg_addr
        csr_cfg_addr.push_back('h304); //mie_addr
        if(fs ==3)
        csr_cfg_addr.push_back('h002); //frm
        //at first position
        csr_cfg_addr.push_front('h00a); //vxrm
        csr_cfg_addr.push_front('h008); //vstart
        csr_cfg_addr.push_front('hc21); //vtype
        csr_cfg_addr.push_front('hc20); //vl
        //vl is set by vset inst

        if($value$plusargs("program_mode=%s",program_mode_string))begin
            case(program_mode_string)
                "M_MODE"    : program_mode = M_MODE;
                "S_MODE"    : program_mode = S_MODE;
                "U_MODE"    : program_mode = U_MODE;
            endcase
        end
        if($value$plusargs("ls_mode=%s",ls_mode_string))begin
            case(ls_mode_string)
                "M_MODE"    : ls_mode = M_MODE;
                "S_MODE"    : ls_mode = S_MODE;
                "U_MODE"    : ls_mode = U_MODE;
            endcase
        end
    endfunction

 constraint except_deleg_c{

        if(program_mode == M_MODE || except_disable & int_ack_disable) s_except_handle_en == 0;

        if(s_except_handle_en){
            (mideleg[1] | mideleg[5] | mideleg[9] | mideleg[13] | (|medeleg)) == 1;
            mstatus_tsr == 0;
        }
        else if(program_mode != M_MODE || ls_mode != M_MODE) {(mideleg[1] | mideleg[5] | mideleg[9] | mideleg[13] | (|medeleg)) == 0;}

    }
    constraint mode_c{
        if(program_mode_string == "M_MODE"){
            program_mode == M_MODE;
        }
        else if(program_mode_string == "S_MODE"){
            program_mode == S_MODE;
        }
        else if(program_mode_string == "U_MODE"){
            program_mode == U_MODE;
        }
        program_mode != D_MODE;


        if(program_mode == M_MODE) {
            if(int_ack_disable && except_disable){
                if(ls_mode_string == "M_MODE"){ls_mode == M_MODE;}
                else if(ls_mode_string == "S_MODE"){ls_mode == S_MODE;}
                else if(ls_mode_string == "U_MODE"){ls_mode == U_MODE;}
                else {ls_mode inside{M_MODE,S_MODE,U_MODE};}
            }
            else if(ls_mode_string == "M_MODE"){ls_mode == M_MODE;}
            else if(ls_mode_string == "U_MODE"){ls_mode == U_MODE;}
            else {ls_mode inside{M_MODE,U_MODE};}
        }
        (program_mode == S_MODE) -> ls_mode == S_MODE;
        (program_mode == U_MODE) -> ls_mode == U_MODE;
    }
 constraint fs_c{
        fs dist{
            3:=100 ,
            0:=10
        };
    }

    constraint mie_c{
        if(int_ack_disable){mie ==0; sie==0;}
        else{
            mie dist{
                1:= 100,
                0:= 10
            };
        }
        msie dist{
            1:= 100,
            0:= 10
        };
    }
    constraint frm_c{
        frm dist{
            [3'd0:3'd4] := 100,
            [3'd5:3'd7] := 10
        };
    }
    //TODO: sub field can be divide
constraint mprv_mpp_c{
        if(program_mode == M_MODE && ls_mode == S_MODE)         {mprv ==1 && mpp == 2'b01;}  //no except & no_ack int
        else if(program_mode == M_MODE && ls_mode == U_MODE){
            if(except_disable && int_ack_disable){
                mprv ==1 && mpp == 2'b00 ;
            }
            else{
                mprv == 1 && mpp == 2'b11;
            }
        }//if mprv=1.mpp=M/S/U,after mret, program mode =M, ls_mode = U 
        else if(program_mode == M_MODE && ls_mode == M_MODE){
            if(except_disable && int_ack_disable){
            {mprv ==0 || mprv == 1 && mpp == 2'b11;}
            }
            else{
            {mprv ==0 ;}//|| mprv == 1 && mpp == 2'b11;}
            }
        }
        else if(program_mode == S_MODE) mpp == 2'b01;
        else if(program_mode == U_MODE) mpp == 2'b00;
    }
    constraint map_mode_c{
        map_mode inside {4'd0, 4'd8};// bare. sv39
    }
 constraint mret_config_c{
        if(program_mode !=M_MODE){
            mret_config == 1;
        }
        else if(ls_mode == U_MODE){
            if(mpp == 2'b00) mret_config == 0;
            else {mret_config == 1;}
        }
        else if(mprv == 0 && mpp == 2'b11){
            mret_config inside{0,1};
        }
        else{mret_config == 0;}
    }

    function void post_randomize();
        string map_mode_string;
        if($value$plusargs("map_mode=%s",map_mode_string))begin
            case(map_mode_string)
                "BARE"  : map_mode = 4'd0;
                "SV39"  : map_mode = 4'd8;
            endcase
        end

        if($value$plusargs("fs=%d",fs))begin
        end
        csr_s.fs = fs;
        csr_s.mie = mie;
        csr_s.msie = msie;
        $display("csr_s:%p",csr_s);
        //except for cfg bits,other bits WARL, write all 1s
        csr_cfg_val.push_back(                      (map_mode << 60));
        csr_cfg_val.push_back(64'hffffffffffb00000 | (mstatus_tsr << 22) |(fs << 13) | (vs << 9) | (mprv << 17) | (mie << 3) | (mstatus_sum << 18)|(mpp << 11)); //mstatus_val
        csr_cfg_val.push_back(mideleg);
        csr_cfg_val.push_back(medeleg);
        csr_cfg_val.push_back(64'hfffffffffffffff7 | (msie << 3)); //mie_val
        if(fs == 3)
        csr_cfg_val.push_back(64'hffffffffffffff1f | (frm << 5)); //frm


        foreach(csr_cfg_addr[i])begin
        $fwrite(cfg_file,"addr:%0h\n",csr_cfg_addr[i]);
        $fwrite(cfg_file,"val:%0h\n",csr_cfg_val[i]);
        end

    endfunction

endclass
