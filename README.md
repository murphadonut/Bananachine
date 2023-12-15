
# Bananachine

A very simplified computer to run a Doodle Jump inspired game that uses a monkey and bananas. 
## Files Submitted
- letter_f.mem: Test sprite to get vga working
- letter_m.mem: Another test sprite.
- monke.mem: Actual monkey sprite used in game.
- pallete.mem: A color pallete for the sprites.
- reg.dat: Register file, initialized to all zeros.
- reg_file.v: Uses reg.dat to store values to various registers.
- rom_async.v: Memory to store sprite files.
- real_banana.mem: 16 by 16 bits representation of a banana.
- vga.v: Container class for bit_gen, really could have been bypassed.
- vga_tb.v: Testbench for vga, mainly used to view timings.
- vga_counter.v: Counter to cycle through the six position values used for the sprite positions.
- vga_control.v: Timings for vga
- true_dual_port_ram_single_clock.v: Final memory module, copied directly from Quartus template.
- sprite.v: Reads sprite image file and outputs a single color based on where the vga beam is at the time.
- pc_counter.v: Used to increment the program counter by one if pc_src is set to 2
- muxes.v: Various mux modules and flip flop modules
- memory.dat: Assembly code that runs the game. 
- instruciton_reg.v: Holds instruction value over a single cycle
- datapathFSM.v: Test module used to test the datapath.
- datapath.v: Datapath module that connects everything in the datapath.
- cpu.v: Connects the datapath and controller together
- controller.v: Controller module used in the datapath.
- clut_mem.v: Memory to load color pallete in
- bitgen_tb.v: Testbench for bit_gen
- bit_gen.v: Combines vga_control with sprite.
- bin2bcd.v: Used to convert binary to decimal numbers.
- bananachine.v: Main top level module, instantiates memory and CPU
- bananachine_tb.v: Testbench for viewing all events in the Bananachine
- banana.txt: Text format of the assembly code with comments.
- alu_rf.v: ALU module, instantiated by the data path
- alu_rf_tb.v: Testbench for testing basic ALU functions.
## Authors

- [@murphadonut](https://www.github.com/murphadonut)
- [@Cromie1](https://github.com/Cromie1)
- [@kylakunz](https://github.com/kylakunz)
- [@Mickey-Cloud](https://github.com/Mickey-Cloud)

