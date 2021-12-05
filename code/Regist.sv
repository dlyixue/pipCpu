`timescale 1ns / 1ps

module Regist(input reset,input clock,input [31:0]programCounter,input [25:21]address1,input [20:16]address2,logic [4:0]registerId,input writeEnabled,input [31:0]writeInput,
output logic [31:0]readResult1,output logic [31:0]readResult2);
    logic [31:0]data[31:0];
    integer i ;
    always @(negedge clock)
    begin
        //≥ı ºªØ
        if(reset) begin
            for(i=0;i<32;i=i+1) begin
                data[i]<=32'h00000000;
            end
        end
        else begin 
            if(writeEnabled==1) 
            begin
                data[registerId]=writeInput;
                $display("@%h: $%d <= %h", programCounter,registerId,writeInput);
                data[0]=0;
            end
        end
    end 
    assign readResult1  =data [address1];
    assign readResult2  =data [address2];
endmodule
