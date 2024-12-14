// Copyright (c) 2023-2024 Miao Yuchi <miaoyuchi@ict.ac.cn>
// clint is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

`ifndef INC_CLINT_DEF_SV
`define INC_CLINT_DEF_SV

/* register mapping
 * CLINT_MSIP:
 * BITS:   | 31:1  | 0    |
 * FIELDS: | RES   | MSIP |
 * PERMS:  | NONE  | RW   |
 * ------------------------
 * CLINT_MTIMEL:
 * BITS:   | 31:0   |
 * FIELDS: | MTIMEL |
 * PERMS:  | RO     |
 * ------------------------
 * CLINT_MTIMEH:
 * BITS:   | 31:0   |
 * FIELDS: | MTIMEH |
 * PERMS:  | RO     |
 * ------------------------
 * CLINT_MTIMECMPL:
 * BITS:   | 31:0      |
 * FIELDS: | MTIMECMPL |
 * PERMS:  | RW        |
 * ------------------------
 * CLINT_MTIMECMPH:
 * BITS:   | 31:0      |
 * FIELDS: | MTIMECMPH |
 * PERMS:  | RW        |
 * ------------------------
*/

// verilog_format: off
`define CLINT_MSIP      4'b0000 // BASEADDR + 0x00
`define CLINT_MTIMEL    4'b0001 // BASEADDR + 0x04
`define CLINT_MTIMEH    4'b0010 // BASEADDR + 0x08
`define CLINT_MTIMECMPL 4'b0011 // BASEADDR + 0x0C
`define CLINT_MTIMECMPH 4'b0100 // BASEADDR + 0x10


`define CLINT_MSIP_ADDR      {26'b0, `CLINT_MSIP     , 2'b00}
`define CLINT_MTIMEL_ADDR    {26'b0, `CLINT_MTIMEL   , 2'b00}
`define CLINT_MTIMEH_ADDR    {26'b0, `CLINT_MTIMEH   , 2'b00}
`define CLINT_MTIMECMPL_ADDR {26'b0, `CLINT_MTIMECMPL, 2'b00}
`define CLINT_MTIMECMPH_ADDR {26'b0, `CLINT_MTIMECMPH, 2'b00}

`define CLINT_MSIP_WIDTH     1
`define CLINT_MTIME_WIDTH    64
`define CLINT_MTIMECMP_WIDTH 64

interface clint_if(input logic rtc_clk_i);
    logic  tmr_irq_o;
    logic  sfr_irq_o;
    
    modport dut(input rtc_clk_i, output tmr_irq_o, output sfr_irq_o);
    modport tb(input rtc_clk_i, input tmr_irq_o, input sfr_irq_o);
endinterface
// verilog_format: on
`endif
