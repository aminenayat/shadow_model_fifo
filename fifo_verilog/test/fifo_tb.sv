`timescale 1ns / 1ps

module fifo_tb();

  // پارامترها
  parameter DATA_WIDTH = 8;
  parameter ADDR_WIDTH = 4; // در نتیجه عمق FIFO = 16

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
    // بدون خواندن تا ببینیم بعد از 16 داده، FIFO پر می‌شود
    // سپس 20 بار می‌خوانیم که بعد از 16 داده خالی شود
    //--------------------------------------------------
    $display("--------------------------------------------------");
    $display("Starting test #1: Writing 20 data to FIFO with capacity 16");
    for (i = 1; i <= 20; i = i + 1) begin
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
    $display("\n--------------------------------------------------");
    $display("Starting test #2: Writing 4 data and then reading 20 times");

    // ریست مجدد FIFO تا مستقل از تست قبل باشد
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

    // تلاش برای 20 بار خواندن
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

    //--------------------------------------------------
    // تست سوم:
    // "تعداد write و read برابر (16) و نمایش مقادیر در یک خط"
    // مطابق فرمتی که گفتید:
    // Writing data i: xx -- Reading data i: xx
    // در پایان هم تلاش برای نوشتن بیشتر و مشاهده "FIFO is full..."
    //--------------------------------------------------
    $display("\n--------------------------------------------------");
    $display("Starting test #3: Write & Read in one loop (16 times), then attempt more write");

    // باز هم ریست مجدد FIFO
    rstn = 0;
    #10;
    rstn = 1;
    #10;

    for (i = 1; i <= 16; i = i + 1) begin
      // تولید داده تصادفی
      random_value = $random & 8'hFF;
      write_data   = random_value;

      // مرحله نوشتن
      if (!full) begin
        write_enable = 1;
        #10;  // یک سیکل برای نوشتن
        write_enable = 0;
      end
      else begin
        // اگر در میانه پر شد (در واقعیت نباید پر شود وقتی بلافاصله می‌خوانیم!)
        $display("  FIFO is full; cannot write data %0d", i);
      end

      // مرحله خواندن: (بلافاصله بعد از نوشتن، برای نمایش روی همان خط)
      if (!empty) begin
        read_enable = 1;
        #10;  // یک سیکل برای خواندن
        read_enable = 0;
        $display("  Writing data %0d: %2h -- Reading data %0d: %2h", i, random_value, i, read_data);
      end
      else begin
        // اگر FIFO خالی باشد (به‌صورت تئوری ممکن است به علت تأخیر خواندن)
        $display("  Writing data %0d: %2h -- FIFO is empty; cannot read data %0d", i, random_value, i);
      end

      #10;
    end

    // الان یک بار دیگر تلاش برای نوشتن می‌کنیم:
    // با این فرض که شاید FIFO پر شده باشد (طبق فرمت درخواستی شما).
    random_value = $random & 8'hFF;
    write_data   = random_value;
    if (!full) begin
        $display("  Attempt to write data 17: %2h", random_value);
        write_enable = 1;
        #10;
        write_enable = 0;
    end
    else begin
        $display("  FIFO is full; cannot write data more");
    end

    // پایان شبیه‌سازی
    #100;
    $stop;
  end

endmodule
