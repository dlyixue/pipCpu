`timescale 1ns / 1ps
typedef struct  {
        logic jump;
        logic Branch;
        logic RegDst;
        logic RegWrite;
        logic ALUSrc;
        logic [2:0]ALUOp;
        logic MemRead;
        logic MemWrite;
        logic MemtoReg;
        logic jr;
        logic func;
        logic finish;
    } signal;
module CLU(input [31:26]Op,input [5:0]Funct,output signal sig);
    always @(*)
    begin
    sig.RegDst <=0;
    sig.ALUSrc <=0;
    sig.ALUOp <=3'b000;
    sig.MemtoReg <=0;
    sig.RegWrite<=0;
    sig.MemRead <=0;
    sig.MemWrite <=0;
    sig.Branch <=0;
    sig.jump <=0;
    sig.jr <=0;
    sig.func <=0;
    sig.finish<=0;
    case(Op)
        //R
        6'b000000:
        begin 
            if(Funct==6'b001000) 
            begin
                sig.jr<=1;//¼Ä´æÆ÷Ìø×ª
            end
            else if(Funct==6'b001100)
            begin
                sig.finish<=1;
                //$finish;//systemcall
            end
            else
            begin
            sig.RegDst <= 1;
            sig.RegWrite <=1;
            sig.ALUOp <=3'b010;
            end
        end
        //addi
        6'b001000:
        begin
            sig.ALUSrc <=1;
            sig.RegWrite <=1;
            sig.ALUOp <=3'b000;//+
        end
        //ori
        6'b001101:
        begin
            sig.ALUSrc <=1;
            sig.RegWrite <=1;
            sig.ALUOp <=3'b100;
        end
        //lui 
        6'b001111:
        begin
            sig.ALUSrc <=1;
            sig.RegWrite <=1;
            sig.ALUOp <=3'b101;
        end
        //lw
        6'b100011:
        begin
            sig.ALUSrc <=1;
            sig.MemtoReg <=1;
            sig.RegWrite <=1;
            sig.MemRead <=1;
        end
        //sw
        6'b101011:
        begin
            sig.ALUSrc <=1;
            sig.MemWrite <=1;
        end
        //beq
        6'b000100:
        begin
            sig.Branch <=1;
            //sig.ALUOp <=3'b001;
        end
        //jal
        6'b000011:
        begin
            sig.jump <=1;
            sig.func <=1;
            sig.RegWrite<=1;
        end
        //j
        6'b000010: sig.jump <=1;
    endcase 
    end    
endmodule
