`timescale 1ns / 1ps




module instr_mem (
    input       [15:0] instr_addr,
    output      [15:0] instr
);


reg [15:0] instr_ram [0:511];

initial begin
    $readmemh("rv16i_test.txt", instr_ram); 
end

// combinational read logic
assign instr = instr_ram[instr_addr];

endmodule