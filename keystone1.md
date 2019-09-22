---
layout : default
---

- [I. Using prebuilt toolchain](#i-using-prebuilt-toolchain)
  * I. a) Keystone](#i-a-keystone)
  * I. b) Keystone-demo](#i-b-keystone-demo)
- [II. Using native toolchain](./keystone2.md)
  * II. a) Keystone
  * II. b) Keystone-demo
- [III. Turn on USB & Ethernet drivers](./keystone3.md)
- [IV. Run test on QEMU](./keystone4.md)

* * *

# I. Using prebuilt toolchain

## I. a) Keystone

	$ git clone https://github.com/keystone-enclave/keystone.git
	$ cd keystone/
	$ git checkout dev	#commit 44acf9bf on 10-Aug-2019

	$ echo ${PATH}		#and MAKE SURE that NO ANY TOOLCHAIN is on the PATH
	$ . source.sh
	$ export KEYSTONE_DIR=`pwd`
	
	$ ./fast-setup.sh	#this will download the prebuilt toolchain (gcc-7.2) and set things up
	$ make -j`nproc`
	
	$ sed -i 's/size_t\sfreemem_size\s=\s48\*1024\*1024/size_t freemem_size = 2*1024*1024/g' ./tests/tests/test-runner.cpp
	(this line is for VC707 board, because there is only 1GB of memory on the VC707 board so...)
	
	$ ./sdk/scripts/vault-sample.sh
	$ ./tests/tests/vault.sh
	$ make image -j`nproc`		#after this, a bbl.bin file is generated in hifive-work/bbl.bin

To turn on usb and ethernet drivers in the Linux kernel, see section [III](#iii-turn-on-usb--ethernet-drivers-in-linux-kernel).

To run the test with QEMU, see section [IV](#iv-run-test-on-qemu).

## I. b) Keystone-demo

	$ echo ${PATH}				#and MAKE SURE that NO ANY TOOLCHAIN is on the PATH
	$ cd <your keystone folder>		#go to your keystone folder
	$ . source.sh
	$ export KEYSTONE_DIR=`pwd`
	
	$ cd ../	#go back outside
	$ git clone https://github.com/keystone-enclave/keystone-demo.git
	(branch master commit 64009889 on 17-Jul-2019)
	
	$ cd keystone-demo/
	$ . source.sh
	$ ./quick-start.sh	#type Y when asked
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

| [*back: Initial Setup guide*](./init1.md) | [*next: II. Using native toolchain*](./keystone2.md) |
| :--- | :--- |
||

