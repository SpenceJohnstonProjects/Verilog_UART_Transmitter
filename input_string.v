//Author: Spence Johnston
//Module: input string  
//Purpose:
//			on button pressed, send "hello spence" and an enable for the string_controller
//			button locked out, so it will only transmit one signal if button pressed.

module input_string
(
	input clk, reset, button_,
	output reg, en
);

//states
localparam WAIT = 0;
localparam PRESSED = 1;
localparam IDLE = 2;

reg [1:0] state;

always @ ( posedge clk )
begin                        
	if ( reset )
		state = IDLE;
	else 
		case ( state )
			IDLE:
			begin
				if ( ~button_ )
					state = PRESSED;
				else
					state = state;
			end
			PRESSED:
			begin
				state = WAIT;
			end
			WAIT:
			begin
				if ( ~button_)
					state = state;
				else
					state = IDLE;
			end
		endcase
end

always @ ( state )
begin
	case (state)
		WAIT, 
		IDLE:
		begin
			en = 0;
		end
		PRESSED:
		begin
			en = 1;
		end
	endcase
end
endmodule 

// TESTBENCH
module input_string_bench;

reg clk, reset, button_;
wire en; 

input_string i0 (clk, reset, button_, en);

initial
begin
	clk = 1;
	reset = 1;
	button_ = 1;
	
	
	#2 reset = 0;
	#4 button_ = 0;
	#1 button_ = 1;
	
	#5 button_ = 0;
end

always
begin
	#1 clk = ~clk;
end
endmodule 