`timescale 1ns / 1ps

module pc(input reset,input clock,input PCWrite,input [31:0]Value,output logic[31:0]pcValue);
    always @(posedge clock)
    begin
        if(reset) pcValue <=32'h00003000;
        else
        begin 
            if(PCWrite!=0) pcValue<=Value;
        end
    end 
endmodule
