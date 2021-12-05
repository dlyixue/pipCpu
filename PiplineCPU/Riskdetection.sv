`timescale 1ns / 1ps
//`include "Toplevel.sv"
typedef struct  {
    logic [31:0]pcValue;
    logic [31:0]inst;
    logic [31:0]Reg1;
    logic [31:0]Reg2;
    logic [31:0]ALUtmp;
    logic [31:0]ALUout;
    logic [31:0]MEMdata;
    logic [31:0]branchInput;
    logic [31:0]Value;
    logic [25:0]jumpInput;
    logic [4:0]WRaddress;
    logic [4:0]rs;
    logic [4:0]rt;
    logic [4:0]rd;
    logic [3:0]CL;
    logic zero;
    signal sig;
    } PipReg;
module Riskdetection(input ID_branch,input [4:0]ID_rs,input [4:0]ID_rt,input PipReg ID_EX,input PipReg EX_MEM,output logic Risk);
    always@(*)
    begin
    Risk=0;
        //内存读指令，出现矛盾
        if(ID_EX.sig.MemRead==1 && ((ID_EX.rt == ID_rs) || (ID_EX.rt == ID_rt))) Risk=1;
        //beq：add+beq
        else if(ID_branch==1 && ID_EX.sig.RegWrite && ID_EX.rd!=0 && ((ID_EX.rd == ID_rs) || (ID_EX.rd == ID_rt))) Risk=1;
        //lw+beq
        else if(ID_branch==1 && EX_MEM.sig.MemRead && EX_MEM.rd!=0 && ((EX_MEM.rt == ID_rs) || (EX_MEM.rt == ID_rt))) Risk=1;
    end    
endmodule
