---
layout : default
---

# TEE-HARDWARE

* * *

# I. Hardware

Based on the [Chipyard](https://github.com/ucb-bar/chipyard), this hardware dedicates to accelerating the Trusted Execution Environment (TEE). Original [repo](https://github.com/ckdur/tee-hardware).

The TEE-HW has demos on VC707, DE4, and TR4 FPGA boards.

The core processors can be configured to use [Rocket](https://github.com/chipsalliance/rocket-chip) cores with RV64 or RV32, or a hybrid system of Rocket & [BOOM](https://github.com/riscv-boom/riscv-boom) cores.

## I. a) Build

**Git clone:**

	$ git clone -b dev-thuc https://github.com/ckdur/tee-hardware.git
	$ cd tee-hardware/
	update with firesim:		$ . update.sh
	update without firesim:		$ . update_nosim.sh

### (i) Make verilog files

Export appropriate toolchain to your PATH:

	check PATH:		$ echo ${PATH}		#check the toolchain is on the PATH or not	
	if not, then:		$ export PATH=/opt/gcc9/riscv64gc/bin/:${PATH}
	(export the toolchain that you wanted to use, for example, riscv64gc, riscv32gc, or riscv32imac, etc.)

To make the demo for each board:

	$ cd <to your tee-hardware folder>
	
	for VC707:	$ cd fpga/Xilinx/VC707/
				$ make
					
	for DE4:		$ cd fpga/Altera/DE4/
				$ make
					
	for TR4:		$ cd fpga/Altera/TR4/
				$ make

In the Makefile of each folder (i.e., **fpga/Xilinx/VC707**, **fpga/Altera/DE4**, and **fpga/Altera/TR4**), these options are availabe:

| Variable | Availabe option | Description |
| -------- | --------------- | ----------- |
| ISACONF  | - RV64GC<br />- RV32GC<br />- RV32IMAFC<br />- RV32IMAC | Select the ISA |
| BOOTSRC  | - BOOTROM<br />- QSPI | Select the boot sources |
| HYBRID   | - Rocket<br />- Boom<br />- RocketBoom<br />- BoomRocet | - Two Rocket cores<br />- Two Boom cores<br />- Rocket core 1st, Boom core 2nd<br />- Boom core 1st, Rocket core 2nd |

*Not yet support variables*

| Variable | Availabe option | Description |
| -------- | --------------- | ----------- |
| PCIE     | - Y<br />- N | Include the PCIE or not |
| FREQ     | - 50<br />- 75<br />- 100<br />- 125<br />- 150 | Select frequency (in MHz) for the system bus |

### (ii) Build FPGA (make bitstream)

#### For demo on VC707:
- Open the Vivado tool, select the 'Open Project'
- Point to 'tee-hardware/fpga/vc707/keystone-NEDOFPGA/keystone-NEDOFPGA.xpr', then click 'OK'
- Click the 'Run Synthesis' button or F11
- When it's done, a dialog will appear, choose the 'Run Implementation', then 'OK' and wait
- When it's done, another dialog will appear, choose the 'Generate Bitstream', then 'OK' and wait
- When it's done, another dialog will appear, if you don't want to generate the files for flash programming, skip this then you're done

If you want to program the flash, then choose the 'Generate Memory Configuration File' then click 'OK'. A new dialog will appear:
- Format: select 'MCS'
- On the 'Memory Part': browse to the one with the allias name of '28f00ag18f'
- On the 'Filename': browse to 'tee-hardware/fpga/vc707/keystone-NEDOFPGA/keystone-NEDOFPGA.runs/impl_1/' folder and name the file 'NEDOFPGA.mcs'
- Tick the 'Load bitstream files': start address keep at 0x0, direction is 'up', and the 'Bitfile' browse to the 'keystone-NEDOFPGA/keystone-NEDOFPGA.runs/impl_1/NEDOFPGA.bit'
- Finally, click 'OK' to finish.

Built files are under 'tee-hardware/fpga/Xilinx/VC707/keystone-NEDOFPGA.runs/impl_1/'
- .bit: bitstream file for direct programming
- .mcs and .prm: two files for flash programming

#### For demo on DE4 & TR4:
- Open the Quartus tool, select 'File' then 'Open Project'
- Point to 'tee-hardware/fpga/stratixIV/DE4/NEDOFPGAQuartus.qpf' if DE4; 'tee-hardware/fpga/stratixIV/TR4/TR4.qpf' if TR4. Then click 'Open'
- Click the 'Tools' then 'Platform Designer', choose the 'main.qsys' then 'Open'
- Click the 'Generate HDL' button then 'Generate', and wait for its done
- When it's done, hit 'Close' then 'Finish' to close the Platform Designer's window
- On the Quartus's window, click the 'Compilation' button or Ctrl+L, and wait for it to finish.

Built files are under 'tee-hardware/fpga/Altera/DE4/output_files/' if DE4; 'tee-hardware/fpga/Altera/TR4/output_files/' if TR4
- .sof: bitstream file for direct programming

### (iii) Notes

#### About the program & debug
Guide for program & debug on VC707, DE4, and TR4 can be found [here](./fpgaguide.md).

#### About the BOOTSRC
VC707 doesn't have enough GPIOs for QSPI, so the **BOOTSRC** variable in VC707 demo always point to the BOOTROM.

In the **BOOTSRC**=BOOTROM scenario, the ZSBL is stored in the BootROM inside the FPGA, the FSBL & BBL are stored outside in the SD-card (by different partitions).

In the **BOOTSRC**=QSPI scenario, the ZSBL is stored in the Flash (via QSPI) outside the FPGA, the BootROM inside the FPGA now contains just a simple jump instruction that jumps directly to the Flash outside. And the FSBL & BBL are still stored in the SD-card as same as before.

#### About the 32-bit Boom
The 32-bit Boom doesn't support FPU, so the **ISACONF**=RV32GC/RV32IMAFC will become **ISACONF**=RV32IMAC for Boom core configurations.

## I. b) Use with Idea IntelliJ

Guide to install Idea IntelliJ is in [Initial Setup: II.e)](./init.md#ii-e-idea-intellij).

To import the tee-hardware folder to the **Idea IntelliJ** tool:

 - If the tee-hardware folder wasn't compiled before, go ahead and 'make' for the first time. This act is just for download the dependencies, because the Idea IntelliJ has trouble with dependencies download.
 - **Big note:** when 'make', please notice that there will be one line looks like this, you should copy it for later use *(it usually appears right before the creation of the device tree)*:

```
cd /home/ubuntu/Projects/TEE-HW/tee-hardware && java -Xmx8G -Xss8M -XX:MaxPermSize=256M -jar /home/ubuntu/Projects/TEE-HW/tee-hardware/hardware/chipyard/generators/rocket-chip/sbt-launch.jar ++2.12.4 "project teehardware" "runMain uec.teehardware.exampletop.Generator /home/ubuntu/Projects/TEE-HW/tee-hardware/fpga/Altera/DE4/src uec.teehardware FPGADE4 uec.teehardware DE4ConfigRV64GC"
(the content may be differ on your machine)
```

 - Open the Idea IntelliJ tool, and choose '*Import Project*'
 - Then choose '*sbt*' then hit '*Next*'
 - Tick the '*for imports*' and '*for builds*' options in the ***Use sbt shell*** then hit '*Finish*'
 - Wait for it to sync for the first time.

To debug with the **Idea IntelliJ** tool:

 - Click the ***Add Configuration...*** button right next to the build button (at the top-bar to the right). Then hit the ***+*** button to add a new configuration, and choose the ***JAR Application*** setting
 - Now get back to the " *java -jar* " example note earlier:
```
cd /home/ubuntu/Projects/TEE-HW/tee-hardware && java -Xmx8G -Xss8M -XX:MaxPermSize=256M -jar /home/ubuntu/Projects/TEE-HW/tee-hardware/hardware/chipyard/generators/rocket-chip/sbt-launch.jar ++2.12.4 "project teehardware" "runMain uec.teehardware.exampletop.Generator /home/ubuntu/Projects/TEE-HW/tee-hardware/fpga/Altera/DE4/src uec.teehardware FPGADE4 uec.teehardware DE4ConfigRV64GC"
```
   The ***/home/ubuntu/Projects/TEE-HW/tee-hardware/hardware/chipyard/generators/rocket-chip/sbt-launch.jar*** part will go to the ***Path to JAR:***
   
   The ***++2.12.4 "project teehardware" "runMain uec.teehardware.exampletop.Generator /home/ubuntu/Projects/TEE-HW/tee-hardware/fpga/Altera/DE4/src uec.teehardware FPGADE4 uec.teehardware DE4ConfigRV64GC"*** part will go to the ***Program arguments:***
   
   Everything else just leave as they are, then click '*Apply*' and '*OK*'. Now you can debug with freedom folder.

# II. Software (with Keystone)

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

After the hardware make (section [I. a)](#i-a-build) above), there is a **fsbl.bin** file inside the folder **software/freedom-u540-c000-bootloader/**. That file is for the 4th partition of the SD card:

	$ cd <your tee-hardware folder>
	$ cd software/freedom-u540-c000-bootloader/
	$ sudo dd if=vc707fsbl.bin of=/dev/sdX4 bs=4096 conv=fsync
	where the X4 is the 4th partition of the USB device

## II. c) If using QSPI (Flash)

If you're using the QSPI option in the DE4 & TR4 demos (VC707 demo doesn't support QSPI), then you have to copy the ZSBL to the Flash outside. Below is the instruction of how to program the Flash via QSPI.

We are going to program the Flash via JTAG by using the RISC-V CPU itself:
- Turn on & program the board, connect the JTAG & UART as usual, also remember to connect the Flash to the board.
- On a terminal, run the OpenOCD:
```
$ cd to your riscv-openocd/ folder
$ openocd -f openocd.cfg
```
- If the debugger connection is success, then open a new terminal for GDB:
```
$ cd <your tee-hardware folder>/software/freedom-u540-c000-bootloader
$ export PATH=/opt/gcc9/riscv64gc/bin/:$PATH	# export toolchain if it's not there yet (choose the toolchain that you want)
$ riscv64-unknown-elf-gdb FPGAzsbl.elf	# program the FPGAzsbl.elf to the flash
$ target extended-remote localhost:3333
$ load	#after a while it will be done
```
- Now the flash is programmed, you can quit the GDB/OpenOCD then hit reset on the board.

## II. d) Boot on & run the test

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

