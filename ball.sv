//-------------------------------------------------------------------------
//    Ball.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf 03-01-2006                               --
//                              03-12-2007                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Fall 2014 Distribution                                             --
//                                                                       --
//    For use with ECE 298 Lab 7                                         --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------


module  ball ( input Reset, frame_clk,
					input [9:0] play1xPos, play1yPos, play1xVel, play1yVel, play1Size,
									play2xPos, play2yPos, play2xVel, play2yVel, play2Size,
					input frictionFactor,
					input logic centerBall,
               output [9:0]  BallX, BallY, BallS );
    
    logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion, Ball_Size;
	 
    parameter [9:0] Ball_X_Center=320;  // Center position on the X axis
    parameter [9:0] Ball_Y_Center=240;  // Center position on the Y axis
    parameter [9:0] Ball_X_Min=20;       // Leftmost point on the X axis
    parameter [9:0] Ball_X_Max=619;     // Rightmost point on the X axis
    parameter [9:0] Ball_Y_Min=19;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max=459;     // Bottommost point on the Y axis
    parameter [9:0] Ball_X_Step=3;      // Step size on the X axis
    parameter [9:0] Ball_Y_Step=3;      // Step size on the Y axis

    assign Ball_Size = 4;  // assigns the value 4 as a 10-digit binary number, ie "0000000100"
	 
	 
	 // helper variables
	 logic [9:0] absXDiff1, absYDiff1, absXDiff2, absYDiff2;
	 logic [1:0] frictionCounter;
	 assign absXDiff1 = (play1xPos > Ball_X_Pos)?(play1xPos - Ball_X_Pos):(Ball_X_Pos - play1xPos);
	 assign absYDiff1 = (play1yPos > Ball_Y_Pos)?(play1yPos - Ball_Y_Pos):(Ball_Y_Pos - play1yPos);
	 assign absXDiff2 = (play2xPos > Ball_X_Pos)?(play2xPos - Ball_X_Pos):(Ball_X_Pos - play2xPos);
	 assign absYDiff2 = (play2yPos > Ball_Y_Pos)?(play2yPos - Ball_Y_Pos):(Ball_Y_Pos - play2yPos);
   
    always_ff @ (posedge Reset or posedge frame_clk )
    begin: Move_Ball
        if (Reset)  // Asynchronous Reset
        begin 
            Ball_Y_Motion <= 10'd0; //Ball_Y_Step;
				Ball_X_Motion <= 10'd0; //Ball_X_Step;
				Ball_Y_Pos <= Ball_Y_Center;
				Ball_X_Pos <= Ball_X_Center;
        end
        
		  else if(centerBall == 1'b1) begin
				Ball_Y_Motion <= 10'd0; //Ball_Y_Step;
				Ball_X_Motion <= 10'd0; //Ball_X_Step;
				Ball_Y_Pos <= Ball_Y_Center;
				Ball_X_Pos <= Ball_X_Center;
			end
			
        else
        begin 
				 if ( (Ball_Y_Pos + Ball_Size) >= Ball_Y_Max ) begin  // Ball is at the bottom edge, BOUNCE!
					  Ball_Y_Motion <= (~ (Ball_Y_Step) + 1'b1);  // 2's complement.
					  end
				 else if ( (Ball_Y_Pos - Ball_Size) <= Ball_Y_Min)  begin// Ball is at the top edge, BOUNCE!
					  Ball_Y_Motion <= Ball_Y_Step;
					  end
				  else if ( (Ball_X_Pos + Ball_Size) >= Ball_X_Max)	begin// Ball is at the right, BOUNCE!
						Ball_X_Motion <= (~(Ball_X_Step) + 1'b1);
						end
				  else if ( (Ball_X_Pos - Ball_Size) <= Ball_X_Min)	begin// Ball is left, BOUNCE!
						Ball_X_Motion <= Ball_X_Step;
						end
				  
						// INTERACT WITH PLAYERS
				  else if( (absXDiff1 <= Ball_Size + play1Size) && (absYDiff1 <= Ball_Size + play1Size)) begin
						if($signed(play1xVel) > 0) begin
							Ball_X_Motion <= play1xVel + 10'd3;
						end
						else if($signed(play1xVel) < 0)	begin
							Ball_X_Motion <= play1xVel - 10'd3;
						end
						// player is still
//						else	begin
//							if($signed(Ball_X_Motion) > 0)
//								Ball_X_Motion <= ~Ball_X_Step + 1;
//							else if($signed(Ball_X_Motion) < 0)
//								Ball_X_Motion <= Ball_X_Step;
//						end
						
						if($signed(play1yVel) > 0) begin
							Ball_Y_Motion <= play1yVel + 10'd3;
						end
						else if($signed(play1yVel) < 0)	begin
							Ball_Y_Motion <= play1yVel - 10'd3;
						end
						// player is still
//						else	begin
//							if($signed(Ball_Y_Motion) > 0)
//								Ball_Y_Motion <= ~Ball_Y_Step + 1;
//							else if($signed(Ball_Y_Motion) < 0)
//								Ball_Y_Motion <= Ball_Y_Step;
//						end
					end
				  else if( (absXDiff2 <= Ball_Size + play2Size) && (absYDiff2 <= Ball_Size + play2Size)) begin
						if($signed(play2xVel) > 0) begin
							Ball_X_Motion <= play2xVel + 10'd3;
							end
						else if($signed(play2xVel) < 0)begin
							Ball_X_Motion <= play2xVel - 10'd3;
							end
						// player is still
//						else	begin
//							if($signed(Ball_X_Motion) > 0)
//								Ball_X_Motion <= ~Ball_X_Step + 1;
//							else if($signed(Ball_X_Motion) < 0)
//								Ball_X_Motion <= Ball_X_Step;
//						end	
							
						if($signed(play2yVel) > 0) begin
							Ball_Y_Motion <= play2yVel + 10'd3;
							end
						else if($signed(play2yVel) < 0)begin
							Ball_Y_Motion <= play2yVel - 10'd3;
							end
						// player is still
//						else	begin
//							if($signed(Ball_Y_Motion) > 0)
//								Ball_Y_Motion <= ~Ball_Y_Step + 1;
//							else if($signed(Ball_Y_Motion) < 0)
//								Ball_Y_Motion <= Ball_Y_Step;
//						end
						end
						
				 // friction
				 else begin
						frictionCounter <= frictionCounter + 2'b01;
						if(frictionCounter == 2'b00) begin
							if($signed(Ball_Y_Motion) > $signed(10'd0)) begin
								Ball_Y_Motion <= Ball_Y_Motion - frictionFactor;
							end
							if($signed(Ball_Y_Motion) < $signed(10'd0)) begin
								Ball_Y_Motion <= Ball_Y_Motion + frictionFactor;
							end
							
							
							if($signed(Ball_X_Motion) > $signed(10'd0)) begin
								Ball_X_Motion <= Ball_X_Motion - frictionFactor;
							end
							if($signed(Ball_X_Motion) < $signed(10'd0)) begin
								Ball_X_Motion <= Ball_X_Motion + frictionFactor;
							end
						end
					  end
				 
				 
				 Ball_Y_Pos <= (Ball_Y_Pos + Ball_Y_Motion);  // Update ball position
				 Ball_X_Pos <= (Ball_X_Pos + Ball_X_Motion);
			
			
		end  
    end
       
    assign BallX = Ball_X_Pos;
   
    assign BallY = Ball_Y_Pos;
   
    assign BallS = Ball_Size;
    

endmodule
