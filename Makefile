VC = iverilog
SIM = vvp

test: regs_tb.vcd instr_decode_tb.vcd execute_tb.vcd write_back_tb.vcd


regs_tb: regs.v tb/regs_tb.v
	- $(VC) -o regs_tb regs.v tb/regs_tb.v

regs_tb.vcd: regs_tb
	- $(SIM) regs_tb


instr_decode_tb: regs.v instr_decode.v tb/instr_decode_tb.v
	- $(VC) -o instr_decode_tb regs.v instr_decode.v tb/instr_decode_tb.v

instr_decode_tb.vcd: instr_decode_tb
	- $(SIM) instr_decode_tb


execute_tb: execute.v tb/execute_tb.v
	- $(VC) -o execute_tb execute.v tb/execute_tb.v

execute_tb.vcd: execute_tb
	- $(SIM) execute_tb


write_back_tb: regs.v write_back.v tb/write_back_tb.v
	- $(VC) -o write_back_tb regs.v write_back.v tb/write_back_tb.v

write_back_tb.vcd: write_back_tb
	- $(SIM) write_back_tb

clean:
	- rm *_tb
	- rm *_tb.vcd
