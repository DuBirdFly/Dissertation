transcript on
if ![file isdirectory verilog_libs] {
	file mkdir verilog_libs
}

vlib verilog_libs/altera_ver
vmap altera_ver ./verilog_libs/altera_ver
vlog -vlog01compat -work altera_ver {d:/edatools/quartus18/quartus/eda/sim_lib/altera_primitives.v}

vlib verilog_libs/lpm_ver
vmap lpm_ver ./verilog_libs/lpm_ver
vlog -vlog01compat -work lpm_ver {d:/edatools/quartus18/quartus/eda/sim_lib/220model.v}

vlib verilog_libs/sgate_ver
vmap sgate_ver ./verilog_libs/sgate_ver
vlog -vlog01compat -work sgate_ver {d:/edatools/quartus18/quartus/eda/sim_lib/sgate.v}

vlib verilog_libs/altera_mf_ver
vmap altera_mf_ver ./verilog_libs/altera_mf_ver
vlog -vlog01compat -work altera_mf_ver {d:/edatools/quartus18/quartus/eda/sim_lib/altera_mf.v}

vlib verilog_libs/altera_lnsim_ver
vmap altera_lnsim_ver ./verilog_libs/altera_lnsim_ver
vlog -sv -work altera_lnsim_ver {d:/edatools/quartus18/quartus/eda/sim_lib/altera_lnsim.sv}

vlib verilog_libs/cycloneive_ver
vmap cycloneive_ver ./verilog_libs/cycloneive_ver
vlog -vlog01compat -work cycloneive_ver {d:/edatools/quartus18/quartus/eda/sim_lib/cycloneive_atoms.v}

