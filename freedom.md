---
layout : default
---

# SIFIVE FREEDOM CODE STRUCTURE

Understanding SiFive Freedom U540 Code Structure

* * *

# I. Introduction

Reference link for SiFive Freedom: https://github.com/sifive/freedom

They have two main series of CPU called **E300** (*rv32gc:* 32bit RISC-V with **G**(*eneral*) and **C**(*ompressed*) extensions) and **U500** (*rv64gc:* 64bit RISC-V with **G**(*eneral*) and **C**(*ompressed*) extensions).

* * *

# II. Shell

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

# III. DevKitConfigs

This file is the configuration file for the CPUs and internal bus systems.

* * *

# IV. DevKitFPGADesign: 

This file carries out the actual implementation of the design, with all of the modules and how they are connected.

* * *

# BOTTOM PAGE

| Back |
| :--- |
| [Chisel Study Notes](./chisel.md) |

