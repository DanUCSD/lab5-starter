module seqsm #(parameter DW=8, AW=8, byte_count=2**AW) 
   (
// TODO: define your outputs and inputs
   
   output logic Load_LFSR,
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


   // TODO: define your states
   // TODO: here is one suggestion, but you can implmenet any number of states
   // TODO: you like
   // TODO: typedef enum {
   // TODO:		 Idle, LoadLFSR, ProcessPreamble, Decrypt, Done
   // TODO:		 } states_t;
   // TODO: for example
   // TODO:  1: Idle -> 
   // TODO:  2: LoadLFSR ->
   // TODO:  3: ProcessPreamble (and select LFSR)
   // TODO:  4: Decrypt
   // TODO:  5: Done

   // TODO: implement your state machine
   // TODO:
   // TODO: // sequential part
   // TODO: always_ff @(posedge clk) begin 
   // TODO:     . . .
   // TODO: end
   // TODO:
   // TODO: // combinatorial part
   // TODO: always_comb begin
   // TODO:     . . .
   // TODO: end

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



      unique case (curState) 

         Idle: begin
            nxtState = decRqst ? LoadLFSR : Idle;
         end

         LoadLFSR: begin
            Load_LFSR = 1;
            nxtState = ProcessPreamble;
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
