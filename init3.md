---
layout : default
---

- [I. Init setup for new machine](./init1.md)
- [II. Install tools](./init2.md)
  * II. a) Scala & sbt
  * II. b) Verilator
  * II. c) QEMU
  * II. d) Vivado 2016.4
- [III. RISC-V Toolchain](#iii-risc-v-toolchain)
  * III. a) Git clone
  * III. b) Configurations
  * III. c) Make

* * *

# III. RISC-V toolchain

Toolchain for RISC-V CPU. Ref [link](https://github.com/riscv/riscv-gnu-toolchain).

## III. a) Git clone

Git clone the toolchain-making on github:

	$ git clone https://github.com/riscv/riscv-gnu-toolchain
	$ cd riscv-gnu-toolchain	#brach master commit a03290ea (gcc 9.2) on 22-Aug-2019
	$ git submodule update --init --recursive

## III. b) Configurations

The configuration command format:

	$ ./configure --prefix=[path] --with-arch=[arch]
	
The **[path]** is where you want to store your generated toolchain.

The **[arch]** is the RISC-V architecture that you want. To be specific:

 * **rv64** and **rv32** respectively specify the 64-bit and 32-bit instruction set options.
 * These characters **i**, **a**, **m**, **f**, **d**, **c**, and **g** are respectively stand for the instruction extensions of (*i*)nteger, (*a*)tomic, (*m*)ultiplication & division, (*f*)loating-point, (*d*)ouble floating-point, (*c*)ompress, and (*g*)eneral (general = *imafd*).
 
For example, to generate toolchain for a general 64-bit RISC-V CPU, you can write like this:

	$ ./configure --prefix=/opt/riscv64gc --with-arch=rv64gc

Or for a general 32-bit RISC-V CPU:

	$ ./configure --prefix=/opt/riscv32gc --with-arch=rv32gc

## III. c) Make

After install the dependencies, clone the toolchain-making folder, and set the configurations, now you can 'make' the toolchain by:
	
	for elf-toolchain (or baremetal toolchain) to run directly on the CPU (like MCU)
	$ sudo make -j`nproc`
	
	for linux-toolchain to run on the Linux that run on the CPU (like OS app) 
	$ sudo make linux -j`nproc`

* * *

| [*back: II. Install tools*](./init2.md) | [*next: Keystone guide*](./keystone1.md) |
| :--- | :--- |
||

