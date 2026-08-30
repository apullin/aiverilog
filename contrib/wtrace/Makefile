ROOT := ../..
ROOT_ABS := $(abspath $(ROOT))
IVERILOG := $(ROOT_ABS)/driver/iverilog
IVERILOG_VPI := $(ROOT_ABS)/driver-vpi/iverilog-vpi
VVP := $(ROOT_ABS)/vvp/vvp
BUILD := build

.PHONY: all test benchmark clean

all: wtrace_vpi.vpi

wtrace_vpi.vpi: wtrace_vpi.c $(ROOT_ABS)/vpi/lz4.c $(ROOT_ABS)/vpi/lz4.h
	$(IVERILOG_VPI) --name=wtrace_vpi -I$(ROOT_ABS) -I$(ROOT_ABS)/vpi -L$(ROOT_ABS)/vpi $< $(ROOT_ABS)/vpi/lz4.c

$(BUILD):
	mkdir -p $@

$(BUILD)/basic.vvp: tests/basic.sv | $(BUILD)
	$(IVERILOG) -g2012 -B$(ROOT_ABS)/tgt-vvp -BI$(ROOT_ABS) -BM$(ROOT_ABS)/vpi -BP$(ROOT_ABS)/ivlpp -o $@ $<

$(BUILD)/basic.wtr: wtrace_vpi.vpi $(BUILD)/basic.vvp
	cd $(BUILD) && $(VVP) -M.. -mwtrace_vpi basic.vvp

$(BUILD)/basic.vcd: $(BUILD)/basic.wtr wtrace_decode.py
	python3 wtrace_decode.py $< -o $@

test: $(BUILD)/basic.vcd
	python3 tests/check_trace.py $(BUILD)/basic.wtr

benchmark: wtrace_vpi.vpi
	python3 benchmark.py

clean:
	rm -f wtrace_vpi.o lz4.o wtrace_vpi.vpi
	rm -rf $(BUILD)
