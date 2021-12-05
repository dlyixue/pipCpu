`timescale 1ns / 1ps

module dm(input reset,input clock,input [31:0]programCounter,input [31:0]address,input writeEnabled,input [31:0]writeInput,output logic [31:0]readResult);
    logic [31:0]data[2047:0];
    integer i ;
    always @(posedge clock)
    begin
        //≥ı ºªØ
        if(reset) begin
            for(i=0;i<2047;i=i+1) begin
                data[i]<=32'h00000000;
            end
        end
        else begin 
            if(writeEnabled==1)
            begin ;
            data[address[12:2]]<=writeInput;
            $display("@%h: *%h <= %h", programCounter, address, writeInput);
            end
        end
    end 
    assign readResult =data [address[12:2]];
endmodule
