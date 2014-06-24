//======================================================================
//
// salsa20_qr.v
// -----------
// Verilog 2001 implementation of the stream cipher Salsa20.
// This is the combinational QR logic as a separade module to allow
// us to build versions of the cipher with 1, 2, 4 and even 8
// parallel qr functions.
//
//
// Copyright (c) 2013 Secworks Sweden AB
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or 
// without modification, are permitted provided that the following 
// conditions are met: 
// 
// 1. Redistributions of source code must retain the above copyright 
//    notice, this list of conditions and the following disclaimer. 
// 
// 2. Redistributions in binary form must reproduce the above copyright 
//    notice, this list of conditions and the following disclaimer in 
//    the documentation and/or other materials provided with the 
//    distribution. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
// FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
// COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
// BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, 
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
// ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//======================================================================

module salsa20_qr(
                 input wire [31 : 0]  y0,
                 input wire [31 : 0]  y1,
                 input wire [31 : 0]  y2,
                 input wire [31 : 0]  y3,

                 output wire [31 : 0] z0,
                 output wire [31 : 0] z1,
                 output wire [31 : 0] z2,
                 output wire [31 : 0] z3
                );

  //----------------------------------------------------------------
  // Wires.
  //----------------------------------------------------------------
  reg [31 : 0] tmp_z0;
  reg [31 : 0] tmp_z1;
  reg [31 : 0] tmp_z2;
  reg [31 : 0] tmp_z3;

  
  //----------------------------------------------------------------
  // Concurrent connectivity for ports.
  //----------------------------------------------------------------
  assign z0 = tmp_z0;
  assign z0 = tmp_z1;
  assign z0 = tmp_z2;
  assign z0 = tmp_z3;

  
  //----------------------------------------------------------------
  // qr
  //
  // The actual quarterround function.
  //----------------------------------------------------------------
  always @*
    begin : qr
      reg [31 : 0] z0_0;
      reg [31 : 0] z1_0;
      reg [31 : 0] z2_0;
      reg [31 : 0] z3_0;

      z1_0 = (y0 + y3);
      z1   = {z1_0[24 : 0], z1_0[31 : 25]} ^ y1;

      z2_0 = (z1 + y0);
      z2   = {z2_0[22 : 0], z2_0[31 : 23]} ^ y2;

      z3_0 = (z2 + z1);
      z3   = {z3_0[18 : 0], z3_0[31 : 19]} ^ y3;

      z0_0 = (z3 + z2);
      z0   = {z0_0[13 : 0], z0_0[31 : 14]} ^ y0;
    end // qr
endmodule // salsa20_qr

//======================================================================
// EOF salsa20_qr.v
//======================================================================
