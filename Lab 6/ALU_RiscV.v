`include "defines.v"


module ALU_RiscV (
  input  [31:0]     A, B,
  input  [4: 0]     operation,
  output reg[31: 0] result,
  output reg        flag
);
  always @(*) begin
    case(operation)
      `ALU_ADD : result = A + B;
      `ALU_SUB : result = A - B;
        
      `ALU_XOR : result = A ^ B;
      `ALU_OR  : result = A | B;
      `ALU_AND : result = A & B;
        
      `ALU_SRA : result = $signed(A) >>> $signed(B);
      `ALU_SRL : result = A >> B;
      `ALU_SLL : result = A << B;
      
      `ALU_SLTS: result = $signed(A) < $signed(B);
      `ALU_SLTU: result = A < B;

      `ALU_LTS : result = $signed(A) < $signed(B);
      `ALU_LTU : result = A < B;
	
      `ALU_SLTS: result = $signed(A) < $signed(B);
      `ALU_SLTU: result = A < B;

      `ALU_GES : result = $signed(A) >= $signed(B);
      `ALU_GEU : result = A >= B;
      `ALU_EQ  : result = A == B;
      `ALU_NE  : result = A != B;


    endcase
    flag = (operation[4] == 1) ? result : 0; 
  end
endmodule