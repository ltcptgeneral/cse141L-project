// Program 2 register use map:
// r0 is the accumulator, r1 r2 r3 are often used to cache temp values
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
	LDI #d9
	PUT r8 // load 9 into preamble counter
	LDI #d64
	PUT r9 // load 64 (total encryption length) to r9
	LDI done
	NXT r10 // decrement tap selection by 1, starts at 9 for the first iteration
	JEZ r0 // if no more taps left that didn't work, raise the done flag
	LDI lut_return
	PUT r5 // put the tap_loop address in r5
	LDI tap_lut
	ADD r10
	ADD r10 // add 2*tap select to tap_lut location, results in location of selected tap pattern
	JMP r0 // jump to LUT, which loads the tap pattern into r0
	lut_return: PUT r6 // tap pattern now in r6
	LDW r11 // get the first preamble character
	PUT r1 // put cipher text into r1
	LDI #d32 // load expected space character
	XOR r1 // get the initial state
	PUT r7 // put initial state guess into r7
	NXT r11 // increment read pointer
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
		CLB r0 // clear leading bit for r0 since we do not expect any errors for this program
		XOR r1 // XOR actual from expected, result of 0 means matching
		JNZ r2 // jump to outer loop (picks new tap pattern) if the actual cipher was not equal to the expected
		NXT r11 // increment read pointer
		NXT r9 // decrement total encryption chars remaining
		LDI finish_preamble // load main_loop location into r0
		NXT r8 // decrement preamble counter
		JEZ r0 // if r8 (preamble counter) is zero, then all preamble have matched and current tap pattern is correct, jump to main loop
		LDI tap_loop
		JMP r0 // jump to tap_loop if characters matched but preamble is not over
finish_preamble: LDI lfsr_routine
	JAL r0 // jump to lfsr routine which calculates next state in r7
	LDW r11 // get next ciphertext
	NXT r11 // increment read
	NXT r9 // decrement remaining plaintext characters
	PUT r3 // store clean copy of ciphertext for later use
	XOR r7 // bitwise XOR the current state with ciphertext space to generate plaintext
	CLB r0 // clear the leading bit of the plaintext as in requirements
	PUT r1 // put the plaintext in r1
	LDI finish_preamble
	PUT r2 // load address of finish_preamble loop into r2
	LDI #d32 // get value of space
	XOR r1 // compare if r1 == 32
	JEZ r2 // jump to finish preamble loop if this plaintext == space(32)
	LDI correct_pre
	PUT r2 // put correct handler address in r2
	CHK r1 // check r1 for errors
	JEZ r2
	error_pre: LDI #x80
		STW r12
		LDI common
		JMP r0
	correct_pre: CLB r1
		GET r1
		STW r12
	common_pre: NXT r12 // increment write only if we found the first non preamble char
main_loop: LDI lfsr_routine // load address for the lfsr_routine label
	JAL r0 // jump to the lfsr_routine label
	LDW r11 // load the next ciphertext byte
	PUT r1 // store ciphertext in r1
	LDI correct
	PUT r2 // load address of correct handler in r2
	CHK r1 // check r1(ciphertext) for errors
	JEZ r2 // if there are no errors, jump to correct handler, otherwise continue to error handler
	error: LDI #x80
		STW r12
		LDI common
		JMP r0
	correct: GET r1 // retrieve ciphertext from r1
		XOR r7 // bitwise XOR the current state with ciphertext space to generate plaintext
		CLB r0 // clear the leading bit of the plaintext as in requirements
		STW r12 // store plaintext to write pointer
	common: NXT r11 // increment read pointer
	NXT r12 // increment write pointer
	LDI finish_post // load address of label done
	NXT r9 // decrement number of remaining plaintext chars
	JEZ r0 // jump to end of program if all plaintext chars have been processed
	LDI main_loop // load address of main_loop
	JMP r0 // jump to main_loop if there is still space for message characters
finish_post: LDI #d32
	STW r12 // store extra spaces at the end to pad message
	LDI done
	PUT r1 // store done address in r1
	LDI #d63
	XOR r12 // XOR r12 from 63 to see if they are equal
	JEZ r1 // if write pointer == 63, then we are done
	NXT r12 // increment write pointer
	LDI finish_post
	JMP r0 // otherwise keep on padding spaces to the end
lfsr_routine: GET r7 // get previous state
	AND r6 // and state with taps to get feedback pattern
	PTY r0 // get feedback parity bit
	PUT r1 // store feedback bit to r1 temporarily
	GET r7 // get previous state again
	LSH #d1 // left shift previous state by 1
	XOR r1 // or with parity bit to get next state
	PUT r7 // put next state to r7
	GET r14 // load link register
	JMP r0 // return to function call address
done: DNE // flag the CPU as done
	LDI #d255
	JMP r0