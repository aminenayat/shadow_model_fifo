module write_pointer #(ADDR_WIDTH = 10)
(
    input wire clk,
    input wire rstn,
    input wire full,
    input wire write_en,
    output reg [ADDR_WIDTH:0] write_addr
);

always @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        write_addr <= 0;
    end else if (write_en && !full) begin
        write_addr <= write_addr + 1;
    end
end

endmodule