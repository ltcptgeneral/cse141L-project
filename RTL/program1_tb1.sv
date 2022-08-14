// program1_tb
// testbench for programmable message encryption (Program #1)
// CSE141L    
// runs program 1 (encrypt a message)
module program1_tb ()        ;
// DUT interface -- four one-bit wires, three to DUT, one from
  bit        clk            ,          // advances simulation step-by-step
             init  = 1'b1   ,          // init (reset) command to DUT
             start = 1'b1   ;          // request (start program) command to DUT
  wire       done           ;          // acknowledge (program done) flag returned by DUT
// test bench parameters
  logic[7:0] pre_length     ;          // number of space char. before message itself, sent to data_mem[61]  
  logic[7:0] message1[54]   ,          // original raw message, in binary, up to 54 characters in length
             msg_padded1[64],          // original message, plus pre- and post-padding w/ ASCII spaces
             msg_crypto1[64];          // encrypted message returned by DUT
  logic[7:0] lfsr_ptrn      ,          // choses one of 9 maximal length 7-tap shift reg. patterns
             LFSR_ptrn[9]   ,          // the 9 candidate maximal-length 7-bit LFSR tap ptrns themselves
             lfsr1[64]      ,          // states of program 1 encrypting LFSR
             LFSR_init      ;          // one of 127 possible NONZERO starting states for encrypting LFSR
  int        score          ;          // count of correctly encyrpted characters
// our original American Standard Code for Information Interchange message follows
// note in practice your design should be able to handle ANY ASCII string that is
//  restricted to characters between space (0x20) and script f (0x9f) and shorter than 
//  55 characters in length
  string     str1  = "Mr. Watson, come here. I want to see you.";     // sample program 1 input
//  string     str1  = " Knowledge comes, but wisdom lingers.    ";   // alternative inputs
//  string     str1  = "  01234546789abcdefghijklmnopqrstuvwxyz. ";   //   (make up your own,
//  string     str1  = "  f       A joke is a very serious thing.";   // 	as well)
//  string     str1  = "                           Ajoke          ";   // 
//	string     str1  = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@";
//  string     str1  = " Knowledge comes, but wisdom lingers.    ";   // 

// displayed encrypted string will go here:
  string     str_enc1[64];             // program 1 desired output will go here
  int strlen;                          // length of incoming message string itself, before padding 
  logic[3:0] pt_no;                    // select LFSR pattern, index value 0 through 8
  int file_no;                         // output file tag (set to 1 for write to console/transcript)
// the 9 possible 7-tap maximal-length feedback tap patterns from which to choose
  assign LFSR_ptrn[0] = 8'h60;	       // (0)110_0000  
  assign LFSR_ptrn[1] = 8'h48;
  assign LFSR_ptrn[2] = 8'h78;
  assign LFSR_ptrn[3] = 8'h72;
  assign LFSR_ptrn[4] = 8'h6A;
  assign LFSR_ptrn[5] = 8'h69;
  assign LFSR_ptrn[6] = 8'h5C;
  assign LFSR_ptrn[7] = 8'h7E;         // (0)111_1110
  assign LFSR_ptrn[8] = 8'h7B;
  always_comb begin
    pt_no = 8;//$random;				   // or select a specific pattern ([0] and [1] are simplest to debug
    if(pt_no>8) pt_no[3] = 0;	       // restrict pt_no to 0 through 8
    lfsr_ptrn = LFSR_ptrn[pt_no];      // look up and engage the selected pattern; to data_mem[62]
  end
// now select a starting LFSR state -- any nonzero value will do
  always_comb begin					   
    LFSR_init = 'b1;//$random>>2;            // or set a specific value, such as 7'b1, for easier debug
    if(!LFSR_init) LFSR_init = 7'b1;   // prevents illegal starting state = 7'b0; 
  end

// set preamble length for the program run (always > 9 but < 26)
  always_comb begin
    pre_length = 10;//$random>>10 ;         // number of space characters ahead of message; the >>10 changes the random value
    if(pre_length < 10) pre_length = 10;   // prevents pre_length < 10
	else if(pre_length > 26) pre_length = 26; 
  end

// ***** instantiate your own top level design here *****
  top_level dut(
    .clk     (clk  ),   // input: use your own port names, if different
    .init    (init ),   // input: some prefer to call this ".reset"
    .req     (start),   // input: launch program
    .ack     (done )    // output: "program run complete"
  );

  initial begin
//***** pre-load your instruction ROM here or inside itself	*****
//    $readmemb("encoder.bin", dut.instr_rom.rom);
// you may also pre-load desired constants, etc. into
//   your data_mem here -- the upper addresses are reserved for your use
//    dut.data_mem.DM[128]=8'hfe;       //whatever constants you want	
// to display to console, change this line to file_no = 'b1;
    file_no = 'b1;  	// display to console instead of file
