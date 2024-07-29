`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////// 
// Description: 
//Add three numbers 10, 20 and 30 stored in processor registers.
//• The steps:
//– Initialize register R1 with 10.
//– Initialize register R2 with 20.
//– Initialize register R3 with 30.
//– Add the three numbers and store the sum in R4. 
//////////////////////////////////////////////////////////////////////////////////


module tb1(
    );
    reg clk1,clk2;  
    integer k;
    mips pipe1(clk1,clk2);

        initial 
            begin
                 clk1 = 0; clk2 = 0;
                 repeat(20)
                    begin
                        #5 clk1 = 1; #5 clk1 = 0;   //generating two phase clock
                        #5 clk2 = 1; #5 clk2 = 0;
                    end
            end

        initial
            begin
                for(k = 0; k < 31;k=k+1)
                    pipe1.Reg[k] = k;
                pipe1.Mem[0] = 32'h2801000a;     // ADDI R1,R0,10
                pipe1.Mem[1] = 32'h28020014;     // ADDI R2,R0,20
                pipe1.Mem[2] = 32'h2803001e;     // ADDI R3,R0,25
                pipe1.Mem[3] = 32'h0ce77800;     // OR R7,R7,R7 -- dummy instr
                pipe1.Mem[4] = 32'h0ce77800;     // OR R7,R7,R7 -- dummy instr.
                pipe1.Mem[5] = 32'h00222000;     // ADD R4,R1,R2
                pipe1.Mem[6] = 32'h0ce77800;     // OR R7,R7,R7 -- dummy instr.
                pipe1.Mem[7] = 32'h00832800;     // ADD R5,R4,R3
                pipe1.Mem[8] = 32'hfc000000;     // HLT
                
                pipe1.TAKEN_BRANCH = 0;
                pipe1.HALTED = 0;
                pipe1.PC = 0;

                #280
                for(k=0;k<6;k=k+1)
                    $display("R%1d - %2d",k,pipe1.Reg[k]);

            end


        initial
            begin
                #300 $finish;
            end    
    endmodule
