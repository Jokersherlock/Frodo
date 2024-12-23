vlib work
vmap work work
#vlog  -work work glbl.v

#library
#vlog  -work work ../../library/artix7/*.v

#IP
#vlog  -work work ../../../source_code/ROM_IP/rom_controller.v

#SourceCode
vlog  -work work ../design/*.v

#Testbench
vlog  -work work test256.v 

#vsim -voptargs=+acc -L unisims_ver -L unisim -L work -Lf unisims_ver work.glbl work.test256
vsim -voptargs=+acc -L work -Lf work.test256
vsim work.test256

#Add signal into wave window
do wave.do

run -all
