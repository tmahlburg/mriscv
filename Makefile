VC = iverilog
SIM = vvp

test: regs_test instr_decode_test execute_test


regs_tb: regs.v tb/regs_tb.v
	- $(VC) -o regs_tb regs.v tb/regs_tb.v

regs_test: regs_tb
	- $(SIM) regs_tb


instr_decode_tb: regs.v instr_decode.v tb/instr_decode_tb.v
	- $(VC) -o instr_decode_tb regs.v instr_decode.v tb/instr_decode_tb.v

instr_decode_test: instr_decode_tb
	- $(SIM) instr_decode_tb


execute_tb: execute.v tb/execute_tb.v
	- $(VC) -o execute_tb execute.v tb/execute_tb.v

execute_test: execute_tb
	- $(SIM) execute_tb


clean:
	- rm *_tb
	- rm *_tb.vcd
