`timescale 1ns / 1ps

module control_unit(    );

    // The control unit coordinates the two decoders:
    //   1. main_decoder  → generates broad control signals
    //   2. alu_decoder   → refines ALU operation (from funct fields)
    //
    // Together, they determine how the datapath behaves for each instruction.
endmodule
