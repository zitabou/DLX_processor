quit -sim

vcom DLX_vhd/000-globals.vhd

vcom DLX_vhd/mux21.vhd
vcom DLX_vhd/mux21_generic.vhd

vcom DLX_vhd/a.c-IRAM.vhd
vcom DLX_vhd/a.d-DRAM.vhd

#vcom DLX_vhd/a.b-DataPath.core/a.b.a-FETCH/mux21.vhd
#vcom DLX_vhd/a.b-DataPath.core/a.b.a-FETCH/mux21_generic.vhd
vcom DLX_vhd/a.b-DataPath.core/a.b.a-FETCH.vhd

vcom DLX_vhd/a.b-DataPath.core/a.b.b-DEC/dec_logic.vhd
vcom DLX_vhd/a.b-DataPath.core/a.b.b-DEC/registerfile.vhd
vcom DLX_vhd/a.b-DataPath.core/a.b.b-DEC/stall_detection_unit.vhd
vcom DLX_vhd/a.b-DataPath.core/a.b.b-DEC/jump_logic.vhd
vcom DLX_vhd/a.b-DataPath.core/a.b.b-DEC.vhd

#--components of exe stage
#--components of ALU
#vcom DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/a.b.c.a.a.a-p4_adder/mux21.vhd
#vcom DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/a.b.c.a.a.a-p4_adder/mux21_generic.vhd
vcom DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/a.b.c.a.a.a-p4_adder/fa.vhd
vcom DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/a.b.c.a.a.a-p4_adder/rca_generic.vhd
vcom DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/a.b.c.a.a.a-p4_adder/G_block.vhd
vcom DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/a.b.c.a.a.a-p4_adder/PG_block.vhd
vcom DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/a.b.c.a.a.a-p4_adder/my_xor.vhd
vcom DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/a.b.c.a.a.a-p4_adder/pg_net.vhd
vcom DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/a.b.c.a.a.a-p4_adder/carry_generator.vhd
vcom DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/a.b.c.a.a.a-p4_adder/carry_select_block.vhd
vcom DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/a.b.c.a.a.a-p4_adder/sum_generator.vhd
vcom DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/p4_adder.vhd

vcom DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/a.b.c.a.a.b-shifter/a.b.c.a.a.b.a-mask_generator/mux21.vhd
vcom DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/a.b.c.a.a.b-shifter/a.b.c.a.a.b.a-mask_generator/mux21_generic.vhd
vcom DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/a.b.c.a.a.b-shifter/a.b.c.a.a.b.a-mask_generator/mux41.vhd
vcom DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/a.b.c.a.a.b-shifter/a.b.c.a.a.b.a-mask_generator/mux41_generic.vhd
vcom DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/a.b.c.a.a.b-shifter/mux41.vhd
vcom DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/a.b.c.a.a.b-shifter/mux41_generic.vhd
vcom DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/a.b.c.a.a.b-shifter/mux81.vhd
vcom DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/a.b.c.a.a.b-shifter/mux81_generic.vhd
vcom DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/a.b.c.a.a.b-shifter/mask_generator.vhd
vcom DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/a.b.c.a.a.b-shifter/mask_shifter.vhd
vcom DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/shifter.vhd

vcom DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/a.b.c.a.a.c-logicals/nand31.vhd
vcom DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/a.b.c.a.a.c-logicals/nand41.vhd
vcom DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/logicals.vhd

vcom DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/nor_generic.vhd
vcom DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/comparator.vhd

vcom DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/alu.vhd

vcom DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.b-MUL/negate.vhd
vcom DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.b-MUL/shl1.vhd
vcom DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.b-MUL/shl2.vhd
vcom DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.b-MUL/shl3.vhd
vcom DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.b-MUL/enc33.vhd
vcom DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.b-MUL/mux51.vhd

#vcom DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.b-MUL/a.b.c.a.b.a-p4_adder/mux21.vhd
#vcom DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.b-MUL/a.b.c.a.b.a-p4_adder/mux21_generic.vhd
#vcom DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.b-MUL/a.b.c.a.b.a-p4_adder/fa.vhd
#vcom DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.b-MUL/a.b.c.a.b.a-p4_adder/rca_generic.vhd
#vcom DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.b-MUL/a.b.c.a.b.a-p4_adder/G_block.vhd
#vcom DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.b-MUL/a.b.c.a.b.a-p4_adder/PG_block.vhd
#vcom DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.b-MUL/a.b.c.a.b.a-p4_adder/my_xor.vhd
#vcom DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.b-MUL/a.b.c.a.b.a-p4_adder/pg_net.vhd
#vcom DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.b-MUL/a.b.c.a.b.a-p4_adder/carry_generator.vhd
#vcom DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.b-MUL/a.b.c.a.b.a-p4_adder/carry_select_block.vhd
#vcom DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.b-MUL/a.b.c.a.b.a-p4_adder/sum_generator.vhd
#vcom DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.b-MUL/p4_adder.vhd

