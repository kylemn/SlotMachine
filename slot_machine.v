`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:00:05 05/13/2015 
// Design Name: 
// Module Name:    slot_machine 
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
module slot_machine(
    input clk,
    input mode,
    input spin,
    input up,
    input down,
	 input reset,
    output [7:0] led,
    output [3:0] an,
    output [7:0] seven_segment_out,
    output [7:0] sound,
	output speaker
    );
	
	wire mode_db;
	wire spin_db;
	wire up_db;
	wire down_db;
	wire reset_db;
	
	wire clk_spin;
	wire clk_fast;
	wire clk_increment;
	wire clk_sound;
	wire clk_led;
	
	db_mode db_mode_ (
		.clk(clk),
		.raw_input(mode),
		.db(mode_db)
	);
	
	db_spin db_spin_ (
		.clk(clk),
		.raw_input(spin),
		.db(spin_db)
	);
	
	db_up db_up_ (
		.clk(clk),
		.raw_input(up),
		.db(up_db)
	);
	
	db_down db_down_ (
		.clk(clk),
		.raw_input(down),
		.db(down_db)
	);
	
	db_reset db_reset_ (
		.clk(clk),
		.raw_input(reset),
		.db(reset_db)
	);
	
	master_clock clock_ (
		.clk(clk),
		.clk_spin(clk_spin),
		.clk_fast(clk_fast),
		.clk_increment(clk_increment),
		.clk_sound(clk_sound),
		.clk_led(clk_led)
	);
	
	display display_ (
		.mode(mode_db),
		.spin(spin_db),
		.up(up_db),
		.down(down_db),
		.reset(reset_db),
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

endmodule
