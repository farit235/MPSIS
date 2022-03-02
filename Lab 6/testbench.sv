///6

`timescale 1ns / 1ps
`include "top_RiscV.sv"

module tb_top_with_LSU();

  parameter     HF_CYCLE = 0.25;       // 100 MHz clock задержка 
  parameter     RST_WAIT = 10;         // 10 ns reset
  parameter     RAM_SIZE = 1024;       // in 32-bit words

  reg clk   = 1'b1;
  reg reset = 1'b1;

  top_RiscV #(
    .RAM_SIZE(RAM_SIZE),
    .RAM_INIT_FILE("task.hex")
  ) top (clk, reset);
  
  integer i = 0;
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_top_with_LSU);
    
    clk   = 1'b0;
    reset = 1'b0;
    # RST_WAIT;
    clk = 1'b1;
    # RST_WAIT;
    reset = 1'b1;
    
    while (1) begin
      # HF_CYCLE;
      clk = ~clk;
      i = i + 1;
      if (tb_top_with_LSU.top.core.opcode == `OPCODE_SYSTEM) begin
        $display("RESULT: a0 = %8h", tb_top_with_LSU.top.core.RF_connection.RAM[10]);
        break;
      end
      
      if (i > 1000) begin
        $display("STACK OVERFLOW");
        break;
      end
      
      if (clk == 1'b1) begin
        $display("Takt=%3d :: PC=%2d :: Instr=%8h", i / 2 + 1, tb_top_with_LSU.top.core.pc , tb_top_with_LSU.top.core.instr); //считываем опкоды с инструкций 
        case(tb_top_with_LSU.top.core.opcode)
          `OPCODE_OPERATION_REG : $display("\t OPERATION_REG");
          `OPCODE_OPERATION_IMM : $display("\t OPERATION_IMM");
          `OPCODE_IMM_U_LOAD	: $display("\t IMM_U_LOAD");
          `OPCODE_IMM_U_PC		: $display("\t IMM_U_PC	");
          `OPCODE_STORE			: $display("\t STORE");
          `OPCODE_LOAD 			: $display("\t LOAD");
          `OPCODE_BRANCH		: $display("\t BRANCH");
          `OPCODE_JUMP_LINK_REG : $display("\t JUMP_LINK_REG");
          `OPCODE_JUMP_LINK_IMM : $display("\t JUMP_LINK_IMM");
          `OPCODE_MISC_MEM		: $display("\t MISC_MEM");
          `OPCODE_SYSTEM		: $display("\t SYSTEM");
          default: begin
            $display("\n!!!OPCODE: UNKNOWN!!!");
          end

        endcase// описание 
        if (tb_top_with_LSU.top.core.jal_signal)
          $display("\tJUMP TO %10d", tb_top_with_LSU.top.core.pc + tb_top_with_LSU.top.core.imm_J);
        else if (tb_top_with_LSU.top.core.jalr_signal)
          $display("\tJUMP TO %10d", tb_top_with_LSU.top.core.rd1 + tb_top_with_LSU.top.core.imm_I);
        else if (tb_top_with_LSU.top.core.branch_signal)
          $display("\tRESULT OF(%10d, %10d) TRY JUMP TO %10d", tb_top_with_LSU.top.core.operand_A,  tb_top_with_LSU.top.core.operand_B, tb_top_with_LSU.top.core.pc + tb_top_with_LSU.top.core.imm_B);
        else if (tb_top_with_LSU.top.core.memory_write_enable_signal)
          $display("\tMem[%8h] = %8h", tb_top_with_LSU.top.core.alu_result, tb_top_with_LSU.top.core.rd2 );
        else if (tb_top_with_LSU.top.core.memory_require_signal)
          $display("\tx%2d = Mem[%8h] = %8h", tb_top_with_LSU.top.core.rd3, tb_top_with_LSU.top.core.alu_result, tb_top_with_LSU.top.core.wd3);
        else
          $display("\t%5b(%10d, %10d) = %10d", tb_top_with_LSU.top.core.alu_operation_signal,  tb_top_with_LSU.top.core.operand_A, tb_top_with_LSU.top.core.operand_B, tb_top_with_LSU.top.core.wd3);
      end
    end 
    $finish;
  end
endmodule