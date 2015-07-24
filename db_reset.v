`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:17:50 05/31/2015 
// Design Name: 
// Module Name:    db_reset 
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
module db_reset(
    input clk,
    input raw_input,
    output reg db
    );
	 
	reg [31:0] counter = 0;
	reg clk_en = 0;
	
	always @ (posedge clk) 
	begin
		if (counter == 100000) 
		begin
			counter <= 0;
			clk_en <= 1;
		end 
		else 
		begin
			counter <= counter + 1;
			clk_en <= 0;
		end
	end
	
	always @ (posedge clk_en) 
	begin
		db <= raw_input;
	end


endmodule
