// Copyright (c) 2023-2024 Miao Yuchi <miaoyuchi@ict.ac.cn>
// clint is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

`include "apb4_if.sv"
`include "clint_define.sv"

module apb4_clint_tb ();
  localparam CLK_PEROID = 10;
  // localparam LOW_CLK_PEROID = 30518; // 32768Hz
  localparam LOW_CLK_PEROID = 50; // sim
  logic rst_n_i, clk_i, low_clk_i;

  initial begin
    clk_i = 1'b0;
    forever begin
      #(CLK_PEROID / 2) clk_i <= ~clk_i;
    end
  end

  initial begin
    low_clk_i = 1'b0;
    forever begin
      #(LOW_CLK_PEROID / 2) low_clk_i <= ~low_clk_i;
    end
  end

  task sim_reset(int delay);
    rst_n_i = 1'b0;
    repeat (delay) @(posedge clk_i);
    #1 rst_n_i = 1'b1;
  endtask

  initial begin
    sim_reset(40);
  end

  apb4_if u_apb4_if (
      clk_i,
      rst_n_i
  );

  clint_if u_clint_if (low_clk_i);

  test_top u_test_top (
      .apb4 (u_apb4_if.master),
      .clint(u_clint_if.tb)
  );
  apb4_clint u_apb4_clint (
      .apb4 (u_apb4_if.slave),
      .clint(u_clint_if.dut)
  );

endmodule
