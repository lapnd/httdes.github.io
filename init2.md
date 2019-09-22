---
layout : default
---

- [I. Init setup for new machine](./init1.md)
- [II. Install tools](#ii-install-tools)
  * II. a) Scala & sbt
  * II. b) Verilator
  * II. c) QEMU
  * II. d) Vivado 2016.4
- [III. RISC-V Toolchain](./init3.md)
  * III. a) Git clone
  * III. b) Configurations
  * III. c) Make

* * *

# II. Install tools

Some tips for using Github:

	to git clone
	$ git clone <link>				#clone and keep the original name for the cloned folder
	$ git clone <link> <name>			#clone and change the name for the cloned folder
	
	to track your changes
	$ git diff					#list the differences of your folder
	$ git diff <branch-name>			#list the differences of your folder compare to another branch
	$ git diff <src-branch>..<des-branch>		#list the differences between two branches
	$ git diff <commit-hash>			#list the differences of your folder compare to the old commit
	$ git diff <src-commit-hash>..<des-commit-hash>	#list the differences between two commits
	
	to update your folder FROM github
	$ git pull					#pull from the current branch
	$ git pull <branch-name>			#pull from another branch

	to update your folder TO github
	$ git status					#to see changes for commit
	$ git add <file-name> <folder-name>		#first, add every changes of yours
	$ git commit -m "<some message>"		#make a commit with <some message> attached
	$ git push					#this one will push to the current branch, OR
	$ git push <branch-name>			#	push to another branch

	to switch to another branch and commit
	$ git checkout <branch-name>			#switch to another branch
	$ git checkout <commit-hash>			#rollback to the old commit in the same branch
	$ git checkout -b <branch-name> <commit-hash>	#switch to another branch and rollback to the old commit of that branch

	to patch file
	$ git diff > patch-file				#export current changes into a patch-file
	$ git format-patch <src branch or commit>..<des branch or commit> --stdout > patch-file	
	(export a patch-file from <src branch or commit> to <des branch or commit>
	$ patch -p1 < patch-file			#update your folder with the patch-file
	
	to see the status of repo
	$ git log
	$ git log --oneline
	$ git log --all --decorate --oneline --graph

## II. a) Scala & sbt:

The source code for hardware is called the ChiSel coding. And it is written in Scala embedded language.

The sbt is the library & tool for Scala. Sbt is used to generate from the Scala codes to the actual Verilog codes.

First, we need to install the Scala embedded language following the [website](https://www.scala-lang.org/download/). Download the [Deb file](https://downloads.lightbend.com/scala/2.12.9/scala-2.12.9.deb) (version 2.12.9) and install. You can choose another upgraded version of scala at your own risk :)

Then download sbt according to the [website](https://www.scala-sbt.org/release/docs/Installing-sbt-on-Linux.html). Download the [Deb file](https://www.scala-sbt.org/release/docs/Installing-sbt-on-Linux.html) (version 1.2.8) and install.

Finally:

	$ sbt
	this is just for downloading the sbt library for the first time, then type "exit" to exit the sbt terminal

## II. b) Verilator

Verilator is a cycle-accurate behavioral model, and it is used to simulate the Verilog codes at cycle level (like ModelSim).

To install the Verilator:

	stand where you want to install Verilator
	$ git clone http://git.veripool.org/git/verilator
	$ cd verilator
	$ unset VERILATOR_ROOT # For bash, unsetenv for csh
	$ autoconf #this is to create the ./configure script
	$ ./configure #then run the script
	$ make -j`nproc`
	$ make test	#might skip
	$ sudo make install

## II. c) QEMU

QEMU is an emulation tool, not a simulation tool. It does not simulate anything (.v codes, .scala codes, or .c codes, etc.). It emulates the behavioral that a correct CPU should behave. Ref [link](https://github.com/riscv/riscv-qemu/tree/riscv-qemu-4.0.0).

To install the RISC-V QEMU:

	stand where you want to install RISC-V QEMU
	$ git clone https://github.com/riscv/riscv-qemu.git
	$ cd riscv-qemu/
	$ git checkout riscv-qemu-4.0.0		#commit 62a172e on 19-Mar-2019
	$ git submodule update --init --recursive
	$ mkdir build
	$ cd build
	$ ../configure
	$ make -j`nproc`
	
## II. d) Vivado 2016.4

(because the VC707 project now can compatible only with the 2016.4 version of Vivado)

### Check your eth0 interface

Type "$ ifconfig -a" to make sure that the network interface name is 'eth0'. If not, the Vivado cannot recognize the license from the NAT interface. Then, the network interface name must be rename by:

	$ sudo vi /etc/default/grub
	
	Then add this line beneath those GRUB... lines:
		GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0"
	
	Then:
	$ sudo grub-mkconfig -o /boot/grub/grub.cfg

Finally, reboot again for the computer to update the new ethernet interface.

### Download and Install

First, download the Vivado 2016.4 from Xilinx [website](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/archive.html): (linux .bin file self extract):

Then, cd to the downloaded .bin file and run:

	$ chmod +x Xilinx_....bin
	$ sudo ./Xilinx_....bin

The GUI for installation will be load. Choose to install the Vivado HL Design Edition and wait for the installer to complete.

Install cable driver:

	cd to Vivado installed folder:
	$ cd ...Xilinx/Vivado/2016.4/data/xicom/cable_drivers/lin64/install_script/install_drivers/
	$ sudo ./install_drivers

* * *

| [*back: I. Init setup for new machine*](./init1.md) | [*next: III. RISC-V Toolchain*](./init3.md) |
| :--- | :--- |
||

