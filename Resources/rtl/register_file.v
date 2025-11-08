`timescale 1ns / 1ps

module register_file(
    input       clk,
    input       wr_en,
    input       [2:0] rd_addr1, rd_addr2, wr_addr,
    input       [15:0] wr_data,
    output      [15:0] rd_data1, rd_data2
    );
    
reg [15:0] registers [8:0];

integer i;
initial begin
    for (i = 0; i < 8; i = i + 1) begin
        registers[i] = 0;
    end
end

// register file write logic (synchronous)
always @(posedge clk) begin
    if (wr_en) registers[wr_addr] <= wr_data;
end

// register file read logic (combinational)
assign rd_data1 = registers[rd_addr1];
assign rd_data2 = registers[rd_addr2];

endmodule