---
layout : default
---

# INITIAL SETUP

* * *

# I. Dependencies & Proxy

To make **vi** more comfortable:
```
$ sudo apt install vim
$ vi ~/.vimrc
```

Then add this two lines below:
```	
set nocompatible
syntax on
```

Update & upgrade everything:
```
If your machine has proxy, replace the **http://[address]:[port]** with your proxy address:
$ echo 'Acquire::http::proxy "http://[address]:[port]";' | sudo tee -a /etc/apt/apt.conf
$ echo 'Acquire::https::proxy "http://[address]:[port]";' | sudo tee -a /etc/apt/apt.conf
$ echo 'Acquire::ftp::proxy "http://[address]:[port]";' | sudo tee -a /etc/apt/apt.conf

$ sudo apt update
$ sudo apt upgrade
$ sudo apt-get update
$ sudo apt-get upgrade
$ sudo apt install openjdk-8-jdk
```

Then install dependencies:
```
$ sudo apt-get install autoconf automake autotools-dev curl libmpc-dev libmpfr-dev libgmp-dev libusb-1.0-0-dev gawk build-essential bison flex texinfo gperf libtool libssl-dev libpixman-1-dev patchutils bc zlib1g-dev libglib2.0-dev binutils-dev libboost-all-dev device-tree-compiler pkg-config libexpat-dev python libpython-dev python-pip python-capstone virtualenv git make g++ libusb-1.0.0-dev libusb-dev libyaml-dev xorg-dev libudev-dev libts-dev libgl1-mesa-dev libglu1-mesa-dev libasound2-dev libpulse-dev libopenal-dev libogg-dev libvorbis-dev libaudiofile-dev libfreetype6-dev libdbus-1-dev libdirectfb-dev libsdl2-dev
```

And other dependencies:
```
$ sudo apt install gnutls-bin uuid-dev libpopt-dev libncurses5-dev libncursesw5-dev unzip glib2.0 expat gcc tmux wget bzip2 patch vim-common lbzip2 expect makeself patch npm libexpat1-dev device-tree-compiler cpio rsync cmake llvm-9-dev clang-9 libclang-9-dev
```
	
And the final dependency:
```
For Ubuntu version > 16.04:
$ sudo apt-get install libpng-dev

For Ubuntu version < or = 16.04:
$ sudo apt-get install libpng12-dev
```

Update proxy if your machine has proxy:
```
Replace the **http://[address]:[port]** with your proxy address:

for wget
$ echo 'http_proxy = http://[address]:[port]/' | sudo tee -a /etc/wgetrc
$ echo 'https_proxy = http://[address]:[port]/' | sudo tee -a /etc/wgetrc
$ echo 'ftp_proxy = http://[address]:[port]/' | sudo tee -a /etc/wgetrc

for git
$ git config --global https.proxy http://[address]:[port]
$ git config --global http.proxy http://[address]:[port]
$ git config --global ftp.proxy http://[address]:[port]

for npm
$ npm config set proxy http://[address]:[port]/
$ npm config set https-proxy http://[address]:[port]/
$ npm config set ftp-proxy http://[address]:[port]/

for curl
$ echo 'proxy = "http://[address]:[port]"' | sudo tee -a ~/.curlrc
```

Finally, reboot the machine.

* * *

# II. RISC-V Tools

## II. a) Github

Some tips for using Github:

        to git clone
        $ git clone <link>							#clone and keep the original name for the cloned folder
        $ git clone <link> <name>						#clone and change the name for the cloned folder

        to track your changes
        $ git diff									#list the differences of your folder
        $ git diff <branch-name>						#list the differences of your folder compare to another branch
        $ git diff <src-branch>..<des-branch>			#list the differences between two branches
        $ git diff <commit-hash>						#list the differences of your folder compare to the old commit
        $ git diff <src-commit-hash>..<des-commit-hash>	#list the differences between two commits

        to update your folder FROM github
        $ git pull									#pull from the current branch
        $ git pull <branch-name>						#pull from another branch

        to update your folder TO github
        $ git status									#to see changes for commit
        $ git add <file-name> <folder-name>			#first, add every changes of yours
        $ git commit -m "<some message>"				#make a commit with <some message> attached
        $ git push									#this one will push to the current branch, OR
        $ git push <branch-name>						#       push to another branch

        to switch to another branch and commit
        $ git checkout <branch-name>					#switch to another branch
        $ git checkout <commit-hash>					#rollback to the old commit in the same branch
        $ git checkout -b <branch-name> <commit-hash>	#switch to another branch and rollback to the old commit of that branch

        to patch file
        $ git diff > patch-file							#export current changes into a patch-file
        $ git format-patch <src branch or commit>..<des branch or commit> --stdout > patch-file
        (export a patch-file from <src branch or commit> to <des branch or commit>)
        $ patch -p1 < patch-file						#update your folder with the patch-file

        to see the status of repo
        $ git log
        $ git log --oneline
        $ git log --all --decorate --oneline --graph

