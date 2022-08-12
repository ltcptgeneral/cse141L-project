// Program 3 register use map:
// r0 is the accumulator, r1 and r2 is often used to cache temp values
// r5 is the TAP LUT link register
// r6 is LFSR tap pattern
// r7 is LFSR state value
// r8 is the preamble counter
// r9 is the total encryption length counter
// r10 is the tap selection counter
// r11 is the read pointer
// r12 is the write pointer
init: LDI #d10
	PUT r10 // set the tap counter to 10, which will choose tap pattern 9 to start after subtracting by 1
tap_lut: LDI tap_init
	JMP r0 // goto tap_init, skipping the LUT
	LDI #x60 // load tap pattern 1
	JMP r5 // jump back to tap loop
	LDI #x48 // load tap pattern 2
	JMP r5 // jump back to tap loop
	LDI #x78 // load tap pattern 3
	JMP r5 // jump back to tap loop
	LDI #x72 // load tap pattern 4
	JMP r5 // jump back to tap loop
	LDI #x6A // load tap pattern 5
	JMP r5 // jump back to tap loop
	LDI #x69 // load tap pattern 6
	JMP r5 // jump back to tap loop
	LDI #x5C // load tap pattern 7
	JMP r5 // jump back to tap loop
	LDI #x7E // load tap pattern 8
	JMP r5 // jump back to tap loop
	LDI #x7B // load tap pattern 9
	JMP r5 // jump back to tap loop
tap_init: LDI #d64
	PUT r11 // set read pointer to 64
	LDI #d0 
	PUT r12 // set write pointer to 0
	LDI #d10
	PUT r8 // load 10 into preamble counter
	LDI #d64
	PUT r9 // load 64 (total encryption length) to r9
	LDI done
	NXT r10 // decrement tap selection by 1, starts at 9 for the first iteration
	JEZ r0 // if no more taps left that didn't work, raise the done flag
	LDI tap_init
	PUT r5 // put the tap_loop address in r5
	LDI tap_lut
	ADD r10
	ADD r10 // add 2*tap select to tap_lut location, results in location of selected tap pattern
	JMP r0 // jump to LUT, which loads the tap pattern into r0
	PUT r6 // tap pattern now in r6
	LDW r11 // get the first preamble character
	PUT r1 // put cipher text into r1
	LDI #d32 // load expected space character
	STW r12 // write initial space into memory
	XOR r1 // get the initial state
	PUT r7 // put initial state guess into r7
	NXT r11 // increment read pointer
	NXT r12 // increment write pointer
	NXT r9 // decrement total encryption chars remaining
	tap_loop: LDI lfsr_routine
		JAL r0 // jump to lfsr routine which calculates next state in r7
		LDI #d32 // load space char expected plaintext
		XOR r7
		CLB r0 // clear leading bit in the expected ciphertext
		PUT r1 // store expected cipher text in r1
		LDI tap_init 
		PUT r2 // load the outer loop top into r2
		LDW r11 // load actual ciphertext
		SUB r1 // subtract actual from expected, result of 0 means matching
		JNZ r2 // jump to outer loop (picks new tap pattern) if the actual cipher was not equal to the expected
		LDI #d32 // load preamble char
		STW r12 // store preamble char in memory
		NXT r11 // increment read pointer
		NXT r12 // increment write pointer
		NXT r9 // decrement total encryption chars remaining
		LDI main_loop // load main_loop location into r0
		NXT r8 // decrement preamble counter
		JEZ r0 // if r8 (preamble counter) is zero, then all preamble have matched and current tap pattern is correct, jump to main loop
		LDI tap_loop
		JMP r0 // jump to tap_loop if characters matched but preamble is not over
main_loop: LDI correct
	PUT r1 // put correct handle address in r1
	LDW r11 // load the next ciphertext byte
	CHK r0 // check ciphertext for error
	JEZ r1 // if no error, jump to correct, otherwise continue to error handling
	error: LDI #x80 // load error flag character into r0
	STW r12 // store error flag to write pointer
	LDI common
	JMP r0 // jump out of error handling, to common operations after writing
	correct: XOR r7 // bitwise XOR the current state with ciphertext space to generate plaintext
	CLB r0 // clear the leading bit of the plaintext as in requirements
	STW r12 // store plaintext to write pointer
	common: LDI lfsr_routine // load address for the lfsr_routine label
	JAL r0 // jump to the lfsr_routine label
	NXT r11 // increment read pointer
	NXT r12 // increment write pointer
	LDI done // load address of label done
	NXT r9 // decrement number of remaining plaintext chars
	JEZ r0 // jump to end of program if all plaintext chars have been processed
	LDI main_loop // load address of main_loop
	JMP r0 // jump to main_loop if there is still space for message characters
lfsr_routine: GET r7 // get previous state
	AND r6 // and state with taps to get feedback pattern
	PTY r0 // get feedback parity bit
	PUT r1 // store feedback bit to r1 temporarily
	GET r7 // get previous state again
	LSH #d1 // left shift previous state by 1
	ORR r1 // or with parity bit to get next state
	PUT r7 // put next state to r7
	GET r14 // load link register
	JMP r0 // return to function call address
done: LDI #b10000000 // load the processor flag state needed to halt the program
	PUT r15 // put and set the done flag to 1 to halt the PC and indicate the program has finished
	LDI #d255
	JMP r0