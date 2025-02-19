WORK_PATH = ./build/work
TOP_NAME = fifo_tb
TOP_PATH = ./src/*.sv ./test/fifo_tb.sv
COMPILE_OPTIONS = +acc=nrt

compile:
	vlib $(WORK_PATH)
	vlog -work $(WORK_PATH) $(TOP_PATH) $(COMPILE_OPTIONS)

run:
	vsim -work $(WORK_PATH) $(TOP_NAME) -do "run -all"

clean:
	rm -rf $(WORK_PATH)

