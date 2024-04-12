## Datasheet

### Overview
The `clint(core-local interruptor)` IP is a fully parameterised soft IP implementing the RISCV Privilege Specification v1.1 compatible CLINT. The IP features an APB4 slave interface, fully compliant with the AMBA APB Protocol Specification v2.0.

### Feature
* 64-bit programmable mtime and mtimecmp counter
* Software interrupt support
* Static synchronous design
* Full synthesizable

### Interface
| port name | type        | description          |
|:--------- |:------------|:---------------------|
| apb4 | interface | apb4 slave interface |
| clint ->| interface | clint slave interface |
| `clint.tmr_irq_o` | output | timer irq ouput |
| `clint.sfr_irq_o` | output | software irq ouput |

### Register

| name | offset  | length | description |
|:----:|:-------:|:-----: | :---------: |
| [MSIP](#mahcine-mod-software-interrupt) | 0x0 | 4 | machine mode software interrupt |
| [MTIMEL](#machine-timer-low) | 0x4 | 4 | machine timer low |
| [MTIMEH](#matchine-timer-high) | 0x8 | 4 | machine timer high |
| [MTIMECMPL](#matchine-timer-compare-low) | 0xC | 4 | machine timer compare low |
| [MTIMECMPH](#matchine-timer-compare-high) | 0x10 | 4 | machine timer compare high |

#### Machine Mode Software Interrupt
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:1]` | none | reserved |
| `[0:0]` | RW | MSIP |

reset value: `0x0000_0000`

* MSIP: This bit is reflected in MSIP of the `mip` CSR. A machine-level software interrupt for a HART is
 pending or cleared by writing 1 or 0 respectively to the corresponding this MSIP bit

#### Machine Timer Low
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:0]` | RW | MTIMEL |

reset value: `0x0000_0000`

* MTIMEL: the low 32-bit of 64-bit `mtime` CSR register

#### Machine Timer High
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:0]` | RW | MTIMEH |

reset value: `0x0000_0000`

* MTIMEH: the high 32-bit of 64-bit `mtime` CSR register

#### Machine Timer Compare Low
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:0]` | RW | MTIMECMPL |

reset value: `0xFFFF_FFFF`

* MTIMECMPL: the low 32-bit of 64-bit `mtimecmp` CSR register

#### Machine Timer Compare High
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:0]` | RW | MTIMECMPH |

reset value: `0xFFFF_FFFF`

* MTIMECMPH: the high 32-bit of 64-bit `mtimecmp` CSR register

### Program Guide
The software operation of `clint` is simple. These registers can be accessed by 4-byte aligned read and write. the C-like pseudocode of the timer interrupt operation:
```c
uint32_t val;
clint.MTIMECMPL = MTIMECMP_LOW_32_bit  // write low 32-bit mtimecmp register
clint.MTIMECMPH = MTIMECMP_HIGH_32_bit // write high 32-bit mtimecmp register
...

// === mtime interrupt handle start ===
// add new value to the mtime interrupt
clint.MTIMECMPL = UPDATE_DELTA_VALUE & 0x0000FFFF
clint.MTIMECMPH = UPDATE_DELTA_VALUE & 0xFFFF0000
// === mtime interrupt handle end ===
...

```
software interrupt operation:
```c
clint.MSIP = 1 // trigger software interrupt
...

// === software interrupt handle start ===
clint.MSIP = 0 // clear the software interrupt
// === software interrupt handle end ===
...

```

### Resoureces
### References
### Revision History