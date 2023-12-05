transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/intelFPGA_lite/18.1/Bananachine/ALU {C:/intelFPGA_lite/18.1/Bananachine/ALU/vga_control.v}
vlog -vlog01compat -work work +incdir+C:/intelFPGA_lite/18.1/Bananachine/ALU {C:/intelFPGA_lite/18.1/Bananachine/ALU/bit_gen.v}
vlog -vlog01compat -work work +incdir+C:/intelFPGA_lite/18.1/Bananachine/ALU {C:/intelFPGA_lite/18.1/Bananachine/ALU/rom_async.v}
vlog -vlog01compat -work work +incdir+C:/intelFPGA_lite/18.1/Bananachine/ALU {C:/intelFPGA_lite/18.1/Bananachine/ALU/sprite.v}
vlog -vlog01compat -work work +incdir+C:/intelFPGA_lite/18.1/Bananachine/ALU {C:/intelFPGA_lite/18.1/Bananachine/ALU/bananachine.v}
vlog -vlog01compat -work work +incdir+C:/intelFPGA_lite/18.1/Bananachine/ALU {C:/intelFPGA_lite/18.1/Bananachine/ALU/cpu.v}
vlog -vlog01compat -work work +incdir+C:/intelFPGA_lite/18.1/Bananachine/ALU {C:/intelFPGA_lite/18.1/Bananachine/ALU/datapath.v}
vlog -vlog01compat -work work +incdir+C:/intelFPGA_lite/18.1/Bananachine/ALU {C:/intelFPGA_lite/18.1/Bananachine/ALU/alu_rf.v}
vlog -vlog01compat -work work +incdir+C:/intelFPGA_lite/18.1/Bananachine/ALU {C:/intelFPGA_lite/18.1/Bananachine/ALU/muxes.v}
vlog -vlog01compat -work work +incdir+C:/intelFPGA_lite/18.1/Bananachine/ALU {C:/intelFPGA_lite/18.1/Bananachine/ALU/instruction_reg.v}
vlog -vlog01compat -work work +incdir+C:/intelFPGA_lite/18.1/Bananachine/ALU {C:/intelFPGA_lite/18.1/Bananachine/ALU/controller.v}
vlog -vlog01compat -work work +incdir+C:/intelFPGA_lite/18.1/Bananachine/ALU {C:/intelFPGA_lite/18.1/Bananachine/ALU/pc_counter.v}
vlog -vlog01compat -work work +incdir+C:/intelFPGA_lite/18.1/Bananachine/ALU {C:/intelFPGA_lite/18.1/Bananachine/ALU/vga.v}
vlog -vlog01compat -work work +incdir+C:/intelFPGA_lite/18.1/Bananachine/ALU {C:/intelFPGA_lite/18.1/Bananachine/ALU/vga_counter.v}
vlog -vlog01compat -work work +incdir+C:/intelFPGA_lite/18.1/Bananachine/ALU {C:/intelFPGA_lite/18.1/Bananachine/ALU/reg_file.v}
vlog -vlog01compat -work work +incdir+C:/intelFPGA_lite/18.1/Bananachine/ALU {C:/intelFPGA_lite/18.1/Bananachine/ALU/basic_mem.v}
vlog -vlog01compat -work work +incdir+C:/intelFPGA_lite/18.1/Bananachine/ALU {C:/intelFPGA_lite/18.1/Bananachine/ALU/clut_mem.v}

vlog -vlog01compat -work work +incdir+C:/intelFPGA_lite/18.1/Bananachine/ALU {C:/intelFPGA_lite/18.1/Bananachine/ALU/vga_tb.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  vga_tb

add wave *
view structure
view signals
run -all
