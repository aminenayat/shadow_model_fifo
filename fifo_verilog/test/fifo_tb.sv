`timescale 1ns/1ps
module fifo_tb;
    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 10;
    parameter NUM_VALUES = 1024; 
    
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
    
    //  تولید داده‌های تصادفی و تست خواندن/نوشتن
    initial begin
        // مقداردهی اولیه سیگنال‌ها
        clk = 0;
        rstn = 0;
        write_enable = 0;
        read_enable = 0;
        write_data = 0;

        // باز کردن فایل برای ذخیره داده‌های خوانده‌شده
        outfile = $fopen("verilog_fifo_memory.txt", "w");

        // ✅ تولید داده‌های تصادفی در بازه‌ی [-2^(DATA_WIDTH-1), 2^(DATA_WIDTH-1) - 1]
        for (i = 0; i < NUM_VALUES; i = i + 1) begin
            input_data[i] = $urandom_range(-(1 << (DATA_WIDTH-1)), (1 << (DATA_WIDTH-1)) - 1);
        end
        
        //  راه‌اندازی مدار
        #10;
        rstn = 1;

        //  عملیات نوشتن و خواندن به صورت همزمان
        for (i = 0; i < NUM_VALUES; i = i + 1) begin
            // نوشتن در FIFO
            @(posedge clk);
            while (full) 
            @(posedge clk); // منتظر بماند تا FIFO پر نباشد
            write_enable = 1;
            write_data = input_data[i];
            $display("write_en: %d, write_data: %h", write_enable, write_data);
            @(posedge clk);
            write_enable = 0;
            
            //  اضافه کردن یک کلاک تأخیر برای بروزرسانی سیگنال `read_data`
            @(posedge clk);
            
            //  عملیات خواندن
            while (empty)
            @(posedge clk); // منتظر بماند تا FIFO خالی نباشد
            read_enable = 1;
            @(posedge clk);
            $display("read_en: %d, read_data: %h, empty: %b", read_enable, read_data, empty);
            $fwrite(outfile, "%02x\n", read_data);
            read_enable = 0;
        end
        
        // ✅ پایان شبیه‌سازی پس از کمی تأخیر
        #50;
        $fclose(outfile);
        $finish;
    end
endmodule
