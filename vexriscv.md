---
layout : default
---

# VEXRISCV 32-bit MCU

* * *

# I. VexRiscv CPU

VexRiscv CPU is a 5-stage 32-bit RISC-V CPU.

Original [repo](https://github.com/thuchoang90/VexRiscv). Modified [repo](https://github.com/SpinalHDL/VexRiscv)

## I. a) Make

First, git clone the folder:

	$ git clone https://github.com/thuchoang90/VexRiscv.git		#branch master commit ?? on ??
	$ cd VexRiscv/
	$ git submodule update --init --recursive

VexRiscv CPU has many build options:

	$ cd VexRiscv/			#go to your VexRiscv folder
	
	for smallest CPU:	$ sbt "runMain vexriscv.demo.GenSmallest"
	for GenFull CPU:	$ sbt "runMain vexriscv.demo.GenFull"
	for Linux CPU:	$ sbt "runMain vexriscv.demo.LinuxGen"
	for Briey SoC		$ sbt "runMain vexriscv.demo.Briey"		#GenFull CPU + bus + devices + IO

## I. b) SpinalHDL source-code library

VexRiscv CPUs are constructed based on the SpinalHDL library. Ref [link](https://github.com/SpinalHDL/SpinalHDL).

Actually, this library is downloaded and embedded into the system automatically while we are generating CPUs at those steps above. However, because it is hard to navigate the sources in an embedded library, it is recommended to git clone the library again in a separated folder for more accessible to search for the library source codes.

	$ git clone https://github.com/SpinalHDL/SpinalHDL.git		#branch master commit 
	$ cd SpinalHDL/
	$ git submodule update --init --recursive
	(the library source-code are under the folder: lib/src/main/scala/spinal/lib/)

## I. c) Regression test

Self-test using Verilator:

	$ cd VexRiscv/	#go to your VexRiscv folder
	$ cd src/test/cpp/regression/

	for GenSmallest:	$ make clean run IBUS=SIMPLE DBUS=SIMPLE CSR=no MMU=no DEBUG_PLUGIN=no MUL=no DIV=no
	for GenFull:		$ make clean run
	for LinuxGen:		$ make clean run IBUS=CACHED DBUS=CACHED DEBUG_PLUGIN=STD DHRYSTONE=yes SUPERVISOR=yes MMU=yes CSR=yes DEBUG_PLUGIN=no COMPRESSED=no MUL=yes DIV=yes LRSC=yes AMO=yes REDO=10 TRACE=no COREMARK=yes LINUX_REGRESSION=yes

## I. d) Debug GenFull CPU with GDB

Open three terminals separately: one for Verilator, one for OpenOCD, and one for GDB.

On the first terminal, run Verilator:

	$ cd VexRiscv/	#go to your VexRiscv folder
	$ cd src/test/cpp/regression/
	$ make clean run DEBUG_PLUGIN_EXTERNAL=yes

On the second terminal, run OpenOCD:

	$ cd openocd_riscv/	#go to your openocd_riscv folder
	$ src/openocd -c "set VEXRISCV_YAML <cpu0.yaml PATH>" -f tcl/target/vexriscv_sim.cfg
	where <cpu0.yaml PATH> point to the file cpu0.yaml in the VexRiscv folder
	---> for example: $ src/openocd -c "set VEXRISCV_YAML /home/ubuntu/projects/VexRiscv/VexRiscv/cpu0.yaml" -f tcl/target/vexriscv_sim.cfg

Finally, on the third terminal, run GDB:

	$ echo $PATH					#and check that it DOESN'T contain ANY TOOLCHAIN on the PATH
	$ export PATH=/opt/gcc9/riscv32im/bin/:$PATH	#now export the rv32im toolchain to the path
	
	$ cd VexRiscv/	#go to your VexRiscv folder
	$ riscv32-unknown-elf-gdb src/test/resources/elf/uart.elf	#run the software with gdb tool
	$ target remote localhost:3333	#connect to the hardware (right now is emulated by verilator)
	$ monitor reset halt
	$ load
	$ continue
	(after this, it should prints messages to the Verilator terminal)

* * *

# II. Briey SoC

* * *

# BOTTOM PAGE

| Back | Next |
| :--- | ---: |
| [SiFive Freedom on VC707](./vc707.md) | [Scala Study Notes](./scala.md) |

