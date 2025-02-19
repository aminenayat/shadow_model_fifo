module fifo_memory #(
    parameter DATA_WIDTH = 8, 
    parameter ADDR_WIDTH = 5  
)(
    input wire clk,            
    input wire rstn,           
    input wire write_enable,   
    input wire read_enable,   
    input wire [DATA_WIDTH-1:0] write_data, 
    output wire [DATA_WIDTH-1:0] read_data, 
    output wire full,         
    output wire empty          
);

    // سیگنال‌های داخلی
    wire [ADDR_WIDTH:0] write_addr; // آدرس نوشتن
    wire [ADDR_WIDTH:0] read_addr;  // آدرس خواندن
    wire mem_write_en;             // سیگنال نوشتن حافظه
    wire mem_read_en;              // سیگنال خواندن حافظه


    write_interface #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) write_if (
        .clk(clk),
        .rstn(rstn),
        .write_en(write_enable),
        .write_data(write_data),
        .full(full),
        .write_addr(write_addr),
        .mem_write_en(mem_write_en)
    );

  
    read_interface #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) read_if (
        .clk(clk),
        .rstn(rstn),
        .read_en(read_enable),
        .empty(empty),
        .read_addr(read_addr),
        .mem_read_en(mem_read_en)
    );

   
    dual_port_memory #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) memory (
        .clk(clk),
        .rstn(rstn),
        .write_en(mem_write_en),
        .read_en(mem_read_en),
        .write_addr(write_addr[ADDR_WIDTH-1:0]), // تبدیل آدرس به اندیس مناسب
        .read_addr(read_addr[ADDR_WIDTH-1:0]),  // تبدیل آدرس به اندیس مناسب
        .write_data(write_data),
        .read_data(read_data)
    );


    compare_logic #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) cmp_logic (
        .write_addr(write_addr),
        .read_addr(read_addr),
        .full(full),
        .empty(empty)
    );

endmodule
