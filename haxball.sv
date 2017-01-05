//-------------------------------------------------------------------------
//      lab7_usb.sv                                                      --
//      Christine Chen                                                   --
//      Fall 2014                                                        --
//                                                                       --
//      Fall 2014 Distribution                                           --
//                                                                       --
//      For use with ECE 385 Lab 7                                       --
//      UIUC ECE Department                                              --
//-------------------------------------------------------------------------


module  haxball 		( input         CLOCK_50,
                       input[3:0]    KEY, //bit 0 is set up as Reset
							  input[3:0]	 SW,
							  output [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,
							  output [8:0]  LEDG,
							  output [17:0] LEDR,
							   //VGA Interface 
                       output [7:0]  VGA_R,					//VGA Red
							                VGA_G,					//VGA Green
												 VGA_B,					//VGA Blue
							  output        VGA_CLK,				//VGA Clock
							                VGA_SYNC_N,			//VGA Sync signal
												 VGA_BLANK_N,			//VGA Blank signal
												 VGA_VS,					//VGA virtical sync signal	
												 VGA_HS,					//VGA horizontal sync signal
							  // CY7C67200 Interface
							  inout [15:0]  OTG_DATA,						//	CY7C67200 Data bus 16 Bits
							  output [1:0]  OTG_ADDR,						//	CY7C67200 Address 2 Bits
							  output        OTG_CS_N,						//	CY7C67200 Chip Select
												 OTG_RD_N,						//	CY7C67200 Write
												 OTG_WR_N,						//	CY7C67200 Read
												 OTG_RST_N,						//	CY7C67200 Reset
							  input			 OTG_INT,						//	CY7C67200 Interrupt
							  // SDRAM Interface for Nios II Software
							  output [12:0] DRAM_ADDR,				// SDRAM Address 13 Bits
							  inout [31:0]  DRAM_DQ,				// SDRAM Data 32 Bits
							  output [1:0]  DRAM_BA,				// SDRAM Bank Address 2 Bits
							  output [3:0]  DRAM_DQM,				// SDRAM Data Mast 4 Bits
							  output			 DRAM_RAS_N,			// SDRAM Row Address Strobe
							  output			 DRAM_CAS_N,			// SDRAM Column Address Strobe
							  output			 DRAM_CKE,				// SDRAM Clock Enable
							  output			 DRAM_WE_N,				// SDRAM Write Enable
							  output			 DRAM_CS_N,				// SDRAM Chip Select
							  output			 DRAM_CLK				// SDRAM Clock
											);
    
    logic Reset_h, vssig, hssig, blanksig, syncsig, Clk;
    logic [9:0] drawxsig, drawysig;
	 logic [9:0] ballxsig, ballysig, ballsizesig;
	 logic [9:0] play1xsig, play1ysig, play1sizesig, play1xVel, play1yVel;
	 logic [9:0] play2xsig, play2ysig, play2sizesig, play2xVel, play2yVel;
	 
	 logic resetfieldsig;
	 logic [7:0] score1, score2;
	 
	 logic [31:0] keycode;
    
	 assign Clk = CLOCK_50;
    assign {Reset_h}=~ (KEY[0]);  // The push buttons are active low
	 assign VGA_VS = vssig;
	 assign VGA_HS = hssig;
	 assign VGA_BLANK_N = blanksig;
	 assign VGA_SYNC_N = syncsig;
	 
	 wire [1:0] hpi_addr;
	 wire [15:0] hpi_data_in, hpi_data_out;
	 wire hpi_r, hpi_w,hpi_cs;
	 
	 hpi_io_intf hpi_io_inst(   .from_sw_address(hpi_addr),
										 .from_sw_data_in(hpi_data_in),
										 .from_sw_data_out(hpi_data_out),
										 .from_sw_r(hpi_r),
										 .from_sw_w(hpi_w),
										 .from_sw_cs(hpi_cs),
		 								 .OTG_DATA(OTG_DATA),    
										 .OTG_ADDR(OTG_ADDR),    
										 .OTG_RD_N(OTG_RD_N),    
										 .OTG_WR_N(OTG_WR_N),    
										 .OTG_CS_N(OTG_CS_N),    
										 .OTG_RST_N(OTG_RST_N),   
										 .OTG_INT(OTG_INT),
										 .Clk(Clk),
										 .Reset(1'b0)
	 );
	 
	 //The connections for nios_system might be named different depending on how you set up Qsys
	 haxball_soc nios_system(
										 .clk_clk(Clk),         
										 .reset_reset_n(1'b1),   
										 .sdram_wire_addr(DRAM_ADDR), 
										 .sdram_wire_ba(DRAM_BA),   
										 .sdram_wire_cas_n(DRAM_CAS_N),
										 .sdram_wire_cke(DRAM_CKE),  
										 .sdram_wire_cs_n(DRAM_CS_N), 
										 .sdram_wire_dq(DRAM_DQ),   
										 .sdram_wire_dqm(DRAM_DQM),  
										 .sdram_wire_ras_n(DRAM_RAS_N),
										 .sdram_wire_we_n(DRAM_WE_N), 
										 .sdram_clk_clk(DRAM_CLK),
										 .keycode_export(keycode),  
										 .otg_hpi_address_export(hpi_addr),
										 .otg_hpi_data_in_port(hpi_data_in),
										 .otg_hpi_data_out_port(hpi_data_out),
										 .otg_hpi_cs_export(hpi_cs),
										 .otg_hpi_r_export(hpi_r),
										 .otg_hpi_w_export(hpi_w));
	
	//Fill in the connections for the rest of the modules 
    vga_controller vgasync_instance(.Clk, .Reset(Reset_h), .hs(hssig), .vs(vssig), .pixel_clk(VGA_CLK), .blank(blanksig), .sync(syncsig), .DrawX(drawxsig),
		.DrawY(drawysig));
   
	logic [9:0] newPlay1Size, newPlay1Step, newPlay2Size, newPlay2Step;
	
	// DO NOT CHANGE (unless we create a new mode)
//	assign player1StartX = 210;
//	assign player1StartY = 240;
//	
//	assign player2StartX = 429;
//	assign player2StartY = 240;
	
	
    ball ball_instance(.Reset(Reset_h), .frame_clk(vssig), .centerBall(resetfieldsig), .frictionFactor,
							  .play1xPos(play1xsig), .play1yPos(play1ysig), .play1xVel, .play1yVel, .play1Size(play1sizesig),
							  .play2xPos(play2xsig), .play2yPos(play2ysig), .play2xVel, .play2yVel, .play2Size(play2sizesig),
							  .BallX(ballxsig), .BallY(ballysig), .BallS(ballsizesig));
	 
	 player1 player1_inst(.Reset(Reset_h), .frame_clk(vssig), .keycode, .centerPlayer(resetfieldsig),
								 .neededBallSize(newPlay1Size), .step(newPlay1Step), .frictionFactor,
								 .BallX(play1xsig), .BallY(play1ysig), .xVelocity(play1xVel), .yVelocity(play1yVel), .BallS(play1sizesig));
					
	 player2 player2_inst(.Reset(Reset_h), .frame_clk(vssig), .keycode, .centerPlayer(resetfieldsig),
								 .neededBallSize(newPlay2Size), .step(newPlay2Step), .frictionFactor,
								 .BallX(play2xsig), .BallY(play2ysig), .xVelocity(play2xVel), .yVelocity(play2yVel), .BallS(play2sizesig));
	
    color_mapper color_instance(	.DrawX(drawxsig), .DrawY(drawysig), .mapColor(SW[0]),
											.BallX(ballxsig), .BallY(ballysig), .Ball_size(ballsizesig), 
											.Play1X(play1xsig), .Play1Y(play1ysig), .Play1_size(play1sizesig),
											.Play2X(play2xsig), .Play2Y(play2ysig), .Play2_size(play2sizesig),
											.Red(VGA_R), .Green(VGA_G), .Blue(VGA_B));
											
	 game_engine game_engine_inst(.Clk, .Reset(Reset_h), .BallX(ballxsig), .BallY(ballysig), .resetfieldsig, 
	 .score1, .score2, .greenLeds(LEDG), .redLeds(LEDR));

	 
	 // READ SWITCH INPUTS
	logic [3:0] convScore1, convScore2;
	logic [3:0] mapI;
	logic [3:0] mapC;
	logic [3:0] mapE;
	logic frictionFactor;
	
	
	// CREATE POWERUP MODULE TO TAKE CARE OF SIZE AND VELOCITY
//	assign newPlay1Size = 6;
//	assign newPlay1Step = 2;
//	
//	assign newPlay2Size = 6;
//	assign newPlay2Step = 2;
	// END POWERUP MODULE
	
	always_comb begin
		case(SW[0])
			4'h1: begin
				mapI = 4'h1;
				mapC = 4'hC;
				mapE = 4'hE;
				frictionFactor = 1'b0;
			end
			default: begin
				mapI = 4'h0;
				mapC = 4'h0;
				mapE = 4'h0;
				frictionFactor = 1'b1;
			end
		endcase
		
		case(SW[1])
			4'h1: begin
				newPlay1Size = 10;
				newPlay2Size = 10;
			end
			default: begin
				newPlay1Size = 6;
				newPlay2Size = 6;
			end
		endcase
		
		case(SW[2])
			4'h1: begin
				newPlay1Step = 4;
				newPlay2Step = 4;
			end
			default: begin
				newPlay1Step = 2;
				newPlay2Step = 2;
			end
		endcase
		
		case(score1)
			8'h01: convScore1 = 4'h0;
			8'h96: convScore1 = 4'h1;
			8'h2C: convScore1 = 4'h2;
			8'hC2: convScore1 = 4'h3;
			8'h58: convScore1 = 4'h4;
			8'hEE: begin
						convScore1 = 4'h5;
						newPlay1Step = 0;
						newPlay2Step = 0;
					 end
			default: convScore1 = 4'h0;
		endcase
		case(score2)
			8'h01: convScore2 = 4'h0;
			8'h96: convScore2 = 4'h1;
			8'h2C: convScore2 = 4'h2;
			8'hC2: convScore2 = 4'h3;
			8'h58: convScore2 = 4'h4;
			8'hEE: begin
						convScore2 = 4'h5;
						newPlay1Step = 0;
						newPlay2Step = 0;
					 end
			default: convScore2 = 4'h0;
		endcase
		
	end
			
	 
	 HexDriver hex_inst_0 (mapE, HEX0);
	 HexDriver hex_inst_1 (mapC, HEX1);
	 HexDriver hex_inst_2 (mapI, HEX2);
	 HexDriver hex_inst_3 (4'h0, HEX3);
	 HexDriver hex_inst_4 (convScore2, HEX4);
	 HexDriver hex_inst_5 (4'h0, HEX5);
	
	 HexDriver hex_inst_6 (convScore1, HEX6);
	 HexDriver hex_inst_7 (4'h0, HEX7);
	 

endmodule
