`timescale 1ns/1ps
`include "default_parms.v" 

`define SHA3_MSGLEN       136544         /*  TB Message Length MAX from SHAKE128LongMsg.rsp vector set */  

module test256 #(`PARMS) ();

  // General I/O
  reg   clk                        ; // system clock
  reg   reset                      ; // async reset active low
  reg   start                        ;
  reg   squeeze                      ; // squeeze more md output for each clock cycle
  reg 	[2:0]mode_sel                ; // 0=shake128; 1=shake256; 2=sha3256  
  reg  	[`SHA3_BITLEN-1:0] bitlen    ;  // message length in bits
  reg 	[0 :64-1] din64              ;  // String input (1600 bits)
  reg	hash_ready                   ;
  reg	flag                         ;
  wire	[0 :63]dout32                ;  // String output (256 bits)
  wire	sha3_ready                   ;
  wire	md_valid                     ; // message digest valid pulse
  wire	valid_32                     ;
  
  reg [20:0] Len;
  reg [0:`SHA3_MSGLEN-1] Msg;
  reg [0:`SHA3_D-1] MD;//256
  
//-------------------------------------------------
// instantiate module
//-------------------------------------------------

  sha3_core inst_sha3_core (
    .clk(clk) ,
    .reset(reset) ,
	.start_i(start),
	.squeeze_i(squeeze),
	.mode_sel_i(mode_sel),
	.md_ack_i(md_valid),
	.bitlen_i(bitlen),
	.din64 (din64),
	.hash_ready(hash_ready),
	.flag(flag),
	.dout32(dout32),
    .ready_o(sha3_ready),   
    .md_valid_o(md_valid),
    .valid_32(valid_32)
    );

//-------------------------------------------------
// clock & reset
//-------------------------------------------------

initial
 begin
  clk=1;
   forever
    begin
    #10 clk=!clk;
    end
 end

initial
  begin
   reset=1;
   #100;
   reset=0;
  end

//////////////////////////////////////////////////////////////////////
// BEGIN TESTS
//////////////////////////////////////////////////////////////////////

initial begin
	Msg = 0;
	Len = 0;
	start = 0;
	bitlen = 0;
	squeeze = 0;
	mode_sel = 0;
	din64 = 0; 
	flag = 0;
	hash_ready = 1;
	wait (~reset);
	@(posedge clk);
	hash_ready = 0;

//------------------------------------------
//*  SHA3256 TESTS
//------------------------------------------

$display("     SHA3(512) test results. ");

Len = 1280;
Msg = 1280'he0301b304183c944984df8d46a7093d3531a621c1ccc9d336cdedca42388d770ada31dddc7a3bff96c0c2e5c6eb0e0e385862455147213ad0061ca8b32dfe9cd77cd9bcadf061b2ebeb501cd4b3c33919c59d52c8a373066d1afa40dd67b720d60a578557fb59340d196817bb48f74c77b86f279ab80f7b32d98a7b03e9df69ce4c56d1316459bc19b24e559ecf5ec4438e67a888e6818a195b51532260f62fc;

// e0301b304183c944
// 984df8d46a7093d3
// 531a621c1ccc9d33
// 6cdedca42388d770
// ada31dddc7a3bff9
// 6c0c2e5c6eb0e0e3
// 85862455147213ad
// 0061ca8b32dfe9cd
// 77cd9bcadf061b2e

// beb501cd4b3c3391
// 9c59d52c8a373066
// d1afa40dd67b720d
// 60a578557fb59340
// d196817bb48f74c7
// 7b86f279ab80f7b3
// 2d98a7b03e9df69c
// e4c56d1316459bc1
// 9b24e559ecf5ec44

// 38e67a888e6818a1
// 95b51532260f62fc

sha3512(Len, Msg);
sha3384(Len, Msg);
sha3256(Len, Msg);
sha3224(Len, Msg);
SHAKE128(Len, Msg);
squeeze_play(1);
SHAKE256(Len, Msg);
squeeze_play(1);


// squeeze_play(22);
//==============================================================================
// END

	wait (1000);
	$display(".");
	$display("End of Test. ");
	$stop;

end

  //----------------------------------------------------------------
  // TASK start_hash
  //----------------------------------------------------------------

  task automatic start_hash;
   begin
    wait (sha3_ready);
	@(posedge clk);
    start = 1;
    wait (~sha3_ready);
    start = 0;
	flag = 1;
    wait (sha3_ready);	
    @(posedge clk);	
	flag = 0 ;
//	@(posedge clk);
	hash_ready = 0;
   end
  endtask
  //----------------------------------------------------------------
  // TASK start_hash
  //----------------------------------------------------------------

  task automatic hash_last;
   begin
    wait (sha3_ready);
	@(posedge clk);
    	start = 1;
    wait (~sha3_ready);
		start = 0;
		flag = 1;
    wait (sha3_ready);	
    @(posedge clk);	
		flag = 0 ;
//	@(posedge clk);
		hash_ready = 0;
	wait(valid_32);
	@(posedge clk);
   end
  endtask

//------------------------------------------------------------------
//squeeze
//----------------------------------------------------------------
  task automatic squeeze_play;
  input [4:0] num_cc;  // number of clock cycles to spin
  integer k;
	begin
	while(num_cc != 0)
		begin
			for(k=0;k<24;k=k+1) begin
			@(posedge clk);
				squeeze = 1;
			end
			@(posedge clk);
				squeeze = 0;
			wait(valid_32);
			@(posedge clk);
				num_cc = num_cc - 1;
		end
	#100 ;
	end
  endtask
  //----------------------------------------------------------------
  // TASK sha3_absorb分段，message被分为一个个长度为R的段送给data_i
  // Input MSG MUST BE LEFT JUSTIFIED!!!!!
  //----------------------------------------------------------------

  task automatic sha3_absorb;
   input [20:0] bit_length;
   input [0:`SHA3_MSGLEN-1] message;
   reg   [0:`SHA3_MSGLEN-1] message_shift;
   reg   [10:0] RATEBITS;
   
   integer i,j;
	 begin
	  case (mode_sel)
       3'd0   : RATEBITS = 11'd1344;  // shake128
       3'd1   : RATEBITS = 11'd1088;  // shake256
       3'd2   : RATEBITS = 11'd576 ;  // sha3512
       3'd3   : RATEBITS = 11'd832 ;  // sha3384
       3'd4   : RATEBITS = 11'd1088;  // sha3256
       3'd5   : RATEBITS = 11'd1152;  // sha3224
	   default: RATEBITS = 11'd1088;  // sha3256
	  endcase
		#20;
	  if (bit_length < `SHA3_MSGLEN)
	    message_shift = (message << (`SHA3_MSGLEN-bit_length)); // shift message to left justified
	  else
	    message_shift =  message;
		
      while ( bit_length >= RATEBITS ) 	   
	   begin
        bitlen = RATEBITS; 
		for (i=0;i<RATEBITS/64;i=i+1) begin
		   @(posedge clk);
			for (j=0;j<64;j=j+1) begin
				din64[j] = message_shift[j];
			end
			message_shift = (message_shift << 64); 
		end
		@(posedge clk);
		hash_ready = 1;		
		start_hash;		
		bit_length = bit_length - RATEBITS;
	   end // (end while)
	   
	  //REMAINDER
	  bitlen = bit_length[`SHA3_BITLEN-1:0];//11
		for (i=0;i<RATEBITS/64;i=i+1) begin
		   @(posedge clk);
           for (j=0;j<64;j=j+1) begin
             din64[j] = message_shift[j];			  
		    end
			message_shift = (message_shift << 64);
		end
		@(posedge clk);
		hash_ready = 1;		
		hash_last;		  
	 end
  endtask

  //----------------------------------------------------------------
  // TASK sha3256
  // Input MSG MUST BE LEFT JUSTIFIED!!!!!
  //----------------------------------------------------------------
  task automatic SHAKE128;
   input [20:0] bit_length;
   input [0:`SHA3_MSGLEN-1] message;
   reg   [0:`SHA3_MSGLEN-1] message_shift;
	 begin
      mode_sel = 3'd0;                               
      sha3_absorb(bit_length, message);
	  #100 ;
	 end
  endtask

  task automatic SHAKE256;
   input [20:0] bit_length;
   input [0:`SHA3_MSGLEN-1] message;
   reg   [0:`SHA3_MSGLEN-1] message_shift;
	 begin
      mode_sel = 3'd1;                               
      sha3_absorb(bit_length, message);
	  #100 ;
	 end
  endtask

  task automatic sha3512;
   input [20:0] bit_length;
   input [0:`SHA3_MSGLEN-1] message;
   reg   [0:`SHA3_MSGLEN-1] message_shift;
	 begin
      mode_sel = 3'd2;                               
      sha3_absorb(bit_length, message);
	  #100 ;
	 end
  endtask

  task automatic sha3384;
   input [20:0] bit_length;
   input [0:`SHA3_MSGLEN-1] message;
   reg   [0:`SHA3_MSGLEN-1] message_shift;
	 begin
      mode_sel = 3'd3;                               
      sha3_absorb(bit_length, message);
	  #100 ;
	 end
  endtask

  task automatic sha3256;
   input [20:0] bit_length;
   input [0:`SHA3_MSGLEN-1] message;
   reg   [0:`SHA3_MSGLEN-1] message_shift;
	 begin
      mode_sel = 3'd4;                               
      sha3_absorb(bit_length, message);
	  #100 ;
	 end
  endtask
  
  task automatic sha3224;
   input [20:0] bit_length;
   input [0:`SHA3_MSGLEN-1] message;
   reg   [0:`SHA3_MSGLEN-1] message_shift;
	 begin
      mode_sel = 3'd5;                               
      sha3_absorb(bit_length, message);
	  #100 ;
	 end
  endtask

endmodule // tb_sha3
