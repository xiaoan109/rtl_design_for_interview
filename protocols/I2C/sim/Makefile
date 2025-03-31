UVM_HOME=D:/Tools/questasim64_2021.1/verilog_src/uvm-1.2
UVM_DPI_HOME=D:/Tools/questasim64_2021.1/uvm-1.2/win64
FILELIST=filelist.f
verbosity=UVM_MEDIUM
testcase=
top=

help:
	@echo "[work]: create work lib"
	@echo "[compile]: compile verilog & system verilog files in FILELIST"
	@echo "[run]: start simulation in questasim batch mode"
	@echo "[rung]: start simulation in questasim gui mode"

all: work compile run

work:
	vlib work

compile:
	vlog -f ${FILELIST}

run:
	vsim -voptargs="+acc" -c work.${TOP} -do "run -all" -l sim.log 

rung:
	vsim -voptargs="+acc" work.${TOP} -do "run -all" -l sim.log 

clean:
	rm -rf work *.log transcript

.PHONY: work compile run clean
