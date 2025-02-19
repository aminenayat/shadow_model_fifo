module read_pointer #(ADDR_WIDTH = 10)
(
  input wire clk,
  input wire rstn,
  input wire read_en,
  input wire empty,
  output reg [ADDR_WIDTH:0] read_addr
);

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        read_addr <= 0;
    end else if (read_en && !empty) begin
        read_addr <= read_addr + 1;
    end
end

endmodule