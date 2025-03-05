`timescale 1ns / 1ps

module fifo_tb();

  parameter DATA_WIDTH = 8;
  parameter ADDR_WIDTH = 10; // 2^10 = 1024

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

 
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

 
  initial begin
   
    rstn         = 0;
    write_enable = 0;
    read_enable  = 0;
    write_data   = 8'h00;

  
    #20;
    rstn = 1;
    #20;

    //--------------------------------------------------
    // Test 1: نوشتن 1050 داده و سپس خواندن 1050 داده
    //--------------------------------------------------
    $display("--------------------------------------------------");
    $display("Test 1: Write 1050 data - then Read 1050 data (FIFO depth = 1024)");

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

    $display("Now reading 1050 data from FIFO (after Test 1)...");
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
    // Test 2: نوشتن 100 داده و سپس 1050 بار خواندن
    //--------------------------------------------------
    $display("\n--------------------------------------------------");
    $display("Test 2: Write 100 data - then Read 1050 data (FIFO depth = 1024)");

    
    rstn = 0;
    #10;
    rstn = 1;
    #10;

    
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

    
    $display("  Now reading 1050 data from FIFO (after Test 2)...");
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
    // Test 3: نوشتن 1024 داده و سپس خواندن 1024 داده
    //--------------------------------------------------
    $display("\n--------------------------------------------------");
    $display("Test 3: Write 1024 data - then Read 1024 data (FIFO depth = 1024)");

  
    rstn = 0;
    #10;
    rstn = 1;
    #10;


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

  
    random_value = $random & 8'hFF;
    write_data   = random_value;
    if (!full) begin
      write_enable = 1;
      #10;
      write_enable = 0;
      $display("  (Extra) Writing data 1025: %2h", random_value);
    end
    else begin
      $display("  FIFO is full; cannot write data 1025");
    end

    
    $display("  Now reading 1024 data from FIFO (after Test 3)...");
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

    // تلاش برای خواندن داده 1025
    if (!empty) begin
      read_enable = 1;
      #10;
      read_enable = 0;
      $display("    (Extra) Reading data 1025: %2h", read_data);
    end
    else begin
      $display("    FIFO is empty; cannot read data 1025");
    end


// ....
// Test 4: Random read/write for 50 cycles
//--------------------------------------------------
$display("\n--------------------------------------------------");
$display("Test 4: Random read/write for 50 cycles, then read out everything left in FIFO");


rstn = 0;
#10;
rstn = 1;
#10;


begin : TEST4_BLOCK
  integer cycle_count;
  integer read_count;
  reg [7:0] rand_data;

  
  read_count = 0;


  for (cycle_count = 1; cycle_count <= 50; cycle_count = cycle_count + 1) begin

    if (!full && !empty) begin
      if ($random % 2 == 0) begin
       
        rand_data  = $random & 8'hFF;
        write_data = rand_data;
        write_enable = 1;
        #10;
        write_enable = 0;
        $display("  Cycle %0d: Write  %2h  (FIFO was neither full nor empty)", cycle_count, rand_data);
      end
      else begin
       
        read_enable = 1;
        #10;
        read_enable = 0;
        $display("  Cycle %0d: Read   %2h  (FIFO was neither full nor empty)", cycle_count, read_data);
      end
    end
    else if (full) begin
    
      read_enable = 1;
      #10;
      read_enable = 0;
      $display("  Cycle %0d: Read   %2h  (FIFO was full, forced to read)", cycle_count, read_data);
    end
    else if (empty) begin
     
      rand_data  = $random & 8'hFF;
      write_data = rand_data;
      write_enable = 1;
      #10;
      write_enable = 0;
      $display("  Cycle %0d: Write  %2h  (FIFO was empty, forced to write)", cycle_count, rand_data);
    end

    #10;
  end

  
  $display("  Now reading out all remaining data in FIFO...");
  while (!empty) begin
    read_enable = 1;
    #10;
    read_enable = 0;
    read_count  = read_count + 1;
    $display("    Final read %0d: %2h", read_count, read_data);
    #10;
  end

  $display("End of Test #4");
end


//--------------------------------------------------
// Test 5: Rate mismatch scenario
//  - Phase A: Fast Write, Slow Read
//  - Phase B: Fast Read, Slow Write
//--------------------------------------------------
$display("\n--------------------------------------------------");
$display("Test 5: Rate mismatch scenario");


rstn = 0;
#10;
rstn = 1;
#10;

begin : TEST5_BLOCK

  integer cycle;
  integer read_count;
  integer write_count;
  integer leftover_read;
  reg [7:0] rand_data;

  
  read_count     = 0;
  write_count    = 0;
  leftover_read  = 0;

  // -------------------------
  // فاز A: Fast Write, Slow Read
  // -------------------------
  $display("[Phase A] Fast Write, Slow Read for 30 cycles ...");
  for (cycle = 1; cycle <= 30; cycle = cycle + 1) begin
   
    if ((cycle % 3 == 1) || (cycle % 3 == 2)) begin
      
      if (!full) begin
        rand_data  = $random & 8'hFF;
        write_data = rand_data;
        write_enable = 1;
        #10;
        write_enable = 0;
        write_count = write_count + 1;
        $display("  Cycle %0d: WRITE  %2h (total writes=%0d)", cycle, rand_data, write_count);
      end
      else begin
        $display("  Cycle %0d: FIFO is full; cannot WRITE", cycle);
      end
    end
    else begin
    
      if (!empty) begin
        read_enable = 1;
        #10;
        read_enable = 0;
        read_count = read_count + 1;
        $display("  Cycle %0d: READ   %2h (total reads=%0d)", cycle, read_data, read_count);
      end
      else begin
        $display("  Cycle %0d: FIFO is empty; cannot READ", cycle);
      end
    end
    #10;
  end

  // -------------------------
  // فاز B: Fast Read, Slow Write
  // -------------------------
  $display("\n[Phase B] Fast Read, Slow Write for 30 cycles ...");
  for (cycle = 1; cycle <= 30; cycle = cycle + 1) begin
    
    if ((cycle % 3 == 1) || (cycle % 3 == 2)) begin
      
      if (!empty) begin
        read_enable = 1;
        #10;
        read_enable = 0;
        read_count = read_count + 1;
        $display("  Cycle %0d: READ   %2h (total reads=%0d)", cycle, read_data, read_count);
      end
      else begin
        $display("  Cycle %0d: FIFO is empty; cannot READ", cycle);
      end
    end
    else begin
     
      if (!full) begin
        rand_data  = $random & 8'hFF;
        write_data = rand_data;
        write_enable = 1;
        #10;
        write_enable = 0;
        write_count = write_count + 1;
        $display("  Cycle %0d: WRITE  %2h (total writes=%0d)", cycle, rand_data, write_count);
      end
      else begin
        $display("  Cycle %0d: FIFO is full; cannot WRITE", cycle);
      end
    end
    #10;
  end

  
  $display("\nNow reading out all remaining data in FIFO (after Phase B)...");
  while (!empty) begin
    read_enable = 1;
    #10;
    read_enable = 0;
    leftover_read = leftover_read + 1;
    $display("  leftover READ %0d: %2h", leftover_read, read_data);
    #10;
  end

  $display("End of Test #5: Rate mismatch scenario");
end

//--------------------------------------------------
// Test 6: Fill FIFO to FULL, then drain to EMPTY
//          with separate cycles for each WRITE and READ
//--------------------------------------------------
$display("\n--------------------------------------------------");
$display("Test 6: Fill FIFO to FULL, then drain to EMPTY, ensuring each write/read is on a separate cycle");

rstn = 0;
#10;
rstn = 1;
#10;

begin : TEST6_BLOCK
 
  integer cycle;
  integer j;
  integer read_count;
  integer write_count;
  integer leftover_reads;
  reg [7:0] rand_data;

 
  cycle         = 0;
  j             = 0;
  read_count    = 0;
  write_count   = 0;
  leftover_reads= 0;

  // -------------------------
  // Phase A: پر کردن FIFO
  //  - در هر دور: 8 بار پشت سر هم Write (با فاصلهٔ یک سیکل بعد از هر Write)
  //    سپس 1 بار Read (همراه با فاصلهٔ یک سیکل قبل و بعد)،
  //  - تا وقتی که واقعاً full شود یا از سقف سیکل بگذریم
  // -------------------------
  $display("[Phase A] Trying to fill FIFO until FULL ...");
  while (!full && cycle < 50000) begin
    cycle = cycle + 1;

    for (j = 1; j <= 8; j = j + 1) begin
      if (!full) begin
        rand_data  = $random & 8'hFF;
        write_data = rand_data;
        write_enable = 1;
        #10; 
        write_enable = 0;
        write_count  = write_count + 1;
        $display("  Cycle %0d (W%0d): WRITE %2h (total writes=%0d)",
                  cycle, j, rand_data, write_count);

        #10; 
      end
      else begin
        $display("  Cycle %0d (W%0d): FIFO is full; cannot WRITE", cycle, j);
      end
    end

    
    if (!empty) begin
      read_enable = 1;
      #10;
      read_enable = 0;
      read_count  = read_count + 1;
      $display("  Cycle %0d (R): READ %2h (total reads=%0d)",
                cycle, read_data, read_count);

      #10;
    end
    else begin
      $display("  Cycle %0d (R): FIFO is empty; cannot READ", cycle);
    end
  end

  
  if (full) begin
    $display("*** FIFO became FULL during Phase A at cycle=%0d ***", cycle);
  end
  else begin
    $display("*** Warning: Reached cycle limit in Phase A without seeing FULL ***");
  end

  // -------------------------
  // Phase B: خالی کردن FIFO
  //  - در هر دور: 8 بار پشت سر هم READ (هر کدام با فاصلهٔ یک سیکل)
  //    سپس 1 بار WRITE (با فاصلهٔ یک سیکل)،
  //  - ادامه می‌دهیم تا FIFO واقعاً empty شود یا به سقف سیکل برسیم
  // -------------------------
  $display("\n[Phase B] Draining FIFO until EMPTY ...");
  cycle = 0;
  while (!empty && cycle < 50000) begin
    cycle = cycle + 1;

 
    for (j = 1; j <= 8; j = j + 1) begin
      if (!empty) begin
        read_enable = 1;
        #10;
        read_enable = 0;
        read_count = read_count + 1;
        $display("  Cycle %0d (R%0d): READ %2h (total reads=%0d)",
                  cycle, j, read_data, read_count);

        #10; 
      end
      else begin
        $display("  Cycle %0d (R%0d): FIFO is empty; cannot READ anymore",
                  cycle, j);
      end
    end

    if (!full) begin
      rand_data = $random & 8'hFF;
      write_data = rand_data;
      write_enable = 1;
      #10;
      write_enable = 0;
      write_count  = write_count + 1;
      $display("  Cycle %0d (W): WRITE %2h (total writes=%0d)",
                cycle, rand_data, write_count);

      #10; 
    end
    else begin
      $display("  Cycle %0d (W): FIFO is full; cannot WRITE", cycle);
    end
  end


  if (empty) begin
    $display("*** FIFO became EMPTY during Phase B at cycle=%0d ***", cycle);
  end
  else begin
    $display("*** Warning: Reached cycle limit in Phase B without seeing EMPTY ***");
  end

  $display("\nNow reading out leftover data after Phase B if not empty...");
  leftover_reads = 0;
  while (!empty) begin
    read_enable = 1;
    #10;
    read_enable = 0;
    leftover_reads = leftover_reads + 1;
    $display("  leftover READ %0d: %2h", leftover_reads, read_data);
    #10;
  end

  $display("End of Test #6: FULL -> EMPTY scenario completed\n");
end

//--------------------------------------------------
// Test #7: Random R/W with Reference Model (Scoreboard)
//--------------------------------------------------
$display("\n--------------------------------------------------");
$display("Test #7: Random read/write with a software reference model (queue) to check data integrity");

rstn = 0;
#10;
rstn = 1;
#10;

begin : TEST7_BLOCK

 
  byte ref_queue[$];        // یک صف پویا از بایت‌ها  
  integer cycle_count;
  integer i;
  integer NUM_CYCLES;
  reg [7:0] rand_data;

  
  ref_queue   = {};         
  NUM_CYCLES  = 100;       

  $display("Starting Test #7 with %0d random cycles (Reference Model check)...", NUM_CYCLES);

  
  for (cycle_count = 1; cycle_count <= NUM_CYCLES; cycle_count = cycle_count + 1) begin

   
    if (full) begin
      read_enable = 1;
      #10;
      read_enable = 0;

      if (!empty) begin
        if (ref_queue.size() == 0) begin
          $display("Error at cycle %0d: FIFO not empty but scoreboard is empty!", cycle_count);
          $fatal;
        end
        else begin
          if (read_data !== ref_queue[0]) begin
            $display("Mismatch at cycle %0d: FIFO gave %2h, but ref_queue[0] was %2h",
                      cycle_count, read_data, ref_queue[0]);
            $fatal;
          end
          else begin
            ref_queue.pop_front();
            $display("Cycle %0d: READ %2h matches scoreboard. (Scoreboard size=%0d)",
                      cycle_count, read_data, ref_queue.size());
          end
        end
      end
      else begin
        $display("Cycle %0d: FIFO is both FULL and EMPTY?? Check design logic.", cycle_count);
      end
    end

    else if (empty) begin
      rand_data  = $random & 8'hFF;
      write_data = rand_data;
      write_enable = 1;
      #10;
      write_enable = 0;

      ref_queue.push_back(rand_data);
      $display("Cycle %0d: WRITE %2h (Scoreboard size=%0d)",
                cycle_count, rand_data, ref_queue.size());
    end


    else begin
      if (($random % 2) == 0) begin
   
        rand_data  = $random & 8'hFF;
        write_data = rand_data;
        write_enable = 1;
        #10;
        write_enable = 0;

        ref_queue.push_back(rand_data);
        $display("Cycle %0d: WRITE %2h (Scoreboard size=%0d)",
                  cycle_count, rand_data, ref_queue.size());
      end
      else begin
      
        read_enable = 1;
        #10;
        read_enable = 0;

        if (!empty) begin
          if (ref_queue.size() == 0) begin
            $display("Error at cycle %0d: FIFO has data but scoreboard is empty!", cycle_count);
            $fatal;
          end
          else begin
        
            if (read_data !== ref_queue[0]) begin
              $display("Mismatch at cycle %0d: FIFO gave %2h, but ref_queue[0] was %2h",
                        cycle_count, read_data, ref_queue[0]);
              $fatal;
            end
            else begin
              ref_queue.pop_front();
              $display("Cycle %0d: READ %2h matches scoreboard. (Scoreboard size=%0d)",
                        cycle_count, read_data, ref_queue.size());
            end
          end
        end
        else begin
          $display("Cycle %0d: Attempted READ but FIFO empty?? Check design logic.", cycle_count);
        end
      end
    end

    #10;
  end

  $display("\nEnd of random cycles. Draining FIFO fully to match scoreboard...");

  while (!empty) begin
    read_enable = 1;
    #10;
    read_enable = 0;

    if (ref_queue.size() == 0) begin
      $display("Error: FIFO not empty but scoreboard is empty!");
      $fatal;
    end
    else begin
      if (read_data !== ref_queue[0]) begin
        $display("Mismatch during final drain: FIFO gave %2h, but ref_queue[0] was %2h",
                  read_data, ref_queue[0]);
        $fatal;
      end
      else begin
        ref_queue.pop_front();
        $display("Final drain READ: %2h (Remaining scoreboard size=%0d)",
                  read_data, ref_queue.size());
      end
    end
    #10;
  end


  if (ref_queue.size() != 0) begin
    $display("Error: scoreboard still has %0d items left but FIFO is empty!",
              ref_queue.size());
    $fatal;
  end
  else begin
    $display("Scoreboard is empty, FIFO is empty. Test #7 passed with no mismatches!");
  end

  $display("End of Test #7: Reference Model check complete.\n");
end


    #100;
    $stop;
  end

endmodule
