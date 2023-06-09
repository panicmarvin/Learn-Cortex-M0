//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2010-2013 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2012-07-31 10:47:23 +0100 (Tue, 31 Jul 2012) $
//
//      Revision            : $Revision: 217027 $
//
//      Release Information : Cortex-M System Design Kit-r1p0-00rel0
//
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Abstract : APB example slave, support AMBA APB4.
//            slave is always ready and response is always OKAY.
//-----------------------------------------------------------------------------

module  cmsdk_apb4_eg_slave #(
  // parameter for address width
  parameter ADDRWIDTH = 12)
 (
  // IO declaration
  input  wire                    PCLK,     // pclk
  input  wire                    PCLKG,    // pclkg
  input  wire                    PRESETn,  // reset

  // apb interface inputs
  input  wire                    PSEL,
  input  wire [ADDRWIDTH-1:0]    PADDR,
  input  wire                    PENABLE,
  input  wire                    PWRITE,
  input  wire [31:0]             PWDATA,
  input  wire [3:0]              PSTRB,

  input  wire [3:0]              ECOREVNUM, // Engineering-change-order revision bits

  // apb interface outputs
  output wire [31:0]             PRDATA,
  output wire                    PREADY,
  output wire                    PSLVERR);

//------------------------------------------------------------------------------
// internal wires
//------------------------------------------------------------------------------
  // Register module interface signals
  wire  [ADDRWIDTH-1:0]    reg_addr;
  wire                     reg_read_en;
  wire                     reg_write_en;
  wire  [3:0]              reg_byte_strobe;
  wire  [31:0]             reg_wdata;
  wire  [31:0]             reg_rdata;


//------------------------------------------------------------------------------
// module logic start
//------------------------------------------------------------------------------
 // Interface to convert APB signals to simple read and write controls
 cmsdk_apb4_eg_slave_interface
   #(.ADDRWIDTH (ADDRWIDTH))
   u_apb_eg_slave_interface(

  .pclk            (PCLK),     // pclk
  .pclkg           (PCLKG),    // pclk
  .presetn         (PRESETn),  // reset

  .psel            (PSEL),     // apb interface inputs
  .paddr           (PADDR),
  .penable         (PENABLE),
  .pwrite          (PWRITE),
  .pwdata          (PWDATA),
  .pstrb           (PSTRB),

  .prdata          (PRDATA),   // apb interface outputs
  .pready          (PREADY),
  .pslverr         (PSLVERR),

  // Register interface
  .addr            (reg_addr),
  .read_en         (reg_read_en),
  .write_en        (reg_write_en),
  .byte_strobe     (reg_byte_strobe),
  .wdata           (reg_wdata),
  .rdata           (reg_rdata)

  );

 // Example hardware register block
 cmsdk_apb4_eg_slave_reg
   #(.ADDRWIDTH (ADDRWIDTH))
   u_apb_eg_slave_reg (
  .pclk            (PCLK),
  .pclkg           (PCLKG),
  .presetn         (PRESETn),

   // Register interface
  .addr            (reg_addr),
  .read_en         (reg_read_en),
  .write_en        (reg_write_en),
  .byte_strobe     (reg_byte_strobe),
  .wdata           (reg_wdata),
  .ecorevnum       (ECOREVNUM),
  .rdata           (reg_rdata)
  );

 //------------------------------------------------------------------------------
 // module logic end
 //------------------------------------------------------------------------------

`ifdef ARM_APB_ASSERT_ON

 `include "std_ovl_defines.h"
  // ------------------------------------------------------------
  // Assertions
  // ------------------------------------------------------------

   // Check the reg_write_en signal generated
    assert_implication
    #(`OVL_ERROR,
      `OVL_ASSERT,
      "Error! register write signal was not generated! "
      )
     u_ovl_apb4_eg_slave_reg_write
     (.clk             (PCLK),
      .reset_n         (PRESETn),
      .antecedent_expr ( (PSEL & (~PENABLE) & PWRITE) ),
      .consequent_expr ( reg_write_en == 1'b1)
      );



  // Check the reg_read_en signal generated
    assert_implication
    #(`OVL_ERROR,
      `OVL_ASSERT,
      "Error! register read signal was not generated! "
      )
     u_ovl_apb4_eg_slave_reg_read
     (.clk             (PCLK),
      .reset_n         (PRESETn),
      .antecedent_expr ( (PSEL & (~PENABLE) & (~PWRITE)) ),
      .consequent_expr ( reg_read_en == 1'b1)
      );


  // Check register read and write operation won't assert at the same cycle
    assert_never
     #(`OVL_ERROR,
       `OVL_ASSERT,
       "Error! register read and write active at the same cycle!")
     u_ovl_apb4_eg_slave_rd_wr_illegal
     (.clk         (PCLK),
      .reset_n     (PRESETn),
      .test_expr   ((reg_write_en & reg_read_en))
      );


`endif


endmodule
