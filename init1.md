---
layout : default
---

- [I. Init setup for new machine](#i-init-setup-for-new-machine)
- [II. Install tools](./init2.md)
  * II. a) Scala & sbt
  * II. b) Verilator
  * II. c) QEMU
  * II. d) Vivado 2016.4
- [III. RISC-V Toolchain](./init3.md)
  * III. a) Git clone
  * III. b) Configurations
  * III. c) Make

* * *

# I. Init setup for new machine

To make **vi** more comfortable:
	
	$ sudo apt install vim
	$ vi ~/.vimrc
	
	Then add this two lines below:
		set nocompatible
		syntax on

Update & upgrade everything:
	
	If your machine has proxy, replace the **http://[address]:[port]** with your proxy address:
	$ echo 'Acquire::http::proxy "http://[address]:[port]";' | sudo tee -a /etc/apt/apt.conf
	$ echo 'Acquire::https::proxy "http://[address]:[port]";' | sudo tee -a /etc/apt/apt.conf
	$ echo 'Acquire::ftp::proxy "http://[address]:[port]";' | sudo tee -a /etc/apt/apt.conf
		
	$ sudo apt update
	$ sudo apt upgrade
	$ sudo apt-get update
	$ sudo apt-get upgrade
	$ sudo apt install openjdk-8-jdk

Then install dependencies:

	$ sudo apt-get install autoconf automake autotools-dev curl libmpc-dev libmpfr-dev libgmp-dev libusb-1.0-0-dev gawk build-essential bison flex texinfo gperf libtool libssl-dev libpixman-1-dev patchutils bc zlib1g-dev libglib2.0-dev binutils-dev libboost-all-dev device-tree-compiler pkg-config libexpat-dev python libpython-dev python-pip python-capstone virtualenv git make g++

And other dependencies:

	$ sudo apt install gnutls-bin uuid-dev libpopt-dev libncurses5-dev libncursesw5-dev unzip glib2.0 expat gcc tmux wget bzip2 patch vim-common lbzip2 expect makeself patch npm
	
And the final dependency:

	For Ubuntu version > 16.04:
	$ sudo apt-get install libpng-dev
	
	For Ubuntu version < or = 16.04:
	$ sudo apt-get install libpng12-dev

Update proxy if your machine has proxy:

	Replace the **http://[address]:[port]** with your proxy address:
	
	for wget
	$ echo 'http_proxy = http://[address]:[port]/' | sudo tee -a /etc/wgetrc
	$ echo 'https_proxy = http://[address]:[port]/' | sudo tee -a /etc/wgetrc
	$ echo 'ftp_proxy = http://[address]:[port]/' | sudo tee -a /etc/wgetrc

	for git
	$ git config --global https.proxy http://[address]:[port]
	$ git config --global http.proxy http://[address]:[port]
	$ git config --global ftp.proxy http://[address]:[port]

	for npm
	$ npm config set proxy http://[address]:[port]/
	$ npm config set https-proxy http://[address]:[port]/
	$ npm config set ftp-proxy http://[address]:[port]/

	for curl
	$ echo 'proxy = "http://[address]:[port]"' | sudo tee -a ~/.curlrc

Finally, reboot the machine.

* * *

| [*back: Index*](./index.md) | [*next: II. Install tools*](./init2.md) |
| :--- | :--- |
||

