---
layout : default
---

# KEYSTONE GUIDE

* * *

# I. Make Keystone Project

## I. a) Keystone

	$ git clone https://github.com/keystone-enclave/keystone.git
	$ cd keystone/
	$ git checkout 276e14b6e53130fd5278f700ab1b99332ca143fd		#commit on 23-Nov-2019
	
	$ echo ${PATH}			#and MAKE SURE that NO ANY TOOLCHAIN is on the PATH
	$ . source.sh
	$ export KEYSTONE_DIR=`pwd`
	
	$ ./fast-setup.sh			#this will download the prebuilt toolchain (gcc-7.2) and set things up
	$ make -j`nproc`
	
	$ sed -i 's/size_t\sfreemem_size\s=\s48\*1024\*1024/size_t freemem_size = 2*1024*1024/g' ./tests/tests/test-runner.cpp
	(this line is for FPGA board, because usually there is only 1GB of memory on the board)
	
	$ ./sdk/scripts/vault-sample.sh
	$ ./tests/tests/vault.sh
	$ make image -j`nproc`		#after this, a bbl.bin file is generated in hifive-work/bbl.bin

To turn on usb and ethernet drivers in the Linux kernel, see section [II](#ii-usb--ethernet-drivers).

To run the test with QEMU, see section [III](#iii-run-test-on-qemu).

## 32bit

	$ git clone -b dev-rv32 https://github.com/keystone-enclave/keystone.git keystone-rv32
	$ cd keystone-rv32/
	$ echo ${PATH}                  #and MAKE SURE that NO ANY TOOLCHAIN is on the PATH
	$ export RISCV=/opt/gcc8/riscv32gc
	$ export PATH=$RISCV/bin:$PATH
	$ git config --global submodule.riscv-gnu-toolchain.update none
	$ git submodule sync --recursive
	$ git submodule update --init --recursive
	$ make -j`nproc`
	$ make -C sdk
	
	$ git clone https://github.com/riscv/riscv-gnu-toolchain.git riscv-gnu-toolchain-gcc7
	$ cd riscv-gnu-toolchain-gcc7/
	$ git checkout 0914ab9f41b63681e538ec677c4adeaa889adae5 gcc8
	$ git checkout bb41926cb5a62e6cbe4b659ded6ff52c70b2baf1 gcc7
	$ git submodule update --init --recursive
	$ ./configure --prefix=/opt/gcc7/riscv32gc --with-arch=rv32gc --with-abi=ilp32d
	$ sudo make -j`nproc`
	$ sudo make linux -j`nproc`

## I. b) Keystone-demo

	$ echo ${PATH}				#and MAKE SURE that NO ANY TOOLCHAIN is on the PATH
	$ cd <your keystone folder>		#go to your keystone folder
	$ . source.sh
	$ export KEYSTONE_DIR=`pwd`
	
	$ cd ../				#go back outside
	$ git clone https://github.com/keystone-enclave/keystone-demo.git
	(branch master commit a25084ea on 18-Dec-2019)
	
	$ cd keystone-demo/
	$ . source.sh
	$ ./quick-start.sh		#type Y when asked
	after this step, a new app is generated and coppied to the keystone directory
	
	cd back to the keystone directory and remake the image with the new keystone-demo app
	$ cd ${KEYSTONE_DIR}		#now go back to the keystone folder
	$ make image -j`nproc`		#and update the bbl.bin there
	
	However, it will be a false attestation. To update the new hash value, do the followings:
	$ cd ../keystone-demo/		#first, cd back to the keystone-demo directory
	$ make getandsethash
	$ rm trusted_client.riscv
	$ make trusted_client.riscv
	$ make copybins
	after this step, the app is updated with the correct hash value and coppied to the keystone directory

	$ cd ${KEYSTONE_DIR}		#now go back to the keystone folder
	$ make image -j`nproc`		#and update the bbl.bin there

To run the test with QEMU, see section [III](#iii-run-test-on-qemu).

***Note:*** keystone & keystone-demo in this tutorial use the prebuilt toolchain (kernel=4.13.x & gcc=7.2), and they won't be compatible with the current mainstream of riscv-gnu-toolchain (kernel=5.0.x & gcc=9.2). So please don't try to modify the keystone to match with the riscv-gnu-toolchain mainstream.

***Further note:*** the mainstream keystone now can compatible with kernel 5.x and gcc 9.x. However, they moved from using Makefile to CMake, which is unfamiliar for me. So the task "make Keystone with native toolchain" is for the future work.

* * *

# II. USB & Ethernet Drivers

There are two ways of doing this, the 'formal' way, and the shortcut.

## II. a) Check the PATH things

        $ echo ${PATH}					#and MAKE SURE that NO ANY TOOLCHAIN is on the PATH
        $ cd <your keystone folder>			#go to your keystone folder
        $ . source.sh
        $ export KEYSTONE_DIR=`pwd`

        $ cd <your keystone-demo folder>	#go to your keystone-demo folder
        $ . source.sh

## II. b) Make the 'formal' way

The proper way to modify drivers in Linux kernel is open the kernel, select or diselect some drivers, apply the changes, and remake everything.

        $ cd <your keystone folder>
        $ make -f hifive.mk linux-menuconfig
        wait for the GUI to load, then:
                1. Device drivers -> Network device support -> USB network adapters
                2. choose the appropriate drivers and turn them on (usually they are the RTL** something)
                4. Exit to go back to the Network device support page
                5. Now go to Ethernet driver support page
                6. choose the appropriate drivers and turn them on (mostly they are the Intel and Realtek ones)
                6. Now just keep Exit till the end and choose Yes when asked to save the new configurations

        $ cp hifive-conf/linux_defconfig hifive-conf/linux_cma_conf
        this line is for applying the new config file into the build file

        finally, remake everything:
        $ make clean
        $ make -j`nproc`
        $ make image -j`nproc`

## II. c) Make by the 'shortcut'

So, the bottom line of the 'formal' way above is just to creating a new **linux_cma_conf** file under the *hifive-conf/* directory.

Then, I give you [THE FILE](./linux_cma_conf), you know what to do:

        after copy the **linux_cma_conf** file to your <keystone folder>/hifive-conf/linux_cma_conf:
        $ make clean
        $ make -j`nproc`
        $ make image -j`nproc`

## II. d) Aftermath

After your changes on the kernel, the hash value of the **bbl.bin** file is different now.

So if you want to use the keystone-demo ([I. b)](#i-b-keystone-demo)), you have to do the followings to reapply the hashes to the image file of **bbl.bin**:

        $ cd <your keystone-demo folder>	#go to your keystone-demo folder
        $ make getandsethash
        $ rm trusted_client.riscv
        $ make trusted_client.riscv
        $ make copybins

        $ cd <your keystone folder>			#go to your keystone folder
        $ make image -j`nproc`			#and update the bbl.bin there

* * *

# III. Run Test on QEMU

        $ cd <keystone folder>			#go to your keystone folder
        $ ./scripts/run-qemu.sh
        Login by the id of 'root' and the password of 'sifive'.

        $ insmod keystone-driver.ko	#install driver

        To do the initial test:
        $ time ./tests/tests.ke			#ok if 'Attestation report SIGNATURE is valid' is printed

        To do the keystone-demo test:
        $ cd keystone-demo/			#go to the keystone-demo test
        $ ./enclave-host.riscv &		#run host in localhost
        $ ./trusted_client.riscv localhost	#connect to localhost and test
        okay if the 'Attestation signature and enclave hash are valid' is printed
        exit the Security Monitor by:   $ q

        exit QEMU by:
        $ poweroff

* * *

# BOTTOM PAGE

| Back | Next |
| :--- | ---: |
| [Initial Setup](./init.md) | [SiFive Freedom on VC707](./vc707.md) |

