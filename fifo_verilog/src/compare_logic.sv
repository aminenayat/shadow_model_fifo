module compare_logic #(ADDR_WIDTH = 5)
(
    input wire [ADDR_WIDTH : 0] write_addr,
    input wire [ADDR_WIDTH : 0] read_addr,
    output wire full,
    output wire empty
    
);

assign empty = (write_addr == read_addr);

assign full = (write_addr[ADDR_WIDTH] != read_addr[ADDR_WIDTH]) && (write_addr[ADDR_WIDTH -1 :0] == read_addr[ADDR_WIDTH -1:0]);

endmodule
