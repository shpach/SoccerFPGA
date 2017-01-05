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


module  player1 ( input Reset, frame_clk, centerPlayer,
					input [31:0] keycode,
					input [9:0] neededBallSize, step,
					input frictionFactor,
               output [9:0]  BallX, BallY, xVelocity, yVelocity, BallS );
    
    logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion, Ball_Size;
	 
    parameter [9:0] Ball_X_Center=210;  // Center position on the X axis
    parameter [9:0] Ball_Y_Center=240;  // Center position on the Y axis
    parameter [9:0] Ball_X_Min=0;       // Leftmost point on the X axis
    parameter [9:0] Ball_X_Max=639;     // Rightmost point on the X axis
    parameter [9:0] Ball_Y_Min=0;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max=479;     // Bottommost point on the Y axis
    logic [9:0] Ball_X_Step;      // Step size on the X axis
    logic [9:0] Ball_Y_Step;      // Step size on the Y axis
	assign Ball_X_Step = step;
	assign Ball_Y_Step = step;
	 
//    assign Ball_Size = neededBallSize; 
   
    always_ff @ (posedge Reset or posedge frame_clk )
    begin: Move_Ball
        if (Reset)  // Asynchronous Reset
        begin 
            Ball_Y_Motion <= 10'd0; //Ball_Y_Step;
				Ball_X_Motion <= 10'd0; //Ball_X_Step;
				Ball_Y_Pos <= Ball_Y_Center;
				Ball_X_Pos <= Ball_X_Center;
        end
		  
		  else if (centerPlayer == 1'b1)
        begin 
            Ball_Y_Motion <= 10'd0; //Ball_Y_Step;
				Ball_X_Motion <= 10'd0; //Ball_X_Step;
				Ball_Y_Pos <= Ball_Y_Center;
				Ball_X_Pos <= Ball_X_Center;
        end
		
        else 
        begin 
				 if ( (Ball_Y_Pos + Ball_Size) >= Ball_Y_Max ) begin  // Ball is at the bottom edge, BOUNCE!
					  Ball_Y_Motion <= ~Ball_Y_Step + 1'b1;  // 2's complement.
					  end
				 else if ( (Ball_Y_Pos - Ball_Size) >= Ball_Y_Min - Ball_Y_Step)  begin// Ball is at the top edge, BOUNCE!
					  Ball_Y_Motion <= Ball_Y_Step;
					  end
				  else if ( (Ball_X_Pos + Ball_Size) >= Ball_X_Max)	begin// Ball is at the right, BOUNCE!
						Ball_X_Motion <= ~Ball_X_Step + 1'b1;
						end
				  else if ( (Ball_X_Pos - Ball_Size) >= Ball_X_Min - Ball_X_Step)	begin// Ball is left, BOUNCE!
						Ball_X_Motion <= Ball_X_Step;
						end
					else if ((keycode & 32'h000003c0) == 32'h00000200)	begin		// move up (W)
						Ball_Y_Motion <= ~Ball_Y_Step + 1'b1;
						Ball_X_Motion <= 10'd0;
						end
					else if ((keycode & 32'h000003c0) == 32'h00000100) begin		// move left (A)
						Ball_X_Motion <= ~Ball_X_Step + 1'b1;
						Ball_Y_Motion <= 10'd0;
						end
					else if ((keycode & 32'h000003c0) == 32'h00000080) begin		// move down (S)
						Ball_Y_Motion <= Ball_Y_Step;
						Ball_X_Motion <= 10'd0;
						end
					else if ((keycode & 32'h000003c0) == 32'h00000040) begin		// move right (D)
						Ball_X_Motion <= Ball_X_Step;
						Ball_Y_Motion <= 10'd0;
						end
					else if ((keycode & 32'h000003c0) == 32'h000000C0) begin		// move down-right (SD)
						Ball_X_Motion <= Ball_X_Step;
						Ball_Y_Motion <= Ball_Y_Step;
						end
					else if ((keycode & 32'h000003c0) == 32'h00000300) begin		// move up-left (WA)
						Ball_X_Motion <= ~Ball_X_Step + 1;
						Ball_Y_Motion <= ~Ball_Y_Step + 1;
						end
					else if ((keycode & 32'h000003c0) == 32'h00000240) begin		// move up-right (WD)
						Ball_X_Motion <= Ball_X_Step;
						Ball_Y_Motion <= ~Ball_Y_Step + 1;
						end
					else if ((keycode & 32'h000003c0) == 32'h00000180) begin		// move down-left (SA)
						Ball_X_Motion <= ~Ball_X_Step + 1;
						Ball_Y_Motion <= Ball_Y_Step;
						end
				 else begin
						if($signed(Ball_Y_Motion) > $signed(10'd0)) begin
							Ball_Y_Motion <= Ball_Y_Motion - frictionFactor; //Ball_Y_Motion;  // FRICTION
						end
						if($signed(Ball_Y_Motion) < $signed(10'd0)) begin
							Ball_Y_Motion <= Ball_Y_Motion + frictionFactor;
						end
						
						
						if($signed(Ball_X_Motion) > $signed(10'd0)) begin
							Ball_X_Motion <= Ball_X_Motion - frictionFactor; //Ball_X_Motion;
						end
						if($signed(Ball_X_Motion) < $signed(10'd0)) begin
							Ball_X_Motion <= Ball_X_Motion + frictionFactor;
						end
					  end
				 
				 
				 Ball_Y_Pos <= (Ball_Y_Pos + Ball_Y_Motion);  // Update ball position
				 Ball_X_Pos <= (Ball_X_Pos + Ball_X_Motion);
			
			
		end  
		
		
    end
       
	 always_ff @(posedge frame_clk) begin
		// animating ball size
		if(Ball_Size < neededBallSize) begin
			Ball_Size <= Ball_Size + 1;
		end
		else if(Ball_Size > neededBallSize) begin
			Ball_Size <= Ball_Size - 1;
		end
	end
		 
    assign BallX = Ball_X_Pos;
    assign BallY = Ball_Y_Pos;
    assign xVelocity = Ball_X_Motion;
	 assign yVelocity = Ball_Y_Motion;
    assign BallS = Ball_Size;
    

endmodule