//  file_no = $fopen("msg_enocder_out.txt","w");		 // create your output file
    #0ns strlen = str1.len;             // length of string 1 (# characters between " ")
    if(strlen>54) strlen = 54;          // clip message at 54 characters
// program 1 -- precompute encrypted message
    lfsr1[0]     = LFSR_init;           // any nonzero value (zero may be helpful for debug)
    $fdisplay(file_no,"run encryption program; original message = ");
    $fdisplay(file_no,"%s",str1);       // print original message in transcript window
    $fdisplay(file_no,"pt_no = %d",pt_no);
    $fdisplay(file_no,"LFSR_ptrn = 0x%h, LFSR_init = 0x%h",lfsr_ptrn,LFSR_init);

// will subtract 0x20 from each preamble and each message character
    for(int j=0; j<64; j++)             // pre-fill message_padded with ASCII space characters
      msg_padded1[j] = 8'h20;           //           
    for(int l=0; l<strlen; l++)         // overwrite up to 54 of these spaces w/ message itself
      msg_padded1[pre_length+l] = str1[l];   // test bench does the -0x20 offset now
// compute and store the LFSR sequence
    for (int ii=0;ii<63;ii++)
      lfsr1[ii+1] = {(lfsr1[ii][5:0]),(^(lfsr1[ii]&lfsr_ptrn))};

// encrypt the message character-by-character, then prepend the parity
//  testbench will change on falling clocks to avoid race conditions at rising clocks
    for (int i=0; i<64; i++) begin
      msg_crypto1[i]        = ((msg_padded1[i]-32) ^ lfsr1[i]);
	  msg_crypto1[i][7]     = 'b0;//^msg_crypto1[i][6:0];       // prepend parity bit into MSB
      $fdisplay(file_no,"i=%d, msg_pad=0x%h, lfsr=%b msg_crypt w/ parity = 0x%h",
         i,msg_padded1[i],lfsr1[i],msg_crypto1[i]);
// for display purposes only, add 8'h20 to avoid nonprintable characters (<8'h20)
      str_enc1[i]           = string'(msg_crypto1[i][6:0]+'h20);
    end
	$fdisplay(file_no,"encrypted string =  "); 
	for(int jj=0; jj<64; jj++)
      $fwrite(file_no,"%s",str_enc1[jj]);
    $fdisplay(file_no,"\n");

// run encryption program
// ***** load operands into your data memory *****
// ***** use your instance name for data memory and its internal core *****
    for(int m=0; m<61; m++)
	  dut.DM.core[m] = 8'h0;         // pad memory w/ ASCII space characters
    for(int m=0; m<strlen; m++)
      dut.DM.core[m] = (str1[m]-8'h20);       // overwrite/copy original string into device's data memory[0:strlen-1]
    dut.DM.core[61] = pre_length;     // number of bytes preceding message
    dut.DM.core[62] = lfsr_ptrn;      // LFSR feedback tap positions (9 permissible patterns)
    dut.DM.core[63] = LFSR_init;      // LFSR starting state (nonzero)
    #20ns init  = 1'b0;				  // suggestion: reset = 1 forces your program counter to 0
	#10ns start = 1'b0; 			  //   request/start = 1 holds your program counter 
    #60ns;                            // wait for 6 clock cycles of nominal 10ns each
    wait(done);                       // wait for DUT's ack/done flag to go high
//    #2000ns; 
    #10ns $fdisplay(file_no,"");
    $fdisplay(file_no,"program 1:");
// ***** reads your results and compares to test bench
// ***** use your instance name for data memory and its internal core *****
// the +'h20 restores the -32 bias, for better display visuals
    for(int n=0; n<64; n++)	begin
	  if(msg_crypto1[n]==dut.DM.core[n+64])	begin
        $fdisplay(file_no,"%d bench msg: %s %h dut msg: %h",
          n, msg_crypto1[n][6:0]+8'h20, msg_crypto1[n], dut.DM.core[n+64]);
		score++;
	  end
      else
        $fdisplay(file_no,"%d bench msg: %s %h dut msg: %h  OOPS!",
          n, msg_crypto1[n][6:0]+8'h20, msg_crypto1[n], dut.DM.core[n+64]);
    end
    $fdisplay(file_no,"score = %d/64",score);
    #20ns $fclose(file_no);
    #20ns $stop;
  end

always begin     // continuous loop
  #5ns clk = 1;  // clock tick
  #5ns clk = 0;  // clock tock
end

endmodule