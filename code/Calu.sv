`timescale 1ns / 1ps

module Calu(input [2:0]ALUOp,input [5:0]Funct,output logic [3:0] CL);
    logic [3:0]ans;
    always @(*)
    begin
        case (ALUOp )
        3'b000: ans =4'b0010;
        3'b001: ans =4'b0110;
        3'b010:
        begin
            case(Funct)
            6'b100001: ans =4'b0010;//+
            6'b100011: ans =4'b0110;//-
            6'b100100: ans =4'b0000;//&
            6'b100101: ans =4'b0001;//|
            endcase 
        end
        3'b100: ans=4'b0001;
        3'b101: ans=4'b1000;
        default : ans=4'b1111;
        endcase 
    end
    assign CL=ans;
endmodule
