`timescale 1ns / 1ps

module data_mem #(parameter DATA_WIDTH = 16, ADDR_WIDTH = 16, MEM_SIZE = 256) (
    input clk,
    input wr_en,
    input [ADDR_WIDTH-1:0] wr_addr,
    input [DATA_WIDTH-1:0] wr_data,
    output [DATA_WIDTH-1:0] rd_data_mem
);

    
    reg [DATA_WIDTH-1:0] data_ram [0:MEM_SIZE-1];
    
    
    wire [ADDR_WIDTH-2:0] word_addr = wr_addr[ADDR_WIDTH-1:0];
    
    
    integer i;
initial begin
    for (i = 0; i < MEM_SIZE; i = i + 1)
        data_ram[i] = 16'b0;   

end
    // Combinational read logic
    assign rd_data_mem = data_ram[word_addr];

    // Synchronous write logic
    always @(posedge clk) begin
        if (wr_en) begin
            data_ram[word_addr] <= wr_data;
        end
    end
endmodule