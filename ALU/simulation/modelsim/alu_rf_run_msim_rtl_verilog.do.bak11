transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Data/GIT/Bananachine/ALU {C:/Data/GIT/Bananachine/ALU/datapath.v}
vlog -vlog01compat -work work +incdir+C:/Data/GIT/Bananachine/ALU {C:/Data/GIT/Bananachine/ALU/alu_rf.v}
vlog -vlog01compat -work work +incdir+C:/Data/GIT/Bananachine/ALU {C:/Data/GIT/Bananachine/ALU/CPU.v}
vlog -vlog01compat -work work +incdir+C:/Data/GIT/Bananachine/ALU {C:/Data/GIT/Bananachine/ALU/muxes.v}
vlog -vlog01compat -work work +incdir+C:/Data/GIT/Bananachine/ALU {C:/Data/GIT/Bananachine/ALU/instruction_reg.v}
vlog -vlog01compat -work work +incdir+C:/Data/GIT/Bananachine/ALU {C:/Data/GIT/Bananachine/ALU/controller.v}
vlog -vlog01compat -work work +incdir+C:/Data/GIT/Bananachine/ALU {C:/Data/GIT/Bananachine/ALU/pc_counter.v}
vlog -vlog01compat -work work +incdir+C:/Data/GIT/Bananachine/ALU {C:/Data/GIT/Bananachine/ALU/Bananachine.v}
vlog -vlog01compat -work work +incdir+C:/Data/GIT/Bananachine/ALU {C:/Data/GIT/Bananachine/ALU/basic_mem.v}
vlog -vlog01compat -work work +incdir+C:/Data/GIT/Bananachine/ALU {C:/Data/GIT/Bananachine/ALU/regfile.v}

vlog -vlog01compat -work work +incdir+C:/Data/GIT/Bananachine/ALU {C:/Data/GIT/Bananachine/ALU/Bananachine_tb.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  Bananachine_tb

add wave *
view structure
view signals
run -all
