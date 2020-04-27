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
	
	to comile the TEE-HW for
	VC707:		$ cd fpga/vc707
	DE4:		$ cd fpga/stratixIV/
	then:		$ make

Guide on programming and debuging the VC707 FPGA board can be found [here](./fpgaguide_vc707.md).

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

* * *

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

