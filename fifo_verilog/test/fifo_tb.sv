`timescale 1ns/1ps

module fifo_tb;
    // پارامترها
    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 10;

    // سیگنال‌های تست‌بنچ
    reg clk, rstn;
    reg write_enable, read_enable;
    reg [DATA_WIDTH-1:0] write_data;
    wire [DATA_WIDTH-1:0] read_data;
    wire full, empty;

    // نمونه FIFO
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

    // تولید کلاک
    always #5 clk = ~clk;

    // -------------------------------------------------
    // Task: Test Write 1500 Then Read 100
    // -------------------------------------------------
    task test_write_then_read;
        input integer num_writes;
        input integer num_reads;
        integer write_index, read_index;
    begin
        $display("========== Test Write 1500 Then Read 100 ==========");
        $display("[WRITE THEN READ] Number of writes: %0d, Number of reads: %0d", num_writes, num_reads);

        // Reset FIFO
        rstn = 0;
        #100;
        rstn = 1;
        #10;

        // Initialize signals
        write_enable = 0;
        read_enable = 0;
        write_data = 0;

        // Perform 1500 writes
        for (write_index = 0; write_index < num_writes; write_index = write_index + 1) begin
            @(posedge clk);
            if (!full) begin
                write_enable = 1;
                write_data = $urandom_range(0, (1 << DATA_WIDTH) - 1);
                $display("Attempt %0d: Writing data : %h | full : %b | empty : %b", write_index, write_data, full, empty);
            end else begin
                write_enable = 0;
                $display("Attempt %0d: FIFO FULL, cannot write | full : %b | empty : %b", write_index, full, empty);
            end
        end
        write_enable = 0;

        // Perform 100 reads
        for (read_index = 0; read_index < num_reads; read_index = read_index + 1) begin
            @(posedge clk);
            if (!empty) begin
                read_enable = 1;
                @(posedge clk); // Wait for read data to be available
                $display("Attempt %0d: Reading data : %h | full : %b | empty : %b", read_index, read_data, full, empty);
            end else begin
                read_enable = 0;
                $display("Attempt %0d: FIFO EMPTY, cannot read | full : %b | empty : %b", read_index, full, empty);
            end
        end
        read_enable = 0;

        // Allow time for any remaining operations to complete
        repeat(2) @(posedge clk);
    end
    endtask

    // -------------------------------------------------
    // Task: Test Read 1500 Then Write 100
    // -------------------------------------------------
    task test_read_then_write;
        input integer num_reads;
        input integer num_writes;
        integer write_index, read_index;
    begin
        $display("========== Test Read 1500 Then Write 100 ==========");
        $display("[READ THEN WRITE] Number of reads: %0d, Number of writes: %0d", num_reads, num_writes);

        // Reset FIFO
        rstn = 0;
        #100;
        rstn = 1;
        #10;

        // Initialize signals
        write_enable = 0;
        read_enable = 0;
        write_data = 0;

        // Perform 1500 reads
        for (read_index = 0; read_index < num_reads; read_index = read_index + 1) begin
            @(posedge clk);
            if (!empty) begin
                read_enable = 1;
                @(posedge clk); // Wait for read data to be available
                $display("Attempt %0d: Reading data : %h | full : %b | empty : %b", read_index, read_data, full, empty);
            end else begin
                read_enable = 0;
                $display("Attempt %0d: FIFO EMPTY, cannot read | full : %b | empty : %b", read_index, full, empty);
            end
        end
        read_enable = 0;

        // Perform 100 writes
        for (write_index = 0; write_index < num_writes; write_index = write_index + 1) begin
            @(posedge clk);
            if (!full) begin
                write_enable = 1;
                write_data = $urandom_range(0, (1 << DATA_WIDTH) - 1);
                $display("Attempt %0d: Writing data : %h | full : %b | empty : %b", write_index, write_data, full, empty);
            end else begin
                write_enable = 0;
                $display("Attempt %0d: FIFO FULL, cannot write | full : %b | empty : %b", write_index, full, empty);
            end
        end
        write_enable = 0;

        // Allow time for any remaining operations to complete
        repeat(2) @(posedge clk);
    end
    endtask

    // -------------------------------------------------
    // بلوک initial اصلی تست‌بنچ
    // -------------------------------------------------
    initial begin
        // Initialize signals
        clk = 0;
        rstn = 0;
        write_enable = 0;
        read_enable = 0;
        write_data = 0;

        // Wait for reset
        #100;
        rstn = 1;

        // Run tests
        test_write_then_read(1500, 100); // Write 1500 then read 100
        test_read_then_write(1500, 100); // Read 1500 then write 100

        $display("All tests completed.");
        $finish;
    end
endmodule