`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:39:22 05/13/2015 
// Design Name: 
// Module Name:    master_clock 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module master_clock(
    input clk,
    output reg clk_spin,
    output reg clk_fast,
    output reg clk_increment,
	output reg clk_sound,
	output reg clk_led
    );
	
	reg [31:0] counter_spin = 0;
	reg [31:0] counter_fast = 0;
	reg [31:0] counter_increment = 0;
	reg [31:0] counter_led = 0;
	reg [31:0] counter_sound = 0;
	
	//Adjust these values later
	parameter COUNT_SPIN = 5000000;
	parameter COUNT_FAST = 100000;
	parameter COUNT_INCREMENT = 25000000;
	parameter COUNT_LED = 25000000;
	parameter COUNT_SOUND = 25000000;

	always @ (posedge clk)
	begin
		
		if (counter_spin == COUNT_SPIN)
			begin
				counter_spin <= 0;
				clk_spin <= 1;
			end
		else
			begin
				counter_spin <= counter_spin + 1;
				clk_spin <= 0;
			end
		
		if (counter_fast == COUNT_FAST)
			begin
				counter_fast <= 0;
				clk_fast <= 1;
			end
		else
			begin
				counter_fast <= counter_fast + 1;
				clk_fast <= 0;
			end
		
		if (counter_increment == COUNT_INCREMENT)
			begin
				counter_increment <= 0;
				clk_increment <= 1;
			end
		else
			begin
				counter_increment <= counter_increment + 1;
				clk_increment <= 0;
			end
			
		if (counter_led == COUNT_LED)
			begin
				counter_led <= 0;
				clk_led <= 1;
			end
		else
			begin
				counter_led <= counter_led + 1;
				clk_led <= 0;
			end
		
		if (counter_sound == COUNT_SOUND)
			begin
				counter_sound <= 0;
				clk_sound <= 1;
			end
		else
			begin
				counter_sound <= counter_sound + 1;
				clk_sound <= 0;
			end
	end

endmodule
