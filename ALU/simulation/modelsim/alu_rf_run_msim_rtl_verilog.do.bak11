transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/intelFPGA_lite/18.1/Bananachine/ALU {C:/intelFPGA_lite/18.1/Bananachine/ALU/Sprite.v}
vlog -vlog01compat -work work +incdir+C:/intelFPGA_lite/18.1/Bananachine/ALU {C:/intelFPGA_lite/18.1/Bananachine/ALU/Sprite_Rom.v}
vlog -vlog01compat -work work +incdir+C:/intelFPGA_lite/18.1/Bananachine/ALU {C:/intelFPGA_lite/18.1/Bananachine/ALU/BitGen.v}
vlog -vlog01compat -work work +incdir+C:/intelFPGA_lite/18.1/Bananachine/ALU {C:/intelFPGA_lite/18.1/Bananachine/ALU/vga.v}
vlog -vlog01compat -work work +incdir+C:/intelFPGA_lite/18.1/Bananachine/ALU {C:/intelFPGA_lite/18.1/Bananachine/ALU/VgaControl.v}

vlog -vlog01compat -work work +incdir+C:/intelFPGA_lite/18.1/Bananachine/ALU {C:/intelFPGA_lite/18.1/Bananachine/ALU/Bananachine_tb.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  Bananachine_tb

add wave *
view structure
view signals
run -all
