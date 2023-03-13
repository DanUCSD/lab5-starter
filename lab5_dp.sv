module lab5_dp #(parameter DW=8, AW=8, lfsr_bitwidth=5) (

      output logic [7:0] plainByte,
      output logic fInValid,
      output logic preambleDone,
      output logic messageDone,

      input logic incByteCount,
      input logic getNext,
      input logic load_LFSR,
      input logic lfsr_en,
	   input logic [7:0] encryptByte,

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

   assign preambleDone = byteCount >= pre_len;

   assign messageDone = byteCount == 32;
	
   assign start = 5'h1E ^ fInEncryptByte[4:0];

   logic [4:0] LFSR_state[6];
   lfsr5b l0 (.clk, .en(lfsr_en), .init(load_LFSR), .taps(5'h1E), .start, .state(LFSR_state[0]));
   lfsr5b l1 (.clk, .en(lfsr_en), .init(load_LFSR), .taps(5'h1D), .start, .state(LFSR_state[1]));
   lfsr5b l2 (.clk, .en(lfsr_en), .init(load_LFSR), .taps(5'h1B), .start, .state(LFSR_state[2]));
   lfsr5b l3 (.clk, .en(lfsr_en), .init(load_LFSR), .taps(5'h17), .start, .state(LFSR_state[3]));
   lfsr5b l4 (.clk, .en(lfsr_en), .init(load_LFSR), .taps(5'h14), .start, .state(LFSR_state[4]));
   lfsr5b l5 (.clk, .en(lfsr_en),. init(load_LFSR), .taps(5'h12), .start, .state(LFSR_state[5]));

   logic [5:0] match;
   always @(posedge clk) begin 
      if(rst) begin 
	      match <= 6'h3F;
      end else begin
          if (!preambleDone) begin
            if ({1'b0, fInEncryptByte[6:5], fInEncryptByte[4:0] ^ LFSR_state[5]} != 8'h7E) 				begin
              match[5] = 0;
            end
            if ({1'b0, fInEncryptByte[6:5], fInEncryptByte[4:0] ^ LFSR_state[4]} != 8'h7E) 				begin
              match[4] = 0;
            end
            if ({1'b0, fInEncryptByte[6:5], fInEncryptByte[4:0] ^ LFSR_state[3]} != 8'h7E) 				begin
              match[3] = 0;
            end
            if ({1'b0, fInEncryptByte[6:5], fInEncryptByte[4:0] ^ LFSR_state[2]} != 8'h7E) 				begin
              match[2] = 0;
            end
            if ({1'b0, fInEncryptByte[6:5], fInEncryptByte[4:0] ^ LFSR_state[1]} != 8'h7E) 				begin
              match[1] = 0;
            end
            if ({1'b0, fInEncryptByte[6:5], fInEncryptByte[4:0] ^ LFSR_state[0]} != 8'h7E) 				begin
              match[0] = 0;
            end
          end
	   end  
   end 

  always_comb begin
      if (match[5] == 1) begin
         plainByte = {1'b0, fInEncryptByte[6:5], fInEncryptByte[4:0] ^ LFSR_state[5]};
      end if (match[4] == 1) begin
         plainByte = {1'b0, fInEncryptByte[6:5], fInEncryptByte[4:0] ^ LFSR_state[4]};
      end if (match[3] == 1) begin
         plainByte = {1'b0, fInEncryptByte[6:5], fInEncryptByte[4:0] ^ LFSR_state[3]};
      end if (match[2] == 1) begin
         plainByte = {1'b0, fInEncryptByte[6:5], fInEncryptByte[4:0] ^ LFSR_state[2]};
      end if (match[1] == 1) begin
         plainByte = {1'b0, fInEncryptByte[6:5], fInEncryptByte[4:0] ^ LFSR_state[1]};
      end if (match[0] == 1) begin
         plainByte = {1'b0, fInEncryptByte[6:5], fInEncryptByte[4:0] ^ LFSR_state[0]};
      end
  end
  
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

