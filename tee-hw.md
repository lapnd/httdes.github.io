---
layout : default
---

# TEE-HARDWARE

* * *

# I. Hardware

Based on the [Chipyard](https://github.com/ucb-bar/chipyard), this hardware dedicates to accelerating the Trusted Execution Environment (TEE). Original [repo](https://github.com/ckdur/tee-hardware).

The TEE-HW has demos on VC707, DE4, and TR4 FPGA boards.

The core processors can be configured to use [Rocket](https://github.com/chipsalliance/rocket-chip) cores with RV64 or RV32, or a hybrid system of Rocket (RV64) & [BOOM](https://github.com/riscv-boom/riscv-boom) cores.

## I. a) Build

**Git clone:**

	$ git clone -b dev-thuc https://github.com/ckdur/tee-hardware.git
	$ cd tee-hardware/
	update with firesim:		$ . update.sh
	update without firesim:		$ . update_nosim.sh
	
**To build:**
	
	check PATH:		$ echo ${RISCV}		#check the toolchain is on the PATH or not
					$ echo ${PATH}
					
	if not, then:		$ export RISCV=/opt/gcc9/riscv64gc		#export the toolchain to PATH 
					$ export PATH=${RISCV}/bin/:${PATH}
	
	for VC707:		$ cd fpga/vc707
					$ make
	
	for DE4:		$ cd fpga/stratixIV/
					$ make

* * *

LATER

The format for 'make' command is:

	$ make [CONFIG] [MODEL] [BUILD_DIR] -f Makefile.vc707-u500devkit -j`nproc`

The **[CONFIG]** option is for selecting the frequency.

The **[MODEL]** option is for selecting the PCIe option.
	
The **[BUILD_DIR]** option is to specify the build directory.
	
Example:
	
To clean and build again:

 - Remove the **builds/\<name\>** folder
 - If you used the keystone's zsbl-fsbl boot process, then go the **bootrom/freedom-u540-c000-bootloader/** folder and **$ make clean**.
 - Finally, go to the top folder and 'make' again.

### (ii) Notes

**1:** The maximum frequency for.

**2:** Built files are under **builds/<name>/obj/**. The important built files are:
	
	*.mcs and *.prm		the two files for flash programming
	*.bit						the bitstream file for direct programming
	
## I. b) Program the board

Remember to switch the switches above the LCD to UP-UP-DOWN-UP-DOWN, then open vivado, open hardware manager, open target board, auto connect.

About the cable driver:

	$ cd to [installation path]/Vivado/2016.4/data/xicom/cable_drivers/lin64/install_script/install_drivers
	then run the script "$ sudo ./install_drivers"

Vivado direct programming:

	a. right-click on the xc7vx485t_0
	b. Program Device ...
	c. select the .bit file in the builds/vc707-u500devkit/obj/VC707Shell.bit
	d. Program

Vivado flash programming:

	a. right-click on the xc7vx485t_0
	b. Add Configuration Memory Device ...
	c. select the one with the Alias of 28f00ag18f ---> OK
	d. OK to continue to program the device
	e. select the Configuration file (.mcs) and PRM file (.prm) in the builds/vc707-u500devkit/obj/
	f. select the RS pins: 25:24
	g. OK to write data to the flash
	h. finally, right-click again on the xc7vx485t_0 and select Boot from Configuration Memory Device

## I. c) Debug with GDB via JTAG

Using the Olimex JTAG debugger. Ref [link](https://www.olimex.com/Products/ARM/JTAG/ARM-USB-TINY-H/).

#### (i) Driver

To install the driver for the debugger:

	$ sudo apt-get install libftdi-dev libftdi1
	$ vi /etc/udev/rules.d/olimex-arm-usb-tiny-h.rules

Then add this single line in the olimex-arm-usb-tiny-h.rules file:

	SUBSYSTEM=="usb", ACTION=="add", ATTRS{idProduct}=="002a", ATTRS{idVendor}=="15ba", MODE="664", GROUP="plugdev"

#### (ii) Connection

Connect your Olimex JTAG debugger to the VC707 FPGA board by the XADC (J19) header as shown as follows:

![Branching](./jtag-20pin.png)

The four data pins TDI (pin 5), TMS (pin 7), TCLK (pin 9), and TDO (pin 13) are connected to the XADC_GPIO 0 to 3 (pin 17 to 20). The VCC (pin 1) is connected to the XADC_VCC_HEADER (pin 14). And any of the GND pin on the JTAG side is connected to the GND pin 16 of the XADC header.

![Branching](./jtag-xadc.png)

#### (iii) Run

You need to prepare your riscv-openocd folder, guide is in [Initial Setup: II.g)](./init.md#ii-g-openocd).

Copy this [file](./openocd.cfg) to your **riscv-openocd/** folder. Then:

	$ cd to your riscv-openocd/ folder
	$ openocd -f openocd.cfg
	
If succeed, it will print something like this:
	
	$ openocd -f openocd.cfg 
	Open On-Chip Debugger 0.10.0+dev-00824-gf93ede540 (2019-11-05-10:20)
	Licensed under GNU GPL v2
	For bug reports, read
		http://openocd.org/doc/doxygen/bugs.html
	Info : auto-selecting first available session transport "jtag". To override use 'transport select <transport>'.
	Info : ftdi: if you experience problems at higher adapter clocks, try the command "ftdi_tdo_sample_edge falling"
	Info : clock speed 10000 kHz
	Info : JTAG tap: riscv.cpu tap/device found: 0x20000913 (mfg: 0x489 (SiFive Inc), part: 0x0000, ver: 0x2)
	Info : datacount=2 progbufsize=16
	Info : Disabling abstract command reads from CSRs.
	Info : Examined RISC-V core; found 4 harts
	Info :  hart 0: XLEN=64, misa=0x800000000014112d
	Info :  hart 1: XLEN=64, misa=0x800000000014112d
	Info :  hart 2: XLEN=64, misa=0x800000000014112d
	Info :  hart 3: XLEN=64, misa=0x800000000014112d
	Info : Listening on port 3333 for gdb connections
	Info : Listening on port 6666 for tcl connections
	Info : Listening on port 4444 for telnet connections

Then, open another terminal to start a GDB session: (remember to export the riscv toolchain to your PATH)

	$ riscv64-unknown-elf-gdb
	The GDB terminal will appear after this.
	
	From the GDB terminal, type:
	$ target extended-remote localhost:3333
	If succeed, the CPU will enter the debugging state after this command,
	and on the GDB terminal you can see the current instruction address
	
Some useful tips for debugging the RISC-V CPU:

	Run next line:			$ si
	Run continue:			$ c
	Set breakpoint:		$ hb 0x...
	Delete breakpoint:		$ delete
	Print cores info:		$ info threads
	Select core:			$ thread i			# i is the core number
	Set program counter:	$ set $pc=0x...
	Print registers table:	$ info registers
	Write to address:		$ set *0x...=0x...
	Read from address:		$ print/x *0x...
	Reset CPU:			$ monitor reset halt

## I. d) Other utilities

To quickly set build environment:

	$ vi setenv.sh
	and change the correct corresponding paths in your machine
	
	Then from this point forward, you can auto set your environment by simply:
	$ . setenv.sh

If you want to change the ROM size:

	BootRom size is declared in the file:
		rocket-chip/src/main/scala/devices/tilelink/MaskROM.scala
	
	On the line 12:
		case class MaskROMParams(address: BigInt, name: String, depth: Int = 2048, width: Int = 32)

	Change the <depth> value to change the size.

If you want to change the modules' addresses, number of CPU cores, etc:

	The declarations are in the file:
		src/main/scala/unleashed/DevKitConfigs.scala
	
	But remember to change the addresses on the software as well. These files:
		bootrom/sdboot/include/platform.h
		bootrom/sdboot/linker/memory.lds
		bootrom/freedom-u540-c000-bootloader/sifive/platform.h
		bootrom/freedom-u540-c000-bootloader/memory_vc707.lds
	
*TODO*: script to auto update ROM size, modules' addresses, and number of CPU to software

## I. e) Use with Idea IntelliJ

Guide to install Idea IntelliJ is in [Initial Setup: II.e)](./init.md#ii-e-idea-intellij).

To import the freedom folder to the **Idea IntelliJ** tool:

 - If the freedom folder wasn't compiled before, go ahead and 'make verilog' for the first time (no need to 'make mcs' though). This act is just for download the dependencies, because the Idea IntelliJ has trouble with dependencies download.
 - **Big note:** when 'make verilog', please notice that there will be one line looks like this, you should copy it for later use:

```
java -jar /home/ubuntu/project/freedom/rocket-chip/sbt-launch.jar ++2.12.4 "runMain freechips.rocketchip.system.Generator /home/ubuntu/project/freedom/builds/chip uec.nedo.chip ChipShell uec.nedo.chip ChipDesignTop"
(the content may be differ on your machine)

In the first time 'make', it usually appears near after this line:
	[success] Total time: xxx s, completed xxx, xxx, xx:xx:xx
In the NOT first time 'make', it usually appears right away
```

 - Open the Idea IntelliJ tool, and choose '*Import Project*'
 - Then choose '*sbt*' then hit '*Next*'
 - Tick the '*for imports*' and '*for builds*' options in the ***Use sbt shell*** then hit '*Finish*'
 - Wait for it to sync for the first time. This first time sync will fail
 - After that, go to the tab ***sbt shell*** and type ***++2.12.4***, and then type ***compile***, and wait!
 - After the compile, go to the ***sbt*** tab on the MOST RIGHT EDGE and hit the reload button, it will re-sync for the second time
 - After the second time sync, if it still fail, I have no idea ¯\\_(ツ)_/¯

To debug with the **Idea IntelliJ** tool:

 - Before debugging it, you have to build it first. Go to the ***sbt shell*** tab and type ***++2.12.4*** then type ***compile***
 - Please notice that there might be a task name *Indexing* still running in the background, wait for it to finish.
 - After 'compile' succeed and '*Indexing*' finished, click the ***Add Configuration...*** button right next to the build button (at the top-bar to the right). Then hit the ***+*** button to add a new configuration, and choose the ***JAR Application*** setting
 - Now get back to the " *java -jar* " example note earlier:
```
java -jar /home/ubuntu/project/freedom/rocket-chip/sbt-launch.jar ++2.12.4 "runMain freechips.rocketchip.system.Generator /home/ubuntu/project/freedom/builds/chip uec.nedo.chip ChipShell uec.nedo.chip ChipDesignTop"
```
   The ***/home/ubuntu/project/freedom/rocket-chip/sbt-launch.jar*** part will go to the ***Path to JAR:***
   
   The ***++2.12.4 "runMain freechips.rocketchip.system.Generator /home/ubuntu/project/freedom/builds/chip uec.nedo.chip ChipShell uec.nedo.chip ChipDesignTop"*** part will go to the ***Program arguments:***
   
   Everythiing else just leave as they are, then click '*Apply*' and '*OK*'. Now you can debug with freedom folder.

# II. Software

Ref [link](https://github.com/keystone-enclave/keystone) for the KeyStone project.

## II. a) Prepare the SD card

Use the **gptfdisk** tool to create 4 partitions in the SD card.

If you don't have the **gptfdisk tool**, then do the followings to install it:

	$ git clone https://github.com/tmagik/gptfdisk.git	#branch master commit 3d6a1587 on 9-Dec-2018
	$ cd gptfdisk/
	$ make -j`nproc`

Copy the [mksd-sifive.sh](./mksd-sifive.sh) file to your **gptfdisk** directory, then do this to partition your SD card:

	$ ./mksd-sifive.sh /dev/sdX 8G
	where X is the number of the USB device, and you can change the 8G to 16G if your SD card is 16G
	
The partitions after created:

	Number	Start (sector)	End (sector)	Size			Code	Name
	1		2048		67583		32.0 MiB		5202	SiFive bare-metal (...
	2		264192		15759326	7.4 GiB		8300	Linux filesystem
	4		67584		67839		128.0 KiB	5201	SiFive FSBL (first-...

## II. b) Prepare BBL & FSBL

#### For the bbl.bin:

Follow the [instruction](./keystone.md) to make the **bbl.bin** of the Keystone & Keystone demo.

The **bbl.bin** is for the 1st partition of the SD card:

	$ cd <keystone folder>				#cd to your keystone folder
	$ sudo dd if=hifive-work/bbl.bin of=/dev/sdX1 bs=4096 conv=fsync
	where the X1 is the 1st partition of the USB device
	
#### For the fsbl.bin:

After the hardware make (section [I. a)](#i-a-build) above), there is a **fsbl.bin** file inside the folder **bootrom/freedom-u540-c000-bootloader/**. That file is for the 4th partition of the SD card:

	$ cd <your freedom folder>
	$ cd bootrom/freedom-u540-c000-bootloader/
	$ sudo dd if=vc707fsbl.bin of=/dev/sdX4 bs=4096 conv=fsync
	where the X4 is the 4th partition of the USB device

## II. c) Boot on & run the test

Finally, put in the SD card to the board, program the board, then wait for the board to boot on. Communicate with the board via UART:

	$ sudo minicom -b 115200 -D /dev/ttyUSBx
	where x is the number of connected USB-UART
	Login by the id of 'root' and the password of 'sifive'.

To run the keystone test:

	$ insmod keystone-driver.ko		#install driver
	$ time ./tests/tests.ke 			#okay if the 'Attestation report SIGNATURE is valid' is printed
	$ cd keystone-demo/			#go to the keystone-demo test
	$ ./enclave-host.riscv &			#run host in localhost
	$ ./trusted_client.riscv localhost	#connect to localhost and test
	okay if the 'Attestation signature and enclave hash are valid' is printed

* * *

# BOTTOM PAGE

| Back | Next |
| :--- | ---: |
| [VexRiscv 32-bit MCU](./vexriscv.md) | [Scala](./scala.md) |

