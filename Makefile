VC = iverilog
SIM = vvp
SRC = mriscv.srcs/sources_1/new/

test: regs_test instr_decode_test


regs_tb: $(SRC)/regs.v $(SRC)/regs_tb.v
	- $(VC) -o regs_tb $(SRC)/regs.v $(SRC)/regs_tb.v

regs_test: regs_tb
	- $(SIM) regs_tb


instr_decode_tb: $(SRC)/regs.v $(SRC)/instr_decode.v $(SRC)/instr_decode_tb.v
	- $(VC) -o instr_decode_tb $(SRC)/regs.v $(SRC)/instr_decode.v $(SRC)/instr_decode_tb.v

instr_decode_test: instr_decode_tb
	- $(SIM) instr_decode_tb


clean:
	- rm *_tb
	- rm *_tb.vcd
