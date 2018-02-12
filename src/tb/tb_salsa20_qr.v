//======================================================================
//
// tb_salsa20_qr.v
// ---------------
// Testbench for the Salsa20 quarterround logic module.
//
//
// Author: Joachim Strombergson
// Copyright (c) 2014, Secworks Sweden AB
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


//------------------------------------------------------------------
// Test module.
//------------------------------------------------------------------
module tb_salsa20_qr();

  //----------------------------------------------------------------
  // Internal constant and parameter definitions.
  //----------------------------------------------------------------
  parameter DEBUG = 1;

  parameter CLK_HALF_PERIOD = 1;
  parameter CLK_PERIOD = 2 * CLK_HALF_PERIOD;


  //----------------------------------------------------------------
  // Register and Wire declarations.
  //----------------------------------------------------------------
  reg [31 : 0] cycle_ctr;
  reg [31 : 0] error_ctr;
  reg [31 : 0] tc_ctr;

  reg           tb_clk;
  reg           tb_reset_n;

  reg [31 : 0]  tb_y0;
  reg [31 : 0]  tb_y1;
  reg [31 : 0]  tb_y2;
  reg [31 : 0]  tb_y3;

  wire [31 : 0] tb_z0;
  wire [31 : 0] tb_z1;
  wire [31 : 0] tb_z2;
  wire [31 : 0] tb_z3;


  //----------------------------------------------------------------
  // Device Under Test.
  //----------------------------------------------------------------
  salsa20_qr dut(
                 .y0(tb_y0),
                 .y1(tb_y1),
                 .y2(tb_y2),
                 .y3(tb_y3),

                 .z0(tb_z0),
                 .z1(tb_z1),
                 .z2(tb_z2),
                 .z3(tb_z3)
                );


  //----------------------------------------------------------------
  // clk_gen
  //
  // Always running clock generator process.
  //----------------------------------------------------------------
  always
    begin : clk_gen
      #CLK_HALF_PERIOD;
      tb_clk = !tb_clk;
    end // clk_gen


  //----------------------------------------------------------------
  // sys_monitor()
  //
  // An always running process that creates a cycle counter and
  // conditionally displays information about the DUT.
  //----------------------------------------------------------------
  always
    begin : sys_monitor
      cycle_ctr = cycle_ctr + 1;
      #(CLK_PERIOD);
      if (DEBUG)
        begin
          dump_dut_state();
        end
    end


  //----------------------------------------------------------------
  // dump_dut_state()
  //
  // Dump the state of the dump when needed.
  //----------------------------------------------------------------
  task dump_dut_state;
    begin
      $display("State of DUT");
      $display("------------");
      $display("Inputs and outputs:");
      $display("y0 = 0x%08x, y1 = 0x%08x, y3 = 0x%08x, y3 = 0x%08x",
               dut.y0, dut.y1, dut.y2, dut.y3);
      $display("z0 = 0x%08x, z1 = 0x%08x, z2 = 0x%08x, z3 = 0x%08x",
               dut.z0, dut.z1, dut.z2, dut.z3);
      $display("");
    end
  endtask // dump_dut_state


  //----------------------------------------------------------------
  // init_sim()
  //
  // Initialize all counters and testbed functionality as well
  // as setting the DUT inputs to defined values.
  //----------------------------------------------------------------
  task init_sim;
    begin
      cycle_ctr = 0;
      error_ctr = 0;
      tc_ctr    = 0;

      tb_y0     = 0;
      tb_y1     = 0;
      tb_y2     = 0;
      tb_y3     = 0;
    end
  endtask // init_sim


  //----------------------------------------------------------------
  // display_test_result()
  //
  // Display the accumulated test results.
  //----------------------------------------------------------------
  task display_test_result;
    begin
      if (error_ctr == 0)
        begin
          $display("*** All %02d test cases completed successfully", tc_ctr);
        end
      else
        begin
          $display("*** %02d tests completed - %02d test cases did not complete successfully.",
                   tc_ctr, error_ctr);
        end
    end
  endtask // display_test_result


  //----------------------------------------------------------------
  // test_qr
  //
  // Test case runner task.
  //----------------------------------------------------------------
  task test_qr(input [31 : 0] y0,
               input [31 : 0] y1,
               input [31 : 0] y2,
               input [31 : 0] y3,
               input [31 : 0] ez0,
               input [31 : 0] ez1,
               input [31 : 0] ez2,
               input [31 : 0] ez3
               );
    begin
      tb_y0 = y0;
      tb_y1 = y1;
      tb_y2 = y2;
      tb_y3 = y3;
      #(CLK_PERIOD);
      if ((dut.z0 != ez0) || (dut.z1 != ez1) || (dut.z2 != ez2) || (dut.z3 != ez3))
        begin
          $display("** TC%02d Error: Incorrect z values generated.", tc_ctr);
          $display("** Expected: z0 = 0x%08x, z1 = 0x%08x, z2 = 0x%08x, z3 = 0x%08x",
                   ez0, ez1, ez2, ez3);
          $display("** Got:      z0 = 0x%08x, z1 = 0x%08x, z2 = 0x%08x, z3 = 0x%08x",
                   dut.z0, dut.z1, dut.z2, dut.z3);
          error_ctr = error_ctr + 1;
        end
      else
        begin
          $display("** TC%02d OK.", tc_ctr);
        end
      tc_ctr = tc_ctr + 1;
    end
  endtask // test_qr


  //----------------------------------------------------------------
  // salsa20_qr_test
  //
  // The main test functionality.
  //----------------------------------------------------------------
  initial
    begin : salsa20_qr_test

      reg [31 : 0] ty0;
      reg [31 : 0] ty1;
      reg [31 : 0] ty2;
      reg [31 : 0] ty3;
      reg [31 : 0] ez0;
      reg [31 : 0] ez1;
      reg [31 : 0] ez2;
      reg [31 : 0] ez3;

      $display("   -= Testbench for Salsa20 qr started =-");
      $display("    =====================================");
      $display("");

      init_sim();
      dump_dut_state();

      ty0 = 32'h00000000;
      ty1 = 32'h00000000;
      ty2 = 32'h00000000;
      ty3 = 32'h00000000;
      ez0 = 32'h00000000;
      ez1 = 32'h00000000;
      ez2 = 32'h00000000;
      ez3 = 32'h00000000;
      test_qr(ty0, ty1, ty2, ty3, ez0, ez1, ez2, ez3);

      ty0 = 32'h00000001;
      ty1 = 32'h00000000;
      ty2 = 32'h00000000;
      ty3 = 32'h00000000;
      ez0 = 32'h08008145;
      ez1 = 32'h00000080;
      ez2 = 32'h00010200;
      ez3 = 32'h20500000;
      test_qr(ty0, ty1, ty2, ty3, ez0, ez1, ez2, ez3);

      ty0 = 32'h00000000;
      ty1 = 32'h00000001;
      ty2 = 32'h00000000;
      ty3 = 32'h00000000;
      ez0 = 32'h88000100;
      ez1 = 32'h00000001;
      ez2 = 32'h00000200;
      ez3 = 32'h00402000;
      test_qr(ty0, ty1, ty2, ty3, ez0, ez1, ez2, ez3);

      ty0 = 32'h00000000;
      ty1 = 32'h00000000;
      ty2 = 32'h00000001;
      ty3 = 32'h00000000;
      ez0 = 32'h80040000;
      ez1 = 32'h00000000;
      ez2 = 32'h00000001;
      ez3 = 32'h00002000;
      test_qr(ty0, ty1, ty2, ty3, ez0, ez1, ez2, ez3);

      ty0 = 32'h00000000;
      ty1 = 32'h00000000;
      ty2 = 32'h00000000;
      ty3 = 32'h00000001;
      ez0 = 32'h00048044;
      ez1 = 32'h00000080;
      ez2 = 32'h00010000;
      ez3 = 32'h20100001;
      test_qr(ty0, ty1, ty2, ty3, ez0, ez1, ez2, ez3);

      ty0 = 32'he7e8c006;
      ty1 = 32'hc4f9417d;
      ty2 = 32'h6479b4b2;
      ty3 = 32'h68c67137;
      ez0 = 32'he876d72b;
      ez1 = 32'h9361dfd5;
      ez2 = 32'hf1460244;
      ez3 = 32'h948541a3;
      test_qr(ty0, ty1, ty2, ty3, ez0, ez1, ez2, ez3);

      ty0 = 32'hd3917c5b;
      ty1 = 32'h55f1c407;
      ty2 = 32'h52a58a7a;
      ty3 = 32'h8f887a3b;
      ez0 = 32'h3e2f308c;
      ez1 = 32'hd90a8f36;
      ez2 = 32'h6ab2a923;
      ez3 = 32'h2883524c;
      test_qr(ty0, ty1, ty2, ty3, ez0, ez1, ez2, ez3);

      display_test_result();
      $display("");
      $display("*** Salsa20 qr simulation done. ***");
      $finish;
    end // salsa20_qr_test
endmodule // tb_salsa20_qr_test

//======================================================================
// EOF tb_salsa20_qr.v
//======================================================================
