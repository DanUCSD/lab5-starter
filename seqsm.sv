module seqsm #(parameter DW=8, AW=8, byte_count=2**AW) 
   (
// TODO: define your outputs and inputs
   
   output logic load_LFSR,
   output logic incByteCount,
   output logic lfsr_en,
   output logic validOut,
   output logic done,
   output logic getNext,

   input logic preambleDone,
   input logic messageDone,
   input logic fInValid,
   input logic decRqst,

   input logic clk,
   input logic rst
   );

   typedef enum {Idle, LoadLFSR, ProcessPreamble, Decrypt, Done} state_t;
   
   state_t curState;
   state_t nxtState;

   always_ff @(posedge clk)
      begin
         if (rst)
            curState <= Idle;
         else
            curState <= nxtState;
      end 

   always_comb begin

	load_LFSR = 0;
   getNext = 0;

      unique case (curState) 

         Idle: begin
            nxtState = decRqst ? LoadLFSR : Idle;
         end

         LoadLFSR: begin
            if (fInValid) begin
               load_LFSR = 1;
               nxtState = ProcessPreamble;
            end else begin
               nxtState = LoadLFSR;
            end
         end

         ProcessPreamble: begin
            if (fInValid) begin
               incByteCount = 1;
               getNext = 1;
               lfsr_en = 1;
               validOut = 1;
            end   
            if (preambleDone) begin
               nxtState = Decrypt;
            end else begin
               nxtState = ProcessPreamble;
            end
         end

         Decrypt: begin
            if (fInValid) begin
               incByteCount = 1;
               getNext = 1;
               lfsr_en = 1;
               validOut = 1;
            end
            if (messageDone) begin
               nxtState = Done;
            end else begin
               nxtState = Decrypt;
            end
         end

         Done: begin
            done = 1;
            nxtState = Done;
         end

      endcase

   end


endmodule // seqsm
