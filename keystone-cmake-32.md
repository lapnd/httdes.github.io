---
layout : default
---

# KEYSTONE (using CMake) for RV32 Build

* * *

**ISSUE: cmake-32 has a lot of problems, so the branch dev-rv32-cmake just keep there as reference, but nothing works.**

**Trouble with generating image and build the test.ke, also the path for overlay/root/ folder is messed up. And the keystone-demo wasn't touched yet.**

* * *

# I. Keystone

Note: because their prebuilt toolchain is RV64GC, so for the RV32GC/RV32IMAC build we'll using our local toolchain.

Git clone:
```
If build for RV32GC:	$ git clone -b dev-rv32-cmake https://github.com/thuchoang90/keystone.git keystone-rv32gc
					$ cd keystone-rv32gc/

If build for RV32IMAC:	$ git clone -b dev-rv32-cmake https://github.com/thuchoang90/keystone.git keystone-rv32imac
					$ cd keystone-rv32imac/
```

Check PATH:
```
$ echo ${PATH}			#check if our toolchain is on the PATH or not
# if not then export it to PATH
If build for RV32GC:		$ export RISCV=/opt/GCC8/riscv32gc			#point to RV32GC toolchain
If build for RV32IMAC:		$ export RISCV=/opt/GCC8/riscv32imac		#point to RV32IMAC toolchain

$ export PATH=$RISCV/bin/:$PATH
$ export KEYSTONE_DIR=`pwd`
$ export KEYSTONE_SDK_DIR=`pwd`/sdk
```

Update submodule:
```
$ ./fast-setup.sh		#this time, it won't download the prebuilt toolchain, just update the submodule

# make sdk
$ make -C sdk
$ export EYRIE_DIR=`pwd`/sdk/rts/eyrie
$ ./sdk/scripts/init.sh --runtime eyrie --force
```

Do the following if build for RV32IMAC, skip if build for RV32GC:
```
$ ./patches/imac-patch.sh
```

Create build folder:
```
$ mkdir build
$ cd build/
```

To make: *(Rust-build currently has issue, so please follow the normal-build)*
- Normal-build:
```
$ cmake .. -DRISCV32=y
$ make -j`nproc`
```
- Rust-build:
```
$ rustup update nightly
$ cmake .. -DRISCV32=y -DUSE_RUST_SM=y -DSM_CONFIGURE_ARGS="--enable-opt=0"
$ make -j`nproc`
```
The second SM_CONFIGURE_ARGS option is temporarily, see [PR#62](https://github.com/keystone-enclave/riscv-pk/pull/62).

Build the keystone-test:
```
$ sed -i 's/size_t\sfreemem_size\s=\s48\*1024\*1024/size_t freemem_size = 2*1024*1024/g' ../tests/tests/test-runner.cpp
(this line is for FPGA board, because usually there is only 1GB of memory on the board)
$ make run-tests		#after this, a bbl.bin file is generated
```

* * *

# BOTTOM PAGE

| Back | Next |
| :--- | ---: |
| [Keystone: TEE framework (using CMake) for RV64 Build](./keystone-cmake-64.md) | [Turn on drivers in Keystone](./keystone-drivers.md) |
