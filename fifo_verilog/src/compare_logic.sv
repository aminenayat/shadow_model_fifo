module compare_logic #(ADDR_WIDTH = 10)
(
    input wire [ADDR_WIDTH : 0] write_addr,
    input wire [ADDR_WIDTH : 0] read_addr,
    input wire write_ena, 
    output wire full,
    output wire empty
    
);

// assign empty = (write_addr == read_addr);
assign empty = (write_addr == read_addr) && (write_ena== 0);

assign full = (write_addr[ADDR_WIDTH] != read_addr[ADDR_WIDTH]) && (write_addr[ADDR_WIDTH -1 :0] == read_addr[ADDR_WIDTH -1:0]);

endmodule
