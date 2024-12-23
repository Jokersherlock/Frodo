
module sha3_64to1088(
   input clk,  
   input reset,        //高有效
   input [0:63]din64,  //64位一组输入 
   input hash_ready,   //等于0，继续输入；等于1，停止输入
   input flag,
   input [2:0] mode_sel_i,   //0=SHAKE128,1=SHAKE256,2=SHA3-512,3=SHA3-384,4=SHA3-256,5=SHA3-224
   output wire [0:`SHA3_B-1] dout   //1600位，有效数据后面为0
   );
   
reg [0:1343]qtemp;     //移位寄存器
   
always @(posedge clk)  
   if(reset) qtemp <= 1344'b0;
   else if(!hash_ready) qtemp <= {qtemp[64:1343],din64};    //左移
   else if(flag) qtemp <= 1344'b0;
   else ;

assign dout = (mode_sel_i==0)?{qtemp[0:1343],256'b0}:       //r=1344
			  (mode_sel_i==1)?{qtemp[256:1343],512'b0}:     //r=1088
			  (mode_sel_i==2)?{qtemp[768:1343],1024'b0}:    //d=512
			  (mode_sel_i==3)?{qtemp[512:1343],768'b0}:     //d=384
			  (mode_sel_i==4)?{qtemp[256:1343],512'b0}:     //d=256
			  (mode_sel_i==5)?{qtemp[192:1343],448'b0}:     //d=224
			                  {qtemp[256:1343],512'b0};     //d=256

wire [63:0] test_dout[0:24];
assign test_dout[0] = dout[0:63];
assign test_dout[1] = dout[64:127];
assign test_dout[2] = dout[128:191];
assign test_dout[3] = dout[192:255];
assign test_dout[4] = dout[256:319];
assign test_dout[5] = dout[320:383];
assign test_dout[6] = dout[384:447];
assign test_dout[7] = dout[448:511];
assign test_dout[8] = dout[512:575];
assign test_dout[9] = dout[576:639];
assign test_dout[10] = dout[640:703];
assign test_dout[11] = dout[704:767];
assign test_dout[12] = dout[768:831];
assign test_dout[13] = dout[832:895];
assign test_dout[14] = dout[896:959];
assign test_dout[15] = dout[960:1023];
assign test_dout[16] = dout[1024:1087];
assign test_dout[17] = dout[1088:1151];
assign test_dout[18] = dout[1152:1215];
assign test_dout[19] = dout[1216:1279];
assign test_dout[20] = dout[1280:1343];
assign test_dout[21] = dout[1344:1407];
assign test_dout[22] = dout[1408:1471];
assign test_dout[23] = dout[1472:1535];
assign test_dout[24] = dout[1536:1599];

endmodule  
