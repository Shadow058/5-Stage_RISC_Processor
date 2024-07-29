`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IIT BHU
// Engineer: AYUSH KUMAR
// 
// Create Date: 07.12.2023 12:38:45
// Design Name: MIPS 
// Module Name: mips
// Project Name: PROCESSOR
// Target Devices: 
// Tool Versions: 2023
// Description: PERFORMING SUB OPERATIONS OF MIPS32 OPERATION LIKE
//              ALU, LOAD, STORE, BRANCH
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

 
module mips(clk1,clk2); 
    input clk1,clk2;     //two phase clock
    reg [31:0] Reg [0:31];   //Register bank (32x32)
    reg [31:0] Mem [0:1023];   // 1024x32 memory
    
    reg [31:0] PC, IF_ID_IR, IF_ID_NPC;
    reg [31:0] ID_EX_IR, ID_EX_NPC, ID_EX_A, ID_EX_B, ID_EX_Imm; 
    reg [2:0] ID_EX_type, EX_MEM_type, MEM_WB_type;
    reg [31:0] EX_MEM_IR, EX_MEM_ALUOut, EX_MEM_B;
    reg        EX_MEM_cond;
    reg [31:0] MEM_WB_IR, MEM_WB_ALUOut, MEM_WB_LMD;
    
    parameter ADD=6'b000000, SUB=6'b000001, AND=6'b000010, OR=6'b000011, SLT=6'b000100, MUL=6'b000101, HLT=6'b111111, LW=6'b001000, SW=6'b001001, ADDI=6'b001010, SUBI=6'b001011,SLTI=6'b001100,BNEQZ=6'b001101, BEQZ=6'b001110;
    
    parameter RR_ALU=3'b000, RM_ALU=3'b001, LOAD=3'b010, STORE=3'b011, BRANCH=3'b100, HALT=3'b101;
    //ID_EXE_type
    
    reg HALTED; 
        //Set after HLT instruction is completed (in WB stage)
    reg TAKEN_BRANCH;
        //Required to disable instructions after branch
    
    always @(posedge clk1)   //IF Stage
        begin
            if(HALTED == 0)
                begin
                    if(((EX_MEM_IR[31:26] == BEQZ)&&(EX_MEM_cond == 1))||((EX_MEM_IR[31:26] == BNEQZ)&&(EX_MEM_cond == 0)))
                        begin
                            TAKEN_BRANCH <= #2 1'b1;
                            IF_ID_NPC <= #2 1 + EX_MEM_ALUOut;
                            IF_ID_IR <= #2 Mem[EX_MEM_ALUOut];
                            PC <= #2 EX_MEM_ALUOut+1;
                        end
                    else
                        begin
                            IF_ID_IR <= #2 Mem[PC];
                            IF_ID_NPC <= #2 PC+1;
                            PC <= #2 PC+1; 
                        end                    
                end 
        end
    
    //Stage 2--> Instruction decoding
    always @(posedge clk2)
        begin
            if(HALTED == 0)
                begin
                    if(IF_ID_IR[25:21] == 5'b00000)
                        ID_EX_A <= 0;
                    else                    
                        ID_EX_A <= #2 Reg[IF_ID_IR[25:21]];
                    if(IF_ID_IR[20:16] == 5'b00000)
                        ID_EX_B <=0;
                    else                    
                        ID_EX_B <= #2 Reg[IF_ID_IR[20:16]];
                    
                    ID_EX_IR <= #2 IF_ID_IR;
                    ID_EX_NPC <= #2 IF_ID_NPC;
                    ID_EX_Imm <= #2 {{16{IF_ID_IR[15]}},{IF_ID_IR[15:0]}};
                    
                    case(IF_ID_IR[31:26])
                        ADD,SUB,AND,OR,SLT,MUL: ID_EX_type <= #2 RR_ALU;
                        ADDI,SUBI,SLTI:         ID_EX_type <= #2 RM_ALU;
                        LW:                     ID_EX_type <= #2 LOAD;
                        SW:                     ID_EX_type <= #2 STORE;
                        BEQZ,BNEQZ:             ID_EX_type <= #2 BRANCH;
                        HLT:                    ID_EX_type <= #2 HALT;
                        default:                ID_EX_type <= #2 HALT;
                    endcase
                end 
        end    
    
    //Stage 3--> Exection of instruction
    always @(posedge clk1)
        begin  
            if(HALTED==0)
                begin 
                    TAKEN_BRANCH <= #2 1'b0;
                    EX_MEM_IR <= #2 ID_EX_IR;
                    EX_MEM_type <= #2 ID_EX_type; 
                    case(ID_EX_type)
                        RR_ALU:
                            begin
                                case(ID_EX_IR[31:26]) //opcode
                                    ADD:    EX_MEM_ALUOut <= #2 ID_EX_A + ID_EX_B;
                                    SUB:    EX_MEM_ALUOut <= #2 ID_EX_A - ID_EX_B;
                                    AND:    EX_MEM_ALUOut <= #2 ID_EX_A & ID_EX_B;
                                    OR:     EX_MEM_ALUOut <= #2 ID_EX_A | ID_EX_B;
                                    SLT:    EX_MEM_ALUOut <= #2 ID_EX_A < ID_EX_B;
                                    MUL:    EX_MEM_ALUOut <= #2 ID_EX_A * ID_EX_B;
                                    default:EX_MEM_ALUOut <= #2 32'hxxxxxxxx;
                                endcase 
                            end
                        RM_ALU:
                            begin
                                case(ID_EX_IR[31:26])
                                    ADDI:   EX_MEM_ALUOut <= #2 ID_EX_A + ID_EX_Imm;
                                    SUBI:   EX_MEM_ALUOut <= #2 ID_EX_A - ID_EX_Imm;
                                    SLTI:   EX_MEM_ALUOut <= #2 ID_EX_A < ID_EX_Imm;
                                    default:EX_MEM_ALUOut <= #2 32'hxxxxxxxx;
                                endcase                         
                            end
                        LOAD, STORE: 
                            begin
                                EX_MEM_ALUOut <= #2 ID_EX_A + ID_EX_Imm;
                                EX_MEM_B <= #2 ID_EX_B; 
                            end                         
                        BRANCH:
                            begin
                                EX_MEM_ALUOut <= #2 ID_EX_NPC + ID_EX_Imm;
                                EX_MEM_cond <= #2 (ID_EX_A == 0);
                            end                       
                    endcase
                end
        end
    
    //Stage 4--> Memory Stage
    always @(posedge clk2)
        begin
            if(HALTED==0)
                begin
                    MEM_WB_IR <= #2 EX_MEM_IR;
                    MEM_WB_type <= #2 EX_MEM_type;
                    
                    case(EX_MEM_type)
                        RR_ALU, RM_ALU: 
                            MEM_WB_ALUOut <= #2 EX_MEM_ALUOut;
                        LOAD:   MEM_WB_LMD <= #2 Mem[EX_MEM_ALUOut];
                        STORE:
                            begin
                                if(TAKEN_BRANCH == 0)  //Disable write
                                    Mem[EX_MEM_ALUOut] <= #2 EX_MEM_B;
                            end 
                    endcase
            end
        end
     
    //Stage 5--> Writing Back to the register 
    always @(posedge clk1)
        begin
            if(TAKEN_BRANCH == 0)
                begin
                    case(MEM_WB_type)
                        RR_ALU: Reg[MEM_WB_IR[15:11]] <= #2 MEM_WB_ALUOut;
                        RM_ALU: Reg[MEM_WB_IR[20:16]] <= #2 MEM_WB_ALUOut;
                        LOAD:   Reg[MEM_WB_IR[20:16]] <= #2 MEM_WB_LMD;
                        HALT:   HALTED <= #2 1'b1;
                    endcase
                end
        end   
endmodule
