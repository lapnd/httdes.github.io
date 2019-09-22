---
layout : default
---

KEYSTONE GUIDE

* * *

- [I. Use Prebuilt Toolchain](#i-use-prebuilt-toolchain)
  * [I. a) Keystone](#i-a-keystone)
  * [I. b) Keystone-demo](#i-b-keystone-demo)
- [II. Use Native Toolchain](#ii-use-native-toolchain)
  * [II. a) Keystone](#ii-a-keystone)
  * [II. b) Keystone-demo](#ii-b-keystone-demo)
- [III. USB & Ethernet Drivers](#iii-usb--ethernet-drivers)
- [IV. Run Test on QEMU](#iv-run-test-on-qemu)

* * *

# I. Use Prebuilt Toolchain

## I. a) Keystone

	$ git clone https://github.com/keystone-enclave/keystone.git
	$ cd keystone/
	$ git checkout dev		#commit 44acf9bf on 10-Aug-2019

	$ echo ${PATH}			#and MAKE SURE that NO ANY TOOLCHAIN is on the PATH
	$ . source.sh
	$ export KEYSTONE_DIR=`pwd`
	
	$ ./fast-setup.sh		#this will download the prebuilt toolchain (gcc-7.2) and set things up
	$ make -j`nproc`
	
	$ sed -i 's/size_t\sfreemem_size\s=\s48\*1024\*1024/size_t freemem_size = 2*1024*1024/g' ./tests/tests/test-runner.cpp
	(this line is for VC707 board, because there is only 1GB of memory on the VC707 board so...)
	
	$ ./sdk/scripts/vault-sample.sh
	$ ./tests/tests/vault.sh
	$ make image -j`nproc`		#after this, a bbl.bin file is generated in hifive-work/bbl.bin

To turn on usb and ethernet drivers in the Linux kernel, see section [III](#iii-usb--ethernet-drivers).

To run the test with QEMU, see section [IV](#iv-run-test-on-qemu).

## I. b) Keystone-demo

	$ echo ${PATH}			#and MAKE SURE that NO ANY TOOLCHAIN is on the PATH
	$ cd <your keystone folder>		#go to your keystone folder
	$ . source.sh
	$ export KEYSTONE_DIR=`pwd`
	
	$ cd ../			#go back outside
	$ git clone https://github.com/keystone-enclave/keystone-demo.git
	(branch master commit 64009889 on 17-Jul-2019)
	
	$ cd keystone-demo/
	$ . source.sh
	$ ./quick-start.sh		#type Y when asked
	after this step, a new app is generated and coppied to the keystone directory
	
	However, it will be a false attestation. To update the new hash value, do the followings:
	$ make getandsethash
	$ rm trusted_client.riscv
	$ make trusted_client.riscv
	$ make copybins
	after this step, the app is updated with the correct hash value and coppied to the keystone directory

	$ cd ${KEYSTONE_DIR}		#now go back to the keystone folder
	$ make image -j`nproc`		#and update the bbl.bin there

To run the test with QEMU, see section [IV](#iv-run-test-on-qemu).

* * *

# II. Use Native Toolchain

TODO: in the future, upgrade the build scripts of keystone & keystone-demo from using the prebuilt toolchain (kernel=4.13.x & gcc=7.2) to the current mainstream of riscv-gnu-toolchain (kernel=5.0.x & gcc=9.2).

## II. a) Keystone

## II. b) Keystone-demo

* * *

# III. USB & Ethernet Drivers

There are two ways of doing this, the 'formal' way, and the shortcut.

**First, check the PATH things:**

        $ echo ${PATH}				#and MAKE SURE that NO ANY TOOLCHAIN is on the PATH
        $ cd <your keystone folder>		#go to your keystone folder
        $ . source.sh
        $ export KEYSTONE_DIR=`pwd`

        $ cd <your keystone-demo folder>	#go to your keystone-demo folder
        $ . source.sh

**The 'formal' way:**

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

**The shortcut:**

So, the bottom line of the 'formal' way above is just to creating a new **linux_cma_conf** file under the *hifive-conf/* directory.

Then, I give you THE FILE, you know what to do:

        after copy the **linux_cma_conf** file to your <keystone folder>/hifive-conf/linux_cma_conf:
        $ make clean
        $ make -j`nproc`
        $ make image -j`nproc`

**Aftermath:**

After your changes on the kernel, the hash value of the **bbl.bin** file is different now.

So if you want to use the keystone-demo ([I. b)](#i-b-keystone-demo) or [II. b)](#ii-b-keystone-demo)), you have to do the followings to reapply the hashes to the image file of **bbl.bin**:

        $ cd <your keystone-demo folder>	#go to your keystone-demo folder
        $ make getandsethash
        $ rm trusted_client.riscv
        $ make trusted_client.riscv
        $ make copybins

        $ cd <your keystone folder>		#go to your keystone folder
        $ make image -j`nproc`			#and update the bbl.bin there

* * *

# IV. Run Test on QEMU

        $ cd <keystone folder>		#go to your keystone folder
        $ ./scripts/run-qemu.sh
        Login by the id of 'root' and the password of 'sifive'.

        $ insmod keystone-driver.ko	#install driver

        To do the initial test:
        $ time ./tests/tests.ke		#okay if the 'Attestation report SIGNATURE is valid' is printed

        To do the keystone-demo test:
        $ cd keystone-demo/			#go to the keystone-demo test
        $ ./enclave-host.riscv &		#run host in localhost
        $ ./trusted_client.riscv localhost	#connect to localhost and test
        okay if the 'Attestation signature and enclave hash are valid' is printed
        exit the Security Monitor by:   $ q

        exit QEMU by:
        $ poweroff

* * *

| [*back: Initial setup*](./init.md) | [*next: Freedom on VC707*](./freedom.md) |
| :--- | ---: |
||

