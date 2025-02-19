module read_interface #(
    parameter DATA_WIDTH = 8, 
    parameter ADDR_WIDTH = 5  
)(
    input wire clk,          
    input wire rstn,          
    input wire read_en,       
    input wire empty,          
    output wire [ADDR_WIDTH:0] read_addr, 
    output wire mem_read_en   
);

    read_pointer #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) uut_rp (
        .clk(clk),
        .rstn(rstn),
        .read_en(read_en && !empty), // کنترل خواندن
        .empty(empty),
        .read_addr(read_addr)
    );


    assign mem_read_en = read_en && !empty;

endmodule
