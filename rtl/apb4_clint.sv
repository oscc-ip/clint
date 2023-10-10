// Copyright (c) 2023 Beijing Institute of Open Source Chip
// clint is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

// verilog_format: off
`define CLINT_MSIP      4'b0000 //BASEADDR+0x00
`define CLINT_MTIMEL    4'b0001 //BASEADDR+0x04
`define CLINT_MTIMEH    4'b0010 //BASEADDR+0x08
`define CLINT_MTIMECMPL 4'b0011 //BASEADDR+0x0C
`define CLINT_MTIMECMPH 4'b0100 //BASEADDR+0x10
// verilog_format: on

module apb4_clint (
    // verilog_format: off
    apb4_if.slave apb4,
    // verilog_format: on
    input  logic  rtc_clk_i,
    output logic  tmr_irq_o,
    output logic  sfr_irq_o
);

  logic [3:0] s_apb_addr;
  logic [31:0] s_msip_d, s_msip_q;
  logic [63:0] s_mtime_d, s_mtime_q, s_mtimecmp_d, s_mtimecmp_q;
  logic s_rtc_rise_edge;
  logic s_apb4_wr_valid, s_msip_wr_valid;
  logic s_mtimecmpl_wr_valid, s_mtimecmph_wr_valid, s_mtimecmp_wr_valid;

  assign s_apb4_wr_valid = (apb4.psel && apb4.penable) && apb4.pwrite;
  assign s_apb4_rd_valid = (apb4.psel && apb4.penable) && (~apb4.pwrite);
  assign s_msip_wr_valid = s_apb4_wr_valid && (s_apb_addr == `CLINT_MSIP);

  edge_det u_edge_det (
      .clk_i  (apb4.hclk),
      .rst_n_i(apb4.hresetn),
      .dat_i  (rtc_clk_i),
      .re_o   (s_rtc_rise_edge)
  );

  assign s_apb_addr = apb4.paddr[5:2];
  always_comb begin
    apb4.prdata = '0;
    if (s_apb4_rd_valid) begin
      unique case (s_apb_addr)
        `CLINT_MSIP:      apb4.prdata = s_msip_q;
        `CLINT_MTIMEL:    apb4.prdata = s_mtime_q[31:0];
        `CLINT_MTIMEH:    apb4.prdata = s_mtime_q[63:32];
        `CLINT_MTIMECMPL: apb4.prdata = s_mtimecmp_q[31:0];
        `CLINT_MTIMECMPH: apb4.prdata = s_mtimecmp_q[63:32];
      endcase
    end
  end

  assign s_msip_d = s_msip_wr_valid ? apb4.pwdata : s_msip_q;
  dffr #(32) u_msip_dffr (
      apb4.hclk,
      apb4.hresetn,
      s_msip_d,
      s_msip_q
  );

  assign s_mtime_d = s_rtc_rise_edge ? s_mtime_q + 1'b1 : s_mtime_q;
  dffr #(64) u_mtime_dffr (
      apb4.hclk,
      apb4.hresetn,
      s_mtime_d,
      s_mtime_q
  );

  always_comb begin
    s_mtimecmp_d = s_mtimecmp_q;
    if (s_apb4_wr_valid) begin
      unique case (s_apb_addr)
        `CLINT_MTIMECMPL: s_mtimecmp_d = {32'b0, apb4.pwdata};
        `CLINT_MTIMECMPH: s_mtimecmp_d = {apb4.pwdata, 32'b0};
      endcase
    end
  end

  dffrh #(64) u_mtimecmp_dffrh (
      apb4.hclk,
      apb4.hresetn,
      s_mtimecmp_d,
      s_mtimecmp_q
  );

  assign tmr_irq_o   = s_mtime_q >= s_mtimecmp_q;
  assign sfr_irq_o   = s_msip_q[0] == 1'b1;

  assign apb4.pready = 1'b1;
  assign apb4.pslerr = 1'b0;

endmodule
