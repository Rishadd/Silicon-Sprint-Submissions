`timescale 1ns / 1ps


module alu #(parameter WIDTH = 16) (
    input       [WIDTH-1:0] a, b,     // operands
    input       [3:0] alu_ctrl,         // ALU control
    output reg  [WIDTH-1:0] alu_out,    // ALU output
    output      zero                    // zero flag
);

// Use a combinational always block to select the
// correct operation based on alu_ctrl.

endmodule

