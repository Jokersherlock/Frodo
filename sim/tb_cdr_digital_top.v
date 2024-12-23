`timescale  1ns / 100ps

module tb_cdr_digital_top;

	// cdr_digital_top Parameters
	parameter PERIOD  = 1024;
	parameter REG_BITS = 18;
	parameter N_PI       = 8'd64;
	parameter N_DL       = 9'd64;

	// cdr_digital_top Inputs
	reg   clk                                  = 0 ;
	reg   rst_n                                = 0 ;
	reg   [64-1:0]  data                       = 0 ;
	reg   [64-1:0]  erro                       = 0 ;
	reg   [64-1:0]  erro2                      = 0 ;
	reg   [3-1:0]  dlf_kp                      = 0 ;
	reg   [3-1:0]  dlf_ki                      = 0 ;
	reg   dlf_we                               = 0 ;
	reg   [7-1:0]  dlf_in                      = 0 ;
	reg   bdlev_we                             = 0 ;
	reg   [6-1:0]  bdlev_in                    = 0 ;
	reg   bdlev2_we                            = 0 ;
	reg   [6-1:0]  bdlev2_in                   = 0 ;
	reg   pi_we                                = 0 ;
	reg   [5-1:0]  pi_word                     = 0 ;
	reg   [6-1:0]  pi_I_in                     = 0 ;
	reg   [6-1:0]  pi_Q_in                     = 0 ;

	// cdr_digital_top Outputs
	wire  [7-1:0]  dlf_out                     ;
	wire  [6-1:0]  bdlev                       ;
	wire  [6-1:0]  bdlev2                      ;
	wire  [7-1:0]  dlev_dif                    ;
	wire  [2-1:0]  EN_sel                      ;
	wire  [48-1:0]  EN_I                       ;
	wire  [48-1:0]  EN_Q                       ;
	wire  error_flag                           ;
	wire  [63:0]  data_rec                     ;
	wire  [63:0]  data_gen                     ;  

// ================== initial ================================
	initial begin forever #(PERIOD/2)  clk=~clk; end
	initial begin 
		rst_n = 1; #(PERIOD*2);
		rst_n = 0; #(PERIOD*2);
		rst_n = 1; 
	end

	reg [9:0] task_cnt=0;
	initial begin
		#(PERIOD*10);
		task_set_late;					#(PERIOD*300 );
		task_set_stop;					#(PERIOD*300 );

		// test pi_ctrl
		task_set_earl;					#(PERIOD*10  );
		task_dlf_kpki(3'b011,3'b100);	#(PERIOD*10  );// clear i_reg
		task_dlf_we(7'd0);				#(PERIOD*800 );// set pi word

		// test pi ctrl we
		task_pictrl_we(5'd0 ,6'd48,6'd0 );	#(PERIOD*3   );
		task_pictrl_we(5'd1 ,6'd47,6'd1 );	#(PERIOD*3   );
		task_pictrl_we(5'd2 ,6'd46,6'd2 );	#(PERIOD*3   );
		task_pictrl_we(5'd3 ,6'd45,6'd3 );	#(PERIOD*3   );
		task_pictrl_we(5'd4 ,6'd44,6'd4 );	#(PERIOD*3   );
		task_pictrl_we(5'd5 ,6'd43,6'd5 );	#(PERIOD*3   );
		task_pictrl_we(5'd6 ,6'd42,6'd6 );	#(PERIOD*3   );
		task_pictrl_we(5'd7 ,6'd41,6'd7 );	#(PERIOD*3   );
		task_pictrl_we(5'd8 ,6'd40,6'd8 );	#(PERIOD*3   );
		task_pictrl_we(5'd9 ,6'd39,6'd9 );	#(PERIOD*3   );
		task_pictrl_we(5'd10,6'd38,6'd10);	#(PERIOD*3   );
		task_pictrl_we(5'd11,6'd37,6'd11);	#(PERIOD*3   );
		task_pictrl_we(5'd12,6'd36,6'd12);	#(PERIOD*3   );
		task_pictrl_we(5'd13,6'd35,6'd13);	#(PERIOD*3   );
		task_pictrl_we(5'd14,6'd34,6'd14);	#(PERIOD*3   );
		task_pictrl_we(5'd15,6'd33,6'd15);	#(PERIOD*3   );
		task_pictrl_we(5'd16,6'd32,6'd16);	#(PERIOD*3   );
		task_pictrl_we(5'd17,6'd31,6'd17);	#(PERIOD*3   );
		task_pictrl_we(5'd18,6'd30,6'd18);	#(PERIOD*3   );
		task_pictrl_we(5'd19,6'd29,6'd19);	#(PERIOD*3   );
		task_pictrl_we(5'd20,6'd28,6'd20);	#(PERIOD*3   );
		task_pictrl_we(5'd21,6'd27,6'd21);	#(PERIOD*3   );
		task_pictrl_we(5'd22,6'd26,6'd22);	#(PERIOD*3   );
		task_pictrl_we(5'd23,6'd25,6'd23);	#(PERIOD*3   );
		task_pictrl_we(5'd24,6'd24,6'd24);	#(PERIOD*3   );
		task_pictrl_we(5'd25,6'd23,6'd25);	#(PERIOD*3   );
		task_pictrl_we(5'd26,6'd22,6'd26);	#(PERIOD*3   );
		task_pictrl_we(5'd27,6'd21,6'd27);	#(PERIOD*3   );
		task_pictrl_we(5'd28,6'd20,6'd28);	#(PERIOD*3   );
		task_pictrl_we(5'd29,6'd19,6'd29);	#(PERIOD*3   );
		task_pictrl_we(5'd30,6'd18,6'd30);	#(PERIOD*3   );
		task_pictrl_we(5'd31,6'd17,6'd31);	#(PERIOD*3   );
		task_dlf_kpki(3'b011,3'b100);	#(PERIOD*10  );// clear i_reg
		task_dlf_we(7'd0);				#(PERIOD*800 );// set pi word

		// test dlev
		task_bdlev_we(6'd32);			#(PERIOD*10  );
		task_dlev_up;					#(PERIOD*300 );
		task_bdlev_we(6'd32);			#(PERIOD*10  );
		task_dlev_dn;					#(PERIOD*300 );

		// test dlev2
		task_bdlev2_we(6'd32);			#(PERIOD*10  );
		task_dlev2_up;					#(PERIOD*300 );
		task_bdlev2_we(6'd32);			#(PERIOD*10  );
		task_dlev2_dn;					#(PERIOD*300 );

		// test kp
		task_dlf_kpki(3'b000,3'b100);	#(PERIOD*10  );// clear i_reg
		task_set_earl;					#(PERIOD*10  );
		task_dlf_we(7'd64);				#(PERIOD*10  );// set pi word
		task_dlf_kpki(3'b000,3'b100);	#(PERIOD*500 );// set kp
		task_dlf_we(7'd64);				#(PERIOD*10  );// set pi word
		task_dlf_kpki(3'b001,3'b100);	#(PERIOD*500 );// set kp
		task_dlf_we(7'd64);				#(PERIOD*10  );// set pi word
		task_dlf_kpki(3'b010,3'b100);	#(PERIOD*500 );// set kp
		task_set_late;					#(PERIOD*10  );
		task_dlf_we(7'd64);				#(PERIOD*10  );// set pi word
		task_dlf_kpki(3'b000,3'b100);	#(PERIOD*500 );// set kp
		task_dlf_we(7'd64);				#(PERIOD*10  );// set pi word
		task_dlf_kpki(3'b001,3'b100);	#(PERIOD*500 );// set kp
		task_dlf_we(7'd64);				#(PERIOD*10  );// set pi word
		task_dlf_kpki(3'b010,3'b100);	#(PERIOD*500 );// set kp

		// test ki
		task_set_earl;					#(PERIOD*10  );
		task_dlf_we(7'd64);				#(PERIOD*10  );// set pi word
		task_dlf_kpki(3'b100,3'b111);	#(PERIOD*500 );// set ki
		task_dlf_we(7'd64);				#(PERIOD*10  );// set pi word
		task_dlf_kpki(3'b100,3'b000);	#(PERIOD*500 );// set ki
		task_dlf_we(7'd64);				#(PERIOD*10  );// set pi word
		task_dlf_kpki(3'b100,3'b001);	#(PERIOD*500 );// set ki
		task_set_late;					#(PERIOD*10  );
		task_dlf_we(7'd64);				#(PERIOD*10  );// set pi word
		task_dlf_kpki(3'b100,3'b111);	#(PERIOD*500 );// set ki
		task_dlf_we(7'd64);				#(PERIOD*10  );// set pi word
		task_dlf_kpki(3'b100,3'b000);	#(PERIOD*500 );// set ki
		task_dlf_we(7'd64);				#(PERIOD*10  );// set pi word
		task_dlf_kpki(3'b100,3'b001);	#(PERIOD*500 );// set ki

		// test pi_word write
		task_set_earl;					#(PERIOD*10  );
		task_dlf_we(7'd1  );			#(PERIOD*100 );// set pi word
		task_dlf_we(7'd63 );			#(PERIOD*100 );// set pi word
		task_dlf_we(7'd126);			#(PERIOD*100 );// set pi word

		// test dlev write
		task_set_earl;					#(PERIOD*10  );
		task_bdlev_we(6'd24  );			#(PERIOD*100 );// set dlev
		task_bdlev_we(6'd63 );			#(PERIOD*100 );// set dlev
		$stop();
	end

// ================== instance and test ================================

	cdr_digital_top #(
		.N_PI ( N_PI ),
		.N_DL ( N_DL ))
	u_cdr_digital_top (
		.clk                     ( clk                  ),
		.rst_n                   ( rst_n                ),
		.data                    ( data        [64-1:0] ),
		.erro                    ( erro        [64-1:0] ),
    	.erro2                   ( erro2       [64-1:0] ),
		.dlf_kp                  ( dlf_kp      [3-1:0]  ),
		.dlf_ki                  ( dlf_ki      [3-1:0]  ),
		.dlf_we                  ( dlf_we               ),
		.dlf_in                  ( dlf_in      [7-1:0]  ),
		.bdlev_we                ( bdlev_we             ),
		.bdlev_in                ( bdlev_in    [6-1:0]  ),
		.bdlev2_we               ( bdlev2_we            ),
		.bdlev2_in               ( bdlev2_in   [6-1:0]  ),
		.pi_we                   ( pi_we                ),
		.pi_word                 ( pi_word     [5-1:0]  ),
		.pi_I_in                 ( pi_I_in     [6-1:0]  ),
		.pi_Q_in                 ( pi_Q_in     [6-1:0]  ),

		.dlf_out                 ( dlf_out     [7-1:0]  ),
		.bdlev                   ( bdlev       [6-1:0]  ),
		.bdlev2                  ( bdlev2      [6-1:0]  ),
		.dlev_dif                ( dlev_dif    [7-1:0]  ),
		.EN_sel                  ( EN_sel      [2-1:0]  ),
		.EN_I                    ( EN_I        [48-1:0] ),
		.EN_Q                    ( EN_Q        [48-1:0] ),
		.error_flag              ( error_flag           ),
		.data_rec                ( data_rec    [63:0]   ),
		.data_gen                ( data_gen    [63:0]   )
	);

	// test signal
	wire [7-1:0]	de_dlf_out = dlf_out;
	wire [6-1:0]	de_bdlev = bdlev;
	wire [2-1:0]	de_EN_sel = EN_sel;
	wire [48-1:0]	de_EN_I = EN_I;
	wire [48-1:0]	de_EN_Q = EN_Q;

	wire de_vote_earl = u_cdr_digital_top.vote_earl;
	wire de_vote_late = u_cdr_digital_top.vote_late;

	wire [REG_BITS-1:0] de_dlf_i_d = u_cdr_digital_top.u_dlf.dlf_i_d;
	wire [REG_BITS-1:0] de_dlf_out_d = u_cdr_digital_top.u_dlf.dlf_out_d;

// ================== task ================================

	// task_dlf_kpki(3'b000,3'b000);
	task automatic task_dlf_kpki;
		input [2:0]				tk_dlf_kp;
		input [2:0]				tk_dlf_ki;
		begin
			dlf_kp = tk_dlf_kp;
			dlf_ki = tk_dlf_ki;
			task_cnt = task_cnt + 1;
		end
	endtask //automatic

	// task_dlf_we(7'd64);
	task automatic task_dlf_we;
		input [6:0]				tk_dlf_in;
		begin
			@(posedge clk);
			dlf_we = 1'b1;
			dlf_in = tk_dlf_in;	
			@(posedge clk);		
			@(posedge clk);
			dlf_we = 1'b0;
			task_cnt = task_cnt + 1;
		end
	endtask

	// task_bdlev_we(6'd32);
	task automatic task_bdlev_we;
		input [6:0]				tk_bdlev_in;
		begin
			@(posedge clk);
			bdlev_we = 1'b1;
			bdlev_in = tk_bdlev_in;	
			@(posedge clk);		
			@(posedge clk);
			bdlev_we = 1'b0;
			task_cnt = task_cnt + 1;
		end
	endtask

	// task_bdlev2_we(6'd32);
	task automatic task_bdlev2_we;
		input [6:0]				tk_bdlev2_in;
		begin
			@(posedge clk);
			bdlev2_we = 1'b1;
			bdlev2_in = tk_bdlev2_in;	
			@(posedge clk);		
			@(posedge clk);
			bdlev2_we = 1'b0;
			task_cnt = task_cnt + 1;
		end
	endtask

	// task_pictrl_we(5'd0,6'd0,6'd0);
	task automatic task_pictrl_we;
		input [5-1:0]			tk_pi_word;
		input [6-1:0]			tk_pi_I_in;
		input [6-1:0]			tk_pi_Q_in;
		begin
			@(posedge clk);
			pi_we = 1'b1;
			pi_word = tk_pi_word;
			pi_I_in = tk_pi_I_in;
			pi_Q_in = tk_pi_Q_in;
			repeat(2)
				@(posedge clk);
			@(posedge clk);
			pi_we = 1'b0;
			task_cnt = task_cnt + 1;
		end
	endtask

	task automatic task_set_earl;
		begin
			data = {16{1'b0,1'b1,1'b1,1'b0}};
			erro = {16{1'b1,1'b1,1'b0,1'b1}};
			task_cnt = task_cnt + 1;
		end
	endtask

	task automatic task_set_late;
		begin
			data = {16{1'b0,1'b1,1'b1,1'b0}};
			erro = {16{1'b1,1'b0,1'b1,1'b1}};
			task_cnt = task_cnt + 1;
		end
	endtask

	task automatic task_dlev_up;
		begin
			data = {16{1'b0,1'b1,1'b0,1'b0}};
			erro = {16{1'b1,1'b1,1'b0,1'b1}};
			task_cnt = task_cnt + 1;
		end
	endtask

	task automatic task_dlev_dn;
		begin
			data = {16{1'b0,1'b1,1'b0,1'b0}};
			erro = {16{1'b1,1'b0,1'b0,1'b1}};
			task_cnt = task_cnt + 1;
		end
	endtask

	task automatic task_dlev2_up;
		begin
			data = {16{1'b0,1'b1,1'b1,1'b0}};
			erro = {16{1'b1,1'b1,1'b1,1'b1}};
			task_cnt = task_cnt + 1;
		end
	endtask

	task automatic task_dlev2_dn;
		begin
			data = {16{1'b0,1'b1,1'b1,1'b0}};
			erro = {16{1'b1,1'b0,1'b0,1'b1}};
			task_cnt = task_cnt + 1;
		end
	endtask

	task automatic task_set_stop;
		begin
			data = {16{1'b0,1'b0,1'b0,1'b0}};
			erro = {16{1'b0,1'b0,1'b0,1'b0}};
			task_cnt = task_cnt + 1;
		end
	endtask

endmodule