---
layout : default
---

# KEYSTONE (using Makefile) for RV64 Build

* * *

# I. Keystone

## I. a) Using their prebuilt toolchain (gcc-7.2)

*Note: because their prebuilt toolchain is RV64GC, so for the RV64IMAC build please follow the guide in [I. b) Using our local toolchain](#i-b-using-our-local-toolchain-gcc-83-in-this-example).*

Git clone:
```
$ git clone https://github.com/keystone-enclave/keystone.git keystone-rv64gc
$ cd keystone-rv64gc/
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
$ ./fast-setup.sh			#this will download their prebuilt toolchain (gcc-7.2) and set things up
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
If build for RV64GC:		$ git clone -b local-tc https://github.com/thuchoang90/keystone.git keystone-rv64gc-local
						$ cd keystone-rv64gc-local/

If build for RV64IMAC:		$ git clone -b local-tc https://github.com/thuchoang90/keystone.git keystone-rv64imac
						$ cd keystone-rv64imac/
```

Check PATH:
```
$ echo ${PATH}			#check if our toolchain is on the PATH or not
# if not then export it to PATH
If build for RV64GC:		$ export RISCV=/opt/GCC8/riscv64gc		#point to RV64GC toolchain
If build for RV64IMAC:		$ export RISCV=/opt/GCC8/riscv64imac	#point to RV64IMAC toolchain

$ export PATH=$RISCV/bin/:$PATH
$ export KEYSTONE_DIR=`pwd`
$ export KEYSTONE_SDK_DIR=`pwd`/sdk
```

Update submodule:
```
$ ./fast-setup.sh	#this time, it won't download the prebuilt toolchain, just update the submodule
```

Do the following if build for RV64IMAC, skip if build for RV64GC:
```
$ ./scripts/imac-patch.sh
```

Finally, make:
```
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

*Note: using local toolchain cause trouble on running QEMU, but totally fine with FPGA.*

# II. Keystone-demo

Check PATH:
- Pair with the prebuilt-toolchain of Keystone: *(Note: prebuilt-toolchain is RV64GC, so if you want to build for RV64IMAC please follow the local-built-toolchain)*

```
$ echo ${PATH}			#and MAKE SURE that NO ANY TOOLCHAIN is on the PATH
$ cd keystone-rv64gc/		#go to your keystone folder
$ . source.sh
$ export KEYSTONE_DIR=`pwd`
```

- Pair with the local-built-toolchain of Keystone:

```
#go to your keystone folder
$ cd keystone-rv64gc-local/
Or: $ cd keystone-rv64imac/

$ echo ${PATH}			#check if our toolchain is on the PATH or not
# if not then export it to PATH
If build for RV64GC:		$ export RISCV=/opt/GCC8/riscv64gc	#point to RV64GC toolchain
If build for RV64IMAC:		$ export RISCV=/opt/GCC8/riscv64imac	#point to RV64IMAC toolchain

$ export PATH=$RISCV/bin/:$PATH
$ export KEYSTONE_DIR=`pwd`
$ export KEYSTONE_SDK_DIR=`pwd`/sdk
```

Git clone:
```
$ cd ../			#go back outside
$ git clone https://github.com/keystone-enclave/keystone-demo.git keystone-demo-rv64
(branch master commit a25084ea on 18-Dec-2019)
```

Make:
```
$ cd keystone-demo-rv64/
$ . source.sh
$ ./quick-start.sh		#type Y when asked
after this step, a new app is generated and coppied to the keystone directory
```

Update keystone-demo to the keystone/ folder:
```
$ cd ${KEYSTONE_DIR}		#now go back to the keystone folder
$ make image -j`nproc`			#and update the bbl.bin there
```

**Note on local-built-toolchain:** because the QEMU fail on Keystone with local toolchain, thus the **$ make getandsethash** bellow can't run on local-built-toolchain. This is a TODO. The following step is for prebuilt-toolchain.

To update the new hash value, do the followings:
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

# III. Run Test on QEMU

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

* * *

# BOTTOM PAGE

| Back | Next |
| :--- | ---: |
| [Initial Setup](./init.md) | [Keystone: TEE framework (using Makefile) for RV32 Build](./keystone-makefile-32.md) |
