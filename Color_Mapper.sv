
module  color_mapper ( 	input				[9:0] Play1X, Play1Y, Play1DrawX, Play1DrawY, Play1_size,
								input				[9:0] Play2X, Play2Y, Play2DrawX, Play2DrawY, Play2_size,
								input        [9:0] BallX, BallY, DrawX, DrawY, Ball_size,
								input			mapColor,
                       output logic [7:0]  Red, Green, Blue );
    
	 
    logic ball_on;
	 logic Play1_on;
	 logic Play2_on;
	 logic field_on;
	 logic goal_blue;
	 logic goal_red;
	  
	 // ball
    int BallDistX, BallDistY, BallSize;
	 assign BallDistX = DrawX - BallX;
    assign BallDistY = DrawY - BallY;
    assign BallSize = Ball_size;
	  
	 // player1
    int Play1DistX, Play1DistY, Play1Size;
	 assign Play1DistX = DrawX - Play1X;
    assign Play1DistY = DrawY - Play1Y;
    assign Play1Size = Play1_size; 
	 
	 // player2
    int Play2DistX, Play2DistY, Play2Size;
	 assign Play2DistX = DrawX - Play2X;
    assign Play2DistY = DrawY - Play2Y;
    assign Play2Size = Play2_size;
	 
	 int DrawX_Int, DrawY_Int;
	 assign DrawX_Int = {1'b0, DrawX};
	 assign DrawY_Int = {1'b0, DrawY};
	  
    always_comb
    begin:on_proc
        if ( ( BallDistX*BallDistX + BallDistY*BallDistY) <= (BallSize * BallSize) ) 
            ball_on = 1'b1;
        else 
            ball_on = 1'b0;
				
			if ( ( Play1DistX*Play1DistX + Play1DistY*Play1DistY) <= (Play1Size * Play1Size) ) 
            Play1_on = 1'b1;
        else 
            Play1_on = 1'b0;
				
			if ( ( Play2DistX*Play2DistX + Play2DistY*Play2DistY) <= (Play2Size * Play2Size) ) 
            Play2_on = 1'b1;
        else 
            Play2_on = 1'b0;
			
			// field coloring
			if( 		DrawX >= 10'd20  && DrawX <= 10'd619 && DrawY >= 10'd19   && DrawY <= 10'd21)	// field borders
				field_on = 1'b1;
			else if( DrawX >= 10'd20  && DrawX <= 10'd619 && DrawY >= 10'd458  && DrawY <= 10'd460)
				field_on = 1'b1;
			else if( DrawX >= 10'd19  && DrawX <= 10'd21  && DrawY >= 10'd20   && DrawY <= 10'd459)
				field_on = 1'b1;
			else if( DrawX >= 10'd618 && DrawX <= 10'd620 && DrawY >= 10'd20   && DrawY <= 10'd459)
				field_on = 1'b1;
				
			else if( DrawX >= 10'd20  && DrawX <= 10'd107 && DrawY >= 10'd134 && DrawY <= 10'd136)	// rectanglesLeft
				field_on = 1'b1;
			else if( DrawX >= 10'd20  && DrawX <= 10'd107 && DrawY >= 10'd348 && DrawY <= 10'd350)
				field_on = 1'b1;
			else if( DrawX >= 10'd107 && DrawX <= 10'd109 && DrawY >= 10'd134 && DrawY <= 10'd350)
				field_on = 1'b1;
			else if (DrawX >= 10'd20  && DrawX <= 10'd50  && DrawY >= 10'd207 && DrawY <= 10'd209)	// goalLeft
				field_on = 1'b1;
			else if (DrawX >= 10'd20  && DrawX <= 10'd50  && DrawY >= 10'd271 && DrawY <= 10'd273)
				field_on = 1'b1;
			else if (DrawX >= 10'd50  && DrawX <= 10'd52  && DrawY >= 10'd207 && DrawY <= 10'd273)
				field_on = 1'b1;
				
			else if( DrawX >= 10'd532 && DrawX <= 10'd619 && DrawY >= 10'd134 && DrawY <= 10'd136)	// rectanglesRight
				field_on = 1'b1;
			else if( DrawX >= 10'd532 && DrawX <= 10'd619 && DrawY >= 10'd348 && DrawY <= 10'd350)
				field_on = 1'b1;
			else if( DrawX >= 10'd531 && DrawX <= 10'd533 && DrawY >= 10'd134 && DrawY <= 10'd350)
				field_on = 1'b1;
			else if (DrawX >= 10'd589  && DrawX <= 10'd619  && DrawY >= 10'd207 && DrawY <= 10'd209)	// goalRight
				field_on = 1'b1;
			else if (DrawX >= 10'd589  && DrawX <= 10'd619  && DrawY >= 10'd271 && DrawY <= 10'd273)
				field_on = 1'b1;
			else if (DrawX >= 10'd587  && DrawX <= 10'd589  && DrawY >= 10'd207 && DrawY <= 10'd273)
				field_on = 1'b1;
				
			else if( DrawX >= 10'd319 && DrawX <= 10'd321 && DrawY >= 10'd20  && DrawY <= 10'd459)	// center line
				field_on = 1'b1;
				
			else if((((DrawX_Int - 11'd320)*(DrawX_Int - 11'd320) + (DrawY_Int - 11'd240)*(DrawY_Int - 11'd240)) >= 11'd1849) && 
			   (((DrawX_Int - 11'd320)*(DrawX_Int - 11'd320) + (DrawY_Int - 11'd240)*(DrawY_Int - 11'd240)) <= 11'd2025))	// 900 and 1023
				field_on = 1'b1;
			else
				field_on = 1'b0;
			
			// goal lines
			if(DrawX >= 10'd19 && DrawX <= 10'd21 && DrawY >= 10'd210 && DrawY <= 10'd270)
				goal_red = 1'b1;
			else
				goal_red = 1'b0;
			if (DrawX >= 10'd618 && DrawX <= 10'd620 && DrawY >= 10'd210 && DrawY <= 10'd270)
				goal_blue = 1'b1;
			else
				goal_blue = 1'b0;
     end 
       
    always_comb
    begin:RGB_Display
        if ((ball_on == 1'b1)) 					// ball color
        begin 
            Red = 8'h00;
            Green = 8'h00;
            Blue = 8'h00;
        end       
        else if(Play1_on == 1'b1)				// player 1 color
		  begin 
            Red = 8'hff;
            Green = 8'h00;
            Blue = 8'h00;
        end  
		  else if(Play2_on == 1'b1)				// player 2 color
		  begin 
            Red = 8'h00;
            Green = 8'h00;
            Blue = 8'hff;
        end  
		  else						// background color
        begin 
				if(field_on == 1'b1)
				begin
					Red = 8'hff;
					Green = 8'hff;
					Blue = 8'hff;
				end
				
				else
				begin
					if(mapColor == 4'h1) begin
						Red = 8'd0; 
						Green = 8'd255;
						Blue = 8'd255;
					end
					else begin
						Red = 8'd0; 
						Green = 8'd204;
						Blue = 8'd102;
					end
				end
				
				// goal lines
				if(goal_blue == 1'b1)
				begin
					Red = 8'h00;
					Green = 8'h00;
					Blue = 8'hff;
				end
				
				if(goal_red == 1'b1)
				begin
					Red = 8'hff;
					Green = 8'h00;
					Blue = 8'h00;
				end
		
        end      
    end 
    
endmodule
