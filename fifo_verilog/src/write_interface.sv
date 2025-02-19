module write_interface #(parameter DATA_WIDTH = 8, parameter ADDR_WIDTH = 10   )
(
    input wire clk,
    input wire rstn,
    input wire write_en,
    input wire [DATA_WIDTH-1:0] write_data,
    input wire full,
    output wire [ADDR_WIDTH:0] write_addr,
    output wire mem_write_en
);
     
    write_pointer #(.ADDR_WIDTH(ADDR_WIDTH)) uut_ww 
    (
        .clk(clk),
        .rstn(rstn),
        .write_en(write_en && !full),
        .full(full),
        .write_addr(write_addr)
    );

    
    assign mem_write_en = write_en && !full;

endmodule

