module lab5_dp #(parameter DW=8, AW=8, lfsr_bitwidth=5) (
// TODO: Declare your ports for your datapath
// TODO: for example							 
// TODO: output logic [7:0] encryptByte, // encrypted byte output
// TODO  output logic foundOne, // found one matching LFSR solution
// TODO: ... 
// TODO: input logic 	      clk, // clock signal 
// TODO: input logic 	      rst           // reset
      output logic [7:0] plainByte,
      output logic fInValid,

      input logic incByteCount,
      input logic getNext,
      input logic Load_LFSR,
      input logic lfsr_en,
      input logic validIn,

      input logic clk,
      input logic rst
   );
   


   logic [   lfsr_bitwidth-1:0] start;       // the seed value
   logic [   DW-1:0] 	    pre_len  = 'd7;  // preamble (~) length is fixed to 7 bytes         

   logic [8-1:0] 	       byteCount;

   logic [7:0] 		       fInEncryptByte;  // data from the input fifo
   fifo fm (.rdDat(fInEncryptByte), .valid(fInValid),
	         .wrDat(encryptByte), .push(validIn),
	         .pop(getNext), .clk(clk), .rst(rst));
   
   logic preambleDone;
   assign preambleDone = byteCount >= 7;

   logic messageDone;
   assign messageDone = byteCount == 32;
	
   // TODO: you might want to have 6 different sets of LFSR_state
   // TODO: signals, one belonging to each of six different possible
   // TODO: LFSRs.
   // TODO: for example: 
   // TODO:   logic [4:0] LFSR_state[6];
   // TODO:
   // TODO: and for each LFSR, keep a sticky bit 
   // TODO: (e.g. logic [5:0] match;)
   // TODO: that assumes the LFSR works, and on each
   // TODO: successive byte of the preamble, either remains
   // TODO: set or get's reset (and never set again).
   // TODO: At the end of 7 bytes of premable, you should have
   // TODO: only one of the six lfsr's still decoding premable bytes
   // TODO: correctly.
   // TODO:
   // TODO: Instantiate 6 LFSRs here (one for each of the 6 possible
   // TODO: polynomials (taps)).
   // TODO:
   // TODO: for example:
   // TODO: lfsr5b l0 (.clk ,
   // TODO:            .en   (lfsr_en),      // advance LFSR on rising clk
   // TODO:            .init (load_LFSR),    // initialize LFSR
   // TODO:            .taps(5'h1E)  , 	     // tap pattern
   // TODO:            .start , 	     // starting state for LFSR
   // TODO:            .state(LFSR_state[0]));	  // LFSR state = LFSR output 
   // TODO: lfsr5b l1 ( . . . );
   // TODO: lfsr5b l2 ( . . . );
   // TODO: lfsr5b l3 ( . . . );
   // TODO: lfsr5b l4 ( . . . );
   // TODO: lfsr5b l5 ( . . . );

   // assign LFSR_state[0] = 5'b11110; // 0x1E
   // assign LFSR_state[1] = 5'b11101; // 0x1D
   // assign LFSR_state[2] = 5'b11011; // 0x1B
   // assign LFSR_state[3] = 5'b10111; // 0x17
   // assign LFSR_state[4] = 5'b10100; // 0x14
   // assign LFSR_state[5] = 5'b10010; // 0x12

   logic [4:0] LFSR_state[6];
   lfsr5b l0 (.clk, .en(lfsr_en), .init(load_LFSR), .taps(5'h1E), .start, .state(LFSR_state[0]));
   lfsr5b l1 (.clk, .en(lfsr_en), .init(load_LFSR), .taps(5'h1D), .start, .state(LFSR_state[1]));
   lfsr5b l2 (.clk, .en(lfsr_en), .init(load_LFSR), .taps(5'h1B), .start, .state(LFSR_state[2]));
   lfsr5b l3 (.clk, .en(lfsr_en), .init(load_LFSR), .taps(5'h17), .start, .state(LFSR_state[3]));
   lfsr5b l4 (.clk, .en(lfsr_en), .init(load_LFSR), .taps(5'h14), .start, .state(LFSR_state[4]));
   lfsr5b l5 (.clk, .en(lfsr_en),. init(load_LFSR), .taps(5'h12), .start, .state(LFSR_state[5]));

   logic [7:0] correct = 8'h7E;
   logic [7:0] check0;
   logic [7:0] check1;
   logic [7:0] check2;
   logic [7:0] check3;
   logic [7:0] check4;
   logic [7:0] check5;

   //
   // sticky bit logic to find matching LFSR
   //
   logic [5:0] match;   // match status for each lfsr
   always @(posedge clk) begin 
      if(rst) begin 
	      match <= 6'h3F;
      end else begin
	 // TODO: for each of the 6 LFSRS
	 // TODO: maintain a match bit
	 // TODO: need to check for matches during the
	 // TODO: preamble.  One way to determine we
	 // TODO: are processing the preamble is
	 // TODO: fInValid & getNext & ~payload // processing a preamble byte
	 // TODO:
	 // TODO: OR
	 // TODO:
	 // TODO: you can create a signal from your controller
	 // TODO: that says we are processing a preamble byte
	 // TODO:
	 // TODO: if(.. processing a preamble byte .. ) begin
	 // TODO:    sticky bit logic for match[0], match[1], ... match[5]
	 // TODO: end 
         // if (!preambleDone) begin
         //    check0 


         // end
	   end  
   end 



   

   // TODO: write an expression for plainByte
   // TODO: for example:
   // TODO: assign plainByte = {         };
   // TODO: write an expression for the starting seed (the start value)
   // TODO: for the LFSRs.  You should be able to figure this out based on
   // TODO: the value of the first encrypted byte and the knowledged that
   // TODO: the unencrypted value is the preamble byte.
	
   //
   // byte counter - count the number of bytes processed
   //
   always_ff @(posedge clk) begin 
      if (rst) begin
	      byteCount <= 'd0;
	   end else begin
	      if(incByteCount) begin 
	         byteCount <= byteCount + 'd1; 
	      end else begin 
	         byteCount <= byteCount;
	      end 
	   end
   end 	
		
   
	
endmodule // lab5_dp

