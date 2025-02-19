module write_interface #(parameter DATA_WIDTH = 8, parameter ADDR_WIDTH = 5   )
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



/*



module write_interface #(parameter ADDR_WIDTH = 5 , parameter DATA_WIDTH=8)
(
    input wire clk,
    input wire rstn,
    input wire [DATA_WIDTH-1:0] write_data,
    input wire full,
    input wire write_en;
    output wire [ADDR_WIDTH : 0] write_addr,
    output wire mem_write_en
);

reg [ADDR_WIDTH : 0] write_pointer;

always @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        write_pointer <= 0;
    end else begin
        if (write_en && !full) begin
            write_addr <= write_addr +1;
        end 
    end
end

assign write_addr = write_pointer;
assign mem_write_en = (write_en && !full);

endmodule


*/
