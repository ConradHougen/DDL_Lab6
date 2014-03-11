
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//
// MODULE DETAILS:
// This module uses a 464 order FIR filter to filter a 20 Hz sine wave 
// with a magnitude of 100 out of a morse code signal. The morse code 
// signal is encoded as a value of 100 for '-' and a value of 50 for 
// '.' signals.
// 
// OPERATION: 
// This module is expected to obtain a 16 bit signed number 
// from an external source (the LPCXpresso board). The FPGA filters 
// the data and sets an output pin HIGH if the filtered data is between
// 90 and 110 (representing a '-'), and sets the output pin LOW
// if the filtered data is between 40 and 60 (repre	senting a '.').
// 
// The coefficients (provided) are stored on the FPGA.
//
// Good luck!
//
// Author: Conrad Hougen and Cy Parker
// Date:   Mar. 4th, 2014
//
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

//ADD INPUTS AND OUTPUTS
module lab6 (clk, hndshk, reset, dataIn, dataOut, LED1, LED_CLK, clk_out, LED_dataIN, LED_dataOUT); 
							
	// NUMBER OF COEFFICIENTS (465)
	// 	(Change this to a small value for initial testing and debugging, 
	// 	otherwise it will take ~4 minutes to load your program on the FPGA.)
	parameter NUMCOEFFICIENTS = 465;

	// define inputs and outputs
	input clk, hndshk, reset, dataIn;
	output reg dataOut, clk_out;
	output reg LED1;
	output LED_CLK, LED_dataIN, LED_dataOUT;
	reg [4:0] bits_in_buffer;
	reg EN_mult;
	reg [4:0] flush_index;
	wire done;
	
	assign LED_CLK = clk;
	assign LED_dataIN = dataIn;
	assign LED_dataOUT = dataOut;
	
	// store the input data by shifting into register
	//reg [16:0] dataInReg;
	//reg dataRcvd; // have we received any data
	
	// DEFINE ALL REGISTERS AND WIRES HERE
	//reg 		[11:0]	coeffIndex;		// Coefficient index of FIR filter
	//reg signed 	[16:0] 	coefficient;	// Coefficient of FIR filter for index coeffIndex
	//reg signed 	[16:0] 	out;			// Register used for coefficient calculation
	// Add more here...
	reg signed [(NUMCOEFFICIENTS*10)-1:0] buffer; // buffer to store all 465 pipeline inputs 
	wire [16:0] filtered_val; // result value after filtering and summing
	
	
	initial
	begin
		//dataRcvd <= 1'b0;
		//dataInReg <= 17'b0;
		buffer <= 4650'b0;
		dataOut <= 1'b0;
		clk_out <= 1'b0;
		bits_in_buffer <= 5'b0;
		EN_mult <= 1'b0;
		flush_index <= 5'b0;
	end

	
	multiplier M(buffer, EN_mult, filtered_val, done);

	// BLOCK 1: READ INPUT VALUE (16 bit stream)
	//////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	always @(posedge clk or negedge reset)
	begin
		if(reset == 1'b0)
		begin
			//dataRcvd <= 1'b0;
			//dataInReg <= 17'b0;
			buffer = 4650'b0;
			dataOut <= 1'b0;
			LED1 <= 1'b0;
			bits_in_buffer <= 5'b0;
			flush_index <= 5'b0;
			
			//coefficient	<= 17'd0;
			//coeffIndex <= 12'b0;
			//out <= 17'b0;
		end
		else
		begin
			// handshake is high, so read data
			if(hndshk == 1'b1)
			begin
				// shift the current data left one bit, and add on the next serial data bit
				//dataInReg <= ((dataInReg << 1) + dataIn);
				buffer <= ((buffer << 1) + dataIn);
				//dataRcvd <= 1'b1;
				bits_in_buffer <= bits_in_buffer + 1'b1;
				// turn on the LED based on dataIn
				LED1 <= dataIn;
			end
			// if handshake is low and we have data to send back
			//else if(hndshk == 1'b0 && dataRcvd == 1'b1)
			else if(hndshk == 1'b0 && bits_in_buffer == 5'b1010)
			begin
				LED1 <= 1'b0;
				
				//dataOut = dataInReg[0];
				//dataInReg = (dataInReg >> 1); // flush one bit from storage
				//bits_in_buffer = bits_in_buffer - 1'b1;
				// toggle the output clock
				//clk_out = ~clk_out;
				
				// generate enable signal
				EN_mult = 1'b1;
			end
			else if(hndshk == 1'b0 && done == 1'b1)
			begin
				// write the data back out to the LPC Xpresso
				dataOut = filtered_val[flush_index];
				flush_index = flush_index + 1'b1;
				//filtered_val = (filtered_val >> 1);
				bits_in_buffer = bits_in_buffer - 1'b1;
				clk_out = ~clk_out;
				if(bits_in_buffer == 5'b0)
				begin
					EN_mult = 1'b0;
					flush_index = 5'b0;
				end
			end
		end
	end


	// BLOCK 2: CALCULATING OUTPUT Y
	//////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////
	


	// BLOCK 3: CALCULATING COEFFICIENT
	//////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
endmodule

module multiplier(input_buffer, EN, out, done);
	input[4649:0] input_buffer;
	input EN;
	output reg [16:0] out;
	output reg done;
	
	reg [16:0] multed [464:0];
	
	reg trigger, trigger2;
	
	initial
	begin
		trigger2 = 1'b0;
		trigger = 1'b0;
		done = 0;
	end
	
	always @ (EN) // Define always statement as you wish...
  	begin
		if(EN == 1'b0)
		begin
			trigger = 1'b0;
		end
		else
		begin
			
			multed[0] = input_buffer[4649:4640] * 17'd442;
multed[1] = input_buffer[4639:4630] * -17'd373;
multed[2] = input_buffer[4629:4620] * -17'd169;
multed[3] = input_buffer[4619:4610] * -17'd37;
multed[4] = input_buffer[4609:4600] * 17'd20;
multed[5] = input_buffer[4599:4590] * 17'd15;
multed[6] = input_buffer[4589:4580] * -17'd21;
multed[7] = input_buffer[4579:4570] * -17'd61;
multed[8] = input_buffer[4569:4560] * -17'd80;
multed[9] = input_buffer[4559:4550] * -17'd70;
multed[10] = input_buffer[4549:4540] * -17'd37;
multed[11] = input_buffer[4539:4530] * 17'd4;
multed[12] = input_buffer[4529:4520] * 17'd35;
multed[13] = input_buffer[4519:4510] * 17'd45;
multed[14] = input_buffer[4509:4500] * 17'd32;
multed[15] = input_buffer[4499:4490] * 17'd3;
multed[16] = input_buffer[4489:4480] * -17'd29;
multed[17] = input_buffer[4479:4470] * -17'd49;
multed[18] = input_buffer[4469:4460] * -17'd49;
multed[19] = input_buffer[4459:4450] * -17'd30;
multed[20] = input_buffer[4449:4440] * 17'd0;
multed[21] = input_buffer[4439:4430] * 17'd29;
multed[22] = input_buffer[4429:4420] * 17'd44;
multed[23] = input_buffer[4419:4410] * 17'd41;
multed[24] = input_buffer[4409:4400] * 17'd22;
multed[25] = input_buffer[4399:4390] * -17'd6;
multed[26] = input_buffer[4389:4380] * -17'd31;
multed[27] = input_buffer[4379:4370] * -17'd43;
multed[28] = input_buffer[4369:4360] * -17'd37;
multed[29] = input_buffer[4359:4350] * -17'd18;
multed[30] = input_buffer[4349:4340] * 17'd8;
multed[31] = input_buffer[4339:4330] * 17'd29;
multed[32] = input_buffer[4329:4320] * 17'd38;
multed[33] = input_buffer[4319:4310] * 17'd31;
multed[34] = input_buffer[4309:4300] * 17'd13;
multed[35] = input_buffer[4299:4290] * -17'd9;
multed[36] = input_buffer[4289:4280] * -17'd25;
multed[37] = input_buffer[4279:4270] * -17'd31;
multed[38] = input_buffer[4269:4260] * -17'd24;
multed[39] = input_buffer[4259:4250] * -17'd9;
multed[40] = input_buffer[4249:4240] * 17'd8;
multed[41] = input_buffer[4239:4230] * 17'd19;
multed[42] = input_buffer[4229:4220] * 17'd21;
multed[43] = input_buffer[4219:4210] * 17'd15;
multed[44] = input_buffer[4209:4200] * 17'd4;
multed[45] = input_buffer[4199:4190] * -17'd6;
multed[46] = input_buffer[4189:4180] * -17'd11;
multed[47] = input_buffer[4179:4170] * -17'd10;
multed[48] = input_buffer[4169:4160] * -17'd4;
multed[49] = input_buffer[4159:4150] * 17'd1;
multed[50] = input_buffer[4149:4140] * 17'd3;
multed[51] = input_buffer[4139:4130] * 17'd1;
multed[52] = input_buffer[4129:4120] * -17'd4;
multed[53] = input_buffer[4119:4110] * -17'd7;
multed[54] = input_buffer[4109:4100] * -17'd7;
multed[55] = input_buffer[4099:4090] * -17'd1;
multed[56] = input_buffer[4089:4080] * 17'd10;
multed[57] = input_buffer[4079:4070] * 17'd19;
multed[58] = input_buffer[4069:4060] * 17'd21;
multed[59] = input_buffer[4059:4050] * 17'd13;
multed[60] = input_buffer[4049:4040] * -17'd3;
multed[61] = input_buffer[4039:4030] * -17'd21;
multed[62] = input_buffer[4029:4020] * -17'd34;
multed[63] = input_buffer[4019:4010] * -17'd34;
multed[64] = input_buffer[4009:4000] * -17'd19;
multed[65] = input_buffer[3999:3990] * 17'd7;
multed[66] = input_buffer[3989:3980] * 17'd33;
multed[67] = input_buffer[3979:3970] * 17'd49;
multed[68] = input_buffer[3969:3960] * 17'd47;
multed[69] = input_buffer[3959:3950] * 17'd25;
multed[70] = input_buffer[3949:3940] * -17'd10;
multed[71] = input_buffer[3939:3930] * -17'd44;
multed[72] = input_buffer[3929:3920] * -17'd63;
multed[73] = input_buffer[3919:3910] * -17'd58;
multed[74] = input_buffer[3909:3900] * -17'd29;
multed[75] = input_buffer[3899:3890] * 17'd13;
multed[76] = input_buffer[3889:3880] * 17'd52;
multed[77] = input_buffer[3879:3870] * 17'd73;
multed[78] = input_buffer[3869:3860] * 17'd66;
multed[79] = input_buffer[3859:3850] * 17'd33;
multed[80] = input_buffer[3849:3840] * -17'd15;
multed[81] = input_buffer[3839:3830] * -17'd58;
multed[82] = input_buffer[3829:3820] * -17'd80;
multed[83] = input_buffer[3819:3810] * -17'd70;
multed[84] = input_buffer[3809:3800] * -17'd34;
multed[85] = input_buffer[3799:3790] * 17'd16;
multed[86] = input_buffer[3789:3780] * 17'd60;
multed[87] = input_buffer[3779:3770] * 17'd80;
multed[88] = input_buffer[3769:3760] * 17'd69;
multed[89] = input_buffer[3759:3750] * 17'd32;
multed[90] = input_buffer[3749:3740] * -17'd16;
multed[91] = input_buffer[3739:3730] * -17'd57;
multed[92] = input_buffer[3729:3720] * -17'd75;
multed[93] = input_buffer[3719:3710] * -17'd63;
multed[94] = input_buffer[3709:3700] * -17'd29;
multed[95] = input_buffer[3699:3690] * 17'd15;
multed[96] = input_buffer[3689:3680] * 17'd50;
multed[97] = input_buffer[3679:3670] * 17'd63;
multed[98] = input_buffer[3669:3660] * 17'd51;
multed[99] = input_buffer[3659:3650] * 17'd22;
multed[100] = input_buffer[3649:3640] * -17'd12;
multed[101] = input_buffer[3639:3630] * -17'd37;
multed[102] = input_buffer[3629:3620] * -17'd44;
multed[103] = input_buffer[3619:3610] * -17'd34;
multed[104] = input_buffer[3609:3600] * -17'd13;
multed[105] = input_buffer[3599:3590] * 17'd7;
multed[106] = input_buffer[3589:3580] * 17'd19;
multed[107] = input_buffer[3579:3570] * 17'd19;
multed[108] = input_buffer[3569:3560] * 17'd11;
multed[109] = input_buffer[3559:3550] * 17'd2;
multed[110] = input_buffer[3549:3540] * -17'd1;
multed[111] = input_buffer[3539:3530] * 17'd3;
multed[112] = input_buffer[3529:3520] * 17'd11;
multed[113] = input_buffer[3519:3510] * 17'd16;
multed[114] = input_buffer[3509:3500] * 17'd10;
multed[115] = input_buffer[3499:3490] * -17'd7;
multed[116] = input_buffer[3489:3480] * -17'd29;
multed[117] = input_buffer[3479:3470] * -17'd46;
multed[118] = input_buffer[3469:3460] * -17'd46;
multed[119] = input_buffer[3459:3450] * -17'd24;
multed[120] = input_buffer[3449:3440] * 17'd15;
multed[121] = input_buffer[3439:3430] * 17'd56;
multed[122] = input_buffer[3429:3420] * 17'd81;
multed[123] = input_buffer[3419:3410] * 17'd76;
multed[124] = input_buffer[3409:3400] * 17'd37;
multed[125] = input_buffer[3399:3390] * -17'd24;
multed[126] = input_buffer[3389:3380] * -17'd83;
multed[127] = input_buffer[3379:3370] * -17'd116;
multed[128] = input_buffer[3369:3360] * -17'd105;
multed[129] = input_buffer[3359:3350] * -17'd50;
multed[130] = input_buffer[3349:3340] * 17'd32;
multed[131] = input_buffer[3339:3330] * 17'd109;
multed[132] = input_buffer[3329:3320] * 17'd148;
multed[133] = input_buffer[3319:3310] * 17'd131;
multed[134] = input_buffer[3309:3300] * 17'd60;
multed[135] = input_buffer[3299:3290] * -17'd39;
multed[136] = input_buffer[3289:3280] * -17'd130;
multed[137] = input_buffer[3279:3270] * -17'd173;
multed[138] = input_buffer[3269:3260] * -17'd151;
multed[139] = input_buffer[3259:3250] * -17'd68;
multed[140] = input_buffer[3249:3240] * 17'd45;
multed[141] = input_buffer[3239:3230] * 17'd144;
multed[142] = input_buffer[3229:3220] * 17'd190;
multed[143] = input_buffer[3219:3210] * 17'd162;
multed[144] = input_buffer[3209:3200] * 17'd71;
multed[145] = input_buffer[3199:3190] * -17'd48;
multed[146] = input_buffer[3189:3180] * -17'd150;
multed[147] = input_buffer[3179:3170] * -17'd194;
multed[148] = input_buffer[3169:3160] * -17'd163;
multed[149] = input_buffer[3159:3150] * -17'd70;
multed[150] = input_buffer[3149:3140] * 17'd48;
multed[151] = input_buffer[3139:3130] * 17'd145;
multed[152] = input_buffer[3129:3120] * 17'd184;
multed[153] = input_buffer[3119:3110] * 17'd152;
multed[154] = input_buffer[3109:3100] * 17'd64;
multed[155] = input_buffer[3099:3090] * -17'd44;
multed[156] = input_buffer[3089:3080] * -17'd128;
multed[157] = input_buffer[3079:3070] * -17'd159;
multed[158] = input_buffer[3069:3060] * -17'd127;
multed[159] = input_buffer[3059:3050] * -17'd51;
multed[160] = input_buffer[3049:3040] * 17'd35;
multed[161] = input_buffer[3039:3030] * 17'd98;
multed[162] = input_buffer[3029:3020] * 17'd116;
multed[163] = input_buffer[3019:3010] * 17'd88;
multed[164] = input_buffer[3009:3000] * 17'd33;
multed[165] = input_buffer[2999:2990] * -17'd22;
multed[166] = input_buffer[2989:2980] * -17'd55;
multed[167] = input_buffer[2979:2970] * -17'd57;
multed[168] = input_buffer[2969:2960] * -17'd36;
multed[169] = input_buffer[2959:2950] * -17'd10;
multed[170] = input_buffer[2949:2940] * 17'd4;
multed[171] = input_buffer[2939:2930] * -17'd2;
multed[172] = input_buffer[2929:2920] * -17'd19;
multed[173] = input_buffer[2919:2910] * -17'd30;
multed[174] = input_buffer[2909:2900] * -17'd19;
multed[175] = input_buffer[2899:2890] * 17'd19;
multed[176] = input_buffer[2889:2880] * 17'd71;
multed[177] = input_buffer[2879:2870] * 17'd110;
multed[178] = input_buffer[2869:2860] * 17'd108;
multed[179] = input_buffer[2859:2850] * 17'd52;
multed[180] = input_buffer[2849:2840] * -17'd47;
multed[181] = input_buffer[2839:2830] * -17'd151;
multed[182] = input_buffer[2829:2820] * -17'd214;
multed[183] = input_buffer[2819:2810] * -17'd196;
multed[184] = input_buffer[2809:2800] * -17'd88;
multed[185] = input_buffer[2799:2790] * 17'd78;
multed[186] = input_buffer[2789:2780] * 17'd240;
multed[187] = input_buffer[2779:2770] * 17'd327;
multed[188] = input_buffer[2769:2760] * 17'd290;
multed[189] = input_buffer[2759:2750] * 17'd126;
multed[190] = input_buffer[2749:2740] * -17'd111;
multed[191] = input_buffer[2739:2730] * -17'd333;
multed[192] = input_buffer[2729:2720] * -17'd445;
multed[193] = input_buffer[2719:2710] * -17'd387;
multed[194] = input_buffer[2709:2700] * -17'd165;
multed[195] = input_buffer[2699:2690] * 17'd147;
multed[196] = input_buffer[2689:2680] * 17'd429;
multed[197] = input_buffer[2679:2670] * 17'd564;
multed[198] = input_buffer[2669:2660] * 17'd484;
multed[199] = input_buffer[2659:2650] * 17'd202;
multed[200] = input_buffer[2649:2640] * -17'd183;
multed[201] = input_buffer[2639:2630] * -17'd523;
multed[202] = input_buffer[2629:2620] * -17'd680;
multed[203] = input_buffer[2619:2610] * -17'd577;
multed[204] = input_buffer[2609:2600] * -17'd237;
multed[205] = input_buffer[2599:2590] * 17'd217;
multed[206] = input_buffer[2589:2580] * 17'd613;
multed[207] = input_buffer[2579:2570] * 17'd788;
multed[208] = input_buffer[2569:2560] * 17'd662;
multed[209] = input_buffer[2559:2550] * 17'd269;
multed[210] = input_buffer[2549:2540] * -17'd249;
multed[211] = input_buffer[2539:2530] * -17'd693;
multed[212] = input_buffer[2529:2520] * -17'd883;
multed[213] = input_buffer[2519:2510] * -17'd736;
multed[214] = input_buffer[2509:2500] * -17'd294;
multed[215] = input_buffer[2499:2490] * 17'd278;
multed[216] = input_buffer[2489:2480] * 17'd761;
multed[217] = input_buffer[2479:2470] * 17'd962;
multed[218] = input_buffer[2469:2460] * 17'd795;
multed[219] = input_buffer[2459:2450] * 17'd314;
multed[220] = input_buffer[2449:2440] * -17'd301;
multed[221] = input_buffer[2439:2430] * -17'd813;
multed[222] = input_buffer[2429:2420] * -17'd1021;
multed[223] = input_buffer[2419:2410] * -17'd837;
multed[224] = input_buffer[2409:2400] * -17'd326;
multed[225] = input_buffer[2399:2390] * 17'd318;
multed[226] = input_buffer[2389:2380] * 17'd848;
multed[227] = input_buffer[2379:2370] * 17'd1057;
multed[228] = input_buffer[2369:2360] * 17'd861;
multed[229] = input_buffer[2359:2350] * 17'd331;
multed[230] = input_buffer[2349:2340] * -17'd329;
multed[231] = input_buffer[2339:2330] * -17'd865;
multed[232] = input_buffer[2329:2320] * 17'd31698;
multed[233] = input_buffer[2319:2310] * -17'd865;
multed[234] = input_buffer[2309:2300] * -17'd329;
multed[235] = input_buffer[2299:2290] * 17'd331;
multed[236] = input_buffer[2289:2280] * 17'd861;
multed[237] = input_buffer[2279:2270] * 17'd1057;
multed[238] = input_buffer[2269:2260] * 17'd848;
multed[239] = input_buffer[2259:2250] * 17'd318;
multed[240] = input_buffer[2249:2240] * -17'd326;
multed[241] = input_buffer[2239:2230] * -17'd837;
multed[242] = input_buffer[2229:2220] * -17'd1021;
multed[243] = input_buffer[2219:2210] * -17'd813;
multed[244] = input_buffer[2209:2200] * -17'd301;
multed[245] = input_buffer[2199:2190] * 17'd314;
multed[246] = input_buffer[2189:2180] * 17'd795;
multed[247] = input_buffer[2179:2170] * 17'd962;
multed[248] = input_buffer[2169:2160] * 17'd761;
multed[249] = input_buffer[2159:2150] * 17'd278;
multed[250] = input_buffer[2149:2140] * -17'd294;
multed[251] = input_buffer[2139:2130] * -17'd736;
multed[252] = input_buffer[2129:2120] * -17'd883;
multed[253] = input_buffer[2119:2110] * -17'd693;
multed[254] = input_buffer[2109:2100] * -17'd249;
multed[255] = input_buffer[2099:2090] * 17'd269;
multed[256] = input_buffer[2089:2080] * 17'd662;
multed[257] = input_buffer[2079:2070] * 17'd788;
multed[258] = input_buffer[2069:2060] * 17'd613;
multed[259] = input_buffer[2059:2050] * 17'd217;
multed[260] = input_buffer[2049:2040] * -17'd237;
multed[261] = input_buffer[2039:2030] * -17'd577;
multed[262] = input_buffer[2029:2020] * -17'd680;
multed[263] = input_buffer[2019:2010] * -17'd523;
multed[264] = input_buffer[2009:2000] * -17'd183;
multed[265] = input_buffer[1999:1990] * 17'd202;
multed[266] = input_buffer[1989:1980] * 17'd484;
multed[267] = input_buffer[1979:1970] * 17'd564;
multed[268] = input_buffer[1969:1960] * 17'd429;
multed[269] = input_buffer[1959:1950] * 17'd147;
multed[270] = input_buffer[1949:1940] * -17'd165;
multed[271] = input_buffer[1939:1930] * -17'd387;
multed[272] = input_buffer[1929:1920] * -17'd445;
multed[273] = input_buffer[1919:1910] * -17'd333;
multed[274] = input_buffer[1909:1900] * -17'd111;
multed[275] = input_buffer[1899:1890] * 17'd126;
multed[276] = input_buffer[1889:1880] * 17'd290;
multed[277] = input_buffer[1879:1870] * 17'd327;
multed[278] = input_buffer[1869:1860] * 17'd240;
multed[279] = input_buffer[1859:1850] * 17'd78;
multed[280] = input_buffer[1849:1840] * -17'd88;
multed[281] = input_buffer[1839:1830] * -17'd196;
multed[282] = input_buffer[1829:1820] * -17'd214;
multed[283] = input_buffer[1819:1810] * -17'd151;
multed[284] = input_buffer[1809:1800] * -17'd47;
multed[285] = input_buffer[1799:1790] * 17'd52;
multed[286] = input_buffer[1789:1780] * 17'd108;
multed[287] = input_buffer[1779:1770] * 17'd110;
multed[288] = input_buffer[1769:1760] * 17'd71;
multed[289] = input_buffer[1759:1750] * 17'd19;
multed[290] = input_buffer[1749:1740] * -17'd19;
multed[291] = input_buffer[1739:1730] * -17'd30;
multed[292] = input_buffer[1729:1720] * -17'd19;
multed[293] = input_buffer[1719:1710] * -17'd2;
multed[294] = input_buffer[1709:1700] * 17'd4;
multed[295] = input_buffer[1699:1690] * -17'd10;
multed[296] = input_buffer[1689:1680] * -17'd36;
multed[297] = input_buffer[1679:1670] * -17'd57;
multed[298] = input_buffer[1669:1660] * -17'd55;
multed[299] = input_buffer[1659:1650] * -17'd22;
multed[300] = input_buffer[1649:1640] * 17'd33;
multed[301] = input_buffer[1639:1630] * 17'd88;
multed[302] = input_buffer[1629:1620] * 17'd116;
multed[303] = input_buffer[1619:1610] * 17'd98;
multed[304] = input_buffer[1609:1600] * 17'd35;
multed[305] = input_buffer[1599:1590] * -17'd51;
multed[306] = input_buffer[1589:1580] * -17'd127;
multed[307] = input_buffer[1579:1570] * -17'd159;
multed[308] = input_buffer[1569:1560] * -17'd128;
multed[309] = input_buffer[1559:1550] * -17'd44;
multed[310] = input_buffer[1549:1540] * 17'd64;
multed[311] = input_buffer[1539:1530] * 17'd152;
multed[312] = input_buffer[1529:1520] * 17'd184;
multed[313] = input_buffer[1519:1510] * 17'd145;
multed[314] = input_buffer[1509:1500] * 17'd48;
multed[315] = input_buffer[1499:1490] * -17'd70;
multed[316] = input_buffer[1489:1480] * -17'd163;
multed[317] = input_buffer[1479:1470] * -17'd194;
multed[318] = input_buffer[1469:1460] * -17'd150;
multed[319] = input_buffer[1459:1450] * -17'd48;
multed[320] = input_buffer[1449:1440] * 17'd71;
multed[321] = input_buffer[1439:1430] * 17'd162;
multed[322] = input_buffer[1429:1420] * 17'd190;
multed[323] = input_buffer[1419:1410] * 17'd144;
multed[324] = input_buffer[1409:1400] * 17'd45;
multed[325] = input_buffer[1399:1390] * -17'd68;
multed[326] = input_buffer[1389:1380] * -17'd151;
multed[327] = input_buffer[1379:1370] * -17'd173;
multed[328] = input_buffer[1369:1360] * -17'd130;
multed[329] = input_buffer[1359:1350] * -17'd39;
multed[330] = input_buffer[1349:1340] * 17'd60;
multed[331] = input_buffer[1339:1330] * 17'd131;
multed[332] = input_buffer[1329:1320] * 17'd148;
multed[333] = input_buffer[1319:1310] * 17'd109;
multed[334] = input_buffer[1309:1300] * 17'd32;
multed[335] = input_buffer[1299:1290] * -17'd50;
multed[336] = input_buffer[1289:1280] * -17'd105;
multed[337] = input_buffer[1279:1270] * -17'd116;
multed[338] = input_buffer[1269:1260] * -17'd83;
multed[339] = input_buffer[1259:1250] * -17'd24;
multed[340] = input_buffer[1249:1240] * 17'd37;
multed[341] = input_buffer[1239:1230] * 17'd76;
multed[342] = input_buffer[1229:1220] * 17'd81;
multed[343] = input_buffer[1219:1210] * 17'd56;
multed[344] = input_buffer[1209:1200] * 17'd15;
multed[345] = input_buffer[1199:1190] * -17'd24;
multed[346] = input_buffer[1189:1180] * -17'd46;
multed[347] = input_buffer[1179:1170] * -17'd46;
multed[348] = input_buffer[1169:1160] * -17'd29;
multed[349] = input_buffer[1159:1150] * -17'd7;
multed[350] = input_buffer[1149:1140] * 17'd10;
multed[351] = input_buffer[1139:1130] * 17'd16;
multed[352] = input_buffer[1129:1120] * 17'd11;
multed[353] = input_buffer[1119:1110] * 17'd3;
multed[354] = input_buffer[1109:1100] * -17'd1;
multed[355] = input_buffer[1099:1090] * 17'd2;
multed[356] = input_buffer[1089:1080] * 17'd11;
multed[357] = input_buffer[1079:1070] * 17'd19;
multed[358] = input_buffer[1069:1060] * 17'd19;
multed[359] = input_buffer[1059:1050] * 17'd7;
multed[360] = input_buffer[1049:1040] * -17'd13;
multed[361] = input_buffer[1039:1030] * -17'd34;
multed[362] = input_buffer[1029:1020] * -17'd44;
multed[363] = input_buffer[1019:1010] * -17'd37;
multed[364] = input_buffer[1009:1000] * -17'd12;
multed[365] = input_buffer[999:990] * 17'd22;
multed[366] = input_buffer[989:980] * 17'd51;
multed[367] = input_buffer[979:970] * 17'd63;
multed[368] = input_buffer[969:960] * 17'd50;
multed[369] = input_buffer[959:950] * 17'd15;
multed[370] = input_buffer[949:940] * -17'd29;
multed[371] = input_buffer[939:930] * -17'd63;
multed[372] = input_buffer[929:920] * -17'd75;
multed[373] = input_buffer[919:910] * -17'd57;
multed[374] = input_buffer[909:900] * -17'd16;
multed[375] = input_buffer[899:890] * 17'd32;
multed[376] = input_buffer[889:880] * 17'd69;
multed[377] = input_buffer[879:870] * 17'd80;
multed[378] = input_buffer[869:860] * 17'd60;
multed[379] = input_buffer[859:850] * 17'd16;
multed[380] = input_buffer[849:840] * -17'd34;
multed[381] = input_buffer[839:830] * -17'd70;
multed[382] = input_buffer[829:820] * -17'd80;
multed[383] = input_buffer[819:810] * -17'd58;
multed[384] = input_buffer[809:800] * -17'd15;
multed[385] = input_buffer[799:790] * 17'd33;
multed[386] = input_buffer[789:780] * 17'd66;
multed[387] = input_buffer[779:770] * 17'd73;
multed[388] = input_buffer[769:760] * 17'd52;
multed[389] = input_buffer[759:750] * 17'd13;
multed[390] = input_buffer[749:740] * -17'd29;
multed[391] = input_buffer[739:730] * -17'd58;
multed[392] = input_buffer[729:720] * -17'd63;
multed[393] = input_buffer[719:710] * -17'd44;
multed[394] = input_buffer[709:700] * -17'd10;
multed[395] = input_buffer[699:690] * 17'd25;
multed[396] = input_buffer[689:680] * 17'd47;
multed[397] = input_buffer[679:670] * 17'd49;
multed[398] = input_buffer[669:660] * 17'd33;
multed[399] = input_buffer[659:650] * 17'd7;
multed[400] = input_buffer[649:640] * -17'd19;
multed[401] = input_buffer[639:630] * -17'd34;
multed[402] = input_buffer[629:620] * -17'd34;
multed[403] = input_buffer[619:610] * -17'd21;
multed[404] = input_buffer[609:600] * -17'd3;
multed[405] = input_buffer[599:590] * 17'd13;
multed[406] = input_buffer[589:580] * 17'd21;
multed[407] = input_buffer[579:570] * 17'd19;
multed[408] = input_buffer[569:560] * 17'd10;
multed[409] = input_buffer[559:550] * -17'd1;
multed[410] = input_buffer[549:540] * -17'd7;
multed[411] = input_buffer[539:530] * -17'd7;
multed[412] = input_buffer[529:520] * -17'd4;
multed[413] = input_buffer[519:510] * 17'd1;
multed[414] = input_buffer[509:500] * 17'd3;
multed[415] = input_buffer[499:490] * 17'd1;
multed[416] = input_buffer[489:480] * -17'd4;
multed[417] = input_buffer[479:470] * -17'd10;
multed[418] = input_buffer[469:460] * -17'd11;
multed[419] = input_buffer[459:450] * -17'd6;
multed[420] = input_buffer[449:440] * 17'd4;
multed[421] = input_buffer[439:430] * 17'd15;
multed[422] = input_buffer[429:420] * 17'd21;
multed[423] = input_buffer[419:410] * 17'd19;
multed[424] = input_buffer[409:400] * 17'd8;
multed[425] = input_buffer[399:390] * -17'd9;
multed[426] = input_buffer[389:380] * -17'd24;
multed[427] = input_buffer[379:370] * -17'd31;
multed[428] = input_buffer[369:360] * -17'd25;
multed[429] = input_buffer[359:350] * -17'd9;
multed[430] = input_buffer[349:340] * 17'd13;
multed[431] = input_buffer[339:330] * 17'd31;
multed[432] = input_buffer[329:320] * 17'd38;
multed[433] = input_buffer[319:310] * 17'd29;
multed[434] = input_buffer[309:300] * 17'd8;
multed[435] = input_buffer[299:290] * -17'd18;
multed[436] = input_buffer[289:280] * -17'd37;
multed[437] = input_buffer[279:270] * -17'd43;
multed[438] = input_buffer[269:260] * -17'd31;
multed[439] = input_buffer[259:250] * -17'd6;
multed[440] = input_buffer[249:240] * 17'd22;
multed[441] = input_buffer[239:230] * 17'd41;
multed[442] = input_buffer[229:220] * 17'd44;
multed[443] = input_buffer[219:210] * 17'd29;
multed[444] = input_buffer[209:200] * 17'd0;
multed[445] = input_buffer[199:190] * -17'd30;
multed[446] = input_buffer[189:180] * -17'd49;
multed[447] = input_buffer[179:170] * -17'd49;
multed[448] = input_buffer[169:160] * -17'd29;
multed[449] = input_buffer[159:150] * 17'd3;
multed[450] = input_buffer[149:140] * 17'd32;
multed[451] = input_buffer[139:130] * 17'd45;
multed[452] = input_buffer[129:120] * 17'd35;
multed[453] = input_buffer[119:110] * 17'd4;
multed[454] = input_buffer[109:100] * -17'd37;
multed[455] = input_buffer[99:90] * -17'd70;
multed[456] = input_buffer[89:80] * -17'd80;
multed[457] = input_buffer[79:70] * -17'd61;
multed[458] = input_buffer[69:60] * -17'd21;
multed[459] = input_buffer[59:50] * 17'd15;
multed[460] = input_buffer[49:40] * 17'd20;
multed[461] = input_buffer[39:30] * -17'd37;
multed[462] = input_buffer[29:20] * -17'd169;
multed[463] = input_buffer[19:10] * -17'd373;
multed[464] = input_buffer[9:0] * 17'd442;		// This coefficient should be multiplied with the most recent data input

		trigger = 1'b1;
		
		end
	end
	
	always @(trigger)
	begin
		trigger2 = ~trigger2;
	end

	always @(trigger2)
	begin
		if(trigger2 == 1'b0)
		begin
			done = 1'b0;
			out = 0;
		end
		else
		begin
			out = (multed[0] + multed[1] + multed[2] + multed[3] + multed[4] + multed[5] + multed[6] + multed[7] + multed[8] + multed[9] + multed[10] + multed[11] + multed[12] + multed[13] + multed[14] + multed[15] + multed[16] + multed[17] + multed[18] + multed[19] + multed[20] + multed[21] + multed[22] + multed[23] + multed[24] + multed[25] + multed[26] + multed[27] + multed[28] + multed[29] + multed[30] + multed[31] + multed[32] + multed[33] + multed[34] + multed[35] + multed[36] + multed[37] + multed[38] + multed[39] + multed[40] + multed[41] + multed[42] + multed[43] + multed[44] + multed[45] + multed[46] + multed[47] + multed[48] + multed[49] + multed[50] + multed[51] + multed[52] + multed[53] + multed[54] + multed[55] + multed[56] + multed[57] + multed[58] + multed[59] + multed[60] + multed[61] + multed[62] + multed[63] + multed[64] + multed[65] + multed[66] + multed[67] + multed[68] + multed[69] + multed[70] + multed[71] + multed[72] + multed[73] + multed[74] + multed[75] + multed[76] + multed[77] + multed[78] + multed[79] + multed[80] + multed[81] + multed[82] + multed[83] + multed[84] + multed[85] + multed[86] + multed[87] + multed[88] + multed[89] + multed[90] + multed[91] + multed[92] + multed[93] + multed[94] + multed[95] + multed[96] + multed[97] + multed[98] + multed[99] + multed[100] + multed[101] + multed[102] + multed[103] + multed[104] + multed[105] + multed[106] + multed[107] + multed[108] + multed[109] + multed[110] + multed[111] + multed[112] + multed[113] + multed[114] + multed[115] + multed[116] + multed[117] + multed[118] + multed[119] + multed[120] + multed[121] + multed[122] + multed[123] + multed[124] + multed[125] + multed[126] + multed[127] + multed[128] + multed[129] + multed[130] + multed[131] + multed[132] + multed[133] + multed[134] + multed[135] + multed[136] + multed[137] + multed[138] + multed[139] + multed[140] + multed[141] + multed[142] + multed[143] + multed[144] + multed[145] + multed[146] + multed[147] + multed[148] + multed[149] + multed[150] + multed[151] + multed[152] + multed[153] + multed[154] + multed[155] + multed[156] + multed[157] + multed[158] + multed[159] + multed[160] + multed[161] + multed[162] + multed[163] + multed[164] + multed[165] + multed[166] + multed[167] + multed[168] + multed[169] + multed[170] + multed[171] + multed[172] + multed[173] + multed[174] + multed[175] + multed[176] + multed[177] + multed[178] + multed[179] + multed[180] + multed[181] + multed[182] + multed[183] + multed[184] + multed[185] + multed[186] + multed[187] + multed[188] + multed[189] + multed[190] + multed[191] + multed[192] + multed[193] + multed[194] + multed[195] + multed[196] + multed[197] + multed[198] + multed[199] + multed[200] + multed[201] + multed[202] + multed[203] + multed[204] + multed[205] + multed[206] + multed[207] + multed[208] + multed[209] + multed[210] + multed[211] + multed[212] + multed[213] + multed[214] + multed[215] + multed[216] + multed[217] + multed[218] + multed[219] + multed[220] + multed[221] + multed[222] + multed[223] + multed[224] + multed[225] + multed[226] + multed[227] + multed[228] + multed[229] + multed[230] + multed[231] + multed[232] + multed[233] + multed[234] + multed[235] + multed[236] + multed[237] + multed[238] + multed[239] + multed[240] + multed[241] + multed[242] + multed[243] + multed[244] + multed[245] + multed[246] + multed[247] + multed[248] + multed[249] + multed[250] + multed[251] + multed[252] + multed[253] + multed[254] + multed[255] + multed[256] + multed[257] + multed[258] + multed[259] + multed[260] + multed[261] + multed[262] + multed[263] + multed[264] + multed[265] + multed[266] + multed[267] + multed[268] + multed[269] + multed[270] + multed[271] + multed[272] + multed[273] + multed[274] + multed[275] + multed[276] + multed[277] + multed[278] + multed[279] + multed[280] + multed[281] + multed[282] + multed[283] + multed[284] + multed[285] + multed[286] + multed[287] + multed[288] + multed[289] + multed[290] + multed[291] + multed[292] + multed[293] + multed[294] + multed[295] + multed[296] + multed[297] + multed[298] + multed[299] + multed[300] + multed[301] + multed[302] + multed[303] + multed[304] + multed[305] + multed[306] + multed[307] + multed[308] + multed[309] + multed[310] + multed[311] + multed[312] + multed[313] + multed[314] + multed[315] + multed[316] + multed[317] + multed[318] + multed[319] + multed[320] + multed[321] + multed[322] + multed[323] + multed[324] + multed[325] + multed[326] + multed[327] + multed[328] + multed[329] + multed[330] + multed[331] + multed[332] + multed[333] + multed[334] + multed[335] + multed[336] + multed[337] + multed[338] + multed[339] + multed[340] + multed[341] + multed[342] + multed[343] + multed[344] + multed[345] + multed[346] + multed[347] + multed[348] + multed[349] + multed[350] + multed[351] + multed[352] + multed[353] + multed[354] + multed[355] + multed[356] + multed[357] + multed[358] + multed[359] + multed[360] + multed[361] + multed[362] + multed[363] + multed[364] + multed[365] + multed[366] + multed[367] + multed[368] + multed[369] + multed[370] + multed[371] + multed[372] + multed[373] + multed[374] + multed[375] + multed[376] + multed[377] + multed[378] + multed[379] + multed[380] + multed[381] + multed[382] + multed[383] + multed[384] + multed[385] + multed[386] + multed[387] + multed[388] + multed[389] + multed[390] + multed[391] + multed[392] + multed[393] + multed[394] + multed[395] + multed[396] + multed[397] + multed[398] + multed[399] + multed[400] + multed[401] + multed[402] + multed[403] + multed[404] + multed[405] + multed[406] + multed[407] + multed[408] + multed[409] + multed[410] + multed[411] + multed[412] + multed[413] + multed[414] + multed[415] + multed[416] + multed[417] + multed[418] + multed[419] + multed[420] + multed[421] + multed[422] + multed[423] + multed[424] + multed[425] + multed[426] + multed[427] + multed[428] + multed[429] + multed[430] + multed[431] + multed[432] + multed[433] + multed[434] + multed[435] + multed[436] + multed[437] + multed[438] + multed[439] + multed[440] + multed[441] + multed[442] + multed[443] + multed[444] + multed[445] + multed[446] + multed[447] + multed[448] + multed[449] + multed[450] + multed[451] + multed[452] + multed[453] + multed[454] + multed[455] + multed[456] + multed[457] + multed[458] + multed[459] + multed[460] + multed[461] + multed[462] + multed[463] + multed[464]) >> 15;
			done = 1'b1;
		end
	end
	
endmodule
