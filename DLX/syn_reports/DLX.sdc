###################################################################

# Created by write_sdc on Wed Oct 20 12:13:14 2021

###################################################################
set sdc_version 1.9

set_units -time ns -resistance MOhm -capacitance fF -voltage V -current mA
set_wire_load_model -name 5K_hvratio_1_4 -library NangateOpenCellLibrary
create_clock [get_ports CLK]  -period 4  -waveform {0 2}
set_max_delay 4  -from [list [get_ports CLK] [get_ports RST] [get_ports {from_DRAM_data[31]}]  \
[get_ports {from_DRAM_data[30]}] [get_ports {from_DRAM_data[29]}] [get_ports   \
{from_DRAM_data[28]}] [get_ports {from_DRAM_data[27]}] [get_ports              \
{from_DRAM_data[26]}] [get_ports {from_DRAM_data[25]}] [get_ports              \
{from_DRAM_data[24]}] [get_ports {from_DRAM_data[23]}] [get_ports              \
{from_DRAM_data[22]}] [get_ports {from_DRAM_data[21]}] [get_ports              \
{from_DRAM_data[20]}] [get_ports {from_DRAM_data[19]}] [get_ports              \
{from_DRAM_data[18]}] [get_ports {from_DRAM_data[17]}] [get_ports              \
{from_DRAM_data[16]}] [get_ports {from_DRAM_data[15]}] [get_ports              \
{from_DRAM_data[14]}] [get_ports {from_DRAM_data[13]}] [get_ports              \
{from_DRAM_data[12]}] [get_ports {from_DRAM_data[11]}] [get_ports              \
{from_DRAM_data[10]}] [get_ports {from_DRAM_data[9]}] [get_ports               \
{from_DRAM_data[8]}] [get_ports {from_DRAM_data[7]}] [get_ports                \
{from_DRAM_data[6]}] [get_ports {from_DRAM_data[5]}] [get_ports                \
{from_DRAM_data[4]}] [get_ports {from_DRAM_data[3]}] [get_ports                \
{from_DRAM_data[2]}] [get_ports {from_DRAM_data[1]}] [get_ports                \
{from_DRAM_data[0]}] [get_ports {IRAM_data[31]}] [get_ports {IRAM_data[30]}]   \
[get_ports {IRAM_data[29]}] [get_ports {IRAM_data[28]}] [get_ports             \
{IRAM_data[27]}] [get_ports {IRAM_data[26]}] [get_ports {IRAM_data[25]}]       \
[get_ports {IRAM_data[24]}] [get_ports {IRAM_data[23]}] [get_ports             \
{IRAM_data[22]}] [get_ports {IRAM_data[21]}] [get_ports {IRAM_data[20]}]       \
[get_ports {IRAM_data[19]}] [get_ports {IRAM_data[18]}] [get_ports             \
{IRAM_data[17]}] [get_ports {IRAM_data[16]}] [get_ports {IRAM_data[15]}]       \
[get_ports {IRAM_data[14]}] [get_ports {IRAM_data[13]}] [get_ports             \
{IRAM_data[12]}] [get_ports {IRAM_data[11]}] [get_ports {IRAM_data[10]}]       \
[get_ports {IRAM_data[9]}] [get_ports {IRAM_data[8]}] [get_ports               \
{IRAM_data[7]}] [get_ports {IRAM_data[6]}] [get_ports {IRAM_data[5]}]          \
[get_ports {IRAM_data[4]}] [get_ports {IRAM_data[3]}] [get_ports               \
{IRAM_data[2]}] [get_ports {IRAM_data[1]}] [get_ports {IRAM_data[0]}]]  -to [list [get_ports {DRAM_addr[8]}] [get_ports {DRAM_addr[7]}] [get_ports    \
{DRAM_addr[6]}] [get_ports {DRAM_addr[5]}] [get_ports {DRAM_addr[4]}]          \
[get_ports {DRAM_addr[3]}] [get_ports {DRAM_addr[2]}] [get_ports               \
{DRAM_addr[1]}] [get_ports {DRAM_addr[0]}] [get_ports {IRAM_addr[7]}]          \
[get_ports {IRAM_addr[6]}] [get_ports {IRAM_addr[5]}] [get_ports               \
{IRAM_addr[4]}] [get_ports {IRAM_addr[3]}] [get_ports {IRAM_addr[2]}]          \
[get_ports {IRAM_addr[1]}] [get_ports {IRAM_addr[0]}] [get_ports               \
{to_DRAM_data[31]}] [get_ports {to_DRAM_data[30]}] [get_ports                  \
{to_DRAM_data[29]}] [get_ports {to_DRAM_data[28]}] [get_ports                  \
{to_DRAM_data[27]}] [get_ports {to_DRAM_data[26]}] [get_ports                  \
{to_DRAM_data[25]}] [get_ports {to_DRAM_data[24]}] [get_ports                  \
{to_DRAM_data[23]}] [get_ports {to_DRAM_data[22]}] [get_ports                  \
{to_DRAM_data[21]}] [get_ports {to_DRAM_data[20]}] [get_ports                  \
{to_DRAM_data[19]}] [get_ports {to_DRAM_data[18]}] [get_ports                  \
{to_DRAM_data[17]}] [get_ports {to_DRAM_data[16]}] [get_ports                  \
{to_DRAM_data[15]}] [get_ports {to_DRAM_data[14]}] [get_ports                  \
{to_DRAM_data[13]}] [get_ports {to_DRAM_data[12]}] [get_ports                  \
{to_DRAM_data[11]}] [get_ports {to_DRAM_data[10]}] [get_ports                  \
{to_DRAM_data[9]}] [get_ports {to_DRAM_data[8]}] [get_ports {to_DRAM_data[7]}] \
[get_ports {to_DRAM_data[6]}] [get_ports {to_DRAM_data[5]}] [get_ports         \
{to_DRAM_data[4]}] [get_ports {to_DRAM_data[3]}] [get_ports {to_DRAM_data[2]}] \
[get_ports {to_DRAM_data[1]}] [get_ports {to_DRAM_data[0]}] [get_ports         \
DRAM_EN] [get_ports DRAM_LnS] [get_ports {MMU_out[1]}] [get_ports              \
{MMU_out[0]}]]
