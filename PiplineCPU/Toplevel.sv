`timescale 1ns / 1ps
module Toplevel(input reset,input clock);
    logic [31:0]pcValue,Value,pcInput;
    logic [31:0]branchInput;
    logic [31:0]PCmemory[1023:0];
    
    logic [31:0]inst;
    logic [31:0]WRreg;
    logic [31:0]Reg1,Reg2,beq1,beq2;
    logic [31:0]ALUin1,ALUin2,ALUtmp,ALUout;
    logic [31:0]MEMdata;
    logic [25:0]jumpInput;
    logic [4:0]WRaddress;
    logic [3:0]CL;
    logic [1:0]forwardA,forwardB,ID_forwardA,ID_forwardB;
    logic zero;
    logic PCWrite,IF_ID_Write,Risk;
    PipReg IF_ID,ID_EX,EX_MEM,MEM_WB;
    signal sig;
    initial
        begin
        $readmemh("D:\\ViProject\\Pipeline\\code\\Le0.asm.txt",PCmemory);
        //$readmemh("D:\\ViProject\\Pipeline\\test.txt",PCmemory);
        end
    //IF
    pc PCunit(reset,clock,PCWrite,pcInput,pcValue);
    imem IMunit(pcValue ,PCmemory ,inst);
    //ID
    CLU CLUunit(IF_ID.inst[31:26],IF_ID.inst[5:0],sig);
    Regist RGunit(reset,clock,MEM_WB.pcValue,IF_ID.inst[25:21],IF_ID.inst [20:16],MEM_WB.rd,MEM_WB.sig.RegWrite ,WRreg ,Reg1 ,Reg2 );
    Riskdetection RDunit(sig.Branch||sig.jr,IF_ID.inst[25:21],IF_ID.inst[20:16],ID_EX,EX_MEM,Risk);
    Calu CAunit(sig.ALUOp,IF_ID.inst[5:0],CL);
    
    bypass BPunit(sig.Branch||sig.jr,IF_ID.inst[25:21],IF_ID.inst[20:16],ID_EX,EX_MEM,MEM_WB,forwardA,forwardB,ID_forwardA,ID_forwardB);
    //EX
    alu ALunit(ALUin1,ALUin2,ALUout ,ID_EX.CL, zero);
    //MEM
    dm DMunit(reset,clock,EX_MEM.pcValue,EX_MEM.ALUout ,EX_MEM.sig.MemWrite ,EX_MEM.ALUtmp ,MEMdata );
    assign Value=pcValue+4;
    always @(*)
    begin
        //if(pcValue==32'h000031d4) $stop;
        if(Risk)
        begin
            PCWrite=0;
            IF_ID_Write=0;
        end
        else begin
            PCWrite=1;
            IF_ID_Write=1;
        end
        pcInput=Value;
        //WRreg
        if(MEM_WB.sig.MemtoReg) WRreg=MEM_WB.MEMdata;
        else WRreg=MEM_WB.ALUout;
        //pc均可以在ID周期内完成，然后再下一个周期跳转
        if (sig.jump) pcInput[27:0] = IF_ID.jumpInput<<2;
        if (sig.Branch || sig.jr)
        begin
        beq1=0;
        beq2=0;
            case(ID_forwardA)
            2'b00:beq1=Reg1;
            2'b01:beq1=WRreg;
            2'b10:beq1=EX_MEM.ALUout;
            endcase
            case(ID_forwardB)
            2'b00:beq2=Reg2;
            2'b01:beq2=WRreg;
            2'b10:beq2=EX_MEM.ALUout;
            endcase
            if(sig.Branch && ((beq1^beq2)==0)) pcInput = IF_ID.Value + (IF_ID.branchInput<<2);
            if(sig.jr) pcInput=beq1;
        end
        //WRaddress
        if(sig.RegDst ==1) WRaddress=IF_ID.inst[15:11];
        else if(sig.func ==1) WRaddress=31;
        else WRaddress=IF_ID.inst[20:16];
        //ALUin1
        case(forwardA)
        2'b00:ALUin1=ID_EX.Reg1;
        2'b01:ALUin1=WRreg;
        2'b10:ALUin1=EX_MEM.ALUout;
        endcase
        //ALUin2
        case(forwardB)
        2'b00:ALUtmp=ID_EX.Reg2;
        2'b01:ALUtmp=WRreg;
        2'b10:ALUtmp=EX_MEM.ALUout;
        endcase
        if(ID_EX.sig.ALUSrc) begin
            if(ID_EX.CL==4'b0001) ALUin2=({{16{0}}, ID_EX.inst[15:0]});
            else ALUin2=ID_EX.branchInput;
        end 
        else ALUin2=ALUtmp;
        if(MEM_WB.sig.finish) begin 
            $display("over,by dlyixue ");
            $finish;
        end
    end
    
    always @(posedge clock)
    begin
        if(IF_ID_Write)
        begin
            IF_ID.pcValue<=pcValue;
            IF_ID.inst<=inst;
            IF_ID.rs<=inst[25:21];
            IF_ID.rt<=inst[20:16];
            IF_ID.branchInput<=({{16{inst[15]}}, inst[15:0]});
            IF_ID.jumpInput=inst[25:0];
            IF_ID.Value=Value;
        end
        if(Risk)
        begin
            ID_EX.pcValue<=32'b00000000;
            ID_EX.sig.RegDst <=0;
            ID_EX.sig.ALUSrc <=0;
            ID_EX.sig.ALUOp <=3'b000;
            ID_EX.sig.MemtoReg <=0;
            ID_EX.sig.RegWrite<=0;
            ID_EX.sig.MemRead <=0;
            ID_EX.sig.MemWrite <=0;
            ID_EX.sig.Branch <=0;
            ID_EX.sig.jump <=0;
            ID_EX.sig.jr <=0;
            ID_EX.sig.func <=0;
        end
        else 
        begin
            ID_EX<=IF_ID;
            ID_EX.rd<=WRaddress;
            ID_EX.Reg1<=Reg1;
            ID_EX.Reg2<=Reg2;
            ID_EX.CL<=CL;
            ID_EX.sig<=sig;
        end
        EX_MEM<=ID_EX;
        EX_MEM.ALUtmp<=ALUtmp;
        if(ID_EX.sig.func) EX_MEM.ALUout<=ID_EX.pcValue+4+4;//分支延迟
        else EX_MEM.ALUout<=ALUout;
        
        MEM_WB<=EX_MEM;
        MEM_WB.MEMdata<=MEMdata;
    end
endmodule
