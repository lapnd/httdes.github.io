---
layout : default
---

# TURN ON DRIVERS FOR KEYSTONE

* * *

# I. USB & Ethernet Drivers

There are two ways of doing this, the 'formal' way, and the shortcut.

### But first, check the PATH things:
```
$ echo ${PATH}					#and MAKE SURE that NO ANY TOOLCHAIN is on the PATH
$ cd <your keystone folder>			#go to your keystone folder
$ . source.sh
$ export KEYSTONE_DIR=`pwd`

$ cd <your keystone-demo folder>	#go to your keystone-demo folder
$ . source.sh
```

## I. a) Make the 'formal' way

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

## I. b) Make by the 'shortcut'

So, the bottom line of the 'formal' way above is just to creating a new **linux_cma_conf** file under the *hifive-conf/* directory.

Then, I give you [THE FILE](./linux_cma_conf), you know what to do:
- Copy the **linux_cma_conf** file to your <keystone folder>/hifive-conf/linux_cma_conf
- Check the PATH things at III. a)
- Make:

```
$ make clean
$ make -j`nproc`
```

## I. c) Remake after changes

After your changes on the kernel, the hash value of the **bbl.bin** file is different now.

So if you want to use the keystone-demo ([I. b)](#i-b-keystone-demo)), you have to do the followings to reapply the hashes to the image file of **bbl.bin**:
```
$ cd <your keystone-demo folder>	#go to your keystone-demo folder
$ make getandsethash
$ rm trusted_client.riscv
$ make trusted_client.riscv
$ make copybins

$ cd <your keystone folder>			#go to your keystone folder and update the bbl.bin there
if keystone-rv64:	$ make image -j`nproc`	
if keystone-rv32:	$ make -j`nproc`
```

* * *

# BOTTOM PAGE

| Back | Next |
| :--- | ---: |
| [Keystone (using CMake) for RV64 Build](./keystone-cmake-64.md) | [SiFive Freedom](./vc707.md) |