## II. b) Scala & sbt:

The source code for hardware is written in scala language by using the Chisel library. The sbt is the tool to compile the scala codes. Sbt is used to generate java codes from the scala codes, then later on, java generates firrtl codes from the java codes, and finally, from firrtl codes to the actual verilog codes.

First, we need to install the scala. You can follow the [website](https://www.scala-lang.org/download/) to download the [deb file](https://downloads.lightbend.com/scala/2.12.4/scala-2.12.4.deb) (version 2.12.4) and install. (You can choose another version to install at your own risk :))

Then download the sbt tool according to the [website](https://www.scala-sbt.org/release/docs/Installing-sbt-on-Linux.html). Download the [deb file](http://dl.bintray.com/sbt/debian/sbt-1.2.8.deb) (version 1.2.8) and install.

## II. c) Verilator

Verilator is a cycle-accurate behavioral model, and it is used to simulate the Verilog codes at cycle level (like ModelSim).

To install the Verilator:
```
stand where you want to install Verilator
$ git clone http://git.veripool.org/git/verilator
$ cd verilator/
$ git checkout v4.032
$ unset VERILATOR_ROOT		#For bash, unsetenv for csh
$ autoconf #this is to create the ./configure script
$ ./configure #then run the script
$ make -j`nproc`
$ sudo make install
```

## II. d) QEMU

QEMU is an emulation tool, not a simulation tool. It does not simulate anything (.v codes, .scala codes, or .c codes, etc.). It emulates the behavioral that a correct CPU should behave. Ref [link](https://github.com/riscv/riscv-qemu/tree/riscv-qemu-4.0.0).

To install the RISC-V QEMU:
```
stand where you want to install RISC-V QEMU
$ git clone https://github.com/riscv/riscv-qemu.git
$ cd riscv-qemu/
$ git checkout riscv-qemu-4.0.0         	#commit 62a172e on 19-Mar-2019
$ git submodule update --init --recursive
$ mkdir build
$ cd build
$ ../configure
$ make -j`nproc`
```

## II. e) Idea IntelliJ

**Idea IntelliJ** is a tool for compiling scala codes. It much more like a GUI for the SBT tool.

After download the **Idea IntelliJ** from the [website](https://www.jetbrains.com/idea/), extract it and run it by **./idea.sh**

## II. f) Eclipse

Eclipse is the tool for writing software codes (C/C++), to build, to run, and to debug the software.

Download the gnu-mcu-eclipse (linux version) from the [website](https://github.com/gnu-mcu-eclipse/org.eclipse.epp.packages/releases).

Then extract it and copy the folder to any place you want. The execution file is at: ***\[Eclipse folder\]/eclipse/eclipse***

You will be aksed to install plugins at the first launch of the program, remember to choose install the Scala language support.

## II. g) OpenOCD

Open OCD (OCD: On-Chip Debugger) is a tool to control a CPU via a debugger, thus allowing us to load a program, and run or debug that program.

To install & make OpenOCD:
```
$ git clone https://github.com/riscv/riscv-openocd.git			#branch riscv commit 9aa8bab6 on 27-Jul-2021
$ cd riscv-openocd/
$ git submodule update --init --recursive
$ ./bootstrap
$ ./configure --enable-ftdi --enable-dummy
$ make -j`nproc`
$ sudo make install -j`nproc`
```

Configuration files for RISC-V CPU: [without Flash/QSPI](./riscv-openocd.cfg) and [with Flash/QSPI](./riscv-openocd-flash.cfg).
You should download them and put them under the riscv-openocd/ folder.

## II. h) Vivado 2016.4

(because the VC707 project now can compatible only with the 2016.4 version of Vivado)

**Check your eth0 interface:**

Type "$ ifconfig -a" to make sure that the network interface name is 'eth0'. If not, the Vivado cannot recognize the license from the NAT interface. Then, the network interface name must be rename by:
```
$ sudo vi /etc/default/grub

Then add this line beneath those GRUB... lines:
	GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0"

Then:
	$ sudo grub-mkconfig -o /boot/grub/grub.cfg
```

Finally, reboot again for the computer to update the new ethernet interface.

**Download and Install:**

First, download the Vivado 2016.4 from Xilinx [website](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/archive.html) (linux .bin file self extract). Then, cd to the downloaded .bin file and run:
```
$ chmod +x Xilinx_....bin
$ sudo ./Xilinx_....bin
```

The GUI for installation will be load. Choose to install the Vivado HL Design Edition and wait for the installer to complete.

**Install cable driver:**
```
cd to Vivado installed folder:
$ cd ...Xilinx/Vivado/2016.4/data/xicom/cable_drivers/lin64/install_script/install_drivers/
$ sudo ./install_drivers
```

## II. i) Quartus

Just download from the [website](http://fpgasoftware.intel.com/?edition=standard&platform=linux&download_manager=direct) and install.

Choose the version you want to download, then from Ubuntu just click and install. (In this tutorial, the chosen Quartus version is Quartus Prime Standard 18.1)

The Quartus execution file is located at **intelFPGA/18.1/quartus/bin/**

Note: if running Quartus fail due to libpng12 error, then you need to install it manually (Just download & install): for [32-bit](https://packages.ubuntu.com/en/xenial/i386/libpng12-0/download), for [64-bit](https://packages.ubuntu.com/en/xenial/amd64/libpng12-0/download).

**Install cable driver:**

Create two 51- and 52- files:
```
$ sudo vi /etc/udev/rules.d/51-usbblaster.rules
$ sudo vi /etc/udev/rules.d/52-usbblaster.rules
```

And add these lines on both files:
```
# USB-Blaster
BUS=="usb", SYSFS{idVendor}=="09fb", SYSFS{idProduct}=="6001", MODE="0666"
BUS=="usb", SYSFS{idVendor}=="09fb", SYSFS{idProduct}=="6002", MODE="0666" 
BUS=="usb", SYSFS{idVendor}=="09fb", SYSFS{idProduct}=="6003", MODE="0666"   

# USB-Blaster II
BUS=="usb", SYSFS{idVendor}=="09fb", SYSFS{idProduct}=="6010", MODE="0666"
BUS=="usb", SYSFS{idVendor}=="09fb", SYSFS{idProduct}=="6810", MODE="0666"
```

After that, you may:
```
$ sudo service udev restart
```

Or even reboot the computer if it's still not recognize the cable.
	
## II. k) Create Ubuntu Desktop Shorcut

To install the tool:
```
$ sudo apt-get install --no-install-recommends gnome-panel
```

To add a new item on the desktop:
```
$ gnome-desktop-item-edit ~/Desktop/ --create-new
Then fill in the name you wanted, browse to the execution file, and hit OK.
```

Double-click on the new icon for the first time and click the "Trust and Launch" button.

* * *

# III. RISC-V Toolchain

Toolchain for RISC-V CPU. Ref [link](https://github.com/riscv/riscv-gnu-toolchain).

## III. a) Git clone

Git clone the toolchain-making on github:
```
$ git clone https://github.com/riscv/riscv-gnu-toolchain
$ cd riscv-gnu-toolchain/

Current mainstream is gcc 9.2 (brach master commit 6d2706f2 on 19-Feb-2020).
if you want to use older gcc:
gcc 7.2:	$ git checkout bb41926cb5a62e6cbe4b659ded6ff52c70b2baf1		#branch master commit on 21-Feb-2019
gcc 8.3:	$ git checkout 0914ab9f41b63681e538ec677c4adeaa889adae5		#branch master commit on 16-Aug-2019

finally,
$ git submodule update --init --recursive
```

## III. b) Configurations

The configuration command format:
```
$ ./configure --prefix=[path] --with-arch=[arch] --with-abi=[abi]
```

The **[path]** is where you want to store your generated toolchain.

The **[arch]** is the RISC-V architecture that you want. To be specific:

 * **rv64** and **rv32** respectively specify the 64-bit and 32-bit instruction set options.
 * These characters **i**, **a**, **m**, **f**, **d**, **c**, and **g** are respectively stand for the extensions of (*i*)nteger, (*a*)tomic, (*m*)ultiplication & division, (*f*)loating-point, (*d*)ouble floating-point, (*c*)ompress, and (*g*)eneral (general = *imafd*).
 
 The **[abi]** is the ABI that specify the **compile** mode on the software. To be specific:
 * For 32-bit, there are **ilp32** and **ilp32d** to pair with **rv32* using ***soft-float*** or ***hard-float***, respectively.
 * For 64-bit, there are **lp64** and **lp64d** to pair with **rv64** using ***soft-float*** or ***hard-float***, respectively.

For example, to generate toolchain for a general 64-bit RISC-V CPU, you can write like this:
```
$ ./configure --prefix=/opt/riscv64gc --with-arch=rv64gc --with-abi=lp64d
```

Or for a general 32-bit RISC-V CPU:
```
$ ./configure --prefix=/opt/riscv32gc --with-arch=rv32gc --with-abi=ilp32d
```

## III. c) Make

After install the dependencies, clone the toolchain-making folder, and set the configurations, now you can 'make' the toolchain by:
```
for elf-toolchain (or baremetal toolchain) to run directly on the CPU (like MCU)
$ sudo make -j`nproc`

for linux-toolchain to run on the Linux that run on the CPU (like OS app)
$ sudo make linux -j`nproc`
```

*Note*: to re-make again, it is better to **$ sudo make clean** beforehand.

* * *

# BOTTOM PAGE

| Next |
| ---: |
| [Keystone (using Makefile) for RV64 Build](./keystone-makefile-64.md) |

