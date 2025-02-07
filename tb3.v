`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////// 
// Description: Load a word stored in memory loca>on 120, add 45 to it, and store the result in memory loca>on 121.
// � The steps:
// � Ini>alize register R1 with the memory address 120.
// � Load the contents of memory location 120 into register R2.
// � Add 45 to register R2.
// � Store the result in memory location 121.
// 
//////////////////////////////////////////////////////////////////////////////////


module tb3(
    );
    reg clk1,clk2;
    integer k;
    
    mips pipe2(clk1,clk2);
    
    initial
        begin
            clk1 = 0; clk2 = 0;
            repeat(20)
                begin
                    #5 clk1 = 1; #5 clk1 = 0;
                    #5 clk2 = 1; #5 clk2 = 0;
                end 
        end
    

    initial
        begin
            for(k = 0;k<31;k=k+1)
                pipe2.Reg[k] = k;
            
            pipe2.Mem[0] = 32'h28010078;     // ADDI R1,R0,120
            pipe2.Mem[1] = 32'h0c631800;     // OR R3,R3,R3 -- dummy instr.
            pipe2.Mem[2] = 32'h20220000;     // LW R2,0(R1)
            pipe2.Mem[3] = 32'h0c631800;     // OR R3,R3,R3 -- dummy instr.
            pipe2.Mem[4] = 32'h2842002d;     // ADDI R2,R2,45
            pipe2.Mem[5] = 32'h0c631800;     // OR R3,R3,R3 -- dummy instr.  
            pipe2.Mem[6] = 32'h24220001;     // SW R2,1(R1)
            pipe2.Mem[7] = 32'hfc000000;     // HLT
            
            pipe2.Mem[120] = 95;
            pipe2.PC = 0;
            pipe2.TAKEN_BRANCH = 0;
            pipe2.HALTED = 0;
            
            #500
            for(k = 0;k<3;k=k+1)
                $display("R%1d = %2d",k,mips.Reg[k]);
            $display("Mem[120]: %4d \nMem[121]: %4d",pipe2.Mem[120],pipe2.Mem[121]);            
                        
        end
    
    initial
        #600 $finish;        
endmodule
