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
//      Checked In          : $Date: 2011-04-01 17:11:28 +0100 (Fri, 01 Apr 2011) $
//
//      Revision            : $Revision: 166647 $
//
//      Release Information : Cortex-M System Design Kit-r1p0-00rel0
//
//-----------------------------------------------------------------------------
//-------------------------------------------------------------------------
//  Abstract            : Example for File Reader Bus Master
//                         Testbench for the example AHB Lite slave.
//=========================================================================--

`timescale 1ns/1ps

module tb_frbm_example;

parameter CLK_PERIOD = 10;
parameter ADDRWIDTH = 12;
parameter PCLK_DIV  = 2;

parameter InputFileName = "frbm_example.out";
parameter MessageTag = "FileReader:";
parameter StimArraySize = 5000;


//********************************************************************************
// Internal Wires
//********************************************************************************

// AHB Lite BUS SIGNALS
wire             hready;
wire             hreadyout;
wire             hresp;
wire [31:0]      hrdata;

wire [1:0]       htrans;
wire [2:0]       hburst;
wire [3:0]       hprot;
wire [2:0]       hsize;
wire             hwrite;
wire             hmastlock;
wire [31:0]      haddr;
wire [31:0]      hwdata;

// APB BUS SIGNALS
reg             PRESETn;
reg             PCLK;
wire            PCLKG;
wire [ADDRWIDTH-1:0]    paddr;
wire                    penable;
wire                    pwrite;
wire [3:0]              pstrb;
wire [2:0]              pprot;
wire [31:0]             pwdata;
wire                    psel;
wire                    apbactive;
wire [31:0]             prdata;
wire                    pready;
wire                    pslverr;


reg [7:0]       pclken_cnt;
wire            pclken;

reg              HCLK;
reg              HRESETn;

//********************************************************************************
// Clock and reset generation
//********************************************************************************

initial
  begin
    HRESETn = 1'b0;
    HCLK    = 1'b0;
    # (10*CLK_PERIOD);
    HRESETn = 1'b1;
  end

initial
  begin
    PRESETn = 1'b0;
    # (20*CLK_PERIOD);
    PRESETn = 1'b1;
  end

always
  begin
    HCLK = #(CLK_PERIOD/2) ~HCLK;
  end

always @(posedge HCLK or negedge HRESETn)
begin
    if(!HRESETn)
        pclken_cnt <= 'd0;
    else if(pclken_cnt == PCLK_DIV-1)
        pclken_cnt <= 'd0;
    else
        pclken_cnt <= pclken_cnt + 'd1;
end

assign pclken = (pclken_cnt == PCLK_DIV-1);
assign PCLK = HCLK && pclken;



//********************************************************************************
// Address decoder, need to be changed for other configuration
//********************************************************************************
// 0x10000000 - 0x10000FFF : HSEL #0 - Example AHB slave

  assign hsel = (haddr[31:12] == 20'h10000)? 1'b1:1'b0;

//********************************************************************************
// File read bus master:
// generate AHB Master signal by reading a file which store the AHB Operations
//********************************************************************************

cmsdk_ahb_fileread_master32
  #(.InputFileName(InputFileName), .MessageTag(MessageTag),.StimArraySize(StimArraySize))
  u_ahb_fileread_master32(

  .HCLK            (HCLK),
  .HRESETn         (HRESETn),

  .HREADY          (hreadyout),
  .HRESP           ({hresp}),  //AHB Lite response to AHB response
  .HRDATA          (hrdata),
  .EXRESP          (1'b0),     //  Exclusive response (tie low if not used)


  .HTRANS          (htrans),
  .HBURST          (hburst),
  .HPROT           (hprot),
  .EXREQ           (),        //  Exclusive access request (not used)
  .MEMATTR         (),        //  Memory attribute (not used)
  .HSIZE           (hsize),
  .HWRITE          (hwrite),
  .HMASTLOCK       (hmastlock),
  .HADDR           (haddr),
  .HWDATA          (hwdata),

  .LINENUM         ()

  );

cmsdk_ahb_to_apb #(
    .ADDRWIDTH          (ADDRWIDTH  )
    ,.REGISTER_RDATA    (1          )
    ,.REGISTER_WDATA    (0          )
) u_cmsdk_ahb_to_apb(
// --------------------------------------------------------------------------
// Port Definitions
// --------------------------------------------------------------------------
    .HCLK               (HCLK       ),      // Clock
    .HRESETn            (HRESETn    ),   // Reset
    .PCLKEN             (pclken     ),    // APB clock enable signal
    
    .HSEL               (hsel       ),      // Device select
    .HADDR              (haddr[ADDRWIDTH-1:0]),     // Address
    .HTRANS             (htrans     ),    // Transfer control
    .HSIZE              (hsize      ),     // Transfer size
    .HPROT              (hprot      ),     // Protection control
    .HWRITE             (hwrite     ),    // Write control
    .HREADY             (1'b1       ),    // Transfer phase done
    .HWDATA             (hwdata     ),    // Write data
    
    .HREADYOUT          (hreadyout  ), // Device ready
    .HRDATA             (hrdata     ),    // Read data output
    .HRESP              (hresp      ),     // Device response
                // APB Output
    .PADDR              (paddr      ),     // APB Address
    .PENABLE            (penable    ),   // APB Enable
    .PWRITE             (pwrite     ),    // APB Write
    .PSTRB              (pstrb      ),     // APB Byte Strobe
    .PPROT              (pprot      ),     // APB Prot
    .PWDATA             (pwdata     ),    // APB write data
    .PSEL               (psel       ),      // APB Select
    
    .APBACTIVE          (apbactive  ), // APB bus is active, for clock gating
                // of APB bus
    
                // APB Input
    .PRDATA             (prdata     ),    // Read data for each APB slave
    .PREADY             (pready     ),    // Ready for each APB slave
    .PSLVERR            (pslverr    )
  );  // Error state for each APB slave

//********************************************************************************
// Slave module:
//********************************************************************************

cmsdk_clock_gate #(
    .CLKGATE_PRESENT(1'b1)
    ) u_cmsdk_clock_gate(
    .CLK(PCLK),
    .CLKENABLE(apbactive),
    .DISABLEG(1'b0),
    .GATEDCLK(PCLKG)
    );

cmsdk_apb4_eg_slave #(
  // parameter for address width
  .ADDRWIDTH            (ADDRWIDTH  )
  ) u_cmsdk_apb4_eg_slave
 (
  // IO declaration
    .PCLK               (PCLK       ),     // pclk
    .PCLKG              (PCLKG      ),     // pclkg
    .PRESETn            (PRESETn    ),  // reset
    
    
    .PSEL               (psel       ),
    .PADDR              (paddr      ),
    .PENABLE            (penable    ),
    .PWRITE             (pwrite     ),
    .PWDATA             (pwdata     ),
    .PSTRB              (pstrb      ),
    
    .ECOREVNUM          (4'd0       ), // Engineering-change-order revision bits
   
   
    .PRDATA             (prdata     ),
    .PREADY             (pready     ),
    .PSLVERR            (pslverr    )
    );

// --- FSDB ---
initial begin
    $fsdbDumpfile("wave.fsdb");
    $fsdbDumpvars;
    $fsdbDumpflush;
end

 endmodule



