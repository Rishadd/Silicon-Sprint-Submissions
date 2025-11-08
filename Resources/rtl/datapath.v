`timescale 1ns / 1ps

module datapath();
    // Break down the datapath into modular building blocks.
    // Each block handles one function:
    //   - Program Counter (PC): holds current instruction address
    //   - Register File: holds all general-purpose registers
    //   - ALU + ImmGen: perform arithmetic and logic
    //   - Data Memory: load/store access
    //   - MUXes: select between alternate data/control paths
endmodule
