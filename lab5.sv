
// Lab 5
// CSE140L
// for use by registered cse140L students and staff only.
// All rights reserved.
module lab5 #(parameter DW=8, AW=8, byte_count=2**AW, lfsr_bitwidth=5)(
    output logic [7:0]  plainByte,
    output logic        validOut,
    input logic         validIn,   // assert when there is a byte to encrypt
    input logic [7:0]   encryptByte,
    input logic	        clk, 
                        decRqst,
    output logic        done,
    input logic         rst);

    
    logic fInValid;
    logic incByteCount;
    logic getNext;
    logic load_LFSR;
    logic lfsr_en;
    logic preambleDone;
  	logic messageDone;
    
    lab5_dp dp (.*);

    seqsm sm (.*);

endmodule // lab5

