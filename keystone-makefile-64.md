---
layout : default
---

# KEYSTONE: TEE FRAMEWORK (Using Makefile) for RV64 Build

* * *

# I. Keystone

## I. a) Using their prebuilt toolchain (gcc-7.2)

Git clone:
```
$ git clone https://github.com/keystone-enclave/keystone.git keystone-rv64
$ cd keystone-rv64/
$ git checkout 276e14b6e53130fd5278f700ab1b99332ca143fd		#commit on 23-Nov-2019
(this is the commit right before upgrading to CMake)
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
$ make -j`nproc`
```

Build the keystone-test:
```
$ sed -i 's/size_t\sfreemem_size\s=\s48\*1024\*1024/size_t freemem_size = 2*1024*1024/g' ./tests/tests/test-runner.cpp
(this line is for FPGA board, because usually there is only 1GB of memory on the board)

$ ./sdk/scripts/vault-sample.sh
$ ./tests/tests/vault.sh
$ make image -j`nproc`		#after this, a bbl.bin file is generated in hifive-work/bbl.bin
```

## I. b) Using our local toolchain (gcc-8.3 in this example)

Git clone:
```
$ git clone https://github.com/keystone-enclave/keystone.git keystone-rv64-local
$ cd keystone-rv64-local/
$ git checkout 276e14b6e53130fd5278f700ab1b99332ca143fd		#commit on 23-Nov-2019
(this is the commit right before upgrading to CMake)
```

Check PATH:
```
$ echo ${PATH}			#check if our toolchain is on the PATH or not
$ export RISCV=/opt/GCC8/riscv64gc	#if not then export it to PATH
$ export PATH=$RISCV/bin/:$PATH
$ export KEYSTONE_DIR=`pwd`
$ export KEYSTONE_SDK_DIR=`pwd`/sdk
```

Update submodule:
```
$ ./fast-setup.sh	#this time, it won't download the prebuilt toolchain, just update the submodule
```

We need to do some modifications before make:
```
$ vi hifive-conf/buildroot_initramfs_config
Then change the "GCC_7=y" to "GCC_8=y"

$ vi hifive-conf/buildroot_rootfs_config
Then change "GCC_7=y" to "GCC_8=y"

$ vi buildroot/support/scripts/check-kernel-headers.sh
Then change the line "return 1" to "return 0"

Finally,
$ make -j`nproc`
```

Build the keystone-test:
```
$ sed -i 's/size_t\sfreemem_size\s=\s48\*1024\*1024/size_t freemem_size = 2*1024*1024/g' ./tests/tests/test-runner.cpp
(this line is for FPGA board, because usually there is only 1GB of memory on the board)

$ ./sdk/scripts/vault-sample.sh
$ ./tests/tests/vault.sh
$ make image -j`nproc`		#after this, a bbl.bin file is generated in hifive-work/bbl.bin
```

## I. c) Run Test on QEMU

*Note: using local toolchain cause trouble on running QEMU, but totally fine with FPGA.*

Running QEMU on Keystone with local toolchain is a TODO.

```
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
```

# II. Keystone-demo

## II. a) Using their prebuilt toolchain (gcc-7.2)

Check PATH:
```
$ echo ${PATH}				#and MAKE SURE that NO ANY TOOLCHAIN is on the PATH
$ cd keystone-rv64/		#go to your keystone folder
$ . source.sh
$ export KEYSTONE_DIR=`pwd`
```

Git clone:
```
$ cd ../						#go back outside
$ git clone https://github.com/keystone-enclave/keystone-demo.git keystone-demo-rv64
(branch master commit a25084ea on 18-Dec-2019)
```

Make:
```
$ cd keystone-demo-rv64/
$ . source.sh
$ ./quick-start.sh				#type Y when asked
after this step, a new app is generated and coppied to the keystone directory
```

Update keystone-demo to the keystone/ folder:
```
cd back to the keystone directory and remake the image with the new keystone-demo app
$ cd ${KEYSTONE_DIR}		#now go back to the keystone folder
$ make image -j`nproc`			#and update the bbl.bin there
```

