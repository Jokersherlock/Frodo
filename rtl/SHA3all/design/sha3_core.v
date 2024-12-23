`timescale 1ns/1ps
`include "default_parms.v"

module sha3_core (  
	input	clk                             ,  
	input	reset                           ,  // 高有效
	input	start_i                         ,  // pulse to start hashing next msg 
	input	squeeze_i                       ,  // squeeze output by 1 clock cycle. valid only when md_valid_o=1
	input	[2:0] mode_sel_i                ,  //0=SHAKE128,1=SHAKE256,2=SHA3-512,3=SHA3-384,4=SHA3-256,5=SHA3-224
	input	md_ack_i                        ,  // ACK for md_valid_o (handshake)
	input	[`SHA3_BITLEN-1:0] bitlen_i     ,  // bit length (11)
	input	[0:63] din64                    ,  // String of data input (1600 bits)
	input	hash_ready                      ,
	input flag                            ,
	output wire	[0:63] dout32             ,  // message digest output (256 bits)
	output wire	ready_o                   ,  // sha3 is ready for next msg (level signal)
	output wire	md_valid_o                , // message digest valid.  clears by start_i or md_ack_i
	output wire valid_32
	);

	wire [0:1343] md_data_o;
	wire [10:0] RATEBITS ; 
	wire [0:`SHA3_B-1] data_i;
	//////////////////////////////////////////////////////////

	sha3_64to1088 uut(
		.clk(clk),
		.reset(reset),
		.din64(din64),
		.mode_sel_i(mode_sel_i),
		.hash_ready(hash_ready),
		.flag(flag),
		.dout(data_i)
		);

   //-------------------------------------------------------
   // ena, round control
   //-------------------------------------------------------

	wire start = start_i & ready_o;        // start ignored when ready_o=0
	wire squeeze = squeeze_i & ready_o ;   // squeeze ignored when ready_o=0

	reg ena;
	reg md_valid;
	reg md_last;
	reg [4:0] round ;
	wire round_tc = (round == `SHA3_NROUNDS-1);  // round=0~22,round_tc=0; round_tc=23,round_tc=1
	reg init_reg;
	reg start_reg;
	reg squeeze_reg;

	wire init = start && md_last ; //&& md_valid ;  // initialize(初始化) state register of next msg

    always @(posedge clk or posedge reset)
    if (reset)
	  begin
		ena <= 1'b0;
		round <= 5'd0;
		md_valid <= 1'b0;
		md_last <= 1'b1;
		init_reg <= 1'b0;
		start_reg <= 1'b0;
		squeeze_reg <= 1'b0;
	  end
    else
	  begin
		if (start)
			ena <= 1'b1;
		else if (round_tc)
			ena <= 1'b0;

		if (round_tc || start)
			round <= 5'd0;
		else if ((ena || squeeze) && ~start)
			round <= round + 5'd1;

		if (round_tc && (bitlen_i < RATEBITS))
			md_valid <= 1'b1;
		else if (md_ack_i || start)
			md_valid <= 1'b0;

		if (start_reg && ~start && (bitlen_i < RATEBITS) )                    // first start bitlen < RATE
			md_last <= 1'b1;
		else if (start_reg && ~start && (bitlen_i == RATEBITS) )              // first start bitlen >= RATE
			md_last <= 1'b0;
 
		init_reg <= init;
		start_reg <= start;

		if (squeeze && round_tc)
			squeeze_reg <= 1'b1;
		else if (md_ack_i || start)
			squeeze_reg <= 1'b0;

	  end

   assign md_valid_o = (md_valid & md_last) | squeeze_reg;
   assign ready_o = ~ena;

   //-------------------------------------------------------
   // Padding  pad10*1
   //-------------------------------------------------------

	// ratebits
	wire  [0:`SHA3_B-1] a_string;
  
	padding  init_padding(
		.clk(clk),
		.data_i(data_i),
		.bitlen_i(bitlen_i),
		.mode_sel_i(mode_sel_i),
		.a_string(a_string),
		.RATEBITS(RATEBITS)
		);

   //-------------------------------------------------------
   // Instantiate SHA3_RND_A
   //-------------------------------------------------------

   // assign variables (match C code) from a_string 
   // [x,y] = [{o,u,a,e,i},{m,s,b,g,k}]
   // 5x5[x,y] cube config, where Aba=(0,0), Abe=(1,0) .. Aga=(0,1),Age=(1,1),Asu=(4,4)
   // 
   wire [0:`SHA3_W-1] Ako, Aku, Aka, Ake, Aki;     // x={3,4,0,1,2} ; y=2
   wire [0:`SHA3_W-1] Ago, Agu, Aga, Age, Agi;     // x={3,4,0,1,2} ; y=1
   wire [0:`SHA3_W-1] Abo, Abu, Aba, Abe, Abi;     // x={3,4,0,1,2} ; y=0
   wire [0:`SHA3_W-1] Aso, Asu, Asa, Ase, Asi;     // x={3,4,0,1,2} ; y=4
   wire [0:`SHA3_W-1] Amo, Amu, Ama, Ame, Ami;     // x={3,4,0,1,2} ; y=3

   // feedback state_array
   wire [0:`SHA3_B-1] state_reg ;       // state array output (25lanes x 64bits)
   wire [0:`SHA3_B-1] string_xor_state =                             init_reg ?             a_string : 
                                      ( start_reg && (round==0) && ~md_last ) ? state_reg ^ a_string : 
									                                            state_reg            ;
	                                     
  sha3_rnd_a inst_sha3_rnd_a(
	.round_i (round),
	.string_i (string_xor_state),
    .Aba_o (Aba),    // (0,0)
    .Abe_o (Abe),    // (1,0)
    .Abi_o (Abi),    // (2,0)
    .Abo_o (Abo),    // (3,0)
    .Abu_o (Abu),    // (4,0)
    .Aga_o (Aga),    // (0,1)
    .Age_o (Age),    // (1,1)
    .Agi_o (Agi),    // (2,1)
    .Ago_o (Ago),    // (3,1)
    .Agu_o (Agu),    // (4,1)
    .Aka_o (Aka),    // (0,2)
    .Ake_o (Ake),    // (1,2)
    .Aki_o (Aki),    // (2,2)
    .Ako_o (Ako),    // (3,2)
    .Aku_o (Aku),    // (4,2)
    .Ama_o (Ama),    // (0,3)
    .Ame_o (Ame),    // (1,3)
    .Ami_o (Ami),    // (2,3)
    .Amo_o (Amo),    // (3,3)
    .Amu_o (Amu),    // (4,3)
    .Asa_o (Asa),    // (0,4)
    .Ase_o (Ase),    // (1,4)
    .Asi_o (Asi),    // (2,4)
    .Aso_o (Aso),    // (3,4)
    .Asu_o (Asu)     // (3,4)
   );


   //-------------------------------------------------------
   // State Register
   //-------------------------------------------------------


   integer i;
   reg [0:`SHA3_W-1] state_array [0:`SHA3_L-1] ;  // 5x5 (x,y) array [0:63]

    always @(posedge clk or posedge reset)
    if (reset)
      for (i=0; i<`SHA3_L; i=i+1)
        state_array[i] <= 0;
    else
	 if (init)
      for (i=0; i<`SHA3_L; i=i+1)
        //state_array[i] <= a_array[i];    // SEED
        state_array[i] <= 'd0;             // initialize 0, no seed
     else if ((ena || squeeze) && ~start)
	   begin
        state_array[0] <= Aba;
        state_array[1] <= Abe;
        state_array[2] <= Abi;
        state_array[3] <= Abo;
        state_array[4] <= Abu;

        state_array[5] <= Aga;
        state_array[6] <= Age;
        state_array[7] <= Agi;
        state_array[8] <= Ago;
        state_array[9] <= Agu;

        state_array[10] <= Aka;
        state_array[11] <= Ake;
        state_array[12] <= Aki;
        state_array[13] <= Ako;
        state_array[14] <= Aku;

        state_array[15] <= Ama;
        state_array[16] <= Ame;
        state_array[17] <= Ami;
        state_array[18] <= Amo;
        state_array[19] <= Amu;

        state_array[20] <= Asa;
        state_array[21] <= Ase;
        state_array[22] <= Asi;
        state_array[23] <= Aso;
        state_array[24] <= Asu;
      end

  // feedback state_array into rnd(a) .
  assign state_reg = {state_array[ 0], state_array[ 1], state_array[ 2], state_array[ 3], state_array[ 4], 
                      state_array[ 5], state_array[ 6], state_array[ 7], state_array[ 8], state_array[ 9], 
                      state_array[10], state_array[11], state_array[12], state_array[13], state_array[14], 
                      state_array[15], state_array[16], state_array[17], state_array[18], state_array[19], 
                      state_array[20], state_array[21], state_array[22], state_array[23], state_array[24]
                     };

  //-------------------------------------------------------
  // String Output (256) 
  // Convert Little Endian to Big endian bytes
  // Message digest (256)
  //-------------------------------------------------------

// SHA3256 MD = md_data_o[0:255];  SHAKE128 MD = md_data_o[0:127]; SHA3512 MD = md_data_o[0:511] 

  assign md_data_o = { state_array[0][56:63],  state_array[0][48:55],  state_array[0][40:47],  state_array[0][32:39],  state_array[0][24:31],  state_array[0][16:23],  state_array[0][8:15],  state_array[0][0:7], 
                       state_array[1][56:63],  state_array[1][48:55],  state_array[1][40:47],  state_array[1][32:39],  state_array[1][24:31],  state_array[1][16:23],  state_array[1][8:15],  state_array[1][0:7], 
                       state_array[2][56:63],  state_array[2][48:55],  state_array[2][40:47],  state_array[2][32:39],  state_array[2][24:31],  state_array[2][16:23],  state_array[2][8:15],  state_array[2][0:7], 
                       state_array[3][56:63],  state_array[3][48:55],  state_array[3][40:47],  state_array[3][32:39],  state_array[3][24:31],  state_array[3][16:23],  state_array[3][8:15],  state_array[3][0:7],
                       state_array[4][56:63],  state_array[4][48:55],  state_array[4][40:47],  state_array[4][32:39],  state_array[4][24:31],  state_array[4][16:23],  state_array[4][8:15],  state_array[4][0:7], 
                       state_array[5][56:63],  state_array[5][48:55],  state_array[5][40:47],  state_array[5][32:39],  state_array[5][24:31],  state_array[5][16:23],  state_array[5][8:15],  state_array[5][0:7], 
                       state_array[6][56:63],  state_array[6][48:55],  state_array[6][40:47],  state_array[6][32:39],  state_array[6][24:31],  state_array[6][16:23],  state_array[6][8:15],  state_array[6][0:7], 
                       state_array[7][56:63],  state_array[7][48:55],  state_array[7][40:47],  state_array[7][32:39],  state_array[7][24:31],  state_array[7][16:23],  state_array[7][8:15],  state_array[7][0:7],
                       state_array[8][56:63],  state_array[8][48:55],  state_array[8][40:47],  state_array[8][32:39],  state_array[8][24:31],  state_array[8][16:23],  state_array[8][8:15],  state_array[8][0:7], 
                       state_array[9][56:63],  state_array[9][48:55],  state_array[9][40:47],  state_array[9][32:39],  state_array[9][24:31],  state_array[9][16:23],  state_array[9][8:15],  state_array[9][0:7], 
                       state_array[10][56:63], state_array[10][48:55], state_array[10][40:47], state_array[10][32:39], state_array[10][24:31], state_array[10][16:23], state_array[10][8:15], state_array[10][0:7], 
                       state_array[11][56:63], state_array[11][48:55], state_array[11][40:47], state_array[11][32:39], state_array[11][24:31], state_array[11][16:23], state_array[11][8:15], state_array[11][0:7],
                       state_array[12][56:63], state_array[12][48:55], state_array[12][40:47], state_array[12][32:39], state_array[12][24:31], state_array[12][16:23], state_array[12][8:15], state_array[12][0:7], 
                       state_array[13][56:63], state_array[13][48:55], state_array[13][40:47], state_array[13][32:39], state_array[13][24:31], state_array[13][16:23], state_array[13][8:15], state_array[13][0:7], 
                       state_array[14][56:63], state_array[14][48:55], state_array[14][40:47], state_array[14][32:39], state_array[14][24:31], state_array[14][16:23], state_array[14][8:15], state_array[14][0:7], 
                       state_array[15][56:63], state_array[15][48:55], state_array[15][40:47], state_array[15][32:39], state_array[15][24:31], state_array[15][16:23], state_array[15][8:15], state_array[15][0:7],
                       state_array[16][56:63], state_array[16][48:55], state_array[16][40:47], state_array[16][32:39], state_array[16][24:31], state_array[16][16:23], state_array[16][8:15], state_array[16][0:7], 
                       state_array[17][56:63], state_array[17][48:55], state_array[17][40:47], state_array[17][32:39], state_array[17][24:31], state_array[17][16:23], state_array[17][8:15], state_array[17][0:7],
                       state_array[18][56:63], state_array[18][48:55], state_array[18][40:47], state_array[18][32:39], state_array[18][24:31], state_array[18][16:23], state_array[18][8:15], state_array[18][0:7], 
                       state_array[19][56:63], state_array[19][48:55], state_array[19][40:47], state_array[19][32:39], state_array[19][24:31], state_array[19][16:23], state_array[19][8:15], state_array[19][0:7], 
                       state_array[20][56:63], state_array[20][48:55], state_array[20][40:47], state_array[20][32:39], state_array[20][24:31], state_array[20][16:23], state_array[20][8:15], state_array[20][0:7]                
                    };
////////////////////////////////////////////////////////////////////
	sha3_256to32 uut256to32(
		.clk(clk),
		.reset(reset),
		.md_valid_o(md_valid_o),
		.mode_sel_i(mode_sel_i),
		.dout256(md_data_o),
		.dout32(dout32),
		.valid_32(valid_32)
		);
////////////////////////////////////////////////////////////////
endmodule

