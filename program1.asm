// Program 1 register use map:
// r0 is the accumulator, r1 is often used to cache temp values
// r6 is LFSR tap pattern
// r7 is LFSR state value
// r8 is the preamble counter
// r9 is the total encryption length counter
// r11 is the read pointer
// r12 is the write pointer
init: LDI #d62
	PUT r8
	LDW r8
	PUT r6 // tap will now be in r6
	LDI #d63
	PUT r8
	LDW r8
	PUT r7 // state will now be in r7
	LDI #d0
	PUT r11 // init read incrementer to 0
	LDI #d64
	PUT r12 // init write incrementer to 64
	LDI #d61
	PUT r8
	LDW r8
	PUT r8 // init r8 decrementer with number of preamble space chars
	LDI #d64
	PUT r9 // init r9 decrementer to total number of possible ciphertext chars
preamble_loop: LDI #d32 // get space character decimal 32
	XOR r7 // bitwise XOR the current state with plaintext space to generate ciphertext
	CLB r0 // clear the leading bit of the ciphertext as in requirements
	STW r12 // store ciphertext to write pointer
	LDI #lfsr_routine // load address for the lfsr_routine label
	JAL r0 // jump to the lfsr_routine label
	NXT r12 // increment write pointer
	NXT r9 // decrement number of remaining ciphertext characters
	LDI #main_loop // load the address of label main_loop
	NXT r8 // decrement preamble counter
	JEZ r0 // exit preamble loop if the preamble counter has just reached 0
	LDI #preamble_loop // load the address of label preamble_loop
	JMP r0 // jump to preamble_loop if there are more space characters to encode
main_loop: LDW r11 // load the next plaintext byte
	XOR r7 // bitwise XOR the current state with plaintext space to generate ciphertext
	CLB r0 // clear the leading bit of the ciphertext as in requirements
	STW r12 // store ciphertext to write pointer
	LDI #lfsr_routine // load address for the lfsr_routine label
	JAL r0 // jump to the lfsr_routine label
	NXT r11 // increment read pointer
	NXT r12 // increment write pointer
	LDI #done // load address of label done
	NXT r9 // decrement number of remaining ciphertext chars
	JEZ r0 // jump to end of program if all ciphertext chars have been processed
	LDI #main_loop // load address of main_loop
	JMP r0 // jump to main_loop if there is still space for message characters
lfsr_routine: GET r7 // get previous state
	AND r6 // and state with taps to get feedback pattern
	PTY r0 // get feedback parity bit
	PUT r1 // store feedback bit to r1 temporarily
	GET r7 // get previous state again
	LSH #1 // left shift previous state by 1
	ORR r1 // or with parity bit to get next state
	PUT r7 // put next state to r7
	GET r14 // load link register
	JMP r0 // return to function call address
done: LDI #b10000000 // load the processor flag state needed to halt the program
	PUT r15 // put and set the done flag to 1 to halt the PC and indicate the program has finished