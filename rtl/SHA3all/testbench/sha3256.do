onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group port -color Yellow /test256/clk
add wave -noupdate -expand -group port -color Yellow /test256/reset
add wave -noupdate -expand -group port -color Yellow /test256/start
add wave -noupdate -expand -group port -color Yellow /test256/squeeze
add wave -noupdate -expand -group port /test256/mode_sel
add wave -noupdate -expand -group port -radix unsigned /test256/bitlen
add wave -noupdate -expand -group port /test256/din64
add wave -noupdate -expand -group port -color Yellow /test256/hash_ready
add wave -noupdate -expand -group port -color Yellow /test256/flag
add wave -noupdate -expand -group port -color Cyan /test256/clk
add wave -noupdate -expand -group port /test256/dout32
add wave -noupdate -expand -group port -color Yellow /test256/sha3_ready
add wave -noupdate -expand -group port -color Yellow /test256/md_valid
add wave -noupdate -expand -group port -color Yellow /test256/valid_32
add wave -noupdate -label sim:/test256/inst_sha3_core/uut/Group1 -group {Region: sim:/test256/inst_sha3_core/uut} -color Yellow /test256/inst_sha3_core/uut/reset
add wave -noupdate -label sim:/test256/inst_sha3_core/uut/Group1 -group {Region: sim:/test256/inst_sha3_core/uut} /test256/inst_sha3_core/uut/din64
add wave -noupdate -label sim:/test256/inst_sha3_core/uut/Group1 -group {Region: sim:/test256/inst_sha3_core/uut} -color Yellow /test256/inst_sha3_core/uut/hash_ready
add wave -noupdate -label sim:/test256/inst_sha3_core/uut/Group1 -group {Region: sim:/test256/inst_sha3_core/uut} -color Yellow /test256/inst_sha3_core/uut/flag
add wave -noupdate -label sim:/test256/inst_sha3_core/uut/Group1 -group {Region: sim:/test256/inst_sha3_core/uut} -color Cyan /test256/inst_sha3_core/uut/clk
add wave -noupdate -label sim:/test256/inst_sha3_core/uut/Group1 -group {Region: sim:/test256/inst_sha3_core/uut} -radix hexadecimal /test256/inst_sha3_core/uut/dout
add wave -noupdate -label sim:/test256/inst_sha3_core/uut/Group1 -group {Region: sim:/test256/inst_sha3_core/uut} /test256/inst_sha3_core/uut/test_dout
add wave -noupdate -group test_dout {/test256/inst_sha3_core/uut/test_dout[0]}
add wave -noupdate -group test_dout {/test256/inst_sha3_core/uut/test_dout[1]}
add wave -noupdate -group test_dout {/test256/inst_sha3_core/uut/test_dout[2]}
add wave -noupdate -group test_dout {/test256/inst_sha3_core/uut/test_dout[3]}
add wave -noupdate -group test_dout {/test256/inst_sha3_core/uut/test_dout[4]}
add wave -noupdate -group test_dout {/test256/inst_sha3_core/uut/test_dout[5]}
add wave -noupdate -group test_dout {/test256/inst_sha3_core/uut/test_dout[6]}
add wave -noupdate -group test_dout {/test256/inst_sha3_core/uut/test_dout[7]}
add wave -noupdate -group test_dout {/test256/inst_sha3_core/uut/test_dout[8]}
add wave -noupdate -label sim:/test256/inst_sha3_core/init_padding/Group1 -group {Region: sim:/test256/inst_sha3_core/init_padding} -radix unsigned /test256/inst_sha3_core/init_padding/RATEBITS
add wave -noupdate -label sim:/test256/inst_sha3_core/init_padding/Group1 -group {Region: sim:/test256/inst_sha3_core/init_padding} -radix unsigned /test256/inst_sha3_core/init_padding/bitlen_i
add wave -noupdate -label sim:/test256/inst_sha3_core/init_padding/Group1 -group {Region: sim:/test256/inst_sha3_core/init_padding} /test256/inst_sha3_core/init_padding/a_string
add wave -noupdate -label sim:/test256/inst_sha3_core/init_padding/Group1 -group {Region: sim:/test256/inst_sha3_core/init_padding} -color Cyan /test256/inst_sha3_core/uut/clk
add wave -noupdate -label sim:/test256/inst_sha3_core/init_padding/Group1 -group {Region: sim:/test256/inst_sha3_core/init_padding} /test256/inst_sha3_core/init_padding/a_array
add wave -noupdate -group a_array {/test256/inst_sha3_core/init_padding/a_array[0]}
add wave -noupdate -group a_array {/test256/inst_sha3_core/init_padding/a_array[1]}
add wave -noupdate -group a_array {/test256/inst_sha3_core/init_padding/a_array[2]}
add wave -noupdate -group a_array {/test256/inst_sha3_core/init_padding/a_array[3]}
add wave -noupdate -group a_array {/test256/inst_sha3_core/init_padding/a_array[4]}
add wave -noupdate -group a_array {/test256/inst_sha3_core/init_padding/a_array[5]}
add wave -noupdate -group a_array {/test256/inst_sha3_core/init_padding/a_array[6]}
add wave -noupdate -group a_array {/test256/inst_sha3_core/init_padding/a_array[7]}
add wave -noupdate -group a_array {/test256/inst_sha3_core/init_padding/a_array[8]}
add wave -noupdate -expand -label sim:/test256/inst_sha3_core/Group1 -group {Region: sim:/test256/inst_sha3_core} -color Cyan /test256/inst_sha3_core/ready_o
add wave -noupdate -expand -label sim:/test256/inst_sha3_core/Group1 -group {Region: sim:/test256/inst_sha3_core} -color Yellow /test256/inst_sha3_core/start
add wave -noupdate -expand -label sim:/test256/inst_sha3_core/Group1 -group {Region: sim:/test256/inst_sha3_core} -color Yellow /test256/inst_sha3_core/start_reg
add wave -noupdate -expand -label sim:/test256/inst_sha3_core/Group1 -group {Region: sim:/test256/inst_sha3_core} -color Yellow /test256/inst_sha3_core/round_tc
add wave -noupdate -expand -label sim:/test256/inst_sha3_core/Group1 -group {Region: sim:/test256/inst_sha3_core} -color Yellow /test256/inst_sha3_core/ena
add wave -noupdate -expand -label sim:/test256/inst_sha3_core/Group1 -group {Region: sim:/test256/inst_sha3_core} -radix unsigned /test256/inst_sha3_core/round
add wave -noupdate -expand -label sim:/test256/inst_sha3_core/Group1 -group {Region: sim:/test256/inst_sha3_core} -color Yellow /test256/inst_sha3_core/md_valid
add wave -noupdate -expand -label sim:/test256/inst_sha3_core/Group1 -group {Region: sim:/test256/inst_sha3_core} -color Yellow /test256/inst_sha3_core/md_ack_i
add wave -noupdate -expand -label sim:/test256/inst_sha3_core/Group1 -group {Region: sim:/test256/inst_sha3_core} -color Magenta /test256/inst_sha3_core/md_last
add wave -noupdate -expand -label sim:/test256/inst_sha3_core/Group1 -group {Region: sim:/test256/inst_sha3_core} -color Magenta /test256/inst_sha3_core/init
add wave -noupdate -expand -label sim:/test256/inst_sha3_core/Group1 -group {Region: sim:/test256/inst_sha3_core} -color Yellow /test256/inst_sha3_core/init_reg
add wave -noupdate -expand -label sim:/test256/inst_sha3_core/Group1 -group {Region: sim:/test256/inst_sha3_core} -color Yellow /test256/inst_sha3_core/squeeze
add wave -noupdate -expand -label sim:/test256/inst_sha3_core/Group1 -group {Region: sim:/test256/inst_sha3_core} -color Yellow /test256/inst_sha3_core/squeeze_reg
add wave -noupdate -expand -group string /test256/inst_sha3_core/string_xor_state
add wave -noupdate -expand -group string /test256/inst_sha3_core/a_string
add wave -noupdate -expand -group string /test256/inst_sha3_core/state_reg
add wave -noupdate -expand -label sim:/test256/inst_sha3_core/uut256to32/Group1 -group {Region: sim:/test256/inst_sha3_core/uut256to32} -color Yellow /test256/inst_sha3_core/uut256to32/clk
add wave -noupdate -expand -label sim:/test256/inst_sha3_core/uut256to32/Group1 -group {Region: sim:/test256/inst_sha3_core/uut256to32} -color Yellow /test256/inst_sha3_core/uut256to32/reset
add wave -noupdate -expand -label sim:/test256/inst_sha3_core/uut256to32/Group1 -group {Region: sim:/test256/inst_sha3_core/uut256to32} /test256/inst_sha3_core/uut256to32/dout32
add wave -noupdate -expand -label sim:/test256/inst_sha3_core/uut256to32/Group1 -group {Region: sim:/test256/inst_sha3_core/uut256to32} /test256/inst_sha3_core/uut256to32/dout256
add wave -noupdate -expand -label sim:/test256/inst_sha3_core/uut256to32/Group1 -group {Region: sim:/test256/inst_sha3_core/uut256to32} -color Yellow /test256/inst_sha3_core/uut256to32/md_valid_o
add wave -noupdate -expand -label sim:/test256/inst_sha3_core/uut256to32/Group1 -group {Region: sim:/test256/inst_sha3_core/uut256to32} -color Yellow /test256/inst_sha3_core/uut256to32/q
add wave -noupdate -expand -label sim:/test256/inst_sha3_core/uut256to32/Group1 -group {Region: sim:/test256/inst_sha3_core/uut256to32} -radix unsigned /test256/inst_sha3_core/uut256to32/N
add wave -noupdate -expand -label sim:/test256/inst_sha3_core/uut256to32/Group1 -group {Region: sim:/test256/inst_sha3_core/uut256to32} -radix unsigned /test256/inst_sha3_core/uut256to32/i
add wave -noupdate -expand -label sim:/test256/inst_sha3_core/uut256to32/Group1 -group {Region: sim:/test256/inst_sha3_core/uut256to32} /test256/inst_sha3_core/uut256to32/otemp
add wave -noupdate -expand -label sim:/test256/inst_sha3_core/uut256to32/Group1 -group {Region: sim:/test256/inst_sha3_core/uut256to32} /test256/inst_sha3_core/uut256to32/r_dout32
add wave -noupdate -expand -label sim:/test256/inst_sha3_core/uut256to32/Group1 -group {Region: sim:/test256/inst_sha3_core/uut256to32} -color Yellow /test256/inst_sha3_core/uut256to32/valid
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2303426 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 134
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {2174233 ps} {2518109 ps}
