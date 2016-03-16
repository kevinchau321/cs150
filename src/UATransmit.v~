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

  //++++Declarations++++//
  wire SymbolEdge;
  wire Sample;
  wire Start;
  wire TXRunning;
  
  reg SOutReg;
  reg is_running; // ANDREW: Separate registers for running and bitcounter
  reg [9:0] TXShift;
  reg [3:0] BitCounter;
  reg [ClockCounterWidth-1:0] ClockCounter;

  //++++Signals++++//
 
  assign SymbolEdge = (ClockCounter == SymbolEdgeTime - 1);
  assign TXRunning = (BitCounter!=0); // ANDREW: Changed from (BitCounter != 0);
  assign DataInReady = ~TXRunning || Reset; // ANDREW: Changed second expression from DataInValid
  assign SOut = SOutReg;
  assign Start = DataInValid && DataInReady;

  always @ (posedge Clock) begin
	ClockCounter <= (Start || Reset || SymbolEdge) ? 0 : ClockCounter + 1;
  end

  always @ (posedge Clock) begin
	if (Reset) begin
		BitCounter <= 0;
	end else begin
		if (Start) begin
			BitCounter <= 10;
		end else if (SymbolEdge && TXRunning) begin
			BitCounter <= BitCounter - 1;
		end
	end 
  end

  always @ (posedge Clock) begin
	if (Reset) begin
	TXShift <= 10'b0;
	SOutReg <= 1'b1;
	end
	if (Start) begin
		TXShift <= {1'b1,DataIn,1'b0};
	end else if (SymbolEdge) begin
		TXShift <= TXShift >> 1;
        end

	if (TXRunning) begin
		SOutReg <= TXShift[0];
	end
  end

endmodule
