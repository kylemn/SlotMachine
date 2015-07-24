`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:54:02 05/13/2015 
// Design Name: 
// Module Name:    display 
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
module display(
    input mode,
    input spin,
    input up,
    input down,
	 input reset,
    input clk,
    input clk_spin,
    input clk_fast,
    input clk_increment,
    input clk_led,
    input clk_sound,
    output reg [7:0] led,
    output reg [3:0] an,
    output reg [7:0] seven_segment_out,
    output reg [7:0] sound,
	output reg speaker
    );
	
	 parameter zero = 8'b11000000;
	 parameter one = 8'b11111001;
	 parameter two = 8'b10100100;
	 parameter three = 8'b10110000;
	 parameter four = 8'b10011001;
	 parameter five = 8'b10010010;
	 parameter six = 8'b10000010;
	 parameter seven = 8'b11111000;
	 parameter eight = 8'b10000000;
	 parameter nine = 8'b10011000;
	 parameter blank = 8'b11111111;
	 parameter hyphen = 8'b10111111;
	
	//Led 
	reg [2:0] led_current_blinker = 0;

	reg clk_led_d = 0;
   reg clk_spin_d = 0;
	
	//Used for knowing when to stop incrementing or decrementing
	reg [15:0] increment_stack = 0;
	reg [15:0] decrement_stack = 0;
	
	//money count -> decrease bet amt -> spin -> if win (blink and increase money ocunt) -> else stagnant
	//Play Mode
	reg [1:0] counter = 0;
	
	//first_digit is the ones place, second_digit is the tens place, etc
	//This is current money in its separate digit places
	reg [3:0] first_digit = 0;
	reg [3:0] second_digit = 0;
	reg [3:0] third_digit = 1;
	reg [3:0] fourth_digit = 0;
    
    //Same idea, but for betting amount
    reg [3:0] first_digit_bet = 0;
	reg [3:0] second_digit_bet = 5;
	reg [3:0] third_digit_bet = 0;
	reg [3:0] fourth_digit_bet = 0;
    
    //Same idea, but for random spinning mode
    reg [3:0] first_digit_spin = 0;
	reg [3:0] second_digit_spin = 5;
	reg [3:0] third_digit_spin = 0;
	reg [3:0] fourth_digit_spin = 0;
	
	//Current money in one register
	reg [15:0] amount_current = 0;
	//Current bet amount
	reg [15:0] bet_current = 0;
    
    //Need a randomizer tracker to simulate randomness
    reg [7:0] random_number = 0;
	
	//Spin-state tracker
	//0 is default
	//1 is decreasing bet
	//2 is spinning
	//3 is display spin results
	//4 is payout
	reg [2:0] spin_state = 0;
	
	//Stage 2's timer
	reg [31:0] counter_stage_2 = 0;
	parameter COUNT_STAGE2 = 75;
	
	//Stage 3's timer
	reg [31:0] counter_stage_3 = 0;
	parameter COUNT_STAGE3 = 25;
	
	//Integer result combination (gonna only be 0-15)
	integer spin_result = 0;

	//Sound tracker. Temporary
	reg [15:0] temp_sound_counter_test = 0;
	
	//Sounds
	reg [15:0] sound_spin_counter = 0;
	reg [15:0] sound_bing_counter = 0;
	reg [15:0] change_note_counter = 0;
	
	reg [15:0] COUNT_SOUND_SPIN = 100;
	reg [15:0] COUNT_SOUND_BING = 100;
	reg [15:0] COUNT_CHANGE_NOTE = 100000;
	reg [15:0] COUNT_MUTE_SOUND_SPIN = 50;
	reg [31:0] COUNT_MUTE_SOUND_BING = 100000000;

	reg [15:0] mute_sound_counter = 0;
	
	reg [2:0] current_note = 0;
	reg mute_sound = 0;
	
	//0 - welcome screen, 1 - regular gameplay, 2 - game over
	reg [1:0] game_state = 1;
	
	reg [15:0] welcome_screen_counter = 0;
	parameter welcome_counter = 1000000;
	
	initial
	begin
		seven_segment_out = 0;
		led = 0;
		sound = 0;
	end
	
	always @ (posedge clk)
	begin
	
		//Show hello screen
		/*if (game_state == 0)
			begin
				if (welcome_screen_counter == welcome_counter)
					begin
						welcome_screen_counter <= 0;
						game_state <= 1;
					end
				
				else
				begin
					welcome_screen_counter <= welcome_screen_counter + 1;
					counter <= counter + 1;
					if (counter == 0)
						begin
							an <= 4'b0111;
							seven_segment_out <= 8'b11001000;
						end
					
					else if (counter == 1)
						begin
							an <= 4'b1011;
							seven_segment_out <= 8'b10110000;
						end
					
					else if (counter == 2)
						begin
							an <= 4'b1101;
							seven_segment_out <= 8'b11110001;
						end
					
					else 
						begin
							an <= 4'b1110;
							seven_segment_out <= 8'b11000000;
						end
				end
           end*/
		
			
			
		//0 is on
        //Get current value
		  amount_current <= first_digit + (second_digit * 10) + (third_digit * 100) + (fourth_digit * 1000);
        bet_current <= first_digit_bet + (second_digit_bet * 10) + (third_digit_bet * 100) + (fourth_digit_bet * 1000);
		  random_number <= random_number + 1;
		  
        //Adjust bet amount 
        if (spin_state == 0 && (!spin) && clk_increment && mode)
        begin
            if (up)
            begin
                increment_money_bet();
            end
            
            else if (down)
            begin
                decrement_money_bet();
            end
        end
        
        
        //Play mode
        if (!mode && clk_fast && game_state == 1)
        begin
            counter <= counter + 1;
            if (spin_state == 0 || spin_state == 1 || spin_state == 4)
                begin
 
                if (counter == 0)
                    begin
                        an <= 4'b0111;
                        show_number(fourth_digit);
                    end
                
                else if (counter == 1)
                    begin
                        an <= 4'b1011;
                        show_number(third_digit);
                    end
                
                else if (counter == 2)
                    begin
                        an <= 4'b1101;
                        show_number(second_digit);
                    end
                
                else 
                    begin
                        an <= 4'b1110;
                        show_number(first_digit);
                    end
                end
				
				//Slot reel result screen
				else if (spin_state == 3)
				begin
					 if (counter == 0)
                    begin
                        an <= 4'b0111;
                        case (spin_result)
									0: show_number(15);
									1: show_number(15);
									2: show_number(15);
									3: show_number(15);
									4: show_number(15);
									5: show_number(15);
									6: show_number(15);
									7: show_number(15);
									8: show_number(2);
									9: show_number(2);
									10: show_number(2);
									11: show_number(2);
									12: show_number(5);
									13: show_number(5);
									14: show_number(5);
									15: show_number(7);
									default: show_number(15);
								endcase
                    end
                
                else if (counter == 1)
                    begin
                        an <= 4'b1011;
                        case (spin_result)
									0: show_number(15);
									1: show_number(15);
									2: show_number(15);
									3: show_number(15);
									4: show_number(15);
									5: show_number(15);
									6: show_number(15);
									7: show_number(15);
									8: show_number(2);
									9: show_number(2);
									10: show_number(2);
									11: show_number(2);
									12: show_number(5);
									13: show_number(5);
									14: show_number(5);
									15: show_number(7);
									default: show_number(15);
								endcase
                    end
                
                else if (counter == 2)
                    begin
                        an <= 4'b1101;
                        case (spin_result)
									0: show_number(15);
									1: show_number(15);
									2: show_number(15);
									3: show_number(15);
									4: show_number(15);
									5: show_number(15);
									6: show_number(15);
									7: show_number(15);
									8: show_number(2);
									9: show_number(2);
									10: show_number(2);
									11: show_number(2);
									12: show_number(5);
									13: show_number(5);
									14: show_number(5);
									15: show_number(7);
									default: show_number(15);
								endcase
                    end
                
                else 
                    begin
                        an <= 4'b1110;
                        case (spin_result)
									0: show_number(15);
									1: show_number(15);
									2: show_number(15);
									3: show_number(15);
									4: show_number(15);
									5: show_number(15);
									6: show_number(15);
									7: show_number(15);
									8: show_number(2);
									9: show_number(2);
									10: show_number(2);
									11: show_number(2);
									12: show_number(5);
									13: show_number(5);
									14: show_number(5);
									15: show_number(7);
									default: show_number(15);
								endcase
                    end
				end
					 
            else if (spin_state == 2)
					begin
					if (counter == 0)
					begin
						an <= 4'b0111;
						show_number(fourth_digit_spin);
					end
				
					else if (counter == 1)
					begin
						an <= 4'b1011;
						show_number(third_digit_spin);
					end
				
					else if (counter == 2)
					begin
						an <= 4'b1101;
						show_number(second_digit_spin);
					end
				
					else 
					begin
						an <= 4'b1110;
						show_number(first_digit_spin);
					end
            end
		end
       
        
        //Game logic
		//State 0
		if (!mode && clk_spin && spin_state == 0)
		begin
			//If spin is pressed
			if (spin)
				begin
					//Check if user has enough money
					if (amount_current >= bet_current)
						begin
							decrement_stack <= decrement_stack + bet_current;
							spin_state <= 1;
						end
				end
			
		end
		
		//State 1
		else if (clk_spin && spin_state == 1)
		begin
			if (decrement_stack > 0)
				begin
					decrement_money();
					decrement_stack <= decrement_stack - 1;
				end
			else
				begin
					spin_state <= 2;
				end	
		end
				
		//State 2 
		else if (clk_spin && spin_state == 2)
		begin
			spin_result <= random_number % 16;
            
            randomize_screen();
            
			if (counter_stage_2 == COUNT_STAGE2)
				begin
					counter_stage_2 <= 0;
					spin_state <= 3;
					
					//case by case. 16 combos. 0-7 is no win. 8-11 are cherries. 12-14 are bars. 15 is jackpot 777 
					case (spin_result)
						0: increment_stack <= increment_stack + 0;
						1: increment_stack <= increment_stack + 0;
						2: increment_stack <= increment_stack + 0;
						3: increment_stack <= increment_stack + 0;
						4: increment_stack <= increment_stack + 0;
						5: increment_stack <= increment_stack + 0;
						6: increment_stack <= increment_stack + 0;
						7: increment_stack <= increment_stack + 0;
						8: increment_stack <= increment_stack + (bet_current * 2); 
						9: increment_stack <= increment_stack + (bet_current * 2); 
						10: increment_stack <= increment_stack + (bet_current * 2); 
						11: increment_stack <= increment_stack + (bet_current * 2);
						12: increment_stack <= increment_stack + (bet_current * 5);
						13: increment_stack <= increment_stack + (bet_current * 5);
						14: increment_stack <= increment_stack + (bet_current * 5);
						15: increment_stack <= increment_stack + (bet_current * 25);
						default: increment_stack <= increment_stack + 0;
					endcase
					
				end
				
			else 
				begin
					counter_stage_2 <= counter_stage_2 + 1;
				end	 		
		end
		
		//Display slot reel results
		else if (clk_spin && spin_state == 3)
		begin
			if (counter_stage_3 == COUNT_STAGE3)
				begin
					counter_stage_3 <= 0;
					spin_state <= 4;
				end
			else
				begin
					counter_stage_3 <= counter_stage_3 + 1;
				end
		end
		
		
		//State 4
		else if (clk_spin && spin_state == 4)
		begin
			//payout			
			if (increment_stack > 0)
				begin
					increment_stack <= increment_stack - 1;
					increment_money();
				end
			else
				begin
					spin_state <= 0;
				end
		end
		
		//Betting Mode
		if (mode && clk_fast && spin_state == 0 && game_state == 1)
		begin
		
			//Check if reset is being pressed
			
			if (reset)
			begin
			//Reset values to default values lol
			first_digit <= 0;
			second_digit <= 0;
			third_digit <= 1;
			fourth_digit <= 0;
			
			first_digit_bet <= 0;
			second_digit_bet <= 5;
			third_digit_bet <= 0;
			fourth_digit_bet <= 0;
			end
			
			counter <= counter + 1;
			
			if (counter == 0)
			begin
				an <= 4'b0111;
				show_number(fourth_digit_bet);
			end
			
			else if (counter == 1)
			begin
				an <= 4'b1011;
				show_number(third_digit_bet);
			end
			
			else if (counter == 2)
			begin
				an <= 4'b1101;
				show_number(second_digit_bet);
			end
			
			else 
			begin
				an <= 4'b1110;
				show_number(first_digit_bet);
			end
		end
	end

	//LED always block
	always @ (posedge clk)
	begin
    
        if(spin_state != 2)
            begin
            if (clk_led && !clk_led_d)
                begin
                led_current_blinker = led_current_blinker + 1;
                display_led(led_current_blinker);
                end
                
            clk_led_d <= clk_led;
            end
        else if (spin_state == 2)
            begin
                if (clk_spin && !clk_spin_d)
                begin
                display_led((random_number + random_number) % 16);
                end
                
                clk_spin_d <= clk_fast;
            end
        
	end
		
	//SOUND BLOCK	
	always @ (posedge clk)
	begin
		//If muted, dont do anything
		
		if (spin_state == 2)
		begin
			if (mute_sound_counter >= COUNT_MUTE_SOUND_SPIN)
				begin
					mute_sound <= ~mute_sound;
					mute_sound_counter <= 0;
				end
				
			else
				begin
					mute_sound_counter <= mute_sound_counter + 1;
				end
		end 
		
		else if (spin_state == 4)
		begin
			if (mute_sound_counter >= COUNT_MUTE_SOUND_BING)
				begin
				mute_sound <= ~mute_sound;
				mute_sound_counter <= 0;
				end
			
			else
				begin
					mute_sound_counter <= mute_sound_counter + 1;
				end
		end
		
		if (!mute_sound)
			begin
			if (spin_state == 2)
			begin
				if (sound_spin_counter == COUNT_SOUND_SPIN)
					begin
						
						sound_spin_counter <= 0;
						
						speaker <= ~speaker;
					end
				else
					begin
						sound_spin_counter <= sound_spin_counter + 1;
					end
				
				if (change_note_counter == COUNT_CHANGE_NOTE)
					begin					
						if (current_note == 0)
							begin
								current_note <= 1;
								COUNT_SOUND_SPIN <= 1000;
							end
						else if (current_note == 1)
							begin
								current_note <= 2;
								COUNT_SOUND_SPIN <= 1500;
							end
						else if (current_note == 2)
							begin
								current_note <= 3;
								COUNT_SOUND_SPIN <= 2000;
							end
						else if (current_note == 3)
							begin
								current_note <= 4;
								COUNT_SOUND_SPIN <= 2500;
							end
						else
							begin
								current_note <= 0;
								COUNT_SOUND_SPIN <= 500;
							end
							
						
						change_note_counter <= 0;
					end
				else
					begin
						change_note_counter <= change_note_counter + 1;
					end
			end
			
			else if (spin_state == 4)
			begin
				if (sound_bing_counter == COUNT_SOUND_BING)
				begin
					sound_bing_counter <= 0;
					speaker <= ~speaker;
				end
				else
					begin
						sound_bing_counter <= sound_bing_counter + 1;
					end
			end
			
		end
		
		else
			begin
				mute_sound_counter <= mute_sound_counter + 1;
			end
			
	end
	
	task display_led;
		input [3:0] number;
		begin
			case (number)
			0: led <= 8'b00000001;
			1: led <= 8'b00000010;
			2: led <= 8'b00000100;
			3: led <= 8'b00001000;
			4: led <= 8'b00010000;
			5: led <= 8'b00100000;
			6: led <= 8'b01000000;
			7: led <= 8'b10000000;
			8: led <= 8'b00000000;
            9: led <= 8'b01000010;
            10: led <= 8'b10010001;
            11: led <= 8'b00110110;
            12: led <= 8'b11010011;
            13: led <= 8'b01010101;
            14: led <= 8'b10101010;
				default : led <= 8'b11111111;
			endcase
		end
	endtask
	
	task emit_sound;
		input [2:0] number;
		begin
			case (number)
				0: sound <= 27000000/2;
				1: sound <= 27000000/5;
				2: sound <= 27000000/10;
				3: sound <= 27000000/15;
				4: sound <= 27000000/25;
				5: sound <= 27000000/50;
				6: sound <= 27000000/100;
				7: sound <= 27000000/150;
				8: sound <= 27000000/300;
				default : sound <= 27000000/2;
			endcase
		end
	endtask
	
	task show_number;
		input [3:0] number;
		begin
			case (number)
				0: seven_segment_out <= zero;
				1: seven_segment_out <= one;
				2: seven_segment_out <= two;
				3: seven_segment_out <= three;
				4: seven_segment_out <= four;
				5: seven_segment_out <= five;
				6: seven_segment_out <= six;
				7: seven_segment_out <= seven;
				8: seven_segment_out <= eight;
				15: seven_segment_out <= hyphen;
				default: seven_segment_out <= nine;
			endcase
		end
	endtask
		
	task increment_money;
		begin
			if (first_digit == 4'd9)
				begin
					first_digit <= 0;
				end
			else
				begin
				first_digit <= first_digit + 1;
				end
				
			if (first_digit == 4'd9)
				begin
					if (second_digit == 4'd9)
						begin
							second_digit <= 0;
						end
					else
						begin
						second_digit <= second_digit + 1;
						end
				end
				
			if (first_digit == 4'd9 && second_digit == 4'd9)
				begin
					if (third_digit == 4'd9)
						begin
							third_digit <= 0;
						end
					else
						begin
							third_digit <= third_digit + 1;
						end
				end
			
			if (first_digit == 4'd9 && second_digit == 4'd9 && third_digit == 4'd9)
				begin
					//Set all digits to 9 if they are all supposed to be 9
					if (fourth_digit == 4'd9)
						begin
							fourth_digit <= 9;
							third_digit <= 9;
							second_digit <= 9;
							first_digit <= 9;
						end
					else
						begin
							fourth_digit <= fourth_digit + 1;
						end
				end
		end
	endtask
	
	task decrement_money;
		begin
			if (first_digit == 4'd0)
				begin
					if (second_digit == 4'd0)
						begin
							//handle xx00
							if(third_digit == 4'd0)
								begin
								//handle x000
									if (fourth_digit == 4'd0)
										begin
											//do nothing
										end
									else 
										begin
											fourth_digit <= fourth_digit - 1;
											third_digit <= 9;
											second_digit <= 9;
											first_digit <= 9;
										end
								end
							else
								begin
									third_digit <= third_digit - 1;
									second_digit <= 9;
									first_digit <= 9;
								end
						end
					else
						begin
							second_digit <= second_digit - 1;
							first_digit <= 9;
						end
				end
			else
				begin
					first_digit <= first_digit - 1;
				end
		end
	endtask
    
    task increment_money_bet;
		begin
			if (first_digit_bet == 4'd9)
				begin
					first_digit_bet <= 0;
				end
			else
				begin
				first_digit_bet <= first_digit_bet + 1;
				end
				
			if (first_digit_bet == 4'd9)
				begin
					if (second_digit_bet == 4'd9)
						begin
							second_digit_bet <= 0;
						end
					else
						begin
						second_digit_bet <= second_digit_bet + 1;
						end
				end
				
			if (first_digit_bet == 4'd9 && second_digit_bet == 4'd9)
				begin
					if (third_digit_bet == 4'd9)
						begin
							third_digit_bet <= 0;
						end
					else
						begin
							third_digit_bet <= third_digit_bet + 1;
						end
				end
			
			if (first_digit_bet == 4'd9 && second_digit_bet == 4'd9 && third_digit_bet == 4'd9)
				begin
					//Set all digits to 9 if they are all supposed to be 9
					if (fourth_digit_bet == 4'd9)
						begin
							fourth_digit_bet <= 9;
							third_digit_bet <= 9;
							second_digit_bet <= 9;
							first_digit_bet <= 9;
						end
					else
						begin
							fourth_digit_bet <= fourth_digit_bet + 1;
						end
				end
		end
	endtask
    
    task decrement_money_bet;
		begin
			if (first_digit_bet == 4'd0)
				begin
					if (second_digit_bet == 4'd0)
						begin
							//handle xx00
							if(third_digit_bet == 4'd0)
								begin
								//handle x000
									if (fourth_digit_bet == 4'd0)
										begin
											//do nothing
										end
									else 
										begin
											fourth_digit_bet <= fourth_digit_bet - 1;
											third_digit_bet <= 9;
											second_digit_bet <= 9;
											first_digit_bet <= 9;
										end
								end
							else
								begin
									third_digit_bet <= third_digit_bet - 1;
									second_digit_bet <= 9;
									first_digit_bet <= 9;
								end
						end
					else
						begin
							second_digit_bet <= second_digit_bet - 1;
							first_digit_bet <= 9;
						end
				end
			else
				begin
					first_digit_bet <= first_digit_bet - 1;
				end
		end
	endtask
    
    task randomize_screen;
		begin
			first_digit_spin <= random_number % 10;
            second_digit_spin <= (random_number+ 6) % 10;
            third_digit_spin <= (random_number + 3) % 10;
            fourth_digit_spin <= (random_number + random_number) % 10;
		end
	endtask
	
endmodule
