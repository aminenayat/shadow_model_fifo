module fifo_tb;

    // پارامترها
    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 4;  // برای مثال 16 خانه حافظه داریم (2^4)

    // سیگنال‌ها
    reg clk;
    reg rstn;
    reg write_enable;
    reg read_enable;
    reg [DATA_WIDTH-1:0] write_data;
    wire [DATA_WIDTH-1:0] read_data;
    wire full;
    wire empty;

    // نمونه‌سازی ماژول FIFO
    fifo_memory #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) fifo_inst (
        .clk(clk),
        .rstn(rstn),
        .write_enable(write_enable),
        .read_enable(read_enable),
        .write_data(write_data),
        .read_data(read_data),
        .full(full),
        .empty(empty)
    );

    // تولید کلاک
    always #5 clk = ~clk;

    // ایجاد داده‌های تصادفی و تست‌ها
    integer i;
    initial begin
        // آغاز شبیه‌سازی
        clk = 0;
        rstn = 0;
        write_enable = 0;
        read_enable = 0;
        write_data = 0;
        
        // Reset FIFO
        #10 rstn = 1;
        
        // حالت 1: تعداد write_data بیشتر از read_data
        $display("Testing: write_data > read_data");
        for (i = 0; i < 20; i = i + 1) begin
            write_data = $random; // تولید داده تصادفی
            write_enable = 1;
            read_enable = 0;
            #10; // تاخیر برای شبیه‌سازی
            write_enable = 0;
            if (i % 2 == 0) begin
                read_enable = 1;
            end
            $display("index memory: %0d | write_data: %h | read_data: %h | full: %b | empty: %b", i, write_data, read_data, full, empty);
        end

        // حالت 2: تعداد read_data بیشتر از write_data
        $display("Testing: read_data > write_data");
        for (i = 0; i < 20; i = i + 1) begin
            write_data = $random;
            write_enable = 0;
            read_enable = 1;
            #10;
            if (i % 2 == 0) begin
                write_enable = 1;
            end
            $display("index memory: %0d | write_data: %h | read_data: %h | full: %b | empty: %b", i, write_data, read_data, full, empty);
        end

        // حالت 3: تعداد write_data برابر read_data
        $display("Testing: write_data = read_data");
        for (i = 0; i < 16; i = i + 1) begin
            write_data = $random;
            write_enable = 1;
            read_enable = 1;
            #10;
            $display("index memory: %0d | write_data: %h | read_data: %h | full: %b | empty: %b", i, write_data, read_data, full, empty);
        end

        // پایان شبیه‌سازی
        $stop;
    end
endmodule
