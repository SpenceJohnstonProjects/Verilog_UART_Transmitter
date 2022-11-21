/*
Author: Spence Johnston
Module:  string controller 
Purpose: 	
	loops through string, outputting string one char at a time
	one char = one byte
	only passed data when transmitter is ready.
*/

module str_controller 
(
	input clk, reset, enable,
	input transmitter_ready,
	output reg [7:0] out,
	output reg out_en //enable the recieving fsm
);

//states
localparam IDLE = 1;
localparam SEND = 2;
localparam WAIT = 0;
localparam BUFFER = 3;

reg [7:0] str [0:11];//array of 12 8-bit characters
reg [1:0] state;
reg [3:0] count;

always @ ( posedge clk )
begin
	if (reset)
	begin
		str[0] = "H";
		str[1] = "e";
		str[2] = "l";
		str[3] = "l";
		str[4] = "o";
		str[5] = " ";
		str[6] = "s";
		str[7] = "p";
		str[8] = "e";
		str[9] = "n";
		str[10] = "c";
		str[11] = "e";
		
		state = IDLE;
	end
	else
		case (state)
			IDLE://waiting for enable
			begin
				count = 0;
				out = 0;
				
				if (enable)
					state = WAIT;
				else
					state = state;
			end
			WAIT: //doesn't send enable signal
			begin
				out = str[count];
				
				if ( ~(count < 12) ) //if count is out of bounds of string
					state = IDLE;
				else
				if ( transmitter_ready )
					state = SEND;
				else
					state = state;
			end
			SEND: //sends enable signal. inc counter
			begin
				count = count + 1'b1;
				state = BUFFER;
			end
			BUFFER: //needs one clock cycle for transmitter_fsm to interact correctly. this solved that. (my issue)
			begin
				state = WAIT;
			end
		endcase
end

always @ ( state )
begin
	case (state)
		IDLE,
		BUFFER,
		WAIT:
		begin
			out_en = 0;
		end
		SEND:
		begin
			out_en = 1;
		end
	endcase
end
endmodule 

// TESTBENCH
module str_controller_bench;

reg clk, reset, enable;
reg transmitter_ready;
wire [7:0] out;
wire out_en;

str_controller c0 (clk, reset, enable, transmitter_ready, out, out_en);

initial
begin
	clk = 1;
	reset = 1;
	enable = 0;
	transmitter_ready = 1;
	
	#2 reset = 0;
	#2 enable = 1;
	#1 enable = 0;
	
	#1 transmitter_ready = 0;
	#6 transmitter_ready = 1;
	
	#4 transmitter_ready = 0;
	#10 transmitter_ready = 1;
end

always
begin
	#1 clk = ~clk;
end
endmodule
