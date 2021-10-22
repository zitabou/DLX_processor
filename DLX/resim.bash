rm -r work
rm transcript
rm vsim.wlf

#reset DRAM
cp -v dram_empty.mem dram.mem

setmentor
vlib work
vsim
