`timescale 1ns / 1ps

module alu(A,B,C,Op,Zero);
    input [31:0]A,B;
    input [3:0]Op;
    output logic [31:0]C;
    output logic Zero;
    
    always @(*)
    begin
    case(Op)
         4'b0010://+
         begin
             C=A+B;
         end 
         4'b0110://-
         begin
             C=A-B;
         end
         4'b0001:
         begin 
            C=A|B;
         end 
         4'b1000: C=B<<16;
         default: C=0;
    endcase
    end
    assign Zero = (C)?0:1;
endmodule
