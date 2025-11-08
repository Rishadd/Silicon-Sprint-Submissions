`timescale 1ns / 1ps

module immgen (
    input  [3:0]  inp,
    output [15:0] out
);
// The immgen module extends small immediates
// from the instruction into a 16-bit value that the ALU can use.
endmodule
