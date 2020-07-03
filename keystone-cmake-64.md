---
layout : default
---

# KEYSTONE: TEE FRAMEWORK (Using CMake) for RV64 Build

* * *

# I. Install RUST

To enable security monitor written with RUST, llvm-9 and rust nightly toolchain are required:
```
$ sudo apt install llvm-9-dev clang-9 libclang-9-dev
$ curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

Answer the selection with 1 or simply enter key. Add $HOME/.cargo/bin to PATH as the script says.
```
$ export PATH=$HOME/.cargo/bin:$PATH
```

Better yet, add this to the **~/.bashrc** to make it persistent
```
$ sudo vi ~/.bashrc

Then add this line to the end of the file:
$ export PATH=$HOME/.cargo/bin:$PATH
```

To install and setup Rust:
```
$ rustup toolchain install nightly
$ rustup +nightly component add rust-src
$ rustup +nightly target add riscv64gc-unknown-none-elf
$ cargo +nightly install cargo-xbuild
```

# II. Make for RV64

## II. a) Keystone

### Using Their Prebuilt Toolchain (gcc-7.2)

Git clone:
```
$ git clone https://github.com/keystone-enclave/keystone.git keystone-rv64	#commit on 23-Nov-2019
$ cd keystone-rv64/
```

Check PATH:
```
$ echo ${PATH}			#and MAKE SURE that NO ANY TOOLCHAIN is on the PATH
$ . source.sh
$ export KEYSTONE_DIR=`pwd`
```

Download prebuilt toolchain & make:
```
$ ./fast-setup.sh			#this will download the prebuilt toolchain (gcc-7.2) and set things up

$ mkdir build
$ cd build/
$ rustup update nightly
$ cmake .. -DUSE_RUST_SM=y -DSM_CONFIGURE_ARGS="--enable-opt=0"
$ make -j `nproc`
$ make run-tests
```
The second SM_CONFIGURE_ARGS option is temporarily, see [PR#62](https://github.com/keystone-enclave/riscv-pk/pull/62).

Build the keystone-test:
```
$ sed -i 's/size_t\sfreemem_size\s=\s48\*1024\*1024/size_t freemem_size = 2*1024*1024/g' ./tests/tests/test-runner.cpp
(this line is for FPGA board, because usually there is only 1GB of memory on the board)

