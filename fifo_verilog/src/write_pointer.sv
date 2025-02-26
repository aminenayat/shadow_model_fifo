module write_pointer #(
    parameter ADDR_WIDTH = 10
)(
    input wire clk,
    input wire rstn,
    input wire write_trigger,  
    output reg [ADDR_WIDTH:0] write_addr  
);

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        write_addr <= 0;  
    end else if (write_trigger) begin
        write_addr <= write_addr + 1;  
    end
end

endmodule
