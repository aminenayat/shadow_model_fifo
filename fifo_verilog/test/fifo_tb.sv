// fifo_tb.v
`timescale 1ns/1ps
module fifo_tb;
    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 5;
    parameter NUM_VALUES = 32; 
    
    reg clk, rstn;
    reg write_enable, read_enable;
    reg [DATA_WIDTH-1:0] write_data;
    wire [DATA_WIDTH-1:0] read_data;
    wire full, empty;
    
    
    fifo_memory #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) uut (
        .clk(clk),
        .rstn(rstn),
        .write_enable(write_enable),
        .read_enable(read_enable),
        .write_data(write_data),
        .read_data(read_data),
        .full(full),
        .empty(empty)
    );
    
   
    reg [DATA_WIDTH-1:0] input_data [0:NUM_VALUES-1];
    integer i;
    

    integer outfile;
    
   
    always #5 clk = ~clk;
    
    initial begin
        clk = 0;
        rstn = 0;
        write_enable = 0;
        read_enable = 0;
        write_data = 0;
        
       
        outfile = $fopen("verilog_fifo_memory.txt", "w");
        
        
        $readmemh("input_hex.txt", input_data);
        
        #10;
        rstn = 1;
        
        // write
        i = 0;
        while(i < NUM_VALUES) begin
            @(posedge clk);
            if (!full) begin
                write_enable = 1;
                write_data = input_data[i];
                i = i + 1;
            end else begin
                write_enable = 0;
            end
        end
        write_enable = 0;
        
        // کمی تأخیر قبل از خواندن
        #20;
        
    
    i = 0;
    while(i < NUM_VALUES) begin
        @(posedge clk);
        if (!empty) begin
            read_enable = 1;  
        end else begin
            read_enable = 0;
        end

        @(posedge clk);
     
        if (read_enable) begin
            $fwrite(outfile, "%02x\n", read_data);
            i = i + 1;
        end
        
        read_enable = 0;
    end

        
        #50;
        $fclose(outfile);
        $finish;
    end
endmodule