if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/PrjWorkspace/Dissertation/version/v2/rtl/mid/seg_dynamic {D:/PrjWorkspace/Dissertation/version/v2/rtl/mid/seg_dynamic/seg_dynamic.v}
vlog -vlog01compat -work work +incdir+D:/PrjWorkspace/Dissertation/version/v2/rtl/mid/seg_dynamic {D:/PrjWorkspace/Dissertation/version/v2/rtl/mid/seg_dynamic/binary_8421.v}
vlog -vlog01compat -work work +incdir+D:/PrjWorkspace/Dissertation/version/v2/rtl/canny/otus {D:/PrjWorkspace/Dissertation/version/v2/rtl/canny/otus/otus_dsp.v}
vlog -vlog01compat -work work +incdir+D:/PrjWorkspace/Dissertation/version/v2/rtl/canny/otus {D:/PrjWorkspace/Dissertation/version/v2/rtl/canny/otus/otus.v}
vlog -vlog01compat -work work +incdir+D:/PrjWorkspace/Dissertation/version/v2/rtl/canny/otus {D:/PrjWorkspace/Dissertation/version/v2/rtl/canny/otus/histo.v}
vlog -vlog01compat -work work +incdir+D:/PrjWorkspace/Dissertation/version/v2/rtl/mid {D:/PrjWorkspace/Dissertation/version/v2/rtl/mid/get_NegPos.v}
vlog -vlog01compat -work work +incdir+D:/PrjWorkspace/Dissertation/version/v2/rtl/canny {D:/PrjWorkspace/Dissertation/version/v2/rtl/canny/canny5_DTM.v}
vlog -vlog01compat -work work +incdir+D:/PrjWorkspace/Dissertation/version/v2/rtl/canny {D:/PrjWorkspace/Dissertation/version/v2/rtl/canny/canny4_NMS.v}
vlog -vlog01compat -work work +incdir+D:/PrjWorkspace/Dissertation/version/v2/rtl/canny {D:/PrjWorkspace/Dissertation/version/v2/rtl/canny/opr_3x3_1024x8.v}
vlog -vlog01compat -work work +incdir+D:/PrjWorkspace/Dissertation/version/v2/rtl/canny {D:/PrjWorkspace/Dissertation/version/v2/rtl/canny/canny3_sobel.v}
vlog -vlog01compat -work work +incdir+D:/PrjWorkspace/Dissertation/version/v2/rtl/canny {D:/PrjWorkspace/Dissertation/version/v2/rtl/canny/canny2_gaus.v}
vlog -vlog01compat -work work +incdir+D:/PrjWorkspace/Dissertation/version/v2/rtl/canny {D:/PrjWorkspace/Dissertation/version/v2/rtl/canny/canny1_YCbCr.v}
vlog -vlog01compat -work work +incdir+D:/PrjWorkspace/Dissertation/version/v2/rtl/canny {D:/PrjWorkspace/Dissertation/version/v2/rtl/canny/canny_top.v}
vlog -vlog01compat -work work +incdir+D:/PrjWorkspace/Dissertation/version/v2/rtl/cmos/i2c {D:/PrjWorkspace/Dissertation/version/v2/rtl/cmos/i2c/i2c_master_top.v}
vlog -vlog01compat -work work +incdir+D:/PrjWorkspace/Dissertation/version/v2/rtl/cmos/i2c {D:/PrjWorkspace/Dissertation/version/v2/rtl/cmos/i2c/i2c_master_defines.v}
vlog -vlog01compat -work work +incdir+D:/PrjWorkspace/Dissertation/version/v2/rtl/ip/fifo {D:/PrjWorkspace/Dissertation/version/v2/rtl/ip/fifo/afifo_16_512.v}
vlog -vlog01compat -work work +incdir+D:/PrjWorkspace/Dissertation/version/v2/rtl {D:/PrjWorkspace/Dissertation/version/v2/rtl/top.v}
vlog -vlog01compat -work work +incdir+D:/PrjWorkspace/Dissertation/version/v2/rtl/vga {D:/PrjWorkspace/Dissertation/version/v2/rtl/vga/video_define.v}
vlog -vlog01compat -work work +incdir+D:/PrjWorkspace/Dissertation/version/v2/rtl/vga {D:/PrjWorkspace/Dissertation/version/v2/rtl/vga/rgb565_gen.v}
vlog -vlog01compat -work work +incdir+D:/PrjWorkspace/Dissertation/version/v2/rtl/sdram {D:/PrjWorkspace/Dissertation/version/v2/rtl/sdram/sdram_core.v}
vlog -vlog01compat -work work +incdir+D:/PrjWorkspace/Dissertation/version/v2/rtl/sdram {D:/PrjWorkspace/Dissertation/version/v2/rtl/sdram/frame_read_write.v}
vlog -vlog01compat -work work +incdir+D:/PrjWorkspace/Dissertation/version/v2/rtl/sdram {D:/PrjWorkspace/Dissertation/version/v2/rtl/sdram/frame_fifo_write.v}
vlog -vlog01compat -work work +incdir+D:/PrjWorkspace/Dissertation/version/v2/rtl/sdram {D:/PrjWorkspace/Dissertation/version/v2/rtl/sdram/frame_fifo_read.v}
vlog -vlog01compat -work work +incdir+D:/PrjWorkspace/Dissertation/version/v2/rtl/mid {D:/PrjWorkspace/Dissertation/version/v2/rtl/mid/cmos_write_req_gen.v}
vlog -vlog01compat -work work +incdir+D:/PrjWorkspace/Dissertation/version/v2/rtl/ip/pll {D:/PrjWorkspace/Dissertation/version/v2/rtl/ip/pll/video_pll.v}
vlog -vlog01compat -work work +incdir+D:/PrjWorkspace/Dissertation/version/v2/rtl/ip/pll {D:/PrjWorkspace/Dissertation/version/v2/rtl/ip/pll/sys_pll.v}
vlog -vlog01compat -work work +incdir+D:/PrjWorkspace/Dissertation/version/v2/rtl/cmos {D:/PrjWorkspace/Dissertation/version/v2/rtl/cmos/lut_ov5640_rgb565_1024_768.v}
vlog -vlog01compat -work work +incdir+D:/PrjWorkspace/Dissertation/version/v2/rtl/cmos {D:/PrjWorkspace/Dissertation/version/v2/rtl/cmos/i2c_config.v}
vlog -vlog01compat -work work +incdir+D:/PrjWorkspace/Dissertation/version/v2/rtl/cmos {D:/PrjWorkspace/Dissertation/version/v2/rtl/cmos/cmos_8_16bit.v}
vlog -vlog01compat -work work +incdir+D:/PrjWorkspace/Dissertation/version/v2/rtl/ip/shift {D:/PrjWorkspace/Dissertation/version/v2/rtl/ip/shift/shift1024x8.v}
vlog -vlog01compat -work work +incdir+D:/PrjWorkspace/Dissertation/version/v2/rtl/ip/ram {D:/PrjWorkspace/Dissertation/version/v2/rtl/ip/ram/ram2p_128x20b.v}
vlog -vlog01compat -work work +incdir+D:/PrjWorkspace/Dissertation/version/v2/rtl/ip/lpm_div {D:/PrjWorkspace/Dissertation/version/v2/rtl/ip/lpm_div/div_23_16.v}
vlog -vlog01compat -work work +incdir+D:/PrjWorkspace/Dissertation/version/v2/rtl/ip/lpm_mult {D:/PrjWorkspace/Dissertation/version/v2/rtl/ip/lpm_mult/mul_32_32.v}
vlog -vlog01compat -work work +incdir+D:/PrjWorkspace/Dissertation/version/v2/prj/db {D:/PrjWorkspace/Dissertation/version/v2/prj/db/sys_pll_altpll.v}
vlog -vlog01compat -work work +incdir+D:/PrjWorkspace/Dissertation/version/v2/prj/db {D:/PrjWorkspace/Dissertation/version/v2/prj/db/video_pll_altpll.v}
vlog -vlog01compat -work work +incdir+D:/PrjWorkspace/Dissertation/version/v2/rtl/cmos/i2c {D:/PrjWorkspace/Dissertation/version/v2/rtl/cmos/i2c/i2c_master_byte_ctrl.v}
vlog -vlog01compat -work work +incdir+D:/PrjWorkspace/Dissertation/version/v2/rtl/cmos/i2c {D:/PrjWorkspace/Dissertation/version/v2/rtl/cmos/i2c/i2c_master_bit_ctrl.v}
vlog -vlog01compat -work work +incdir+D:/PrjWorkspace/Dissertation/version/v2/rtl/vga {D:/PrjWorkspace/Dissertation/version/v2/rtl/vga/color_bar.v}

