---
layout : default
---

# SIFIVE FREEDOM CODE STRUCTURE

Understanding SiFive Freedom U540 Code Structure

* * *

# I. Introduction

Reference link for SiFive Freedom: https://github.com/sifive/freedom

# I. a) Important files

They have two main series of CPU called **E300** (rv32gc) and **U500** (rv64gc). The way they structured them are similar. They used three kind of scala files, i.e., *Shell* file, *Configs* file, and *Design* file, to create a system.

 - **The *Configs* file** is used as a configuration file for the CPU, and it's usually fixed for multiple designs.
 - **The *Design* file** is an extension upon the *Configs* file. In the *Design* file, all of the modules are called and connected. The *Design* file is also usually fixed for multiple platforms.
 - **The *Shell* file** is like a top file where all of the IOs are declared. They usually have one *Shell* file for each platform.

<table>
  <tr>
    <th>File</th>
    <th>Description</th>
    <th>Example file</th>
  </tr>
  <tr>
    <td><span style="font-weight:bold">Configs</span></td>
    <td></td>
		<td></td>
  </tr>
	<tr>
		<td><span style="font-weight:bold">Design</span></td>
		<td></td>
		<td></td>
	</tr>
	<tr>
		<td><span style="font-weight:bold">Shell</span></td>
		<td></td>
		<td></td>
	</tr>
</table>

## I. b) Build procedure

When 'make verilog' in the **freedom** top folder, the job of the Makefiles is just to pass the arguments into the **sbt** tool.

The **sbt** tool is a tool to compile the scala codes into java executable files. Then, subsequently, create the **.fir** files from those java executives.

The actual command to create **.fir** file from scala codes:
```makefile
java -jar $(rocketchip_dir)/sbt-launch.jar ++2.12.4 "runMain freechips.rocketchip.system.Generator $(BUILD_DIR) $(PROJECT) $(MODEL) $(CONFIG_PROJECT) $(CONFIG)"
```
where:
 - **$(BUILD_DIR)** is the folder that you want to generate your *.fir* file into
 - **$(PROJECT)** is the package that contains the *$(MODEL)*
 - **$(MODEL)** is the name of the top *Shell* in scala codes
 - **$(CONFIG_PROJECT)** is the package that contains the *$(CONFIG)*
 - **$(CONFIG)** is the name of the top *Design* in scala codes

After we have the **.fir** file, this is the command to create the verilog code from the **.fir** file:
```makefile
FIRRTL_JAR = $(rocketchip_dir)/firrtl/utils/bin/firrtl.jar
java -Xmx2G -Xss8M -XX:MaxPermSize=256M -cp $(FIRRTL_JAR) firrtl.Driver -i <path to .fir file> -o <path to .v file> -X verilog
```
The verilog codes are generated into one **.v** file. 

## I. c) Some concepts

* * *

# II. Shell File

This file is like a top file with the main purpose of IOs declaration.

SiFive Freedom codes are relied on extending the **LazyModule** which relied on **lazy val** declaration. Because of the **lazy** property, if a group of IOs isn't declared in the top Shell, the corresponding lazy module won't be instantiated, thus leading to the removal of the relevant modules in the actual implementation.

For example: in the *fpga-shells/src/main/scala/shell/xilinx/**VC707NewShell.scala***
```scala
abstract class VC707Shell()(implicit p: Parameters) extends Series7Shell
{
  . . .
  val led       = Overlay(LEDOverlayKey)       (new LEDVC707Overlay     (_, _, _))
  val switch    = Overlay(SwitchOverlayKey)    (new SwitchVC707Overlay  (_, _, _))
  . . .
}
```
If we just // the *val led* and *val switch*, like this:
```scala
abstract class VC707Shell()(implicit p: Parameters) extends Series7Shell
{
  . . .
  //val led       = Overlay(LEDOverlayKey)       (new LEDVC707Overlay     (_, _, _))
  //val switch    = Overlay(SwitchOverlayKey)    (new SwitchVC707Overlay  (_, _, _))
  . . .
}
```
Then the IOs of leds & switches won't be declared, thus the GPIOs module won't be instantiated in the design, and there will be no GPIOs module in the final verilog code.

* * *

# III. Configs File

This file is the configuration file for the CPUs and internal bus systems.

* * *

# IV. Design File 

This file carries out the actual implementation of the design, with all of the modules and how they are connected.

* * *

# BOTTOM PAGE

| Back |
| :--- |
| [Chisel Study Notes](./chisel.md) |

