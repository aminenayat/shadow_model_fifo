module write_interface #(
    parameter DATA_WIDTH = 8
)(
    input wire clk,
    input wire rstn,
    input wire write_en, 
    input wire full, 
    output wire write_trigger 
);

    
    assign write_trigger = write_en && !full;

endmodule
