module dual_port_memory #(
    parameter DATA_WIDTH = 8, 
    parameter ADDR_WIDTH = 10 
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


reg [DATA_WIDTH-1:0] memory_array [0:(1<<ADDR_WIDTH)-1];

reg [DATA_WIDTH-1 : 0] write_data_reg ;

// مقداردهی اولیه در چند سیکل برای سنتز
integer i;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
for(i=0;i<(1<<ADDR_WIDTH);i=i+1) begin
    memory_array[i] = 0;
    end
    read_data<=0;
   
    write_data_reg <=0;
end
end


always @(posedge clk) begin
    if (write_en) begin
        write_data_reg <= write_data;
        memory_array[write_addr] <= write_data_reg;
    end 
end

// عملیات خواندن در حافظه (با یک سیکل تأخیر)
always @(posedge clk) begin
    if (read_en) begin

        read_data <= memory_array[read_addr];
       
    end 
end

endmodule
