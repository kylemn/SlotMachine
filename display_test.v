`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   10:27:00 05/18/2015
// Design Name:   display
// Module Name:   C:/Users/152/Desktop/lab4/lab4/lab4/display_test.v
// Project Name:  lab4
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: display
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module display_test;

	// Inputs
	reg mode;
	reg spin;
	reg up;
	reg down;
	reg clk;
	reg clk_spin;
	reg clk_fast;
	reg clk_increment;
	reg clk_led;
	reg clk_sound;
	

	// Outputs
	wire [7:0] led;
	wire [3:0] an;
	wire [7:0] seven_segment_out;
	wire [7:0] sound;
	wire speaker;
	
	// Instantiate the Unit Under Test (UUT)
	display uut (
		.mode(mode), 
		.spin(spin), 
		.up(up), 
		.down(down), 
		.clk(clk), 
		.clk_spin(clk_spin), 
		.clk_fast(clk_fast), 
		.clk_increment(clk_increment), 
		.clk_led(clk_led), 
		.clk_sound(clk_sound), 
		.led(led), 
		.an(an), 
		.seven_segment_out(seven_segment_out), 
		.sound(sound),
		.speaker(speaker)
	);

	initial begin
		// Initialize Inputs
		mode = 1;
		spin = 0;
		up = 0;
		down = 0;
		clk = 0;
		clk_spin = 0;
		clk_fast = 0;
		clk_increment = 0;
		clk_led = 0;
		clk_sound = 0;
        
        


		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
	
    always #10000000 up = ~up;
	always #100 clk = ~clk;
	always #250000 clk_led = ~clk_led;
	always #250000 clk_sound = ~clk_sound;
    always #250000 clk_increment = ~clk_increment;
      
endmodule