$ ./sdk/scripts/vault-sample.sh
$ ./tests/tests/vault.sh
$ make image -j`nproc`		#after this, a bbl.bin file is generated in hifive-work/bbl.bin
```

### Using Our Own Local Toolchain (gcc-8.3 in this example)



### For Ethernet Driver & QEMU

To turn on usb and ethernet drivers in the Linux kernel, see section [III](#iii-usb--ethernet-drivers).

To run the test with QEMU, see section [IV](#iv-run-test-on-qemu).

*Note: using local toolchain cause trouble on running QEMU, but totally fine with FPGA.*

## I. b) Keystone-demo

	$ echo ${PATH}				#and MAKE SURE that NO ANY TOOLCHAIN is on the PATH
	$ cd <your keystone folder>		#go to your keystone folder
	$ . source.sh
	$ export KEYSTONE_DIR=`pwd`
	
	$ cd ../						#go back outside
	$ git clone https://github.com/keystone-enclave/keystone-demo.git keystone-demo-rv64
	(branch master commit a25084ea on 18-Dec-2019)
	
	$ cd keystone-demo-rv64/
	$ . source.sh
	$ ./quick-start.sh				#type Y when asked
	after this step, a new app is generated and coppied to the keystone directory
	
	cd back to the keystone directory and remake the image with the new keystone-demo app
	$ cd ${KEYSTONE_DIR}		#now go back to the keystone folder
	$ make image -j`nproc`			#and update the bbl.bin there
	
	However, it will be a false attestation. To update the new hash value, do the followings:
	$ cd ../keystone-demo-rv64/		#first, cd back to the keystone-demo directory
	$ make getandsethash
	$ rm trusted_client.riscv
	$ make trusted_client.riscv
	$ make copybins
	after this step, the app is updated with the correct hash value and coppied to the keystone directory

	$ cd ${KEYSTONE_DIR}		#now go back to the keystone folder
	$ make image -j`nproc`			#and update the bbl.bin there

To run the test with QEMU, see section [IV](#iv-run-test-on-qemu).

* * *

# II. Make for RV32

## II. a) Keystone

You need the gcc8 riscv toolchain for this build.

To build the gcc8 riscv toolchain, follow the instruction in [Initial Setup](./init.md#iii-risc-v-toolchain).

	# config rv32 with FPU:		$ ./configure --prefix=/opt/riscv32gc --with-arch=rv32gc --with-abi=ilp32d
	#       or without FPU:		$ ./configure --prefix=/opt/riscv32imac --with-arch=rv32imac --with-abi=ilp32
	
	# after config, then 'make'
	$ sudo make -j`nproc`
	$ sudo make linux -j`nproc`

When gcc8 is ready, we can make the keystone-rv32:

	$ git clone -b dev-rv32 https://github.com/thuchoang90/keystone.git keystone-rv32
	(branch dev-rv32 commit 11cae58f on 26-May-2020)
	
	$ cd keystone-rv32/
	$ echo ${PATH}					#and MAKE SURE that NO ANY TOOLCHAIN is on the PATH
	
	#point to the gcc8 toolchain of rv32
	with FPU:	$ export RISCV=/opt/gcc8/riscv32gc
	without FPU:	$ export RISCV=/opt/gcc8/riscv32imac
	
	$ export PATH=$RISCV/bin:$PATH	#export the toolchain to the PATH
	$ ./fast-setup.sh					#now clone the submodules
	
	#run this line if you're using rv32 without FPU:
	$ patch -p1 < patches/rv32imac.patch
	
	#finally, let's 'make'
	$ make -j`nproc`
	$ make -C sdk
	
	$ sed -i 's/size_t\sfreemem_size\s=\s48\*1024\*1024/size_t freemem_size = 2*1024*1024/g' ./sdk/examples/tests/test-runner.cpp
	(this line is for FPGA board, because usually there is only 1GB of memory on the board)
	
	$ cd sdk/							#make sdk
	$ export KEYSTONE_SDK_DIR=`pwd`
	$ export EYRIE_DIR=`pwd`/rts/eyrie
	$ ./scripts/init.sh
	$ cd ../
	
	$ ./sdk/scripts/vault-sample.sh		#make demo
	$ ./sdk/examples/tests/vault.sh
	$ make -j`nproc`					#do this to update the demo to the image file bbl.bin

To turn on usb and ethernet drivers in the Linux kernel, see section [III](#iii-usb--ethernet-drivers).

To run the test with QEMU, see section [IV](#iv-run-test-on-qemu).

## II. b) Keystone-demo
	
	$ echo ${PATH}					#and MAKE SURE that NO ANY TOOLCHAIN is on the PATH
	
	#point to the gcc8 toolchain of rv32
	with FPU:	$ export RISCV=/opt/gcc8/riscv32gc
	without FPU:	$ export RISCV=/opt/gcc8/riscv32imac
	
	$ export PATH=$RISCV/bin:$PATH	#export the toolchain to the PATH
	
	$ cd <your keystone folder>			#go to your keystone folder
	$ export KEYSTONE_DIR=`pwd`
	
	$ cd ../							#go back outside
	$ git clone -b dev-rv32 https://github.com/thuchoang90/keystone-demo.git keystone-demo-rv32
	(branch dev-rv32 commit 7c913f0b on 24-Mar-2020)
	
	$ cd keystone-demo-rv32/
	$ . source.sh
	$ ./quick-start.sh					#type Y when asked
	after this step, a new app is generated and coppied to the keystone directory
	
	cd back to the keystone directory and remake the image with the new keystone-demo app
	$ cd ${KEYSTONE_DIR}			#now go back to the keystone folder
	$ make -j`nproc`					#and update the bbl.bin there
	
	However, it will be a false attestation. To update the new hash value, do the followings:
	$ cd ../keystone-demo-rv32/			#first, cd back to the keystone-demo directory
	$ make getandsethash
	$ rm trusted_client.riscv
	$ make trusted_client.riscv
	$ make copybins
	after this step, the app is updated with the correct hash value and coppied to the keystone directory
	
	$ cd ${KEYSTONE_DIR}			#now go back to the keystone folder
	$ make -j`nproc`					#and update the bbl.bin there
	
To run the test with QEMU, see section [IV](#iv-run-test-on-qemu).

* * *

# III. USB & Ethernet Drivers

There are two ways of doing this, the 'formal' way, and the shortcut.

## III. a) Check the PATH things

	$ echo ${PATH}					#and MAKE SURE that NO ANY TOOLCHAIN is on the PATH
	$ cd <your keystone folder>			#go to your keystone folder
	$ . source.sh
	$ export KEYSTONE_DIR=`pwd`

	$ cd <your keystone-demo folder>	#go to your keystone-demo folder
	$ . source.sh

## III. b) Make the 'formal' way

The proper way to modify drivers in Linux kernel is open the kernel, select or diselect some drivers, apply the changes, and remake everything.

	$ cd <your keystone folder>
	$ make -f hifive.mk linux-menuconfig
	wait for the GUI to load, then:
		1. Device drivers -> Network device support -> USB network adapters
		2. choose the appropriate drivers and turn them on (usually they are the RTL** something)
		3. Exit to go back to the Network device support page
		4. Now go to Ethernet driver support page
		5. choose the appropriate drivers and turn them on (mostly they are the Intel and Realtek ones)
		6. Now just keep Exit till the end and choose Yes when asked to save the new configurations

	$ cp hifive-conf/linux_defconfig hifive-conf/linux_cma_conf
	this line is for applying the new config file into the build file

	finally, remake everything:
	$ make clean
	if keystone-rv64:	$ make image -j`nproc`
	if keystone-rv32:	$ make -j`nproc`

## III. c) Make by the 'shortcut'

So, the bottom line of the 'formal' way above is just to creating a new **linux_cma_conf** file under the *hifive-conf/* directory.

Then, I give you [THE FILE](./linux_cma_conf), you know what to do:

	after copy the **linux_cma_conf** file to your <keystone folder>/hifive-conf/linux_cma_conf:
	and also after "Check the PATH things" at III. a):
	$ make clean
	$ make -j`nproc`
	
## III. d) Aftermath

After your changes on the kernel, the hash value of the **bbl.bin** file is different now.

So if you want to use the keystone-demo ([I. b)](#i-b-keystone-demo)), you have to do the followings to reapply the hashes to the image file of **bbl.bin**:

	$ cd <your keystone-demo folder>	#go to your keystone-demo folder
	$ make getandsethash
	$ rm trusted_client.riscv
	$ make trusted_client.riscv
	$ make copybins

	$ cd <your keystone folder>			#go to your keystone folder and update the bbl.bin there
	if keystone-rv64:	$ make image -j`nproc`	
	if keystone-rv32:	$ make -j`nproc`

* * *

# IV. Run Test on QEMU

	$ cd <keystone folder>			#go to your keystone folder
	$ ./scripts/run-qemu.sh
	Login by the id of 'root' and the password of 'sifive'.

	$ insmod keystone-driver.ko		#install driver

	To do the initial test:
	$ time ./tests/tests.ke			#ok if 'Attestation report SIGNATURE is valid' is printed

	To do the keystone-demo test:
	$ cd keystone-demo/			#go to the keystone-demo test
	$ ./enclave-host.riscv &			#run host in localhost
	$ ./trusted_client.riscv localhost	#connect to localhost and test
	okay if the 'Attestation signature and enclave hash are valid' is printed
	exit the Security Monitor by:	$ q

	exit QEMU by:	$ poweroff

* * *

# BOTTOM PAGE

| Back | Next |
| :--- | ---: |
| [Keystone: TEE framework (using Makefile) for RV32 Build](./keystone-makefile-32.md) | [Keystone: TEE framework (using CMake) for RV32 Build](./keystone-cmake-32.md) |
