############################################################################
# SCRIPT FOR SPEEDING UP and RECORDING the DLX SYNTHESIS                   #
# analyzing and checking vhdl netlist                                      #
# here the analyze command is used for each file from bottom to top        #
############################################################################

analyze -library WORK -format vhdl {../DLX_vhd/000-globals.vhd}
analyze -library WORK -format vhdl {../DLX_vhd/a.a-hardwired_CU.vhd}

analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.a-FETCH/mux21.vhd}
analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.a-FETCH/mux21_generic.vhd}
##analyze -library WORK -format vhdl {../DLX_vhd/a.c-IRAM.vhd}
analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.a-FETCH.vhd}

analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.b-DEC/dec_logic.vhd}
analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.b-DEC/jump_logic.vhd}
##analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.b-DEC/mux21.vhd}
##analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.b-DEC/mux21_generic.vhd}
analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.b-DEC/stall_detection_unit.vhd}
analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.b-DEC/registerfile.vhd}
analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.b-DEC.vhd}

#--p4 adder
##analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/a.b.c.a.a.a-p4_adder/mux21.vhd}
##analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/a.b.c.a.a.a-p4_adder/mux21_generic.vhd}
analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/a.b.c.a.a.a-p4_adder/fa.vhd}
analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/a.b.c.a.a.a-p4_adder/rca_generic.vhd}
analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/a.b.c.a.a.a-p4_adder/G_block.vhd}
analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/a.b.c.a.a.a-p4_adder/PG_block.vhd}
analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/a.b.c.a.a.a-p4_adder/pg_net.vhd}
analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/a.b.c.a.a.a-p4_adder/carry_generator.vhd}
analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/a.b.c.a.a.a-p4_adder/my_xor.vhd}
analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/a.b.c.a.a.a-p4_adder/carry_select_block.vhd}
analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/a.b.c.a.a.a-p4_adder/sum_generator.vhd}
analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/p4_adder.vhd}
#--t2 shifter
##analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/a.b.c.a.a.b-shifter/a.b.c.a.a.b.a-mask_generator/mux21.vhd}
##analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/a.b.c.a.a.b-shifter/a.b.c.a.a.b.a-mask_generator/mux21_generic.vhd}
##analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/a.b.c.a.a.b-shifter/a.b.c.a.a.b.a-mask_generator/mux41.vhd}
##analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/a.b.c.a.a.b-shifter/a.b.c.a.a.b.a-mask_generator/mux41_generic.vhd}
analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/a.b.c.a.a.b-shifter/mux41.vhd}
analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/a.b.c.a.a.b-shifter/mux41_generic.vhd}
analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/a.b.c.a.a.b-shifter/mux81.vhd}
analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/a.b.c.a.a.b-shifter/mux81_generic.vhd}
analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/a.b.c.a.a.b-shifter/mask_generator.vhd}
analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/a.b.c.a.a.b-shifter/mask_shifter.vhd}
analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/shifter.vhd}
#--logicals
analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/a.b.c.a.a.c-logicals/nand31.vhd}
analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/a.b.c.a.a.c-logicals/nand41.vhd}
analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/logicals.vhd}
#--comparator
analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/nor_generic.vhd}
analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.a-ALU/comparator.vhd}

#--multiplier
##analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.b-MUL/a.b.c.a.b.a-p4_adder/carry_generator.vhd}
##analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.b-MUL/a.b.c.a.b.a-p4_adder/carry_select_block.vhd}
##analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.b-MUL/a.b.c.a.b.a-p4_adder/fa.vhd}
##analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.b-MUL/a.b.c.a.b.a-p4_adder/G_block.vhd}
##analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.b-MUL/a.b.c.a.b.a-p4_adder/mux21.vhd}
##analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.b-MUL/a.b.c.a.b.a-p4_adder/mux21_generic.vhd}
##analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.b-MUL/a.b.c.a.b.a-p4_adder/my_xor.vhd}
##analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.b-MUL/a.b.c.a.b.a-p4_adder/PG_block.vhd}
##analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.b-MUL/a.b.c.a.b.a-p4_adder/pg_net.vhd}
##analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.b-MUL/a.b.c.a.b.a-p4_adder/rca_generic.vhd}
##analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.b-MUL/a.b.c.a.b.a-p4_adder/sum_generator.vhd}
analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.b-MUL/mux51.vhd}
##analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.b-MUL/p4_adder.vhd}
analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.b-MUL/enc33.vhd}
analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.b-MUL/negate.vhd}
analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.b-MUL/shl1.vhd}
analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.b-MUL/shl2.vhd}
analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/a.b.c.a.b-MUL/shl3.vhd}

#--EXE
analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/alu.vhd}
analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.c-EXE/a.b.c.a-EXU/BOOTHMUL.vhd}
#analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.c-EXE/mux41.vhd}
#analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.c-EXE/mux41_generic.vhd}
analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.c-EXE/forwarding_unit.vhd}
analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.c-EXE/EXU.vhd}
analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.c-EXE.vhd}

analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.d-MEM/mux51.vhd}
analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.d-MEM/mux51_generic.vhd}
analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.d-MEM/MMU.vhd}
##analyze -library WORK -format vhdl {../DLX_vhd/a.d-DRAM.vhd}
analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.d-MEM.vhd}

##analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.e-WB/mux21.vhd}
##analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.e-WB/mux21_generic.vhd}
analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.core/a.b.e-WB.vhd}

analyze -library WORK -format vhdl {../DLX_vhd/a.b-DataPath.vhd}
##analyze -library WORK -format vhdl {../DLX_vhd/mux21.vhd}
##analyze -library WORK -format vhdl {../DLX_vhd/mux21_generic.vhd}

analyze -library WORK -format vhdl {../DLX_vhd/a-DLX.vhd}

############################################################################
# elaborating the top entity by using a chosen architecture                #
############################################################################

elaborate DLX -architecture STRUCTURAL -library WORK -parameters "MEM_SIZE = 128, WORD_size = 32, NREG = 32"

############################################################################
# set constraints                                                          #
############################################################################

set_wire_load_model -name 5K_hvratio_1_4
create_clock -name "CLK" -period 4 {"CLK"}
set_max_delay 4 -from [all_inputs] -to [all_outputs]
#set_max_dynamic_power 2.0 mW

############################################################################
# compile with optimization                                                #
############################################################################

compile -exact_map -map_effort HIGH

############################################################################
# save reports                                                             #
############################################################################

report_clock > DLX_clock.rpt
report_timing > DLX_timing.rpt
report_timing -nworst 10 > DLX_timing_worst_critical_paths.rpt
report_power > DLX_power.rpt
report_area > DLX_area.rpt

############################################################################
# saving files                                                             #
############################################################################

write -hierarchy -format ddc -output DLX.ddc
write -hierarchy -format vhdl -output DLX.vhdl
write -hierarchy -format verilog -output DLX.v
write_sdc DLX.sdc

