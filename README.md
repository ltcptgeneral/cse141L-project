# cse141L-project
This project for CSE 141L presents a general purpose instruction set and processor design files for the Cumulus architecture. This processor was designed primarily to accelerate specific lfsr encryption and decryption algorithms which feature specialized operations and simple memory access patterns. As a result, many instructions are restricted to use Special Purpose (SP) registers in an attempt to minimize required operand encoding space. Additionally, there are few General Purpose (GP) registers. Finally, the architecture uses a direct register addressing mode since 8 byte addresses are sufficient for the memory requirements.

## Architecure Type
The Cumulus architecture is an Accumulator processor and features a direct register addressing mode. Registers are 8 bits, and instructions are 9 bits.

## Registers

There are 16 total registers supported, but only 8 General Purpose registers. The register map is included below. Although r10 and r11 are indicated as read and write incrementors, they can be used for any incrementation purpose.
Register(s) | Type | Purpose
---|---|---
r0 | GP | A = accumulator
r1 - r7 | GP | 7 extra general purpose registers
r8 - r10 | SP | decrementors
r11 | SP | read incrementor
r12 | SP | write incrementor
r13 | SP | incrementor
r14 | GP | link register
r15 | GP | processor flags = [done, 0, 0, 0, 0, 0, 0, zero]

The done flag will be set by the program when the program has finished, and will be unset by the test bench when the next program should run. The done flag is not automatically set after each instruction, so it can be modified by programs using the PUT command.

## Instruction Types
Type | Layout
---|---
Large Immediate (I) Type |1 bit opcode, 8 bit operand
Small Immediate (T) Type |6 bit opcode, 3 bit immediate
Special Purpose register source (S) Type | 6 bit opcode, 3 bit operand
General Purpose register source (G) Type | 6 bit opcode, 3 bit operand
Any register source (A) Type (4 bit operand) | 5 bit opcode, 4 bit operand
  
## Instructions
Instruction | Type | Description | Pseudocode | Encoding
---|---|---|---|---
LDI | I | loads an 8 bit immediate field into A | A = #immd; | [1 xxxx xxxx] where x is the 8 bit immediate
PUT | A | Copies the accumulator value to any destination register | reg[x]= A; | [0 0000 xxxx] where x is the destination register
GET | A | Gets any source register and saves it to the accumulator | A = reg[x]; | [0 0001 xxxx] where x is the source register
LDW | S | Load word from memory at index address to A | A = mem[index]; | [0 0010 1xxx] where x is the index which is an SP register
STW | S | Store word from G0 register to memory at index address (SP) | mem[index] = A; | [0 0011 1xxx] where x is the index which is an SP register
NXT | S | Increments/Decrements/Next-state a SP register according to their type | src = next_state(src); | [0 0100 1xxx] where x is the source which is an SP register
CLB | G | Sets the leading (parity) bit of a GP register to 0 | reg[src][7] = 0; | [0 0101 0xxx] where x is the source and destination GP register
ADD | A | Add src to A | A = A + src; | [0 0110 xxxx] where x is the source which can be any register
AND | A | Bitwise AND between A and src | A = A & src; | [0 0111 xxxx] where x is the source which can be any register
LSH | T | Perform a left shift on A by the immediate amount | A = A << #imm; | [0 1000 0xxx] where x is a 3 bit immediate
NOP | T | No operation performed, encoded as a LSH by 0 | A = A << 0; | [0 1000 0000]
RXR | A | Generate an xor reduction parity bit from src is an error | A = ^(src); | [0 1001 xxxx] where x is any register
XOR | A | Bitwise XOR between A and src | A = A ^ src; | [0 1010 xxxx] where x is the source which can be any register
DNE | T | Set the done flag, indicates the program is finished, stalls the PC | done = 1; | [0 1011 1111] although marked as T type, the immediate does not matter
JNZ | G | Jump to value in src if Zero flag is false | pc = Z == 0? src : pc; | [0 1100 0xxx] where x is the jump target which is an GP
JEZ | G | Jump to value in src if Zero flag is true | pc = Z == 1? src : pc; | [0 1101 0xxx] where x is the jump target which is an GP
JMP | G | Unconditional jump to instruction address in src | pc = src; | [0 1110 0xxx] where x is the jump target which is an GP
JAL | G | Jump to address in src (GP) and save pc+4 to link | pc = src; link = pc + 4; | [0 1111 0xxx] where x is the jump target which is an GP

### Instruction Example
Example instruction for incrementing the read incrementor state by one stage:

NXT $r11 = [0 0001 0011]

Note: although the operand is $r11 since the NXT instruction can only apply to SP registers, the leading bit of the register address is ignored in the operand encoding. Thus, 14 = ‘b1011 becomes ‘b011 when encoded into this instruction. 

## Programs

The example programs can be found in `firmware/*.asm`. 
