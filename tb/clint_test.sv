// Copyright (c) 2023-2024 Miao Yuchi <miaoyuchi@ict.ac.cn>
// clint is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

`ifndef INC_CLINT_TEST_SV
`define INC_CLINT_TEST_SV

`include "apb4_master.sv"
`include "clint_define.sv"

class ClintTest extends APB4Master;
  string                 name;
  int                    wr_val;
  virtual apb4_if.master apb4;
  virtual clint_if.tb    clint;

  extern function new(string name = "clint_test", virtual apb4_if.master apb4,
                      virtual clint_if.tb clint);
  extern task automatic test_reset_reg();
  extern task automatic test_wr_rd_reg(input bit [31:0] run_times = 1000);
  extern task automatic test_irq(input bit [31:0] run_times = 1000);
endclass

function ClintTest::new(string name, virtual apb4_if.master apb4, virtual clint_if.tb clint);
  super.new("apb4_master", apb4);
  this.name   = name;
  this.wr_val = 0;
  this.apb4   = apb4;
  this.clint  = clint;
endfunction

task automatic ClintTest::test_reset_reg();
  super.test_reset_reg();
  // verilog_format: off
  this.rd_check(`CLINT_MSIP_ADDR, "MSIP REG", 32'b0 & {`CLINT_MSIP_WIDTH{1'b1}}, Helper::EQUL, Helper::INFO);
  this.rd_check(`CLINT_MTIMECMPL_ADDR, "MTIMECMPL REG", 32'hFFFF_FFFF, Helper::EQUL, Helper::INFO);
  this.rd_check(`CLINT_MTIMECMPH_ADDR, "MTIMECMPH REG", 32'hFFFF_FFFF, Helper::EQUL, Helper::INFO);
  // verilog_format: on
endtask

task automatic ClintTest::test_wr_rd_reg(input bit [31:0] run_times = 1000);
  super.test_wr_rd_reg();
  // verilog_format: off
  for (int i = 0; i < run_times; i++) begin
    this.wr_rd_check(`CLINT_MSIP_ADDR, "MSIP REG", $random & {`CLINT_MSIP_WIDTH{1'b1}}, Helper::EQUL);
    this.wr_rd_check(`CLINT_MTIMECMPL_ADDR, "MTIMECMPL REG", $random, Helper::EQUL);
    this.wr_rd_check(`CLINT_MTIMECMPH_ADDR, "MTIMECMPH REG", $random, Helper::EQUL);
  end
  // verilog_format: on
endtask

task automatic ClintTest::test_irq(input bit [31:0] run_times = 1000);
  super.test_irq();
  $display("test timer irq");
  repeat (200) @(posedge this.apb4.pclk);
  this.write(`CLINT_MSIP_ADDR, 32'b0 & {`CLINT_MSIP_WIDTH{1'b1}});
  this.write(`CLINT_MTIMECMPL_ADDR, 32'hEFF);
  this.write(`CLINT_MTIMECMPH_ADDR, 32'h0);
  @(this.clint.tmr_irq_o);
  $display("%t tmr_irq_o: %d", $time, this.clint.tmr_irq_o);
  this.write(`CLINT_MTIMECMPL_ADDR, 32'h10FF);
  @(this.clint.tmr_irq_o);
  $display("%t tmr_irq_o: %d", $time, this.clint.tmr_irq_o);

  $display("test software irq");
  this.write(`CLINT_MSIP_ADDR, 32'b1 & {`CLINT_MSIP_WIDTH{1'b1}});
  wait(this.clint.sfr_irq_o);
  $display("%t sfr_irq_o: %d", $time, this.clint.sfr_irq_o);

endtask
`endif
