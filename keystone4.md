---
layout : default
---

- [I. Using prebuilt toolchain](./keystone1.md)
  * I. a) Keystone
  * I. b) Keystone-demo
- [II. Using native toolchain](./keystone2.md)
  * II. a) Keystone
  * II. b) Keystone-demo
- [III. Turn on USB & Ethernet drivers](./keystone3.md)
- [IV. Run test on QEMU](#iv-run-test-on-qemu)

* * *

# IV. Run test on QEMU

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
	exit the Security Monitor by:	$ q
	
	exit QEMU by:
	$ poweroff

* * *

| [*back: III. Turn on USB & Ethernet drivers*](./keystone3.md) | [*next: Freedom on VC707 guide*](./vc7071.md) |
| :--- | :--- |
||

