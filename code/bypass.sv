`timescale 1ns / 1ps
module bypass(input ID_branch,input [4:0]ID_rs,input [4:0]ID_rt,input PipReg ID_EX,input PipReg EX_MEM,input PipReg MEM_WB,
output logic [1:0]forwardA,output logic [1:0]forwardB,output logic [1:0]ID_forwardA,output logic [1:0]ID_forwardB);
    always@(*)
    begin
    //到R指令的旁路
    if(EX_MEM.sig.RegWrite && ((EX_MEM.rd!=0 && EX_MEM.rd == ID_EX.rs)||((EX_MEM.sig.func ==1)&&(ID_EX.rs==31)))) forwardA=2'b10;
    else if(MEM_WB.sig.RegWrite && MEM_WB.rd !=0 && MEM_WB.rd == ID_EX.rs) forwardA=2'b01;
    else forwardA=2'b00;
    if(EX_MEM.sig.RegWrite && ((EX_MEM.rd!=0 && EX_MEM.rd == ID_EX.rt)||((EX_MEM.sig.func ==1)&&(ID_EX.rt==31)))) forwardB=2'b10;
    else if(MEM_WB.sig.RegWrite && MEM_WB.rd !=0 && MEM_WB.rd == ID_EX.rt) forwardB=2'b01;
    else forwardB=2'b00;
    //从R到LW的指令
    
    //到beq的ID旁路
    if(ID_branch)
    begin
        if(EX_MEM.sig.RegWrite && ((EX_MEM.rd!=0 && EX_MEM.rd == ID_rs)||((EX_MEM.sig.func ==1)&&(ID_rs==31)))) ID_forwardA=2'b10;
        else if(MEM_WB.sig.RegWrite && MEM_WB.rd !=0 && MEM_WB.rd == ID_rs) ID_forwardA=2'b01;
        else ID_forwardA=2'b00;
        if(EX_MEM.sig.RegWrite && ((EX_MEM.rd!=0 && EX_MEM.rd == ID_rt)||((EX_MEM.sig.func ==1)&&(ID_rt==31)))) ID_forwardB=2'b10;
        else if(MEM_WB.sig.RegWrite && MEM_WB.rd !=0 && MEM_WB.rd == ID_rt) ID_forwardB=2'b01;
        else ID_forwardB=2'b00;
    end
    end 
endmodule
