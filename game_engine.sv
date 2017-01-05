module game_engine (input Clk, input Reset, 
						  input [9:0] BallX, BallY,
						  output logic [7:0] score1, score2, 
						  output logic resetfieldsig,
						  output logic [7:0] greenLeds,
						  output logic [17:0] redLeds);

			
		// SCORING STATE MACHINE	
		enum logic [2:0] {START, PLAY, SCORE_1, SCORE_2, ACK_SCORE_1, ACK_SCORE_2} state, next_state;
		logic [2:0] counter;
		logic [7:0] nextScore1, nextScore2;
		logic [26:0] ledBlinker;
		always_ff @ (posedge Clk) begin
			ledBlinker <= ledBlinker + 1;
			if((score1 == 8'hEE || score2 == 8'hEE) && (ledBlinker >= 26'd0 && ledBlinker <= 26'd33554432)) begin
				greenLeds <= 8'hFF;
				redLeds <= 18'd262143;		// turns on all redLEDS, 2^18 - 1 
			end
			else begin
				greenLeds <= 8'h00;
				redLeds <= 18'd0;
			end
		end

	
		always_ff @ (posedge Clk) begin
			if (Reset == 1'b1) begin
				state <= START;
				score1 <= 8'd0;
				score2 <= 8'd0;
				counter <= 3'b000;
			end else begin
				counter <= counter + 1;
				state <= next_state;
				case (state)
					START: begin
						score1 <= 8'd0;
						score2 <= 8'd0;
					end
					PLAY: begin
						score1 <= score1;
						score2 <= score2;
						counter <= 3'b000;
					end
					
					SCORE_1: begin
						score1 <= score1;
						score2 <= score2;
					end
					
					SCORE_2: begin
						score1 <= score1;
						score2 <= score2;
					end
					
					ACK_SCORE_1: begin
						score2 <= score2;
						score1 <= nextScore1;
					end
					
					ACK_SCORE_2: begin
						score1 <= score1;
						score2 <= nextScore2;
					end
						
				endcase	
			end
		end
		
		always_comb begin
			next_state = state;
			nextScore1 = score1;
			nextScore2 = score2;
			case (state)
				START: begin
					next_state = PLAY;
				end
				PLAY: begin
					if (BallX >= 10'd0 && BallX <= 10'd30 && BallY >= 10'd209 && BallY <= 10'd271) begin //21
						next_state = SCORE_2;
					end
					else if (BallX >= 10'd609 && BallX <= 10'd639 && BallY >= 10'd209 && BallY <= 10'd271) begin // 618
						next_state = SCORE_1;
					end
				end
				
				SCORE_1: begin
					if(counter == 3'b010) begin
						next_state = ACK_SCORE_1;
					end
				end
				
				SCORE_2: begin
					if(counter == 3'b010)
						next_state = ACK_SCORE_2;
				end
				
				ACK_SCORE_1: begin
					if(counter == 3'b100)
						nextScore1 = score1 + 1;
					if(counter == 3'b111)
						next_state = PLAY;
				end
				
				ACK_SCORE_2: begin
					if(counter == 3'b100)
						nextScore2 = score2 + 1;
					if(counter == 3'b111)
						next_state = PLAY;
				end
			endcase
		end
		
		always_comb begin
			resetfieldsig = 1'b0;
			case (state)
				START: begin
					resetfieldsig = 1'b0;
				end
				
				PLAY: begin
					resetfieldsig = 1'b0;
				end
				SCORE_1: begin
					resetfieldsig = 1'b1;
				end
				
				SCORE_2: begin
					resetfieldsig = 1'b1;
				end
				ACK_SCORE_1: begin
					resetfieldsig = 1'b0;
				end
				ACK_SCORE_2: begin
					resetfieldsig = 1'b0;
				end
			endcase
		end

endmodule		