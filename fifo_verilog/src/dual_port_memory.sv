module dual_port_memory #(
    parameter DATA_WIDTH = 8, 
    parameter ADDR_WIDTH = 5 
)(
    input wire clk,
    input wire rstn,                         
    input wire write_en,                
    input wire read_en,                  
    input wire [ADDR_WIDTH-1:0] write_addr,  
    input wire [ADDR_WIDTH-1:0] read_addr,   
    input wire [DATA_WIDTH-1:0] write_data,  
    output reg [DATA_WIDTH-1:0] read_data    
);

// TODO: Fix array dimension index
    reg [DATA_WIDTH-1:0] memory_array [2**ADDR_WIDTH-1:0];

    // مقداردهی اولیه آرایه حافظه
    integer i;
    initial begin
        for (i = 0; i < 2**ADDR_WIDTH; i = i + 1)
            memory_array[i] = 0;
    end

always @(posedge clk or negedge rstn) begin
    if (write_en) begin
        memory_array[write_addr] <= write_data;
    end 
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        read_data <= 0;
    end else begin
        read_data <= memory_array[read_addr];
    end
end

endmodule
