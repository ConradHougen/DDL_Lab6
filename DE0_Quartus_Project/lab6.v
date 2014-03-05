
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
// if the filtered data is between 40 and 60 (representing a '.').
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
module lab6 (clk, hndshk, reset, dataIn, dataOut, LED1, LED_CLK, clk_out, LED_dataIN); 
							
	// NUMBER OF COEFFICIENTS (465)
	// 	(Change this to a small value for initial testing and debugging, 
	// 	otherwise it will take ~4 minutes to load your program on the FPGA.)
	parameter NUMCOEFFICIENTS = 465;

	// define inputs and outputs
	input clk, hndshk, reset, dataIn;
	output reg dataOut, clk_out;
	output reg LED1;
	output LED_CLK, LED_dataIN;
	//reg [4:0] bits_in_buffer;
	
	assign LED_CLK = clk;
	assign LED_dataIN = dataIn;
	
	// store the input data by shifting into register
	reg [16:0] dataInReg;
	// toggle var to keep track of handshake
	reg dataRcvd; // have we received any data
	
	// DEFINE ALL REGISTERS AND WIRES HERE
	reg 		[11:0]	coeffIndex;		// Coefficient index of FIR filter
	reg signed 	[16:0] 	coefficient;	// Coefficient of FIR filter for index coeffIndex
	reg signed 	[16:0] 	out;			// Register used for coefficient calculation
	// Add more here...
	//reg signed [464:0] buffer[9:0]; // buffer to store all 465 current inputs
	//output reg [16:0] filtered_val; // result value after filtering and summing
	
	
	initial
	begin
		dataRcvd <= 1'b0;
		dataInReg <= 17'b0;
		dataOut <= 1'b0;
		clk_out <= 1'b0;
		//bits_in_buffer <= 5'b0;
	end


	// BLOCK 1: READ INPUT VALUE (16 bit stream)
	//////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	always @(posedge clk or negedge reset)
	begin
		if(reset == 1'b0)
		begin
			dataRcvd <= 1'b0;
			dataInReg <= 17'b0;
			dataOut <= 1'b0;
			LED1 <= 1'b0;
			//bits_in_buffer <= 5'b0;
			
			coefficient	<= 17'd0;
			coeffIndex <= 12'b0;
			out <= 17'b0;
		end
		else
		begin
			// handshake is high, so read data
			if(hndshk == 1'b1)
			begin
				// shift the current data left one bit, and add on the next serial data bit
				dataInReg <= ((dataInReg << 1) + dataIn);
				dataRcvd <= 1'b1;
				//bits_in_buffer <= bits_in_buffer + 1'b1;
				// turn on the LED based on dataIn
				LED1 <= dataIn;
			end
			// if handshake is low and we have data to send back
			else if(hndshk == 1'b0 && dataRcvd == 1'b1)
			begin
				LED1 <= 1'b0;
				// write the data back out to the LPC Xpresso
				dataOut = dataInReg[0];
				dataInReg = (dataInReg >> 1); // flush one bit from storage
				//bits_in_buffer = bits_in_buffer - 1'b1;
				// toggle the output clock
				clk_out = ~clk_out;
			end
		end
	end


	// BLOCK 2: CALCULATING OUTPUT Y
	//////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////
	


	// BLOCK 3: CALCULATING COEFFICIENT
	//////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	// Calculate the next coefficient here
	/*
	always @ (negedge hndshk) // Define always statement as you wish...
  	begin  	
		
		// Reset values
		
		if (reset)
		begin
			coefficient	= 17'd0;
		end
		
		// Calculate coefficient based on the coeffIndex value. Note that coeffIndex is a signed value!
		// (Note: These don't necessarily have to be blocking statements.)
    	case ( coeffIndex )
		
			12'd0: out = 17'd442;	// This coefficient should be multiplied with the oldest input value
			12'd1: out = -17'd373;
			12'd2: out = -17'd169;
			12'd3: out = -17'd37;
			12'd4: out = 17'd20;
			12'd5: out = 17'd15;
			12'd6: out = -17'd21;
			12'd7: out = -17'd61;
			12'd8: out = -17'd80;
			12'd9: out = -17'd70;
			12'd10: out = -17'd37;
			12'd11: out = 17'd4;
			12'd12: out = 17'd35;
			12'd13: out = 17'd45;
			12'd14: out = 17'd32;
			12'd15: out = 17'd3;
			12'd16: out = -17'd29;
			12'd17: out = -17'd49;
			12'd18: out = -17'd49;
			12'd19: out = -17'd30;
			12'd20: out = 17'd0;
			12'd21: out = 17'd29;
			12'd22: out = 17'd44;
			12'd23: out = 17'd41;
			12'd24: out = 17'd22;
			12'd25: out = -17'd6;
			12'd26: out = -17'd31;
			12'd27: out = -17'd43;
			12'd28: out = -17'd37;
			12'd29: out = -17'd18;
			12'd30: out = 17'd8;
			12'd31: out = 17'd29;
			12'd32: out = 17'd38;
			12'd33: out = 17'd31;
			12'd34: out = 17'd13;
			12'd35: out = -17'd9;
			12'd36: out = -17'd25;
			12'd37: out = -17'd31;
			12'd38: out = -17'd24;
			12'd39: out = -17'd9;
			12'd40: out = 17'd8;
			12'd41: out = 17'd19;
			12'd42: out = 17'd21;
			12'd43: out = 17'd15;
			12'd44: out = 17'd4;
			12'd45: out = -17'd6;
			12'd46: out = -17'd11;
			12'd47: out = -17'd10;
			12'd48: out = -17'd4;
			12'd49: out = 17'd1;
			12'd50: out = 17'd3;
			12'd51: out = 17'd1;
			12'd52: out = -17'd4;
			12'd53: out = -17'd7;
			12'd54: out = -17'd7;
			12'd55: out = -17'd1;
			12'd56: out = 17'd10;
			12'd57: out = 17'd19;
			12'd58: out = 17'd21;
			12'd59: out = 17'd13;
			12'd60: out = -17'd3;
			12'd61: out = -17'd21;
			12'd62: out = -17'd34;
			12'd63: out = -17'd34;
			12'd64: out = -17'd19;
			12'd65: out = 17'd7;
			12'd66: out = 17'd33;
			12'd67: out = 17'd49;
			12'd68: out = 17'd47;
			12'd69: out = 17'd25;
			12'd70: out = -17'd10;
			12'd71: out = -17'd44;
			12'd72: out = -17'd63;
			12'd73: out = -17'd58;
			12'd74: out = -17'd29;
			12'd75: out = 17'd13;
			12'd76: out = 17'd52;
			12'd77: out = 17'd73;
			12'd78: out = 17'd66;
			12'd79: out = 17'd33;
			12'd80: out = -17'd15;
			12'd81: out = -17'd58;
			12'd82: out = -17'd80;
			12'd83: out = -17'd70;
			12'd84: out = -17'd34;
			12'd85: out = 17'd16;
			12'd86: out = 17'd60;
			12'd87: out = 17'd80;
			12'd88: out = 17'd69;
			12'd89: out = 17'd32;
			12'd90: out = -17'd16;
			12'd91: out = -17'd57;
			12'd92: out = -17'd75;
			12'd93: out = -17'd63;
			12'd94: out = -17'd29;
			12'd95: out = 17'd15;
			12'd96: out = 17'd50;
			12'd97: out = 17'd63;
			12'd98: out = 17'd51;
			12'd99: out = 17'd22;
			12'd100: out = -17'd12;
			12'd101: out = -17'd37;
			12'd102: out = -17'd44;
			12'd103: out = -17'd34;
			12'd104: out = -17'd13;
			12'd105: out = 17'd7;
			12'd106: out = 17'd19;
			12'd107: out = 17'd19;
			12'd108: out = 17'd11;
			12'd109: out = 17'd2;
			12'd110: out = -17'd1;
			12'd111: out = 17'd3;
			12'd112: out = 17'd11;
			12'd113: out = 17'd16;
			12'd114: out = 17'd10;
			12'd115: out = -17'd7;
			12'd116: out = -17'd29;
			12'd117: out = -17'd46;
			12'd118: out = -17'd46;
			12'd119: out = -17'd24;
			12'd120: out = 17'd15;
			12'd121: out = 17'd56;
			12'd122: out = 17'd81;
			12'd123: out = 17'd76;
			12'd124: out = 17'd37;
			12'd125: out = -17'd24;
			12'd126: out = -17'd83;
			12'd127: out = -17'd116;
			12'd128: out = -17'd105;
			12'd129: out = -17'd50;
			12'd130: out = 17'd32;
			12'd131: out = 17'd109;
			12'd132: out = 17'd148;
			12'd133: out = 17'd131;
			12'd134: out = 17'd60;
			12'd135: out = -17'd39;
			12'd136: out = -17'd130;
			12'd137: out = -17'd173;
			12'd138: out = -17'd151;
			12'd139: out = -17'd68;
			12'd140: out = 17'd45;
			12'd141: out = 17'd144;
			12'd142: out = 17'd190;
			12'd143: out = 17'd162;
			12'd144: out = 17'd71;
			12'd145: out = -17'd48;
			12'd146: out = -17'd150;
			12'd147: out = -17'd194;
			12'd148: out = -17'd163;
			12'd149: out = -17'd70;
			12'd150: out = 17'd48;
			12'd151: out = 17'd145;
			12'd152: out = 17'd184;
			12'd153: out = 17'd152;
			12'd154: out = 17'd64;
			12'd155: out = -17'd44;
			12'd156: out = -17'd128;
			12'd157: out = -17'd159;
			12'd158: out = -17'd127;
			12'd159: out = -17'd51;
			12'd160: out = 17'd35;
			12'd161: out = 17'd98;
			12'd162: out = 17'd116;
			12'd163: out = 17'd88;
			12'd164: out = 17'd33;
			12'd165: out = -17'd22;
			12'd166: out = -17'd55;
			12'd167: out = -17'd57;
			12'd168: out = -17'd36;
			12'd169: out = -17'd10;
			12'd170: out = 17'd4;
			12'd171: out = -17'd2;
			12'd172: out = -17'd19;
			12'd173: out = -17'd30;
			12'd174: out = -17'd19;
			12'd175: out = 17'd19;
			12'd176: out = 17'd71;
			12'd177: out = 17'd110;
			12'd178: out = 17'd108;
			12'd179: out = 17'd52;
			12'd180: out = -17'd47;
			12'd181: out = -17'd151;
			12'd182: out = -17'd214;
			12'd183: out = -17'd196;
			12'd184: out = -17'd88;
			12'd185: out = 17'd78;
			12'd186: out = 17'd240;
			12'd187: out = 17'd327;
			12'd188: out = 17'd290;
			12'd189: out = 17'd126;
			12'd190: out = -17'd111;
			12'd191: out = -17'd333;
			12'd192: out = -17'd445;
			12'd193: out = -17'd387;
			12'd194: out = -17'd165;
			12'd195: out = 17'd147;
			12'd196: out = 17'd429;
			12'd197: out = 17'd564;
			12'd198: out = 17'd484;
			12'd199: out = 17'd202;
			12'd200: out = -17'd183;
			12'd201: out = -17'd523;
			12'd202: out = -17'd680;
			12'd203: out = -17'd577;
			12'd204: out = -17'd237;
			12'd205: out = 17'd217;
			12'd206: out = 17'd613;
			12'd207: out = 17'd788;
			12'd208: out = 17'd662;
			12'd209: out = 17'd269;
			12'd210: out = -17'd249;
			12'd211: out = -17'd693;
			12'd212: out = -17'd883;
			12'd213: out = -17'd736;
			12'd214: out = -17'd294;
			12'd215: out = 17'd278;
			12'd216: out = 17'd761;
			12'd217: out = 17'd962;
			12'd218: out = 17'd795;
			12'd219: out = 17'd314;
			12'd220: out = -17'd301;
			12'd221: out = -17'd813;
			12'd222: out = -17'd1021;
			12'd223: out = -17'd837;
			12'd224: out = -17'd326;
			12'd225: out = 17'd318;
			12'd226: out = 17'd848;
			12'd227: out = 17'd1057;
			12'd228: out = 17'd861;
			12'd229: out = 17'd331;
			12'd230: out = -17'd329;
			12'd231: out = -17'd865;
			12'd232: out = 17'd31698;
			12'd233: out = -17'd865;
			12'd234: out = -17'd329;
			12'd235: out = 17'd331;
			12'd236: out = 17'd861;
			12'd237: out = 17'd1057;
			12'd238: out = 17'd848;
			12'd239: out = 17'd318;
			12'd240: out = -17'd326;
			12'd241: out = -17'd837;
			12'd242: out = -17'd1021;
			12'd243: out = -17'd813;
			12'd244: out = -17'd301;
			12'd245: out = 17'd314;
			12'd246: out = 17'd795;
			12'd247: out = 17'd962;
			12'd248: out = 17'd761;
			12'd249: out = 17'd278;
			12'd250: out = -17'd294;
			12'd251: out = -17'd736;
			12'd252: out = -17'd883;
			12'd253: out = -17'd693;
			12'd254: out = -17'd249;
			12'd255: out = 17'd269;
			12'd256: out = 17'd662;
			12'd257: out = 17'd788;
			12'd258: out = 17'd613;
			12'd259: out = 17'd217;
			12'd260: out = -17'd237;
			12'd261: out = -17'd577;
			12'd262: out = -17'd680;
			12'd263: out = -17'd523;
			12'd264: out = -17'd183;
			12'd265: out = 17'd202;
			12'd266: out = 17'd484;
			12'd267: out = 17'd564;
			12'd268: out = 17'd429;
			12'd269: out = 17'd147;
			12'd270: out = -17'd165;
			12'd271: out = -17'd387;
			12'd272: out = -17'd445;
			12'd273: out = -17'd333;
			12'd274: out = -17'd111;
			12'd275: out = 17'd126;
			12'd276: out = 17'd290;
			12'd277: out = 17'd327;
			12'd278: out = 17'd240;
			12'd279: out = 17'd78;
			12'd280: out = -17'd88;
			12'd281: out = -17'd196;
			12'd282: out = -17'd214;
			12'd283: out = -17'd151;
			12'd284: out = -17'd47;
			12'd285: out = 17'd52;
			12'd286: out = 17'd108;
			12'd287: out = 17'd110;
			12'd288: out = 17'd71;
			12'd289: out = 17'd19;
			12'd290: out = -17'd19;
			12'd291: out = -17'd30;
			12'd292: out = -17'd19;
			12'd293: out = -17'd2;
			12'd294: out = 17'd4;
			12'd295: out = -17'd10;
			12'd296: out = -17'd36;
			12'd297: out = -17'd57;
			12'd298: out = -17'd55;
			12'd299: out = -17'd22;
			12'd300: out = 17'd33;
			12'd301: out = 17'd88;
			12'd302: out = 17'd116;
			12'd303: out = 17'd98;
			12'd304: out = 17'd35;
			12'd305: out = -17'd51;
			12'd306: out = -17'd127;
			12'd307: out = -17'd159;
			12'd308: out = -17'd128;
			12'd309: out = -17'd44;
			12'd310: out = 17'd64;
			12'd311: out = 17'd152;
			12'd312: out = 17'd184;
			12'd313: out = 17'd145;
			12'd314: out = 17'd48;
			12'd315: out = -17'd70;
			12'd316: out = -17'd163;
			12'd317: out = -17'd194;
			12'd318: out = -17'd150;
			12'd319: out = -17'd48;
			12'd320: out = 17'd71;
			12'd321: out = 17'd162;
			12'd322: out = 17'd190;
			12'd323: out = 17'd144;
			12'd324: out = 17'd45;
			12'd325: out = -17'd68;
			12'd326: out = -17'd151;
			12'd327: out = -17'd173;
			12'd328: out = -17'd130;
			12'd329: out = -17'd39;
			12'd330: out = 17'd60;
			12'd331: out = 17'd131;
			12'd332: out = 17'd148;
			12'd333: out = 17'd109;
			12'd334: out = 17'd32;
			12'd335: out = -17'd50;
			12'd336: out = -17'd105;
			12'd337: out = -17'd116;
			12'd338: out = -17'd83;
			12'd339: out = -17'd24;
			12'd340: out = 17'd37;
			12'd341: out = 17'd76;
			12'd342: out = 17'd81;
			12'd343: out = 17'd56;
			12'd344: out = 17'd15;
			12'd345: out = -17'd24;
			12'd346: out = -17'd46;
			12'd347: out = -17'd46;
			12'd348: out = -17'd29;
			12'd349: out = -17'd7;
			12'd350: out = 17'd10;
			12'd351: out = 17'd16;
			12'd352: out = 17'd11;
			12'd353: out = 17'd3;
			12'd354: out = -17'd1;
			12'd355: out = 17'd2;
			12'd356: out = 17'd11;
			12'd357: out = 17'd19;
			12'd358: out = 17'd19;
			12'd359: out = 17'd7;
			12'd360: out = -17'd13;
			12'd361: out = -17'd34;
			12'd362: out = -17'd44;
			12'd363: out = -17'd37;
			12'd364: out = -17'd12;
			12'd365: out = 17'd22;
			12'd366: out = 17'd51;
			12'd367: out = 17'd63;
			12'd368: out = 17'd50;
			12'd369: out = 17'd15;
			12'd370: out = -17'd29;
			12'd371: out = -17'd63;
			12'd372: out = -17'd75;
			12'd373: out = -17'd57;
			12'd374: out = -17'd16;
			12'd375: out = 17'd32;
			12'd376: out = 17'd69;
			12'd377: out = 17'd80;
			12'd378: out = 17'd60;
			12'd379: out = 17'd16;
			12'd380: out = -17'd34;
			12'd381: out = -17'd70;
			12'd382: out = -17'd80;
			12'd383: out = -17'd58;
			12'd384: out = -17'd15;
			12'd385: out = 17'd33;
			12'd386: out = 17'd66;
			12'd387: out = 17'd73;
			12'd388: out = 17'd52;
			12'd389: out = 17'd13;
			12'd390: out = -17'd29;
			12'd391: out = -17'd58;
			12'd392: out = -17'd63;
			12'd393: out = -17'd44;
			12'd394: out = -17'd10;
			12'd395: out = 17'd25;
			12'd396: out = 17'd47;
			12'd397: out = 17'd49;
			12'd398: out = 17'd33;
			12'd399: out = 17'd7;
			12'd400: out = -17'd19;
			12'd401: out = -17'd34;
			12'd402: out = -17'd34;
			12'd403: out = -17'd21;
			12'd404: out = -17'd3;
			12'd405: out = 17'd13;
			12'd406: out = 17'd21;
			12'd407: out = 17'd19;
			12'd408: out = 17'd10;
			12'd409: out = -17'd1;
			12'd410: out = -17'd7;
			12'd411: out = -17'd7;
			12'd412: out = -17'd4;
			12'd413: out = 17'd1;
			12'd414: out = 17'd3;
			12'd415: out = 17'd1;
			12'd416: out = -17'd4;
			12'd417: out = -17'd10;
			12'd418: out = -17'd11;
			12'd419: out = -17'd6;
			12'd420: out = 17'd4;
			12'd421: out = 17'd15;
			12'd422: out = 17'd21;
			12'd423: out = 17'd19;
			12'd424: out = 17'd8;
			12'd425: out = -17'd9;
			12'd426: out = -17'd24;
			12'd427: out = -17'd31;
			12'd428: out = -17'd25;
			12'd429: out = -17'd9;
			12'd430: out = 17'd13;
			12'd431: out = 17'd31;
			12'd432: out = 17'd38;
			12'd433: out = 17'd29;
			12'd434: out = 17'd8;
			12'd435: out = -17'd18;
			12'd436: out = -17'd37;
			12'd437: out = -17'd43;
			12'd438: out = -17'd31;
			12'd439: out = -17'd6;
			12'd440: out = 17'd22;
			12'd441: out = 17'd41;
			12'd442: out = 17'd44;
			12'd443: out = 17'd29;
			12'd444: out = 17'd0;
			12'd445: out = -17'd30;
			12'd446: out = -17'd49;
			12'd447: out = -17'd49;
			12'd448: out = -17'd29;
			12'd449: out = 17'd3;
			12'd450: out = 17'd32;
			12'd451: out = 17'd45;
			12'd452: out = 17'd35;
			12'd453: out = 17'd4;
			12'd454: out = -17'd37;
			12'd455: out = -17'd70;
			12'd456: out = -17'd80;
			12'd457: out = -17'd61;
			12'd458: out = -17'd21;
			12'd459: out = 17'd15;
			12'd460: out = 17'd20;
			12'd461: out = -17'd37;
			12'd462: out = -17'd169;
			12'd463: out = -17'd373;
			12'd464: out = 17'd442;		// This coefficient should be multiplied with the most recent data input
			
			// This should never occur.
    		default: out = 17'h0000;
			
    endcase
      
		// Output coefficient value
		coefficient = out;

	end
	*/
endmodule