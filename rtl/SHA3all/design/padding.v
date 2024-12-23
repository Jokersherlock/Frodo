`include "default_parms.v"

module padding(
   input clk,
   input  [0:`SHA3_B-1] data_i, //1600
   input  [`SHA3_BITLEN-1:0] bitlen_i,//11,输入数据位的长度
   input  [2:0] mode_sel_i, //模式选择(选择SHAKE128,256等)
   output [0:`SHA3_B-1] a_string,//1600,填充后的消息字符串
   output reg [10:0] RATEBITS //输出速率(取决于所选模式)
   );
   
  localparam [10:0] SHAKE128_R = 11'd1344; 
  localparam [10:0] SHAKE256_R = 11'd1088; 
  localparam [10:0] SHA3512_R  = 11'd576; 
  localparam [10:0] SHA3384_R  = 11'd832; 
  localparam [10:0] SHA3256_R  = 11'd1088; 
  localparam [10:0] SHA3224_R  = 11'd1152; 
  localparam [ 7:0] PAD_END    =  8'h80;  // last byte padding (q>=2)128

  reg [0:`SHA3_B-1] string ;   // String of data input (1600 bits)
  reg [ 7:0] PAD_1ST;
  reg [ 7:0] PAD_Q1;
  
  always @(*)
   begin
    string = 0;   // default. avoid latch
	case (mode_sel_i)

	3'd0 : begin                                                  // SHAKE128
	        RATEBITS = SHAKE128_R;
			PAD_1ST  = 8'h1F;                                     // first padding byte
			PAD_Q1   = 8'h9F;                                     // last byte padding for q=1

            if (bitlen_i >= SHAKE128_R)
              string[0:SHAKE128_R-1] = data_i[0:SHAKE128_R-1];    // bitlen_i >= RATEBITS

            else if (bitlen_i == SHAKE128_R-8) begin              // bitlen_i == RATEBITS-8
              string[0  : SHAKE128_R-8] = data_i[0:SHAKE128_R-8];  
	          string[SHAKE128_R-1 -: 8] = PAD_Q1 ;                // end of pad (shake128='h80 | 'h1F) 
			  end

            else begin                                            // bitlen_i <  RATEBITS-8
              string[0:SHAKE128_R - 16] = data_i[0:SHAKE128_R-16];// data
	          string[bitlen_i     +: 8] = PAD_1ST ;               // start of pad
	          string[SHAKE128_R-1 -: 8] = PAD_END ;               // end of pad = 'h80
			  end
	       end

	3'd1 : begin                                                  // SHAKE256
	        RATEBITS = SHAKE256_R;
			PAD_1ST  = 8'h1F;                                     // first padding byte
			PAD_Q1   = 8'h9F;                                     // last byte padding for q=1

            if (bitlen_i >= SHAKE256_R)
              string[0:SHAKE256_R-1] = data_i[0:SHAKE256_R-1];    // bitlen_i >= RATEBITS

            else if (bitlen_i == SHAKE256_R-8) begin              // bitlen_i == RATEBITS-8
              string[0  : SHAKE256_R-8] = data_i[0:SHAKE256_R-8];  
	          string[SHAKE256_R-1 -: 8] = PAD_Q1 ;                // end of pad (shake256='h80 | 'h1F) 
			  end

            else begin                                            // bitlen_i <  RATEBITS-8
              string[0:SHAKE256_R - 16] = data_i[0:SHAKE256_R-16];// data
	          string[bitlen_i     +: 8] = PAD_1ST ;               // start of pad
	          string[SHAKE256_R-1 -: 8] = PAD_END ;               // end of pad = 'h80
			  end

	       end

	3'd2 : begin                                                  // SHA3512
	        RATEBITS = SHA3512_R;
			PAD_1ST  = 8'h06;                                     // first padding byte
			PAD_Q1   = 8'h86;                                     // last byte padding for q=1

            if (bitlen_i >= SHA3512_R)
              string[0:SHA3512_R-1] = data_i[0:SHA3512_R-1];      // bitlen_i >= RATEBITS
			  
            else if (bitlen_i == SHA3512_R-8) begin               // bitlen_i == RATEBITS-8
              string[0  : SHA3512_R-8] = data_i[0:SHA3512_R-8];  
	          string[SHA3512_R-1 -: 8] = PAD_Q1 ;                 // end of pad (shake128='h80 | 'h06) 
			  end

            else begin                                            // bitlen_i <  RATEBITS-8
              string[0:SHA3512_R - 16] = data_i[0:SHA3512_R-16];  // data
	          string[bitlen_i    +: 8] = PAD_1ST ;                // start of pad
	          string[SHA3512_R-1 -: 8] = PAD_END ;                // end of pad = 'h80
			  end
	       end

	3'd3 : begin                                                  // SHA3384
	        RATEBITS = SHA3384_R;
			PAD_1ST  = 8'h06;                                     // first padding byte
			PAD_Q1   = 8'h86;                                     // last byte padding for q=1

            if (bitlen_i >= SHA3384_R)
              string[0:SHA3384_R-1] = data_i[0:SHA3384_R-1];      // bitlen_i >= RATEBITS

            else if (bitlen_i == SHA3384_R-8) begin               // bitlen_i == RATEBITS-8
              string[0:SHA3384_R -  8] = data_i[0:SHA3384_R-8];  
	          string[SHA3384_R-1 -: 8] = PAD_Q1 ;                 // end of pad ('h80 | 'h06) 
			  end

            else begin                                            // bitlen_i <  RATEBITS-8
              string[0:SHA3384_R - 16] = data_i[0:SHA3384_R-16];  // data
	          string[bitlen_i    +: 8] = PAD_1ST ;                // start of pad
	          string[SHA3384_R-1 -: 8] = PAD_END ;                // end of pad = 'h80
			  end
	       end

	3'd4 : begin                                                  // SHA3256
	        RATEBITS = SHA3256_R;
			PAD_1ST  = 8'h06;                                     // first padding byte
			PAD_Q1   = 8'h86;                                     // last byte padding for q=1

            if (bitlen_i >= SHA3256_R)
              string[0:SHA3256_R-1] = data_i[0:SHA3256_R-1];      // bitlen_i >= RATEBITS

            else if (bitlen_i == SHA3256_R-8) begin               // bitlen_i == RATEBITS-8
              string[0:SHA3256_R -  8] = data_i[0:SHA3256_R-8];  
	          string[SHA3256_R-1 -: 8] = PAD_Q1 ;                 // end of pad ('h80 | 'h06) 
			  end

            else begin                                            // bitlen_i <  RATEBITS-8
              string[0:SHA3256_R - 16] = data_i[0:SHA3256_R-16];  // data
	          string[bitlen_i    +: 8] = PAD_1ST ;                // start of pad
	          string[SHA3256_R-1 -: 8] = PAD_END ;                // end of pad = 'h80
			  end
	       end

	3'd5 : begin                                                  // SHA3224
	        RATEBITS = SHA3224_R;
			PAD_1ST  = 8'h06;                                     // first padding byte
			PAD_Q1   = 8'h86;                                     // last byte padding for q=1

            if (bitlen_i >= SHA3224_R)
              string[0:SHA3224_R-1] = data_i[0:SHA3224_R-1];      // bitlen_i >= RATEBITS

            else if (bitlen_i == SHA3224_R-8) begin               // bitlen_i == RATEBITS-8
              string[0:SHA3224_R -  8] = data_i[0:SHA3224_R-8];  
	          string[SHA3224_R-1 -: 8] = PAD_Q1 ;                 // end of pad ('h80 | 'h06) 
			  end

            else begin                                            // bitlen_i <  RATEBITS-8
              string[0:SHA3224_R - 16] = data_i[0:SHA3224_R-16];  // data
	          string[bitlen_i    +: 8] = PAD_1ST ;                // start of pad
	          string[SHA3224_R-1 -: 8] = PAD_END ;                // end of pad = 'h80
			  end
	       end

    default : begin                                               // SHA3256
	        RATEBITS = SHA3256_R;
			PAD_1ST  = 8'h06;                                     // first padding byte
			PAD_Q1   = 8'h86;                                     // last byte padding for q=1

            if (bitlen_i >= SHA3256_R)
              string[0:SHA3256_R-1] = data_i[0:SHA3256_R-1];      // bitlen_i >= RATEBITS

            else if (bitlen_i == SHA3256_R-8) begin               // bitlen_i == RATEBITS-8
              string[0:SHA3256_R -  8] = data_i[0:SHA3256_R-8];  
	          string[SHA3256_R-1 -: 8] = PAD_Q1 ;                 // end of pad ('h80 | 'h06) 
			  end

            else begin                                            // bitlen_i <  RATEBITS-8
              string[0:SHA3256_R - 16] = data_i[0:SHA3256_R-16];  // data
	          string[bitlen_i    +: 8] = PAD_1ST ;                // start of pad
	          string[SHA3256_R-1 -: 8] = PAD_END ;                // end of pad = 'h80
			  end
	       end
    endcase
  end


  
   function [0:`SHA3_W-1] byteswap(input [0:`SHA3_W-1] data);
    byteswap = { data[56:63],
                 data[48:55],
                 data[40:47],
                 data[32:39],
                 data[24:31],
                 data[16:23],
                 data[ 8:15],
                 data[ 0: 7]
	           };
   endfunction

   // convert data_i to a_array to be able to (Endian) byte swap

   wire [0:`SHA3_W-1] a_array [0:`SHA3_L-1] ;  // 5x5 (x,y) array [0:63]   25*64

   assign a_array[ 0] = byteswap(string[   0:  63]);
   assign a_array[ 1] = byteswap(string[  64: 127]);
   assign a_array[ 2] = byteswap(string[ 128: 191]);
   assign a_array[ 3] = byteswap(string[ 192: 255]);
   assign a_array[ 4] = byteswap(string[ 256: 319]);
   assign a_array[ 5] = byteswap(string[ 320: 383]);
   assign a_array[ 6] = byteswap(string[ 384: 447]);
   assign a_array[ 7] = byteswap(string[ 448: 511]);
   assign a_array[ 8] = byteswap(string[ 512: 575]);
   assign a_array[ 9] = byteswap(string[ 576: 639]);
   assign a_array[10] = byteswap(string[ 640: 703]);
   assign a_array[11] = byteswap(string[ 704: 767]);
   assign a_array[12] = byteswap(string[ 768: 831]);
   assign a_array[13] = byteswap(string[ 832: 895]);
   assign a_array[14] = byteswap(string[ 896: 959]);
   assign a_array[15] = byteswap(string[ 960:1023]);
   assign a_array[16] = byteswap(string[1024:1087]);
   assign a_array[17] = byteswap(string[1088:1151]);
   assign a_array[18] = byteswap(string[1152:1215]);
   assign a_array[19] = byteswap(string[1216:1279]);
   assign a_array[20] = byteswap(string[1280:1343]);
   assign a_array[21] = byteswap(string[1344:1407]);
   assign a_array[22] = byteswap(string[1408:1471]);
   assign a_array[23] = byteswap(string[1472:1535]);
   assign a_array[24] = byteswap(string[1536:1599]);

   // convert array back to string to pass into rnd_a()

// String of data  (1600 bits)
  assign a_string = { a_array[ 0], a_array[ 1], a_array[ 2], a_array[ 3], a_array[ 4], 
                      a_array[ 5], a_array[ 6], a_array[ 7], a_array[ 8], a_array[ 9], 
                      a_array[10], a_array[11], a_array[12], a_array[13], a_array[14], 
                      a_array[15], a_array[16], a_array[17], a_array[18], a_array[19], 
                      a_array[20], a_array[21], a_array[22], a_array[23], a_array[24]
                     };
					 
endmodule	
