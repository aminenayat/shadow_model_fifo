module read_interface #(
    parameter DATA_WIDTH = 8
)(
    input wire clk,
    input wire rstn,
    input wire read_en,  
    input wire empty, 
    output wire read_trigger 
);

   
    assign read_trigger = read_en && !empty;

endmodule