However, it will be a false attestation. To update the new hash value, do the followings:
```
$ cd ../keystone-demo-rv64/		#first, cd back to the keystone-demo directory
$ make getandsethash
$ rm trusted_client.riscv
$ make trusted_client.riscv
$ make copybins
after this step, the app is updated with the correct hash value and coppied to the keystone directory

$ cd ${KEYSTONE_DIR}		#now go back to the keystone folder
$ make image -j`nproc`			#and update the bbl.bin there
```

### Using Our Own Local Toolchain (gcc-8.3 in this example)

Check PATH:
```
$ cd keystone-rv64-local/		#go to your keystone folder
$ echo ${PATH}			#check if our toolchain is on the PATH or not
$ export RISCV=/opt/GCC8/riscv64gc	#if not then export it to PATH
$ export PATH=$RISCV/bin/:$PATH
$ export KEYSTONE_DIR=`pwd`
$ export KEYSTONE_SDK_DIR=`pwd`/sdk
```

Git clone:
```
$ cd ../						#go back outside
$ git clone https://github.com/keystone-enclave/keystone-demo.git keystone-demo-rv64-local
(branch master commit a25084ea on 18-Dec-2019)
```

Make:
```
$ cd keystone-demo-rv64-local/
$ . source.sh
$ ./quick-start.sh				#type Y when asked
after this step, a new app is generated and coppied to the keystone directory
```

Update keystone-demo to the keystone/ folder:
```
cd back to the keystone directory and remake the image with the new keystone-demo app
$ cd ${KEYSTONE_DIR}		#now go back to the keystone folder
$ make image -j`nproc`			#and update the bbl.bin there
```

However, because the QEMU fail on Keystone with local toolchain, thus the **$ make getandsethash** on the Keystone-demo can't be done. This is a TODO.

* * *

# III. USB & Ethernet Drivers

There are two ways of doing this, the 'formal' way, and the shortcut.

## III. a) Check the PATH things

```
$ echo ${PATH}					#and MAKE SURE that NO ANY TOOLCHAIN is on the PATH
$ cd <your keystone folder>			#go to your keystone folder
$ . source.sh
$ export KEYSTONE_DIR=`pwd`

$ cd <your keystone-demo folder>	#go to your keystone-demo folder
$ . source.sh
```

## III. b) Make the 'formal' way

The proper way to modify drivers in Linux kernel is open the kernel, select or diselect some drivers, apply the changes, and remake everything.

```
$ cd <your keystone folder>
$ make -f hifive.mk linux-menuconfig
```

wait for the GUI to load, then:
```
1. Device drivers -> Network device support -> USB network adapters
2. choose the appropriate drivers and turn them on (usually they are the RTL** something)
3. Exit to go back to the Network device support page
4. Now go to Ethernet driver support page
5. choose the appropriate drivers and turn them on (mostly they are the Intel and Realtek ones)
6. Now just keep Exit till the end and choose Yes when asked to save the new configurations
```

This line is for applying the new config file into the build file
```
$ cp hifive-conf/linux_defconfig hifive-conf/linux_cma_conf
```

Finally, remake everything:
```
$ make clean
if keystone-rv64:	$ make image -j`nproc`
if keystone-rv32:	$ make -j`nproc`
```

## III. c) Make by the 'shortcut'

So, the bottom line of the 'formal' way above is just to creating a new **linux_cma_conf** file under the *hifive-conf/* directory.

Then, I give you [THE FILE](./linux_cma_conf), you know what to do:
- Copy the **linux_cma_conf** file to your <keystone folder>/hifive-conf/linux_cma_conf
- Check the PATH things at III. a)
- Make:
```
$ make clean
$ make -j`nproc`
```

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

# BOTTOM PAGE

| Back | Next |
| :--- | ---: |
| [Initial Setup](./init.md) | [Keystone: TEE framework (using Makefile) for RV32 Build](./keystone-makefile-32.md) |