vcom DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/BOOTHMUL.vhd

#vcom DLX_vhd/a.b-DataPath.core/a.b.e-WB/mux21.vhd
#vcom DLX_vhd/a.b-DataPath.core/a.b.e-WB/mux21_generic.vhd

vcom DLX_vhd/a.b-DataPath.core/a.b.c-EXE/EXU.vhd
vcom DLX_vhd/a.b-DataPath.core/a.b.c-EXE/mux41.vhd
vcom DLX_vhd/a.b-DataPath.core/a.b.c-EXE/mux41_generic.vhd
vcom DLX_vhd/a.b-DataPath.core/a.b.c-EXE/forwarding_unit.vhd
vcom DLX_vhd/a.b-DataPath.core/a.b.c-EXE.vhd


#--components mem stage
vcom DLX_vhd/a.b-DataPath.core/a.b.d-MEM/mux51.vhd
vcom DLX_vhd/a.b-DataPath.core/a.b.d-MEM/mux51_generic.vhd
vcom DLX_vhd/a.b-DataPath.core/a.b.d-MEM/MMU.vhd
vcom DLX_vhd/a.b-DataPath.core/a.b.d-MEM.vhd

#vcom DLX_vhd/a.b-DataPath.core/a.b.e-WB/mux21.vhd
#vcom DLX_vhd/a.b-DataPath.core/a.b.e-WB/mux21_generic.vhd
vcom DLX_vhd/a.b-DataPath.core/a.b.e-WB.vhd

vcom DLX_vhd/a.b-DataPath.vhd
vcom DLX_vhd/a.a-hardwired_CU.vhd

vcom DLX_vhd/a-DLX.vhd


vcom DLX_vhd/test_bench/tb_DLX.vhd

vsim work.test_DLX_cfg

set stdArithNoWarnings 1
set NumericStdNoWarnings 1

add wave -position 0  sim:/tb_dlx/s_RST
add wave -position 0  sim:/tb_dlx/s_CLK
add wave -position 0  sim:/tb_dlx/DLX_test/data_path/dec_stage/opcode
add wave -position 0  sim:/tb_dlx/DLX_test/data_path/instr
add wave -position 0  sim:/tb_dlx/DLX_test/data_path/fetch_stage/PC
add wave -position end  sim:/tb_dlx/DLX_test/data_path/RF1
add wave -position end  sim:/tb_dlx/DLX_test/data_path/RF2
add wave -position end  sim:/tb_dlx/DLX_test/data_path/EN1
add wave -position end  sim:/tb_dlx/DLX_test/data_path/Ld
add wave -position end  sim:/tb_dlx/DLX_test/data_path/S1
add wave -position end  sim:/tb_dlx/DLX_test/data_path/S2
add wave -position end  sim:/tb_dlx/DLX_test/data_path/ALU3
add wave -position end  sim:/tb_dlx/DLX_test/data_path/ALU2
add wave -position end  sim:/tb_dlx/DLX_test/data_path/ALU1
add wave -position end  sim:/tb_dlx/DLX_test/data_path/ALU0
add wave -position end  sim:/tb_dlx/DLX_test/data_path/SN
add wave -position end  sim:/tb_dlx/DLX_test/data_path/LnS
add wave -position end  sim:/tb_dlx/DLX_test/data_path/Wrd
add wave -position end  sim:/tb_dlx/DLX_test/data_path/BHU1
add wave -position end  sim:/tb_dlx/DLX_test/data_path/BHU0
add wave -position end  sim:/tb_dlx/DLX_test/data_path/EN3
add wave -position end  sim:/tb_dlx/DLX_test/data_path/S3
add wave -position end  sim:/tb_dlx/DLX_test/data_path/WF1
add wave -position end  sim:/tb_dlx/DLX_test/data_path/dec_stage/REG_FILE/REGISTERS
add wave -position end  sim:/tb_dlx/main_mem/MEMORY
add wave -position end  sim:/tb_dlx/DLX_test/data_path/OVF





run 35 ns
