/*
Author: Spence Johnston
Module:  UART transmitter
Purpose: 
	outputs "hello spence" via uart protocol.
	This is done by calling input_string.
	input_string sends the string and 
	enable signal on button press to string controller.
	string_controller runs through each character of the string
	and sends it and an enable signal to transmit_fsm.
	transmit_fsm sends the signal character via the uart protocol
	to a USB adapter. This is done through GPIO.
	All modules that send enable signals require a done signal from the module accepting the enable.
*/
module uart_transmitter (
	input CLOCK_50,
	input reset,
	input button_,
	input receiver_done,
	output uart_out
);

wire clk_9600;
wire transmitter_donew;
wire string_cont_enw;
wire transmitter_enw;
wire [7:0] str_cont_outbytew;

input_string i0 (clk_9600, reset, button_, string_cont_enw);
str_controller s0 (clk_9600, reset, string_cont_enw, transmitter_donew, str_cont_outbytew, transmitter_enw);
transmit_fsm t0 (clk_9600, transmitter_enw, reset, receiver_done, str_cont_outbytew, uart_out, transmitter_donew);

endmodule 

//TESTBENCH
module uart_transmitter_bench;

	reg clk;
	reg reset;
	reg button_;
	reg receiver_done;
	wire uart_out;

uart_transmitter t0 (clk, reset, button_, receiver_done, uart_out);	
	
initial
begin
	clk = 1;
	reset = 1;
	button_ = 1;
	receiver_done = 1;
	
	
	#2 reset = 0;
	#4 button_ = 0;
	#1 button_ = 1;
	
	#22 receiver_done = 0;
	#20 receiver_done = 1;
	
end

always
begin
	#1 clk = ~clk;
end
endmodule 