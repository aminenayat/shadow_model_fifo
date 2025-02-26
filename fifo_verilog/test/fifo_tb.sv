`timescale 1ns / 1ps

module fifo_tb();

  // پارامترها برای FIFO با عمق 1024
  parameter DATA_WIDTH = 8;
  parameter ADDR_WIDTH = 10; // 2^10 = 1024

  // سیگنال‌ها
  reg                    clk;
  reg                    rstn;
  reg                    write_enable;
  reg                    read_enable;
  reg  [DATA_WIDTH-1:0]  write_data;
  wire [DATA_WIDTH-1:0]  read_data;
  wire                   full;
  wire                   empty;

  integer i;
  reg [7:0] random_value;

  // ماژول FIFO
  fifo_memory #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH)
  ) DUT (
    .clk          (clk),
    .rstn         (rstn),
    .write_enable (write_enable),
    .read_enable  (read_enable),
    .write_data   (write_data),
    .read_data    (read_data),
    .full         (full),
    .empty        (empty)
  );

  // تولید کلاک با پریود 10ns
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // بلوک اصلی تست
  initial begin
    // مقدار اولیه سیگنال‌ها
    rstn         = 0;
    write_enable = 0;
    read_enable  = 0;
    write_data   = 8'h00;

    // کمی در حالت ریست
    #20;
    rstn = 1;
    #20;

    //--------------------------------------------------
    // Test #1: نوشتن 1050 داده و سپس خواندن 1050 داده
    // انتظار داریم از دیتای 1025 به بعد نوشتن ناموفق باشد.
    // هنگام خواندن هم از 1025 به بعد خالی باشد.
    //--------------------------------------------------
    $display("--------------------------------------------------");
    $display("Test #1: Write 1050 data -> then Read 1050 data (FIFO depth = 1024)");

    for (i = 1; i <= 1050; i = i + 1) begin
      random_value = $random & 8'hFF;
      write_data   = random_value;

      if (!full) begin
        write_enable = 1;
        #10;
        write_enable = 0;
        $display("  Writing data %0d: %2h", i, random_value);
      end
      else begin
        $display("  FIFO is full; cannot write data %0d", i);
      end
      #10;
    end

    $display("Now reading 1050 data from FIFO (after Test #1)...");
    for (i = 1; i <= 1050; i = i + 1) begin
      if (!empty) begin
        read_enable = 1;
        #10;
        read_enable = 0;
        $display("  Reading data %0d: %2h", i, read_data);
      end
      else begin
        $display("  FIFO is empty; cannot read data %0d", i);
      end
      #10;
    end

    //--------------------------------------------------
    // Test #2: نوشتن 100 داده و سپس خواندن 1050 داده
    // (پس از 100 بار خواندن، FIFO خالی می‌شود)
    //--------------------------------------------------
    $display("\n--------------------------------------------------");
    $display("Test #2: Write 100 data -> then Read 1050 data (FIFO depth = 1024)");

    // ریست مجدد
    rstn = 0;
    #10;
    rstn = 1;
    #10;

    // نوشتن 100 داده
    for (i = 1; i <= 100; i = i + 1) begin
      random_value = $random & 8'hFF;
      write_data   = random_value;

      if (!full) begin
        write_enable = 1;
        #10;
        write_enable = 0;
        $display("  Writing data %0d: %2h", i, random_value);
      end
      else begin
        $display("  FIFO is full; cannot write data %0d", i);
      end
      #10;
    end

    // حالا 1050 بار می‌خوانیم
    $display("  Now reading 1050 data from FIFO (after Test #2)...");
    for (i = 1; i <= 1050; i = i + 1) begin
      if (!empty) begin
        read_enable = 1;
        #10;
        read_enable = 0;
        $display("    Reading data %0d: %2h", i, read_data);
      end
      else begin
        $display("    FIFO is empty; cannot read data %0d", i);
      end
      #10;
    end

    //--------------------------------------------------
    // Test #3: نوشتن 1024 داده و سپس خواندن 1024 داده
    // انتظار داریم بعد از نوشتن 1024 داده، FIFO دقیقاً پر شود.
    // و پس از خواندن 1024 داده، FIFO دقیقاً خالی شود.
    //--------------------------------------------------
    $display("\n--------------------------------------------------");
    $display("Test #3: Write 1024 data -> then Read 1024 data (FIFO depth = 1024)");

    // ریست دوباره
    rstn = 0;
    #10;
    rstn = 1;
    #10;

    // نوشتن 1024 داده
    for (i = 1; i <= 1024; i = i + 1) begin
      random_value = $random & 8'hFF;
      write_data   = random_value;

      if (!full) begin
        write_enable = 1;
        #10;
        write_enable = 0;
        $display("  Writing data %0d: %2h", i, random_value);
      end
      else begin
        $display("  FIFO is full; cannot write data %0d", i);
      end
      #10;
    end

    // تلاشی برای نوشتن دادهٔ 1025
    random_value = $random & 8'hFF;
    write_data   = random_value;
    if (!full) begin
      write_enable = 1;
      #10;
      write_enable = 0;
      $display("  (Extra) Writing data 1025: %2h (Check if FIFO is truly full or not)", random_value);
    end
    else begin
      $display("  FIFO is full; cannot write data 1025");
    end

    // حالا 1024 بار می‌خوانیم
    $display("  Now reading 1024 data from FIFO (after Test #3)...");
    for (i = 1; i <= 1024; i = i + 1) begin
      if (!empty) begin
        read_enable = 1;
        #10;
        read_enable = 0;
        $display("    Reading data %0d: %2h", i, read_data);
      end
      else begin
        $display("    FIFO is empty; cannot read data %0d", i);
      end
      #10;
    end

    // تلاشی برای خواندن دادهٔ 1025 (حین خالی بودن FIFO)
    if (!empty) begin
      read_enable = 1;
      #10;
      read_enable = 0;
      $display("    (Extra) Reading data 1025: %2h", read_data);
    end
    else begin
      $display("    FIFO is empty; cannot read data 1025");
    end

    // پایان شبیه‌سازی
    #100;
    $stop;
  end

endmodule
