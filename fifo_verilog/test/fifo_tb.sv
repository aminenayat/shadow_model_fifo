`timescale 1ns / 1ps

module fifo_tb();

  // پارامترها
  parameter DATA_WIDTH = 8;
  parameter ADDR_WIDTH = 4; // با 4 بیت آدرس، عمق FIFO = 16 خواهد شد

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

  // نمونه‌سازی از FIFO
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

  // تولید کلاک
  initial begin
    clk = 0;
    forever #5 clk = ~clk;  // پریود کلاک 10 نانوثانیه
  end

  // بلوک اصلی تست
  initial begin
    // مقدار اولیه سیگنال‌ها
    rstn         = 0;
    write_enable = 0;
    read_enable  = 0;
    write_data   = 8'h00;

    // مدتی در حالت ریست بمانیم
    #20;
    rstn = 1;
    #20;

    //--------------------------------------------------
    // تست اول:
    // "نوشتن 20 داده در FIFO با ظرفیت 16"
    // مرحله A: فقط نوشتن 20 داده
    //--------------------------------------------------
    $display("Starting test #1: Writing 20 data to FIFO with capacity 16");
    for (i = 1; i <= 20; i = i + 1) begin
      // داده تصادفی تولید کنید یا به‌صورت ثابت قرار دهید
      random_value = $random & 8'hFF;
      write_data   = random_value;

      // در صورت پر نبودن FIFO، عمل نوشتن انجام شود
      if (!full) begin
        write_enable = 1;
        #10;  // یک سیکل برای نوشتن
        write_enable = 0;
        $display("  Writing data %0d: %2h", i, random_value);
      end
      else begin
        // اگر FIFO پر شده باشد
        $display("  FIFO is full; cannot write data %0d", i);
      end
      #10; // کمی فاصله بین نوشتن‌های متوالی
    end

    // مرحله B: حال 20 بار تلاش به خواندن از FIFO
    $display("Now reading 20 data from FIFO (after first test) ...");
    for (i = 1; i <= 20; i = i + 1) begin
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
    // تست دوم:
    // "نوشتن فقط 4 داده و سپس تلاش برای 20 بار خواندن"
    //--------------------------------------------------
    $display("\nStarting test #2: Writing 4 data and then reading 20 times");
    // اول FIFO را ریست می‌کنیم تا تست کاملاً مستقل باشد
    rstn = 0;
    #10;
    rstn = 1;
    #10;

    // نوشتن 4 داده
    for (i = 1; i <= 4; i = i + 1) begin
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

    // سپس تلاش برای 20 بار خواندن
    $display("  Now reading 20 data from FIFO ...");
    for (i = 1; i <= 20; i = i + 1) begin
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

    // پایان شبیه‌سازی
    #100;
    $stop;
  end

endmodule