vlog -vlog01compat -work work +incdir+D:/PrjWorkspace/Dissertation/version/v2/prj/../tb/tb {D:/PrjWorkspace/Dissertation/version/v2/prj/../tb/tb/tb_median_filtering.v}
vlog -vlog01compat -work work +incdir+D:/PrjWorkspace/Dissertation/version/v2/prj/../tb/my_ip/fifo {D:/PrjWorkspace/Dissertation/version/v2/prj/../tb/my_ip/fifo/sfifo.v}
vlog -vlog01compat -work work +incdir+D:/PrjWorkspace/Dissertation/version/v2/prj/../tb/my_ip/med_filter {D:/PrjWorkspace/Dissertation/version/v2/prj/../tb/my_ip/med_filter/median_filtering.v}
vlog -vlog01compat -work work +incdir+D:/PrjWorkspace/Dissertation/version/v2/prj/../tb/my_ip/med_filter {D:/PrjWorkspace/Dissertation/version/v2/prj/../tb/my_ip/med_filter/sort.v}
vlog -vlog01compat -work work +incdir+D:/PrjWorkspace/Dissertation/version/v2/prj/../tb/my_ip/shift {D:/PrjWorkspace/Dissertation/version/v2/prj/../tb/my_ip/shift/opr_3x3.v}
vlog -vlog01compat -work work +incdir+D:/PrjWorkspace/Dissertation/version/v2/prj/../tb/my_ip/shift {D:/PrjWorkspace/Dissertation/version/v2/prj/../tb/my_ip/shift/shift_1x3.v}
vlog -vlog01compat -work work +incdir+D:/PrjWorkspace/Dissertation/version/v2/prj/../tb/devide {D:/PrjWorkspace/Dissertation/version/v2/prj/../tb/devide/gray_gen.v}
vlog -vlog01compat -work work +incdir+D:/PrjWorkspace/Dissertation/version/v2/prj/../tb/devide {D:/PrjWorkspace/Dissertation/version/v2/prj/../tb/devide/my_color_bar.v}
vlog -vlog01compat -work work +incdir+D:/PrjWorkspace/Dissertation/version/v2/prj/../tb/devide {D:/PrjWorkspace/Dissertation/version/v2/prj/../tb/devide/my_video_define.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  tb_median_filtering

add wave *
view structure
view signals
run -all
