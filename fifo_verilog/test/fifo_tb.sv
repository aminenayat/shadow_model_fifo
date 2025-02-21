`timescale 1ns/1ps
module fifo_tb;
    // پارامترها
    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 10;         
    parameter NUM_VALUES = 2048;       

    // سیگنال‌های تست‌بنچ
    reg clk, rstn;
    reg write_enable, read_enable;
    reg [DATA_WIDTH-1:0] write_data;
    wire [DATA_WIDTH-1:0] read_data;
    wire full, empty;
    
    // آرایه برای نگهداری داده‌های تصادفی تولیدشده (برای مقایسه)
    reg [DATA_WIDTH-1:0] expected_data [0:NUM_VALUES-1];
    
    integer i;
    integer outfile;

   
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

   
    always #5 clk = ~clk;
    

    task test_write_only;
        integer accepted_count;
        integer write_index;
        integer read_index;
    begin
        $display("========== Test Write Only ==========");
       
        for(write_index = 0; write_index < NUM_VALUES; write_index = write_index + 1) begin
            expected_data[write_index] = $urandom_range(0, (1<<DATA_WIDTH)-1);
        end
        
        accepted_count = 0;
       
        for(write_index = 0; write_index < NUM_VALUES; write_index = write_index + 1) begin
            @(posedge clk);
            if(!full) begin
                write_enable = 1;
                write_data = expected_data[write_index];
                $display("[WRITE ONLY] Attempt %0d: Writing data %h, full = %b", write_index, write_data, full);
                accepted_count = accepted_count + 1;
            end else begin
                write_enable = 0;
                $display("[WRITE ONLY] Attempt %0d: FIFO FULL, cannot write data %h", write_index, expected_data[write_index]);
            end
        end
        write_enable = 0;
        $display("[WRITE ONLY] Total accepted writes: %0d (Expected Capacity: %0d)", accepted_count, (1 << ADDR_WIDTH));
        
        // اجازه می‌دهیم تا داده‌ها از FIFO به خروجی برسند؛
        // با توجه به تاخیر دو چرخه‌ای، دو چرخه انتظار می‌کنیم.
        repeat(2) @(posedge clk);
        
       
        read_index = 0;
        while(!empty) begin
            @(posedge clk);
            read_enable = 1;
            @(posedge clk);  
            
            if(read_index >= 2) begin
                $display("FIFO index %0d: write_data = %h | read_data = %h", read_index-2, expected_data[read_index-2], read_data);
                if(read_data === expected_data[read_index-2])
                    $display("Match: write_data = read_data");
                else
                    $display("ERROR [WRITE ONLY]: Data mismatch at FIFO index %0d", read_index-2);
            end else begin
             
                $display("FIFO index %0d: (Delay period) read_data = %h", read_index, read_data);
            end
            read_index = read_index + 1;
            read_enable = 0;
        end
        read_enable = 0;
        $display("[WRITE ONLY] Total data read from FIFO: %0d", read_index);
    end
    endtask

    // -------------------------------------------------
    // Task: Test Read Only
    // - بررسی می‌کند که در حالت اولیه (بدون نوشتن) FIFO خالی است.
    // -------------------------------------------------
    
    task test_read_only;
    begin
        $display("========== Test Read Only ==========");
           rstn = 0;
    #100;
    rstn = 1;
    #10; // 

        write_enable = 0;
        @(posedge clk);
        if(!empty )
            $display("ERROR [READ ONLY]: FIFO not empty when no writes.");
        else
            $display("[READ ONLY] FIFO is empty as expected.");
    
    end
    endtask


    // -------------------------------------------------
    // بلوک initial اصلی تست‌بنچ
    // -------------------------------------------------
    initial begin
        outfile = $fopen("fifo_test_log.txt", "w");
       
        clk = 0;
        rstn = 0;
        write_enable = 0;
        read_enable = 0;
        write_data = 0;
        
      
        #100;
        rstn = 1;
  

      
        test_read_only();
        test_write_only();
        
        $display("All tests completed.");
        $fclose(outfile);
        $finish;
    end

endmodule
