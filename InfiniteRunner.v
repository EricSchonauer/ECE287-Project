module InfiniteRunner(clk, rst, hsync, vsync, vga_R, vga_G, vga_B, vga_blank, vga_clk, button_R, button_L, button_U, button_D, switch, a, b, c, d, e, f, g);

input button_R, button_L, button_U, button_D;
input wire clk, rst;
output hsync, vsync;
input switch;
output [7:0] vga_R, vga_G, vga_B;
output vga_blank;
output vga_clk;

wire [3:0] one, ten, hund, thous;
output [3:0] a, b, c, d, e, f, g;

wire lose;
reg lost;

wire [7:0] randPos0;
wire [7:0] randShape0;
wire randClock0;

wire [7:0] randPos1;
wire [7:0] randShape1;
wire randClock1;

wire [7:0] randPos2;
wire [7:0] randShape2;
wire randClock2;

wire [7:0] randPos3;
wire [7:0] randShape3;
wire randClock3;

wire [7:0] randPos4;
wire [7:0] randShape4;
wire randClock4;

wire [7:0] randPos5;
wire [7:0] randShape5;
wire randClock5;

wire [7:0] randPos6;
wire [7:0] randShape6;
wire randClock6;

wire [7:0] randPos7;
wire [7:0] randShape7;
wire randClock7;

wire [7:0] randPos8;
wire [7:0] randShape8;
wire randClock8;

wire [7:0] randPos9;
wire [7:0] randShape9;
wire randClock9;

wire [99:0]s_x0, s_x1, s_x2, s_x3, s_y0, s_y1, s_y2, s_y3;

wire [7:0]vga_R_play, vga_G_play, vga_B_play, vga_R_back, vga_G_back, vga_B_back;
wire [79:0]obs_R, obs_G, obs_B;

reg [9:0] pixel_x;
reg [9:0] pixel_y;

wire [9:0] player_x, player_y;

reg vga_HS, vga_VS;
reg clock25;

reg clock20 = 1'd0;
reg [21:0]count20 = 22'd0;

reg clock58 = 1'd0;
reg [19:0]count58 = 20'd0;

reg clockPulse = 1'd0;
reg [23:0]countPulse;
reg [23:0] pulseMax;  // starts at 25,000,000 and then gradually decreases
	
wire CounterXmaxed = (pixel_x==799); //799 full width of field including front and back porches and sync
wire CounterYmaxed = (pixel_y==525); //525 full length of field including front and back porches and sync

//--------------------------------------------------------------------------25 MHz clock------------------------------------------------------------------------------------------------------//
	always @(posedge clk)
		if(clock25)
			begin
				clock25 = 0;
			end
		else
			begin
				clock25 = 1;
			end

