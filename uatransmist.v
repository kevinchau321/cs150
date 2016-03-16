module UATransmit(
  input   Clock,
  input   Reset,

  input   [7:0] DataIn,
  input         DataInValid,
  output        DataInReady,

  output        SOut
);
  // for log2 function
  `include "util.vh"

  //--|Parameters|--------------------------------------------------------------

  parameter   ClockFreq         =   100_000_000;
  parameter   BaudRate          =   115_200;

  // See diagram in the lab guide
  localparam  SymbolEdgeTime    =   ClockFreq / BaudRate;
  localparam  ClockCounterWidth =   log2(SymbolEdgeTime);

  //--|Solution|----------------------------------------------------------------
  wire                            SymbolEdge;
  wire                            Start;
  wire                            TXRunning;

  reg 				  Out; 
  reg     [7:0]                   TXShift;
  reg     [3:0]                   BitCounter;
  reg     [ClockCounterWidth-1:0] ClockCounter;
 				  

  //--|Signal Assignments|------------------------------------------------------

  // Goes high at every symbol edge
  assign  SymbolEdge   = (ClockCounter == SymbolEdgeTime - 1);  

  // Goes high when it is time to start transmitting a new character
  assign  Start         = DataInValid && !TXRunning;

  // Currently transmitting a character
  assign  TXRunning     = BitCounter != 4'd10;

  // Outputs
  assign  SOut = Out;
  assign  DataInReady = !TXRunning;
   

  //--|Counters|----------------------------------------------------------------

  // Counts cycles until a single symbol is done
  always @ (posedge Clock) begin
     ClockCounter <= (Start || Reset || SymbolEdge) ? 0 : ClockCounter + 1;
  end

  // Counts down from 10 bits for every character
  always @ (posedge Clock) begin
     if (Start) BitCounter <= 0;
     else if (Reset) BitCounter <=4'd10;
     else if (SymbolEdge && TXRunning) BitCounter <= BitCounter + 1;
  end

  //--|Shift Register|----------------------------------------------------------
  always @(posedge Clock) begin
     if (Start) begin 
	Out <= 1'b0;
	TXShift = DataIn;
     end
     else if (TXRunning) begin
	if (BitCounter == 9) Out <= 1'b1;
	else Out <= TXShift[BitCounter-1];
     end
  end
endmodule