# II. Hardware: Simulate with Verilator

#### Install tools

Guide to install verilator is in [Initial Setup: II. c)](./init.md#ii-c-verilator)

To use simulation, you also need to install the [riscv-isa-sim](https://github.com/riscv/riscv-isa-sim).
```
$ git clone https://github.com/riscv/riscv-isa-sim.git
$ cd riscv-isa-sim/
$ mkdir build
$ cd build
$ ../configure --prefix=/opt/GCC8/riscv64gc	#point to your toolchain
$ make
$ sudo make install
```

#### Build TEE-Hardware WithSimulation

Export appropriate toolchain to your PATH:
```
check PATH:		$ echo ${PATH}		#check the toolchain is on the PATH or not	
if not, then:		$ export RISCV=/opt/riscv64gc
			$ export PATH=${RISCV}/bin/:${PATH}
```

Make simulation:
```
$ cd tee-hardware/	#go to your tee-hardware folder
$ cd simulator/verilator/
$ make
```

After make, it will generate an executable file, use it with **software/simbootloader**