//----------------------------------------------------------------------------20 Hz clock------------------------------------------------------------------------------------------------------//

	always @ (posedge clk or negedge rst)
		begin
			if(rst == 1'b0)
				begin
					count20 <= 22'd0;
					clock20 <= 1'd0;
				end
			else if (count20 < 22'd2100000)
				count20 <= count20 + 1'b1;
			else
				begin
					count20 <= 22'd0;
					clock20 <= ~clock20;
				end
		end


//----------------------------------------------------------------------------58 Hz clock--------------------------------------------------------------------//

	always @ (posedge clk or negedge rst)
		begin
			if(rst == 1'b0)
				begin
					count58 <= 20'd0;
					clock58 <= 1'd0;
				end
			else if (count58 < 20'd862069)
				count58 <= count58 + 1'b1;
			else
				begin
					count58 <= 20'd0;
					clock58 <= ~clock58;
				end
		end
	
//-------------------------------------------------------------puleRate clock for obstacle movement-----------------------------------------------------------//
		
	always @ (posedge clk or negedge rst)
		begin
			if(rst == 1'b0)
				begin
					countPulse <= 24'd0;
					clockPulse <= 1'd0;
					pulseMax <= 24'd12500000;
				end
			else if(countPulse < pulseMax)
				countPulse <= countPulse + 1'd1;
			else
				begin
					countPulse <= 24'd0;
					clockPulse <= ~clockPulse;
					if(pulseMax > 24'd1666666)
						pulseMax <= pulseMax - 24'd4500;
				end
		end
		
		
//---------------------------------------------------------------------Synchronize VGA Output-----------------------------------------------------------------//
	assign vga_clk = clock25;
	assign vga_blank = vsync & hsync;
		
	always @(posedge clock25 or negedge rst)
		if (rst == 1'b0)
			begin
			pixel_y <= 0;
			pixel_x <= 0;
			end
		else if (CounterXmaxed && ~CounterYmaxed)
			begin
			pixel_x <= 0;
			pixel_y <= pixel_y + 1'b1;
			end 
		else if (~CounterXmaxed)
			pixel_x <= pixel_x + 1'b1;
		else if (CounterXmaxed && CounterYmaxed)
			begin
			pixel_y <= 0;
			pixel_x <= 0;
			end
	
	always @(posedge clock25 or negedge rst)
		if(rst == 1'b0) 
		begin
			vga_HS <= 1'b0;
			vga_VS <= 1'b0;
		end
		else
		begin
			vga_HS <= (pixel_x <= 96);   // active for 16 clocks
			vga_VS <= (pixel_y <= 2);   // active for 800 clocks
		end 

	assign hsync = ~vga_HS;
	assign vsync = ~vga_VS;
	
	
//--------------------------------------------------------------INSTANTIATIONS------------------------------------------------------------------//

randomNum pos0(clk, rst, 8'd79, button_R, button_L, button_U, button_D, randPos0);
randomNum shape0(clk, rst, 8'd142, button_R, button_L, button_U, button_D, randShape0);
object obj0(clockPulse, rst, 5'd0, randPos0[7:4], randShape0[7:5], 2'd0, s_x0[9:0], s_x1[9:0], s_x2[9:0], s_x3[9:0], s_y0[9:0], s_y1[9:0], s_y2[9:0], s_y3[9:0], obs_R[7:0], obs_G[7:0], obs_B[7:0]);

randomNum pos1(clk, rst, 8'd234, button_R, button_L, button_U, button_D, randPos1);
randomNum shape1(clk, rst, 8'd19, button_R, button_L, button_U, button_D, randShape1);
object obj1(clockPulse, rst, 5'd2, randPos1[7:4], randShape1[7:5], 2'd0, s_x0[19:10], s_x1[19:10], s_x2[19:10], s_x3[19:10], s_y0[19:10], s_y1[19:10], s_y2[19:10], s_y3[19:10], obs_R[15:8], obs_G[15:8], obs_B[15:8]);

randomNum pos2(clk, rst, 8'd156, button_R, button_L, button_U, button_D, randPos2);
randomNum shape2(clk, rst, 8'd67, button_R, button_L, button_U, button_D, randShape2);
object obj2(clockPulse, rst, 5'd4, randPos2[7:4], randShape2[7:5], 2'd0, s_x0[29:20], s_x1[29:20], s_x2[29:20], s_x3[29:20], s_y0[29:20], s_y1[29:20], s_y2[29:20], s_y3[29:20], obs_R[23:16], obs_G[23:16], obs_B[23:16]);

randomNum pos3(clk, rst, 8'd192, button_R, button_L, button_U, button_D, randPos3);
randomNum shape3(clk, rst, 8'd4, button_R, button_L, button_U, button_D, randShape3);
object obj3(clockPulse, rst, 5'd6, randPos3[7:4], randShape3[7:5], 2'd0, s_x0[39:30], s_x1[39:30], s_x2[39:30], s_x3[39:30], s_y0[39:30], s_y1[39:30], s_y2[39:30], s_y3[39:30], obs_R[31:24], obs_G[31:24], obs_B[31:24]);

randomNum pos4(clk, rst, 8'd123, button_R, button_L, button_U, button_D, randPos4);
randomNum shape4(clk, rst, 8'd69, button_R, button_L, button_U, button_D, randShape4);
object obj4(clockPulse, rst, 5'd8, randPos4[7:4], randShape4[7:5], 2'd0, s_x0[49:40], s_x1[49:40], s_x2[49:40], s_x3[49:40], s_y0[49:40], s_y1[49:40], s_y2[49:40], s_y3[49:40], obs_R[39:32], obs_G[39:32], obs_B[39:32]);

randomNum pos5(clk, rst, 8'd98, button_R, button_L, button_U, button_D, randPos5);
randomNum shape5(clk, rst, 8'd46, button_R, button_L, button_U, button_D, randShape5);
object obj5(clockPulse, rst, 5'd10, randPos5[7:4], randShape5[7:5], 2'd0, s_x0[59:50], s_x1[59:50], s_x2[59:50], s_x3[59:50], s_y0[59:50], s_y1[59:50], s_y2[59:50], s_y3[59:50], obs_R[47:40], obs_G[47:40], obs_B[47:40]);

randomNum pos6(clk, rst, 8'd17, button_R, button_L, button_U, button_D, randPos6);
randomNum shape6(clk, rst, 8'd230, button_R, button_L, button_U, button_D, randShape6);
object obj6(clockPulse, rst, 5'd12, randPos6[7:4], randShape6[7:5], 2'd0, s_x0[69:60], s_x1[69:60], s_x2[69:60], s_x3[69:60], s_y0[69:60], s_y1[69:60], s_y2[69:60], s_y3[69:60], obs_R[55:48], obs_G[55:48], obs_B[55:48]);

randomNum pos7(clk, rst, 8'd110, button_R, button_L, button_U, button_D, randPos7);
randomNum shape7(clk, rst, 8'd222, button_R, button_L, button_U, button_D, randShape7);
object obj7(clockPulse, rst, 5'd14, randPos7[7:4], randShape7[7:5], 2'd0, s_x0[79:70], s_x1[79:70], s_x2[79:70], s_x3[79:70], s_y0[79:70], s_y1[79:70], s_y2[79:70], s_y3[79:70], obs_R[63:56], obs_G[63:56], obs_B[63:56]);

randomNum pos8(clk, rst, 8'd185, button_R, button_L, button_U, button_D, randPos8);
randomNum shape8(clk, rst, 8'd37, button_R, button_L, button_U, button_D, randShape8);
object obj8(clockPulse, rst, 5'd16, randPos8[7:4], randShape8[7:5], 2'd0, s_x0[89:80], s_x1[89:80], s_x2[89:80], s_x3[89:80], s_y0[89:80], s_y1[89:80], s_y2[89:80], s_y3[89:80], obs_R[71:64], obs_G[71:64], obs_B[71:64]);

randomNum pos9(clk, rst, 8'd101, button_R, button_L, button_U, button_D, randPos9);
randomNum shape9(clk, rst, 8'd220, button_R, button_L, button_U, button_D, randShape9);
object obj9(clockPulse, rst, 5'd18, randPos9[7:4], randShape9[7:5], 2'd0, s_x0[99:90], s_x1[99:90], s_x2[99:90], s_x3[99:90], s_y0[99:90], s_y1[99:90], s_y2[99:90], s_y3[99:90], obs_R[79:72], obs_G[79:72], obs_B[79:72]);


playerMove playaMove(clock20, rst, button_R, button_L, button_U, button_D, player_x, player_y);

draw draw(pixel_x, pixel_y, player_x, player_y, s_x0, s_x1, s_x2, s_x3, s_y0, s_y1, s_y2, s_y3, obs_R, obs_G, obs_B, vga_R_play, vga_G_play, vga_B_play, lost);

collide collisions(rst, player_x, player_y, s_x0, s_x1, s_x2, s_x3, s_y0, s_y1, s_y2, s_y3, lose);

score score(clockPulse, rst, lost, button_R, button_L, button_U, button_D, one, ten, hund, thous);
displayScore display0(rst, one, a[0], b[0], c[0], d[0], e[0], f[0], g[0]);
displayScore display1(rst, ten, a[1], b[1], c[1], d[1], e[1], f[1], g[1]);
displayScore display2(rst, hund, a[2], b[2], c[2], d[2], e[2], f[2], g[2]);
displayScore display3(rst, thous, a[3], b[3], c[3], d[3], e[3], f[3], g[3]);

assign vga_R = vga_R_play;
assign vga_G = vga_G_play;
assign vga_B = vga_B_play;

always @ (posedge clk or negedge rst)
begin
	if(rst == 1'b0)
		lost <= 1'b0;
	else if ((lost == 1'b0) && (lose))
		lost <= 1'b1;
end

endmodule

//-------------------------------------------------------------DRAW----------------------------------------------------------------------------//

module draw(pixel_x, pixel_y, player_x, player_y, s_x0, s_x1, s_x2, s_x3, s_y0, s_y1, s_y2, s_y3, obs_R, obs_G, obs_B, vga_R, vga_G, vga_B, lose);
input [99:0]s_x0, s_x1, s_x2, s_x3, s_y0, s_y1, s_y2, s_y3;
input [9:0]player_x, player_y;
input [9:0]pixel_x, pixel_y;
output reg [7:0]vga_R, vga_G, vga_B;
input [79:0]obs_R, obs_G, obs_B;
input lose;


always @ (*)
begin
	//LOSER
	if (lose)
		begin
			// L
			if (((pixel_x >= 10'd210) && (pixel_x <= 10'd242)) && ((pixel_y >= 10'd148) && (pixel_y <= 10'd308)))
				begin
					vga_R = 8'd255;
					vga_G = 8'd0;
					vga_B = 8'd0;
				end
			else if (((pixel_x >= 10'd242) && (pixel_x <= 10'd274)) && ((pixel_y >= 10'd276) && (pixel_y <= 10'd308)))
				begin
					vga_R = 8'd255;
					vga_G = 8'd0;
					vga_B = 8'd0;
				end
				
			// O
			else if (((pixel_x >= 10'd306) && (pixel_x <= 10'd338)) && ((pixel_y >= 10'd148) && (pixel_y <= 10'd308)))
				begin
					vga_R = 8'd255;
					vga_G = 8'd0;
					vga_B = 8'd0;
				end
			else if (((pixel_x >= 10'd338) && (pixel_x <= 10'd370)) && ((pixel_y >= 10'd148) && (pixel_y <= 10'd180)))
				begin
					vga_R = 8'd255;
					vga_G = 8'd0;
					vga_B = 8'd0;
				end
			else if (((pixel_x >= 10'd338) && (pixel_x <= 10'd370)) && ((pixel_y >= 10'd276) && (pixel_y <= 10'd308)))
				begin
					vga_R = 8'd255;
					vga_G = 8'd0;
					vga_B = 8'd0;
				end
			else if (((pixel_x >= 10'd370) && (pixel_x <= 10'd402)) && ((pixel_y >= 10'd148) && (pixel_y <= 10'd308)))
				begin
					vga_R = 8'd255;
					vga_G = 8'd0;
					vga_B = 8'd0;
				end
				
			//S
			else if (((pixel_x >= 10'd434) && (pixel_x <= 10'd466)) && ((pixel_y >= 10'd148) && (pixel_y <= 10'd244)))
				begin
					vga_R = 8'd255;
					vga_G = 8'd0;
					vga_B = 8'd0;
				end
			else if (((pixel_x >= 10'd466) && (pixel_x <= 10'd498)) && ((pixel_y >= 10'd212) && (pixel_y <= 10'd308)))
				begin
					vga_R = 8'd255;
					vga_G = 8'd0;
					vga_B = 8'd0;
				end
			else if (((pixel_x >= 10'd466) && (pixel_x <= 10'd498)) && ((pixel_y >= 10'd148) && (pixel_y <= 10'd180)))
				begin
					vga_R = 8'd255;
					vga_G = 8'd0;
					vga_B = 8'd0;
				end	
			else if (((pixel_x >= 10'd434) && (pixel_x <= 10'd466)) && ((pixel_y >= 10'd276) && (pixel_y <= 10'd308)))
				begin
					vga_R = 8'd255;
					vga_G = 8'd0;
					vga_B = 8'd0;
				end
			
			// E
			else if (((pixel_x >= 10'd530) && (pixel_x <= 10'd562)) && ((pixel_y >= 10'd148) && (pixel_y <= 10'd308)))
				begin
					vga_R = 8'd255;
					vga_G = 8'd0;
					vga_B = 8'd0;
				end
			else if (((pixel_x >= 10'd562) && (pixel_x <= 10'd594)) && ((pixel_y >= 10'd148) && (pixel_y <= 10'd180)))
				begin
					vga_R = 8'd255;
					vga_G = 8'd0;
					vga_B = 8'd0;
				end
			else if (((pixel_x >= 10'd562) && (pixel_x <= 10'd594)) && ((pixel_y >= 10'd212) && (pixel_y <= 10'd244)))
				begin
					vga_R = 8'd255;
					vga_G = 8'd0;
					vga_B = 8'd0;
				end
			else if (((pixel_x >= 10'd562) && (pixel_x <= 10'd594)) && ((pixel_y >= 10'd276) && (pixel_y <= 10'd308)))
				begin
					vga_R = 8'd255;
					vga_G = 8'd0;
					vga_B = 8'd0;
				end
				
			// R
			else if (((pixel_x >= 10'd626) && (pixel_x <= 10'd658)) && ((pixel_y >= 10'd148) && (pixel_y <= 10'd308)))
				begin
					vga_R = 8'd255;
					vga_G = 8'd0;
					vga_B = 8'd0;
				end
			else if (((pixel_x >= 10'd658) && (pixel_x <= 10'd690)) && ((pixel_y >= 10'd148) && (pixel_y <= 10'd180)))
				begin
					vga_R = 8'd255;
					vga_G = 8'd0;
					vga_B = 8'd0;
				end
			else if (((pixel_x >= 10'd658) && (pixel_x <= 10'd690)) && ((pixel_y >= 10'd212) && (pixel_y <= 10'd244)))
				begin
					vga_R = 8'd255;
					vga_G = 8'd0;
					vga_B = 8'd0;
				end
			else if (((pixel_x >= 10'd690) && (pixel_x <= 10'd722)) && ((pixel_y >= 10'd180) && (pixel_y <= 10'd212)))
				begin
					vga_R = 8'd255;
					vga_G = 8'd0;
					vga_B = 8'd0;
				end
			else if (((pixel_x >= 10'd690) && (pixel_x <= 10'd722)) && ((pixel_y >= 10'd244) && (pixel_y <= 10'd308)))
				begin
					vga_R = 8'd255;
					vga_G = 8'd0;
					vga_B = 8'd0;
				end
				
			else
				begin
					vga_R = 8'b00000000;
					vga_G = 8'b00000000;
					vga_B = 8'b00000000;
				end
			
		
		end
	// SHAPE0 $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
	else if ((((pixel_x >= s_x0[9:0]) && (pixel_x <= (s_x0[9:0] + 10'd32))) && ((pixel_y >= s_y0[9:0]) && (pixel_y <= (s_y0[9:0] + 10'd32)))) && (!(s_x0[9:0] < 10'd146)))
		begin
			vga_R = obs_R[7:0];
			vga_G = obs_G[7:0];
			vga_B = obs_B[7:0];
		end
	else if ((((pixel_x >= s_x1[9:0]) && (pixel_x <= (s_x1[9:0] + 10'd32))) && ((pixel_y >= s_y1[9:0]) && (pixel_y <= (s_y1[9:0] + 10'd32)))) && (!(s_x1[9:0] < 10'd146)))
		begin
			vga_R = obs_R[7:0];
			vga_G = obs_G[7:0];
			vga_B = obs_B[7:0];
		end
	else if ((((pixel_x >= s_x2[9:0]) && (pixel_x <= (s_x2[9:0] + 10'd32))) && ((pixel_y >= s_y2[9:0]) && (pixel_y <= (s_y2[9:0] + 10'd32)))) && (!(s_x2[9:0] < 10'd146)))
		begin
			vga_R = obs_R[7:0];
			vga_G = obs_G[7:0];
			vga_B = obs_B[7:0];
		end
	else if ((((pixel_x >= s_x3[9:0]) && (pixel_x <= (s_x3[9:0] + 10'd32))) && ((pixel_y >= s_y3[9:0]) && (pixel_y <= (s_y3[9:0] + 10'd32)))) && (!(s_x3[9:0] < 10'd146)))
		begin
			vga_R = obs_R[7:0];
			vga_G = obs_G[7:0];
			vga_B = obs_B[7:0];
		end
		
		
	// SHAPE1 $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$	
		
	else if ((((pixel_x >= s_x0[19:10]) && (pixel_x <= (s_x0[19:10] + 10'd32))) && ((pixel_y >= s_y0[19:10]) && (pixel_y <= (s_y0[19:10] + 10'd32)))) && (!(s_x0[19:10] < 10'd146)))
		begin
			vga_R = obs_R[15:8];
			vga_G = obs_G[15:8];
			vga_B = obs_B[15:8];
		end
	else if ((((pixel_x >= s_x1[19:10]) && (pixel_x <= (s_x1[19:10] + 10'd32))) && ((pixel_y >= s_y1[19:10]) && (pixel_y <= (s_y1[19:10] + 10'd32)))) && (!(s_x1[19:10] < 10'd146)))
		begin
			vga_R = obs_R[15:8];
			vga_G = obs_G[15:8];
			vga_B = obs_B[15:8];
		end
	else if ((((pixel_x >= s_x2[19:10]) && (pixel_x <= (s_x2[19:10] + 10'd32))) && ((pixel_y >= s_y2[19:10]) && (pixel_y <= (s_y2[19:10] + 10'd32)))) && (!(s_x2[19:10] < 10'd146)))
		begin
			vga_R = obs_R[15:8];
			vga_G = obs_G[15:8];
			vga_B = obs_B[15:8];
		end
	else if ((((pixel_x >= s_x3[19:10]) && (pixel_x <= (s_x3[19:10] + 10'd32))) && ((pixel_y >= s_y3[19:10]) && (pixel_y <= (s_y3[19:10] + 10'd32)))) && (!(s_x3[19:10] < 10'd146)))
		begin
			vga_R = obs_R[15:8];
			vga_G = obs_G[15:8];
			vga_B = obs_B[15:8];
		end
		
	// SHAPE2 $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$	
		
	else if ((((pixel_x >= s_x0[29:20]) && (pixel_x <= (s_x0[29:20] + 10'd32))) && ((pixel_y >= s_y0[29:20]) && (pixel_y <= (s_y0[29:20] + 10'd32)))) && (!(s_x0[29:20] < 10'd146)))
		begin
			vga_R = obs_R[23:16];
			vga_G = obs_G[23:16];
			vga_B = obs_B[23:16];
		end
	else if ((((pixel_x >= s_x1[29:20]) && (pixel_x <= (s_x1[29:20] + 10'd32))) && ((pixel_y >= s_y1[29:20]) && (pixel_y <= (s_y1[29:20] + 10'd32)))) && (!(s_x1[29:20] < 10'd146)))
		begin
			vga_R = obs_R[23:16];
			vga_G = obs_G[23:16];
			vga_B = obs_B[23:16];
		end
	else if ((((pixel_x >= s_x2[29:20]) && (pixel_x <= (s_x2[29:20] + 10'd32))) && ((pixel_y >= s_y2[29:20]) && (pixel_y <= (s_y2[29:20] + 10'd32)))) && (!(s_x2[29:20] < 10'd146)))
		begin
			vga_R = obs_R[23:16];
			vga_G = obs_G[23:16];
			vga_B = obs_B[23:16];
		end
	else if ((((pixel_x >= s_x3[29:20]) && (pixel_x <= (s_x3[29:20] + 10'd32))) && ((pixel_y >= s_y3[29:20]) && (pixel_y <= (s_y3[29:20] + 10'd32)))) && (!(s_x3[29:20] < 10'd146)))
		begin
			vga_R = obs_R[23:16];
			vga_G = obs_G[23:16];
			vga_B = obs_B[23:16];
		end
		
	// SHAPE3 $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$	
		
	else if ((((pixel_x >= s_x0[39:30]) && (pixel_x <= (s_x0[39:30] + 10'd32))) && ((pixel_y >= s_y0[39:30]) && (pixel_y <= (s_y0[39:30] + 10'd32)))) && (!(s_x0[39:30] < 10'd146)))
		begin
			vga_R = obs_R[31:24];
			vga_G = obs_G[31:24];
			vga_B = obs_B[31:24];
		end
	else if ((((pixel_x >= s_x1[39:30]) && (pixel_x <= (s_x1[39:30] + 10'd32))) && ((pixel_y >= s_y1[39:30]) && (pixel_y <= (s_y1[39:30] + 10'd32)))) && (!(s_x1[39:30] < 10'd146)))
		begin
			vga_R = obs_R[31:24];
			vga_G = obs_G[31:24];
			vga_B = obs_B[31:24];
		end
	else if ((((pixel_x >= s_x2[39:30]) && (pixel_x <= (s_x2[39:30] + 10'd32))) && ((pixel_y >= s_y2[39:30]) && (pixel_y <= (s_y2[39:30] + 10'd32)))) && (!(s_x2[39:30] < 10'd146)))
		begin
			vga_R = obs_R[31:24];
			vga_G = obs_G[31:24];
			vga_B = obs_B[31:24];
		end
	else if ((((pixel_x >= s_x3[39:30]) && (pixel_x <= (s_x3[39:30] + 10'd32))) && ((pixel_y >= s_y3[39:30]) && (pixel_y <= (s_y3[39:30] + 10'd32)))) && (!(s_x3[39:30] < 10'd146)))
		begin
			vga_R = obs_R[31:24];
			vga_G = obs_G[31:24];
			vga_B = obs_B[31:24];
		end
		
	
	// SHAPE4 $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$	
		
	else if ((((pixel_x >= s_x0[49:40]) && (pixel_x <= (s_x0[49:40] + 10'd32))) && ((pixel_y >= s_y0[49:40]) && (pixel_y <= (s_y0[49:40] + 10'd32)))) && (!(s_x0[49:40] < 10'd146)))
		begin
			vga_R = obs_R[39:32];
			vga_G = obs_G[39:32];
			vga_B = obs_B[39:32];
		end
	else if ((((pixel_x >= s_x1[49:40]) && (pixel_x <= (s_x1[49:40] + 10'd32))) && ((pixel_y >= s_y1[49:40]) && (pixel_y <= (s_y1[49:40] + 10'd32)))) && (!(s_x1[49:40] < 10'd146)))
		begin
			vga_R = obs_R[39:32];
			vga_G = obs_G[39:32];
			vga_B = obs_B[39:32];
		end
	else if ((((pixel_x >= s_x2[49:40]) && (pixel_x <= (s_x2[49:40] + 10'd32))) && ((pixel_y >= s_y2[49:40]) && (pixel_y <= (s_y2[49:40] + 10'd32)))) && (!(s_x2[49:40] < 10'd146)))
		begin
			vga_R = obs_R[39:32];
			vga_G = obs_G[39:32];
			vga_B = obs_B[39:32];
		end
	else if ((((pixel_x >= s_x3[49:40]) && (pixel_x <= (s_x3[49:40] + 10'd32))) && ((pixel_y >= s_y3[49:40]) && (pixel_y <= (s_y3[49:40] + 10'd32)))) && (!(s_x3[49:40] < 10'd146)))
		begin
			vga_R = obs_R[39:32];
			vga_G = obs_G[39:32];
			vga_B = obs_B[39:32];
		end
		
		
	// SHAPE5 $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$	
		
	else if ((((pixel_x >= s_x0[59:50]) && (pixel_x <= (s_x0[59:50] + 10'd32))) && ((pixel_y >= s_y0[59:50]) && (pixel_y <= (s_y0[59:50] + 10'd32)))) && (!(s_x0[59:50] < 10'd146)))
		begin
			vga_R = obs_R[47:40];
			vga_G = obs_G[47:40];
			vga_B = obs_B[47:40];
		end
	else if ((((pixel_x >= s_x1[59:50]) && (pixel_x <= (s_x1[59:50] + 10'd32))) && ((pixel_y >= s_y1[59:50]) && (pixel_y <= (s_y1[59:50] + 10'd32)))) && (!(s_x1[59:50] < 10'd146)))
		begin
			vga_R = obs_R[47:40];
			vga_G = obs_G[47:40];
			vga_B = obs_B[47:40];
		end
	else if ((((pixel_x >= s_x2[59:50]) && (pixel_x <= (s_x2[59:50] + 10'd32))) && ((pixel_y >= s_y2[59:50]) && (pixel_y <= (s_y2[59:50] + 10'd32)))) && (!(s_x2[59:50] < 10'd146)))
		begin
			vga_R = obs_R[47:40];
			vga_G = obs_G[47:40];
			vga_B = obs_B[47:40];
		end
	else if ((((pixel_x >= s_x3[59:50]) && (pixel_x <= (s_x3[59:50] + 10'd32))) && ((pixel_y >= s_y3[59:50]) && (pixel_y <= (s_y3[59:50] + 10'd32)))) && (!(s_x3[59:50] < 10'd146)))
		begin
			vga_R = obs_R[47:40];
			vga_G = obs_G[47:40];
			vga_B = obs_B[47:40];
		end
		
	// SHAPE6 $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$	
		
	else if ((((pixel_x >= s_x0[69:60]) && (pixel_x <= (s_x0[69:60] + 10'd32))) && ((pixel_y >= s_y0[69:60]) && (pixel_y <= (s_y0[69:60] + 10'd32)))) && (!(s_x0[69:60] < 10'd146)))
		begin
			vga_R = obs_R[55:48];
			vga_G = obs_G[55:48];
			vga_B = obs_B[55:48];
		end
	else if ((((pixel_x >= s_x1[69:60]) && (pixel_x <= (s_x1[69:60] + 10'd32))) && ((pixel_y >= s_y1[69:60]) && (pixel_y <= (s_y1[69:60] + 10'd32)))) && (!(s_x1[69:60] < 10'd146)))
		begin
			vga_R = obs_R[55:48];
			vga_G = obs_G[55:48];
			vga_B = obs_B[55:48];
		end
	else if ((((pixel_x >= s_x2[69:60]) && (pixel_x <= (s_x2[69:60] + 10'd32))) && ((pixel_y >= s_y2[69:60]) && (pixel_y <= (s_y2[69:60] + 10'd32)))) && (!(s_x2[69:60] < 10'd146)))
		begin
			vga_R = obs_R[55:48];
			vga_G = obs_G[55:48];
			vga_B = obs_B[55:48];
		end
	else if ((((pixel_x >= s_x3[69:60]) && (pixel_x <= (s_x3[69:60] + 10'd32))) && ((pixel_y >= s_y3[69:60]) && (pixel_y <= (s_y3[69:60] + 10'd32)))) && (!(s_x3[69:60] < 10'd146)))
		begin
			vga_R = obs_R[55:48];
			vga_G = obs_G[55:48];
			vga_B = obs_B[55:48];
		end	
		
	// SHAPE7 $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$	
		
	else if ((((pixel_x >= s_x0[79:70]) && (pixel_x <= (s_x0[79:70] + 10'd32))) && ((pixel_y >= s_y0[79:70]) && (pixel_y <= (s_y0[79:70] + 10'd32)))) && (!(s_x0[79:70] < 10'd146)))
		begin
			vga_R = obs_R[63:56];
			vga_G = obs_G[63:56];
			vga_B = obs_B[63:56];
		end
	else if ((((pixel_x >= s_x1[79:70]) && (pixel_x <= (s_x1[79:70] + 10'd32))) && ((pixel_y >= s_y1[79:70]) && (pixel_y <= (s_y1[79:70] + 10'd32)))) && (!(s_x1[79:70] < 10'd146)))
		begin
			vga_R = obs_R[63:56];
			vga_G = obs_G[63:56];
			vga_B = obs_B[63:56];
		end
	else if ((((pixel_x >= s_x2[79:70]) && (pixel_x <= (s_x2[79:70] + 10'd32))) && ((pixel_y >= s_y2[79:70]) && (pixel_y <= (s_y2[79:70] + 10'd32)))) && (!(s_x2[79:70] < 10'd146)))
		begin
			vga_R = obs_R[63:56];
			vga_G = obs_G[63:56];
			vga_B = obs_B[63:56];
		end
	else if ((((pixel_x >= s_x3[79:70]) && (pixel_x <= (s_x3[79:70] + 10'd32))) && ((pixel_y >= s_y3[79:70]) && (pixel_y <= (s_y3[79:70] + 10'd32)))) && (!(s_x3[79:70] < 10'd146)))
		begin
			vga_R = obs_R[63:56];
			vga_G = obs_G[63:56];
			vga_B = obs_B[63:56];
		end	
	
	// SHAPE8 $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$	
		
	else if ((((pixel_x >= s_x0[89:80]) && (pixel_x <= (s_x0[89:80] + 10'd32))) && ((pixel_y >= s_y0[89:80]) && (pixel_y <= (s_y0[89:80] + 10'd32)))) && (!(s_x0[89:80] < 10'd146)))
		begin
			vga_R = obs_R[71:64];
			vga_G = obs_G[71:64];
			vga_B = obs_B[71:64];
		end
	else if ((((pixel_x >= s_x1[89:80]) && (pixel_x <= (s_x1[89:80] + 10'd32))) && ((pixel_y >= s_y1[89:80]) && (pixel_y <= (s_y1[89:80] + 10'd32)))) && (!(s_x1[89:80] < 10'd146)))
		begin
			vga_R = obs_R[71:64];
			vga_G = obs_G[71:64];
			vga_B = obs_B[71:64];
		end
	else if ((((pixel_x >= s_x2[89:80]) && (pixel_x <= (s_x2[89:80] + 10'd32))) && ((pixel_y >= s_y2[89:80]) && (pixel_y <= (s_y2[89:80] + 10'd32)))) && (!(s_x2[89:80] < 10'd146)))
		begin
			vga_R = obs_R[71:64];
			vga_G = obs_G[71:64];
			vga_B = obs_B[71:64];
		end
	else if ((((pixel_x >= s_x3[89:80]) && (pixel_x <= (s_x3[89:80] + 10'd32))) && ((pixel_y >= s_y3[89:80]) && (pixel_y <= (s_y3[89:80] + 10'd32)))) && (!(s_x3[89:80] < 10'd146)))
		begin
			vga_R = obs_R[71:64];
			vga_G = obs_G[71:64];
			vga_B = obs_B[71:64];
		end		
		
	// SHAPE9 $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$	
		
	else if ((((pixel_x >= s_x0[99:90]) && (pixel_x <= (s_x0[99:90] + 10'd32))) && ((pixel_y >= s_y0[99:90]) && (pixel_y <= (s_y0[99:90] + 10'd32)))) && (!(s_x0[99:90] < 10'd146)))
		begin
			vga_R = obs_R[79:72];
			vga_G = obs_G[79:72];
			vga_B = obs_B[79:72];
		end
	else if ((((pixel_x >= s_x1[99:90]) && (pixel_x <= (s_x1[99:90] + 10'd32))) && ((pixel_y >= s_y1[99:90]) && (pixel_y <= (s_y1[99:90] + 10'd32)))) && (!(s_x1[99:90] < 10'd146)))
		begin
			vga_R = obs_R[79:72];
			vga_G = obs_G[79:72];
			vga_B = obs_B[79:72];
		end
	else if ((((pixel_x >= s_x2[99:90]) && (pixel_x <= (s_x2[99:90] + 10'd32))) && ((pixel_y >= s_y2[99:90]) && (pixel_y <= (s_y2[99:90] + 10'd32)))) && (!(s_x2[99:90] < 10'd146)))
		begin
			vga_R = obs_R[79:72];
			vga_G = obs_G[79:72];
			vga_B = obs_B[79:72];
		end
	else if ((((pixel_x >= s_x3[99:90]) && (pixel_x <= (s_x3[99:90] + 10'd32))) && ((pixel_y >= s_y3[99:90]) && (pixel_y <= (s_y3[99:90] + 10'd32)))) && (!(s_x3[99:90] < 10'd146)))
		begin
			vga_R = obs_R[79:72];
			vga_G = obs_G[79:72];
			vga_B = obs_B[79:72];
		end
		
	//Draw player
	else if (((pixel_x >= player_x) && (pixel_x <= (player_x + 10'd32))) && ((pixel_y >= player_y) && (pixel_y <= (player_y + 10'd32))))
		begin
			vga_R = 8'd255;
			vga_G = 8'd255;
			vga_B = 8'd255;
		end
		
	// Draw Background	
	else if (pixel_x == 10'd178)
		begin
			vga_R <= 8'd75;
			vga_G <= 8'd75;
			vga_B <= 8'd75;
		end
	else if (pixel_x == 10'd210)
		begin
			vga_R <= 8'd75;
			vga_G <= 8'd75;
			vga_B <= 8'd75;
		end
	else if (pixel_x == 10'd242)
		begin
			vga_R <= 8'd75;
			vga_G <= 8'd75;
			vga_B <= 8'd75;
		end
	else if (pixel_x == 10'd274)
		begin
			vga_R <= 8'd75;
			vga_G <= 8'd75;
			vga_B <= 8'd75;
		end
	else if (pixel_x == 10'd306)
		begin
			vga_R <= 8'd75;
			vga_G <= 8'd75;
			vga_B <= 8'd75;
		end
	else if (pixel_x == 10'd338)
		begin
			vga_R <= 8'd75;
			vga_G <= 8'd75;
			vga_B <= 8'd75;
		end
	else if (pixel_x == 10'd370)
		begin
			vga_R <= 8'd211;
			vga_G <= 8'd57;
			vga_B <= 8'd57;
		end
	else if (pixel_x == 10'd402)
		begin
			vga_R <= 8'd75;
			vga_G <= 8'd75;
			vga_B <= 8'd75;
		end
	else if (pixel_x == 10'd434)
		begin
			vga_R <= 8'd75;
			vga_G <= 8'd75;
			vga_B <= 8'd75;
		end
	else if (pixel_x == 10'd466)
		begin
			vga_R <= 8'd75;
			vga_G <= 8'd75;
			vga_B <= 8'd75;
		end
	else if (pixel_x == 10'd498)
		begin
			vga_R <= 8'd75;
			vga_G <= 8'd75;
			vga_B <= 8'd75;
		end
	else if (pixel_x == 10'd530)
		begin
			vga_R <= 8'd75;
			vga_G <= 8'd75;
			vga_B <= 8'd75;
		end
	else if (pixel_x == 10'd562)
		begin
			vga_R <= 8'd75;
			vga_G <= 8'd75;
			vga_B <= 8'd75;
		end
	else if (pixel_x == 10'd594)
		begin
			vga_R <= 8'd75;
			vga_G <= 8'd75;
			vga_B <= 8'd75;
		end
	else if (pixel_x == 10'd626)
		begin
			vga_R <= 8'd75;
			vga_G <= 8'd75;
			vga_B <= 8'd75;
		end
	else if (pixel_x == 10'd658)
		begin
			vga_R <= 8'd75;
			vga_G <= 8'd75;
			vga_B <= 8'd75;
		end
	else if (pixel_x == 10'd690)
		begin
			vga_R <= 8'd75;
			vga_G <= 8'd75;
			vga_B <= 8'd75;
		end
	else if (pixel_x == 10'd722)
		begin
			vga_R <= 8'd75;
			vga_G <= 8'd75;
			vga_B <= 8'd75;
		end
	else if (pixel_x == 10'd754)
		begin
			vga_R <= 8'd75;
			vga_G <= 8'd75;
			vga_B <= 8'd75;
		end
	else if (pixel_y == 10'd52)
		begin
			vga_R <= 8'd75;
			vga_G <= 8'd75;
			vga_B <= 8'd75;
		end
	else if (pixel_y == 10'd84)
		begin
			vga_R <= 8'd75;
			vga_G <= 8'd75;
			vga_B <= 8'd75;
		end
	else if (pixel_y == 10'd116)
		begin
			vga_R <= 8'd75;
			vga_G <= 8'd75;
			vga_B <= 8'd75;
		end
	else if (pixel_y == 10'd148)
		begin
			vga_R <= 8'd75;
			vga_G <= 8'd75;
			vga_B <= 8'd75;
		end
	else if (pixel_y == 10'd180)
		begin
			vga_R <= 8'd75;
			vga_G <= 8'd75;
			vga_B <= 8'd75;
		end
	else if (pixel_y == 10'd212)
		begin
			vga_R <= 8'd75;
			vga_G <= 8'd75;
			vga_B <= 8'd75;
		end
	else if (pixel_y == 10'd244)
		begin
			vga_R <= 8'd75;
			vga_G <= 8'd75;
			vga_B <= 8'd75;
		end
	else if (pixel_y == 10'd276)
		begin
			vga_R <= 8'd75;
			vga_G <= 8'd75;
			vga_B <= 8'd75;
		end
	else if (pixel_y == 10'd308)
		begin
			vga_R <= 8'd75;
			vga_G <= 8'd75;
			vga_B <= 8'd75;
		end
	else if (pixel_y == 10'd340)
		begin
			vga_R <= 8'd75;
			vga_G <= 8'd75;
			vga_B <= 8'd75;
		end
	else if (pixel_y == 10'd372)
		begin
			vga_R <= 8'd75;
			vga_G <= 8'd75;
			vga_B <= 8'd75;
		end
	else if (pixel_y == 10'd404)
		begin
			vga_R <= 8'd75;
			vga_G <= 8'd75;
			vga_B <= 8'd75;
		end
	else if (pixel_y == 10'd436)
		begin
			vga_R <= 8'd75;
			vga_G <= 8'd75;
			vga_B <= 8'd75;
		end
	else if (pixel_y == 10'd468)
		begin
			vga_R <= 8'd75;
			vga_G <= 8'd75;
			vga_B <= 8'd75;
		end
	else
		begin
			vga_R = 8'b00000000;
			vga_G = 8'b00000000;
			vga_B = 8'b00000000;
		end
		
	
end


endmodule

	

//-------------------------------------------------------Player Movement-------------------------------------------------------------------------------------//
	
module playerMove(clock20, rst, button_R, button_L, button_U, button_D, player_x, player_y);
output reg [9:0]player_x = 10'd242;
output reg [9:0]player_y = 10'd244;
input button_R, button_L, button_U, button_D;
input clock20, rst;


always @ (posedge clock20 or negedge rst)
	begin
		if (rst == 1'b0)
			begin
				player_x = 10'd242;
				player_y = 10'd244;
			end
		
		else if (button_R == 1'b0)
			begin
				if (player_x >= 10'd338)
					player_x = 10'd338;
				else
					begin
						player_x = player_x + 10'd32;
						player_y = player_y;
					end
			end
		
		else if (button_L == 1'b0)
			begin
				if (player_x <= 10'd146)
					player_x = 10'd146;
				else
					begin
						player_x = player_x - 10'd32;
						player_y = player_y;
					end
			end
		
		else if (button_U == 1'b0)
			begin
				if (player_y <= 10'd20)
					player_y = 10'd20;
				else
					begin
						player_x = player_x;
						player_y = player_y - 10'd32;
					end
			end
		
		else if (button_D <= 1'b0)
			begin
				if (player_y >= 10'd468)
					player_y = 10'd468;
				else
					begin
						player_x = player_x;
						player_y = player_y + 10'd32;
					end
			end
		
		else
			begin
				player_x = player_x;
				player_y = player_y;
			end
	end
	
endmodule


//-----------------------------------------------------------------LFSR---------------------------------------------------------------------------------------//

module randomNum(clk, rst, change, button_R, button_L, button_U, button_D, out, firstPress);
input clk, rst;
input button_R, button_L, button_U, button_D;
reg [7:0]count;
output reg firstPress;
output reg [7:0]out;
input [7:0]change;

// counter for seed
	always @ (posedge clk)
		begin
			if (count > 8'd255)
				count <= 8'd0;
			else
				count <= count + 8'd1;
		end
	
	// assigns count to seed when button is pressed first
	always @ (posedge clk or negedge rst)
		begin
			if (rst == 1'b0)
				firstPress <= 1'b0;
			else if (((!button_R) | (!button_L) | (!button_U) | (!button_D)) & !firstPress)
				begin
					firstPress <= 1'b1;
				end
		end
	
	
	always @ (posedge clk)
		begin
			if (((!button_R) | (!button_L) | (!button_U) | (!button_D)) & !firstPress)
				out <= count * change;
			else
				out <= {out[0],out[7], (out[0] ^ out[6]), (out[0] ^ out[5]), (out[0] ^ out[4]), out[3], out[2], out[1]};
		end

endmodule


//--------------------------------------------------------object movement--------------------------------------------------------------------------------//
module object(clockPulse, rst, waitTime, randPos, randShape, orient, s_x0, s_x1, s_x2, s_x3, s_y0, s_y1, s_y2, s_y3, obs_R, obs_G, obs_B);
input rst;
input [3:0]randPos;
input [2:0]randShape;
input [1:0]orient; 
input clockPulse;
input [4:0]waitTime;

output reg [7:0]obs_R, obs_G, obs_B;

reg [4:0]count;
reg firstTime;
reg [3:0] position;
reg [2:0] shape;

output reg [9:0]s_x0, s_x1, s_x2, s_x3;
output reg [9:0]s_y0, s_y1, s_y2, s_y3; 
reg posCheck, shapeCheck;

reg [2:0]S, NS;

parameter ST = 3'd0,
			 GRAB = 3'd1,
			 START_VALS = 3'd2,
			 WAIT = 3'd3,
			 MOVE = 3'd4;
			 
always @ (posedge clockPulse or negedge rst)
begin
	if (rst == 1'b0)
		S <= ST;
	else 
		S <= NS;
end

always @ (*)
begin
	case(S)
		ST: NS = GRAB;
		GRAB: NS = START_VALS;
		START_VALS: 
			begin
				if (posCheck & shapeCheck & firstTime)
					NS = WAIT;
				else if (posCheck & shapeCheck & (!firstTime))
					NS = MOVE;
				else
					NS = START_VALS;
			end
		WAIT:
			begin
				if (count < waitTime)
					NS = WAIT;
				else
					NS = MOVE;
			end
		MOVE: 
			begin 
				if (s_x3 < 10'd146)
					NS = GRAB;
				else
					NS = MOVE;
			end
	endcase
end

always @ (posedge clockPulse or negedge rst)
begin
	if (rst == 1'b0)
		begin
			s_x0 <= 10'd0;
			s_x1 <= 10'd0;
			s_x2 <= 10'd0;
			s_x3 <= 10'd0;
			s_y0 <= 10'd0;
			s_y1 <= 10'd0;
			s_y2 <= 10'd0;
			s_y3 <= 10'd0;
			
			posCheck <= 1'b0;
			shapeCheck <= 1'b0;
			shape <= 3'd0;
			position <= 4'd0;
			firstTime <= 1'b1;
			count <= 5'd0;
		end
	else
		case(S)
			GRAB:
				begin
					shape <= randShape;
					position <= randPos;
				end
				
			START_VALS:
				begin
					if (position == 4'd15)
						position = 4'd0;
					case(shape)
							// horizontal line
							3'd0:
								begin
									s_x0 = 10'd786;
									s_y0 = 10'd20 + (10'd32 * position);
									
									s_x1 = 10'd818;
									s_y1 = 10'd20 + (10'd32 * position);
									
									s_x2 = 10'd850;
									s_y2 = 10'd20 + (10'd32 * position);
									
									s_x3 = 10'd882;
									s_y3 = 10'd20 + (10'd32 * position);
									
									obs_R = 8'd0;
									obs_G = 8'd222;
									obs_B = 8'd255;
								end
							// reverse-L
							3'd1:
								begin
									s_x0 = 10'd786;
									s_y0 = 10'd20 + (10'd32 * position);
									
									s_x1 = 10'd786;
									s_y1 = 10'd52 + (10'd32 * position);
									
									s_x2 = 10'd818;
									s_y2 = 10'd52 + (10'd32 * position);
									
									s_x3 = 10'd850;
									s_y3 = 10'd52 + (10'd32 * position);
									
									obs_R = 8'd0;
									obs_G = 8'd70;
									obs_B = 8'd183;
								end
							// L
							3'd2:
								begin
									s_x0 = 10'd786;
									s_y0 = 10'd52 + (10'd32 * position);
									
									s_x1 = 10'd818;
									s_y1 = 10'd52 + (10'd32 * position);
									
									s_x2 = 10'd850;
									s_y2 = 10'd52 + (10'd32 * position);
									
									s_x3 = 10'd850;
									s_y3 = 10'd20 + (10'd32 * position);
									
									obs_R = 8'd220;
									obs_G = 8'd80;
									obs_B = 8'd0;
								end
							// S
							3'd3:
								begin
									s_x0 = 10'd786;
									s_y0 = 10'd52 + (10'd32 * position);
									
									s_x1 = 10'd818;
									s_y1 = 10'd52 + (10'd32 * position);
									
									s_x2 = 10'd818;
									s_y2 = 10'd20 + (10'd32 * position);
									
									s_x3 = 10'd850;
									s_y3 = 10'd20 + (10'd32 * position);
									
									obs_R = 8'd38;
									obs_G = 8'd168;
									obs_B = 8'd23;
								end
							// Z
							3'd4:
								begin
									s_x0 = 10'd786;
									s_y0 = 10'd20 + (10'd32 * position);
									
									s_x1 = 10'd818;
									s_y1 = 10'd20 + (10'd32 * position);
									
									s_x2 = 10'd818;
									s_y2 = 10'd52 + (10'd32 * position);
									
									s_x3 = 10'd850;
									s_y3 = 10'd52 + (10'd32 * position);
									
									obs_R = 8'd240;
									obs_G = 8'd20;
									obs_B = 8'd20;
								end
							// T
							3'd5:
								begin
									s_x0 = 10'd786;
									s_y0 = 10'd52 + (10'd32 * position);
									
									s_x1 = 10'd818;
									s_y1 = 10'd52 + (10'd32 * position);
									
									s_x2 = 10'd818;
									s_y2 = 10'd20 + (10'd32 * position);
									
									s_x3 = 10'd850;
									s_y3 = 10'd52 + (10'd32 * position);
									
									obs_R = 8'd121;
									obs_G = 8'd19;
									obs_B = 8'd173;
								end
							// square
							3'd6:
								begin
									s_x0 = 10'd786;
									s_y0 = 10'd20 + (10'd32 * position);
									
									s_x1 = 10'd818;
									s_y1 = 10'd20 + (10'd32 * position);
									
									s_x2 = 10'd786;
									s_y2 = 10'd52 + (10'd32 * position);
									
									s_x3 = 10'd818;
									s_y3 = 10'd52 + (10'd32 * position);
									
									obs_R = 8'd244;
									obs_G = 8'd244;
									obs_B = 8'd46;
								end
							// vertical line
							3'd7:
								begin
									s_x0 = 10'd786;
									s_y0 = 10'd20 + (10'd32 * position);
									
									s_x1 = 10'd786;
									s_y1 = 10'd52 + (10'd32 * position);
									
									s_x2 = 10'd786;
									s_y2 = 10'd84 + (10'd32 * position);
									
									s_x3 = 10'd786;
									s_y3 = 10'd116 + (10'd32 * position);
									
									obs_R = 8'd252;
									obs_G = 8'd108;
									obs_B = 8'd223;
								end
						endcase
						
					posCheck <= 1'b1;
					shapeCheck <= 1'b1;
				end
			WAIT:
				begin
					count <= count + 5'd1;
					firstTime = 1'b0;
				end
			MOVE:	
				begin
					s_x0 <= s_x0 - 10'd32;
					s_x1 <= s_x1 - 10'd32;
					s_x2 <= s_x2 - 10'd32;
					s_x3 <= s_x3 - 10'd32;
					
					count <= 5'd0;
				end
			
			default: 
				begin
					s_x0 <= 10'd0;
					s_x1 <= 10'd0;
					s_x2 <= 10'd0;
					s_x3 <= 10'd0;
					s_y0 <= 10'd0;
					s_y1 <= 10'd0;
					s_y2 <= 10'd0;
					s_y3 <= 10'd0;
					
					posCheck <= 1'b0;
					shapeCheck <= 1'b0;
					shape <= 3'd0;
					position <= 4'd0;
					firstTime <= 1'b1;
					count <= 5'd0;
				end
		endcase
end
endmodule


module collide(rst, player_x, player_y, s_x0, s_x1, s_x2, s_x3, s_y0, s_y1, s_y2, s_y3, lose);

input rst;
input [9:0]player_x, player_y;
input [99:0]s_x0, s_x1, s_x2, s_x2, s_x3, s_y0, s_y1, s_y2, s_y3;
output reg lose;

always @ (*)
begin
	if (rst == 1'b0)
		lose = 1'b0;
	else if ((player_x == s_x0[9:0]) && (player_y == s_y0[9:0]))
		lose = 1'b1;
	else if ((player_x == s_x0[19:10]) && (player_y == s_y0[19:10]))
		lose = 1'b1;
	else if ((player_x == s_x0[29:20]) && (player_y == s_y0[29:20]))
		lose = 1'b1;
	else if ((player_x == s_x0[39:30]) && (player_y == s_y0[39:30]))
		lose = 1'b1;
	else if ((player_x == s_x0[49:40]) && (player_y == s_y0[49:40]))
		lose = 1'b1;
	else if ((player_x == s_x0[59:50]) && (player_y == s_y0[59:50]))
		lose = 1'b1;
	else if ((player_x == s_x0[69:60]) && (player_y == s_y0[69:60]))
		lose = 1'b1;
	else if ((player_x == s_x0[79:70]) && (player_y == s_y0[79:70]))
		lose = 1'b1;
	else if ((player_x == s_x0[89:80]) && (player_y == s_y0[89:80]))
		lose = 1'b1;
	else if ((player_x == s_x0[99:90]) && (player_y == s_y0[99:90]))
		lose = 1'b1;
	else if ((player_x == s_x1[9:0]) && (player_y == s_y1[9:0]))
		lose = 1'b1;
	else if ((player_x == s_x1[19:10]) && (player_y == s_y1[19:10]))
		lose = 1'b1;
	else if ((player_x == s_x1[29:20]) && (player_y == s_y1[29:20]))
		lose = 1'b1;
	else if ((player_x == s_x1[39:30]) && (player_y == s_y1[39:30]))
		lose = 1'b1;
	else if ((player_x == s_x1[49:40]) && (player_y == s_y1[49:40]))
		lose = 1'b1;
	else if ((player_x == s_x1[59:50]) && (player_y == s_y1[59:50]))
		lose = 1'b1;
	else if ((player_x == s_x1[69:60]) && (player_y == s_y1[69:60]))
		lose = 1'b1;
	else if ((player_x == s_x1[79:70]) && (player_y == s_y1[79:70]))
		lose = 1'b1;
	else if ((player_x == s_x1[89:80]) && (player_y == s_y1[89:80]))
		lose = 1'b1;
	else if ((player_x == s_x1[99:90]) && (player_y == s_y1[99:90]))
		lose = 1'b1;
	else if ((player_x == s_x2[9:0]) && (player_y == s_y2[9:0]))
		lose = 1'b1;
	else if ((player_x == s_x2[19:10]) && (player_y == s_y2[19:10]))
		lose = 1'b1;
	else if ((player_x == s_x2[29:20]) && (player_y == s_y2[29:20]))
		lose = 1'b1;
	else if ((player_x == s_x2[39:30]) && (player_y == s_y2[39:30]))
		lose = 1'b1;
	else if ((player_x == s_x2[49:40]) && (player_y == s_y2[49:40]))
		lose = 1'b1;
	else if ((player_x == s_x2[59:50]) && (player_y == s_y2[59:50]))
		lose = 1'b1;
	else if ((player_x == s_x2[69:60]) && (player_y == s_y2[69:60]))
		lose = 1'b1;
	else if ((player_x == s_x2[79:70]) && (player_y == s_y2[79:70]))
		lose = 1'b1;
	else if ((player_x == s_x2[89:80]) && (player_y == s_y2[89:80]))
		lose = 1'b1;
	else if ((player_x == s_x2[99:90]) && (player_y == s_y2[99:90]))
		lose = 1'b1;
	else if ((player_x == s_x3[9:0]) && (player_y == s_y3[9:0]))
		lose = 1'b1;
	else if ((player_x == s_x3[19:10]) && (player_y == s_y3[19:10]))
		lose = 1'b1;
	else if ((player_x == s_x3[29:20]) && (player_y == s_y3[29:20]))
		lose = 1'b1;
	else if ((player_x == s_x3[39:30]) && (player_y == s_y3[39:30]))
		lose = 1'b1;
	else if ((player_x == s_x3[49:40]) && (player_y == s_y3[49:40]))
		lose = 1'b1;
	else if ((player_x == s_x3[59:50]) && (player_y == s_y3[59:50]))
		lose = 1'b1;
	else if ((player_x == s_x3[69:60]) && (player_y == s_y3[69:60]))
		lose = 1'b1;
	else if ((player_x == s_x3[79:70]) && (player_y == s_y3[79:70]))
		lose = 1'b1;
	else if ((player_x == s_x3[89:80]) && (player_y == s_y3[89:80]))
		lose = 1'b1;
	else if ((player_x == s_x3[99:90]) && (player_y == s_y3[99:90]))
		lose = 1'b1;
	else
		lose = 1'b0;
end

endmodule


//---------------------------------------------------------------------FSM for score----------------------------------------------------------------------------------------------------//

module score(clk, rst, stop, button_R, button_L, button_U, button_D, one, ten, hund, thous);
input clk, rst, stop, button_R, button_L, button_U, button_D;
reg firstPress;
reg [13:0] count;
output [3:0] one, ten, hund, thous;

reg [1:0] S, NS;

parameter ST = 2'd0,
			 COUNT = 2'd1,
			 STOP = 2'd2;
			 
			 
always @ (posedge clk or negedge rst)
begin
	if (rst == 1'b0)
		S <= ST;
	else
		S <= NS;
end

always @ (*)
begin
	case(S)
		ST: 
			begin
				if (firstPress)
					NS <= COUNT;
				else
					NS <= ST;
			end
		COUNT:
			begin
				if (stop)
					NS <= STOP;
				else if (count >= 14'd9999)
					NS <= ST;
				else
					NS <= COUNT;
			end
		STOP: NS <= STOP;
	endcase
end

always @ (posedge clk or negedge rst)
begin
	if (rst == 1'b0)
		begin
			count <= 14'd0;
			firstPress <= 1'b0;
		end
	else
		begin
			case(S)
				ST: 
					begin
						count <= 14'd0;
						
						if (((!button_R) | (!button_L) | (!button_U) | (!button_D)) & !firstPress)
								firstPress <= 1'b1;
					end
				COUNT:
					begin
						count <= count + 14'd1;
					end
				STOP:
					begin
						count <= count;
					end
			endcase
		end
end

assign one = count % 14'd10;
assign ten = ((count % 14'd100) - one) / 10;
assign hund = ((count % 14'd1000) - ten - one) / 100;
assign thous = (count - hund - ten - one) / 1000;
					

/*
input clk, rst;
output reg [3:0] one, ten, hund, thous;


reg [2:0] S, NS;

parameter ST = 3'd0,
			 ONES = 3'd1,
			 TENS = 3'd2,
			 HUND = 3'd3,
			 THOUS = 3'd4;

always @ (posedge clk or negedge rst)
begin
	if (rst == 1'b0)
		S <= ST;
	else
		S <= NS;
end


always @ (*)
begin
	case(S)
		ST: NS = ONES;
		ONES: 
			begin
				if (one >= 4'd9)
					NS = TENS;
				else
					NS = ONES;
			end
		TENS:
			begin
				if (ten >= 4'd9)
					NS = HUND;
				else
					NS = ONES;
			end
		HUND:
			begin
				if (hund >= 4'd9)
					NS = THOUS;
				else
					NS = TENS;
			end
		THOUS:
			begin
				if (thous >= 4'd9)
					NS = ST;
				else
					NS = HUND;
			end
	endcase
end


always @ (posedge clk or negedge rst)
begin
	if (rst == 1'b0)
		begin
			one <= 4'd0;
			ten <= 4'd0;
			hund <= 4'd0;
			thous <= 4'd0;
		end
	else
		begin
			case(S)
				ST:
					begin
						one <= 4'd0;
						ten <= 4'd0;
						hund <= 4'd0;
						thous <= 4'd0;
					end
				ONES:
					begin
						one <= one + 4'd1;
					end
				TENS:
					begin
						ten <= ten + 4'd1;
						one <= 4'd0;
					end
				HUND:
					begin
						hund <= hund + 4'd1;
						ten <= 4'd0;
					end
				THOUS:
					begin
						thous <= thous + 4'd1;
						hund <= 4'd0;
					end
			endcase
		end
end
*/

endmodule


module displayScore(rst, in, a, b, c, d, e, f, g);
input rst;
input [3:0] in;
output a, b, c, d, e, f, g;

assign a = !((~in[2] & ~in[1] & ~in[0]) || (in[3] & ~in[2] & ~in[1]) || (~in[3] & in[2] & in[0]) || (~in[3] & in[1]));
assign b = !((~in[2] & ~in[1]) || (~in[3] & ~in[2]) || (~in[3] & ~in[1] & ~in[0]) || (~in[3] & in[1] & in[0]));
assign c = !((~in[2] & ~in[1]) || (~in[3] & ~in[1]) || (~in[3] & in[0]) || (~in[3] & in[2]));
assign d = !((~in[2] & ~in[1] & ~in[0]) || (~in[3] & in[2] & ~in[1] & in[0]) || (~in[3] & ~in[2] & in[1]) || (~in[3] & in[1] & ~in[0]));
assign e = !((~in[2] & ~in[1] & ~in[0]) || (~in[3] & in[1] & ~in[0]));
assign f = !((~in[2] & ~in[1] & ~in[0]) || (~in[3] & in[2] & ~in[0]) || (~in[3] & in[2] & ~in[1]) || (in[3] & ~in[2] & ~in[1]));
assign g = !((~in[3] & ~in[2] & in[1]) || (~in[3] & in[2] & ~in[1]) || (~in[3] & in[1] & ~in[0]) || (in[3] & ~in[2] & ~in[1]));

endmodule








