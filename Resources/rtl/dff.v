`timescale 1ns / 1ps



module dff #(parameter WIDTH = 16) (
    input       clk, rst,
    input       [WIDTH-1:0] d,
    output reg  [WIDTH-1:0] q
);
// This module acts as a register - it captures the input 'd'
// on each rising edge of 'clk' and outputs it as 'q'.

endmodule
