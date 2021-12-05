`timescale 1ns / 1ps

module imem(input [31:0]address,input [31:0]memory[1023:0],output logic [31:0] instruction);
    assign instruction = memory [address[11:2]];
endmodule
