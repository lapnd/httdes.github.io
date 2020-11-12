# KEYSTONE (using CMake) for RV32 Build

* * *

# I. Keystone

## I. a) Using their prebuilt toolchain (gcc-7.2)

Note: because their prebuilt toolchain is RV64GC, so for the RV64IMAC build please follow the guide in [I. b) Using our local toolchain](#i-b-using-our-local-toolchain-gcc-83-in-this-example).

Git clone:
```
$ git clone -b dev-cmake https://192.168.100.100/rinkai/keystone.git keystone-rv32gc
$ cd keystone-rv32gc/
```

Check PATH:
```
$ echo ${PATH}			#and MAKE SURE that NO ANY TOOLCHAIN is on the PATH
$ export KEYSTONE_DIR=`pwd`
```

Download prebuilt toolchain:
```
$ ./aist-setup32.sh		#this will download the prebuilt toolchain (gcc-7.2) and set things up
$ . source32.sh			#update PATH
```

Update sdk examples:
```
$ cd sdk/
$ sed -i 's/size_t[ ]*freemem_size[ ]*=[ ]*48/size_t freemem_size = 2/g' examples/tests/test-runner.cpp
(this line is for FPGA board, because usually there is only 1GB of memory on the board)
$ cd build/
$ make examples
$ cd ../../		#back outside
```

Create build folder then make:
```
$ mkdir build
$ cd build/
$ cmake .. -DRISCV32=y
$ make -j`nproc`
$ make run-tests	#after this, a bbl.bin file is generated
```

## I. b) Using our local toolchain (gcc-8.3 in this example)

Git clone:
```
If build for RV64GC:	$ git clone -b dev-cmake-local https://192.168.100.100/rinkai/keystone.git keystone-rv64gc-local
			$ cd keystone-rv64gc-local/

If build for RV64IMAC:	$ git clone -b dev-cmake-local https://192.168.100.100/rinkai/keystone.git keystone-rv64imac
			$ cd keystone-rv64imac/
```

Check PATH:
```
$ echo ${PATH}		#check if our toolchain is on the PATH or not
# if not then export it to PATH
If build for RV64GC:	$ export RISCV=/opt/GCC8/riscv64gc	#point to RV64GC toolchain
If build for RV64IMAC:	$ export RISCV=/opt/GCC8/riscv64imac	#point to RV64IMAC toolchain

$ export PATH=$RISCV/bin/:$PATH
$ export KEYSTONE_DIR=`pwd`
```

Update submodule:
```
$ ./aist-setup.sh	#this time, it won't download the prebuilt toolchain, just update the submodule
```

Do the following if build for RV64IMAC, skip if build for RV64GC:
```
$ ./patches/imac-patch.sh
```

Update sdk example:
```
$ cd sdk/
$ sed -i 's/size_t[ ]*freemem_size[ ]*=[ ]*48/size_t freemem_size = 2/g' examples/tests/test-runner.cpp
(this line is for FPGA board, because usually there is only 1GB of memory on the board)
$ cd build/
$ export KEYSTONE_SDK_DIR=`pwd`
$ make examples
$ cd ../../	#back outside
```

Create build folder then make:
```
$ mkdir build
$ cd build/
$ cmake ..
$ make -j`nproc`
$ make run-tests	#after this, a bbl.bin file is generated
```

* * *

# II. Keystone-demo

Check PATH:
- Pair with the prebuilt-toolchain of Keystone: *(Note: prebuilt-toolchain is RV64GC, so if you want to build for RV64IMAC please follow the local-built-toolchain)*

```
$ echo ${PATH}			#and MAKE SURE that NO ANY TOOLCHAIN is on the PATH
$ cd keystone-rv64gc/		#go to your keystone folder
$ . source.sh
$ export KEYSTONE_DIR=`pwd`
$ export KEYSTONE_BUILD_DIR=`pwd`/build		#point to the build folder
```

- Pair with the local-built-toolchain of Keystone:

```
#go to your keystone folder
$ cd keystone-rv64gc-local/
Or: $ cd keystone-rv64imac/

$ echo ${PATH}		#check if our toolchain is on the PATH or not
# if not then export it to PATH
If build for RV64GC:	$ export RISCV=/opt/GCC8/riscv64gc	#point to RV64GC toolchain
If build for RV64IMAC:	$ export RISCV=/opt/GCC8/riscv64imac	#point to RV64IMAC toolchain

$ export PATH=$RISCV/bin/:$PATH
$ export KEYSTONE_DIR=`pwd`
$ export KEYSTONE_SDK_DIR=`pwd`/sdk/build
$ export KEYSTONE_BUILD_DIR=`pwd`/build		#point to the build folder
```

Git clone:
```
$ cd ../	#go back outside
$ git clone -b cmake https://192.168.100.100/rinkai/keystone-demo.git keystone-demo-rv64
```

Make:
```
$ cd keystone-demo-rv64/
$ . source.sh
$ ./quick-start.sh	#type Y when asked
$ . copybins.sh		#copy binaries to keystone overlay
```

Update keystone-demo to keystone build folder:
```
$ cd ${KEYSTONE_BUILD_DIR}	#now go back to the keystone folder
$ make image			#and update the bbl.bin there
```

Note: there is kind of a bug with "script/run-qemu.sh", so do this to make sure that the "script/run-qemu.sh" will run smoother later
```
$ <open a new terminal>
$ cd <to the keystone build folder>
$ ./script/run-qemu.sh
Log in by the id of "root" and the password of "sifive"
Then exit qemu by "poweroff"
If it got stuck with "Power off" then just close the terminal
```

To update the new hash value to the keystone-demo folder, do the followings:
```
Now go back with the original terminal ealier
$ cd ../../keystone-demo-rv64/		#first, cd back to the keystone-demo directory
$ ./scripts/get_attestation.sh ./include
(if it stuck at "Power off", just Ctrl+C)
$ rm build/trusted_client.riscv
$ make -C build/ trusted_client.riscv
$ . copybins.sh
after this step, the app is updated with the correct hash value and coppied to the keystone directory

$ cd ${KEYSTONE_BUILD_DIR}	#now go back to the keystone folder
$ make image			#and update the bbl.bin there
```

***Note:*** sometimes ***./scripts/get_attestation.sh ./include*** encountered a problem like this:
```
spawn ./scripts/run-qemu.sh
**** Running QEMU SSH on port 3000 ****
qemu-system-riscv64: Could not set up host forwarding rule 'tcp::3000-:22'
expect: spawn id exp4 not open
    while executing
"expect "*?assword" { send "sifive\r" }"
Could not extract the SM_HASH!
```

Then just change the SSH port in **${KEYSTONE_BUILD_DIR}/scripts/get_attestation.sh** from:
```
HOST_PORT=${HOST_PORT:="$((3000 + RANDOM % 3000))"};
```
To any fix number like this for example:
```
HOST_PORT=${HOST_PORT:="$((3222))"};
```

* * *

# III. Run Test on QEMU

```
$ cd <keystone folder>		#go to your keystone folder
$ cd build/			#go to build folder
$ ./scripts/run-qemu.sh
Login by the id of 'root' and the password of 'sifive'.

$ insmod keystone-driver.ko	#install driver

To do the initial test:
$ time ./tests.ke		#ok if 'Attestation report SIGNATURE is valid' is printed

To do the keystone-demo test:
$ cd keystone-demo/		#go to the keystone-demo test
$ ./demo-server.riscv &		#run host in localhost
$ ./trusted_client.riscv localhost	#connect to localhost and test
okay if the 'Attestation signature and enclave hash are valid' is printed
exit the Security Monitor by:	$ q

exit QEMU by:	$ poweroff
```

***Note:*** sometimes ***./scripts/run-qemu.sh*** encountered a problem like this:
```
**** Running QEMU SSH on port 5291 ****
overriding secure boot ROM (file: /home/ubuntu/Projects/Keystone/CMake/keystone-rv64gc-local/build/bootrom.build/bootrom.bin)
boot ROM size: 54061
fdt dumped at 58157
qemu-system-riscv64: -device virtio-blk-device,drive=hd0: Failed to get "write" lock
Is another process using the image [/home/ubuntu/Projects/Keystone/CMake/keystone-rv64gc-local/build/buildroot.build/images/rootfs.ext2]?
```

Then just remake the image and rerun again:
```
$ make image -j`nproc`
$ ./scripts/run-qemu.sh
```

* * *



#!/bin/bash

set -e

echo "Starting RV32 Instllation..."

if ( $(command -v riscv32-unknown-linux-gnu-gcc > /dev/null) &&
  $(command -v riscv32-unknown-elf-gcc > /dev/null) )
then
  echo "RISCV32 tools are already installed"
else
  echo "Downloading Prebuilt RISC-V 32 Toolchain... "

  export RISCV32=$(pwd)/riscv32
  export PATH=$PATH:$RISCV32/bin
  wget https://keystone-enclave.eecs.berkeley.edu/files/rv32gc.tar.gz

  # Check tool integrity
  echo "Verifying prebuilt toolchain integrity..."
  sha256sum -c .prebuilt_tools_shasums --status --ignore-missing
  if [[ $? != 0 ]]
  then
      echo "Toolchain binary download incomplete or corrupted. You can build the toolchain locally or try again."
      exit 1
  fi

  tar -xzvf rv32gc.tar.gz
  mv riscv32gc riscv32
  rm rv32gc.tar.gz
  echo "Toolchain has been installed in $RISCV32"
fi

echo "Updating and cloning submodules, this may take a long time"
git config submodule.riscv-gnu-toolchain.update none

# shallow clone submodules ahead of time (Git must be > 2.11)
if [ ! -e linux/.git ]; then
  git clone --shallow-since=2019-09-14 https://github.com/torvalds/linux.git linux
fi
if [ ! -e buildroot/.git ]; then
  git clone --shallow-since=2019-08-29 https://github.com/buildroot/buildroot.git buildroot
fi
if [ ! -e qemu/.git ]; then
  git clone --shallow-since=2018-08-14 https://github.com/qemu/qemu.git qemu
fi

git config submodule.qemu.update none
git submodule sync --recursive
git submodule update --init --recursive

cd qemu
git checkout 146aa0f
sed -i 's/git\.qemu\.org\/git/github.com\/qemu/g' .gitmodules
git submodule update --init --recursive
cd ..

# build SDK if not present
if [ -z $KEYSTONE_SDK_DIR ]
then
  echo "KEYSTONE_SDK_DIR is not set. Installing from $(pwd)/sdk"
  export KEYSTONE_SDK_DIR=$(pwd)/sdk/build
  cd sdk
  mkdir -p build
  cd build
  cmake .. -DRISCV32=y
  make
  make install
  cd ../..
fi

# update source.sh
sed "s|KEYSTONE_SDK_DIR=.*|KEYSTONE_SDK_DIR=$KEYSTONE_SDK_DIR|" -i source32.sh

echo "RISC-V toolchain and Keystone SDK have been fully setup"
