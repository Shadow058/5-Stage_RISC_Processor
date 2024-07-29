`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////// 
// Description: 
// Compute the factorial of a number N stored in memory location 200. Thevresult will be stored in memory loca>on 198.
// • The steps:
// - Initialize register R10 with the memory address 200.
// - Load the contents of memory location 200 into register R3.
// - Initialize register R2 with the value 1.
// - In a loop, multiply R2 and R3, and store the product in R2.
// - Decrement R3 by 1; if not zero repeat the loop.
// - Store the result (from R3) in memory location 198.
//////////////////////////////////////////////////////////////////////////////////


module tb();
    reg clk1,clk2;
    integer k;
    
    mips pipe(clk1,clk2);
    
    initial
        begin
            clk1 = 0; clk2 = 0;
            repeat(50)
                begin
                    #5 clk1 = 1; #5 clk1 = 0;
                    #5 clk2 = 1; #5 clk2 = 0;
                end 
        end
    

    initial
        begin
            for(k = 0;k<31;k=k+1)
                pipe.Reg[k] = k;
            
            pipe.Mem[0] = 32'h280a00c8;     // ADDI R10,R0,200
            pipe.Mem[1] = 32'h28020001;     // ADDI R2,R0,1
            pipe.Mem[2] = 32'h0e94a000;     // OR R20,R20,R20 -- dummy instr
            pipe.Mem[3] = 32'h21430000;     // LW R3,0(R10)
            pipe.Mem[4] = 32'h0e94a000;     // OR R20,R20,R20 -- dummy instr.
            pipe.Mem[5] = 32'h14431000;     // Loop: MUL R2,R2,R3
            pipe.Mem[6] = 32'h2c630001;     // SUBI R3,R3,1
            pipe.Mem[7] = 32'h0e94a000;     // OR R20,R20,R20 -- dummy instr.
            pipe.Mem[8] = 32'h3460fffc;     // BNEQZ R3,Loop (i.e. -4 offset)
            pipe.Mem[9] = 32'h2542fffe;
            pipe.Mem[10] = 32'hdc000000;
            
            
            
            pipe.Mem[200] = 7;
            pipe.PC = 0;
            pipe.TAKEN_BRANCH = 0;
            pipe.HALTED = 0;
            
            #2000
            $display("Mem[200]: %4d \nMem[198]: %6d",pipe.Mem[200],pipe.Mem[198]);            
                        
        end
    
    initial
    begin
        $monitor("R2: %4d",pipe.Reg[2]);
        #3000 $finish;
        end        
endmodule
