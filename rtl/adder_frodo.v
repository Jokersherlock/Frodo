`include "../rtl/full_adder.v"
// Module name   :   ADDER_FRODO�?
// Full name     :  16bit adder and multiplier for frodo
//
// Author        :  

module ADDER_FRODO(
input          clk,
input          reset,  
input          en,            ////Pull up during work
input   [15:0] in_a,             ////multiplier  (unsiged)
input   [15:0] in_b,             ///multiplicand (signed) 1111_1111_1111_XXXX or 0000_0000_0000_XXXX
input   [15:0] in_c,             ///addend


output  [15:0] out_d          /// a * b + c

);
/////////////////////////////// media outcome   //////////////////////////////////////////////// 
wire  [15:0] product        ; ///   a * b outcome


/////////////////////////////// First adder array in/out control   ////////////////////////////////////////
reg  [15:0] array_in0; // first row adder array in 
reg  [15:0] array_in1; // first row adder array in
reg         cnt;

/////////////////////////////////////////Partial volume////////////////  
wire [15:0] cn0; //storage b[0] & a[15:0]
wire [14:0] cn1; //storage b[1] & a[15:0]
wire [13:0] cn2; //storage b[2] & a[15:0]
wire [12:0] cn3; //storage b[3] & a[15:0]
wire [11:0] cn4; //storage b[4] & a[15:0]
wire [10:0] cn5; //storage b[5] & a[15:0]
wire [9:0]  cn6; //storage b[6] & a[15:0]
wire [8:0]  cn7; //storage b[7] & a[15:0]
wire [7:0]  cn8; //storage b[8] & a[15:0]
wire [6:0]  cn9; //storage b[9] & a[15:0]
wire [5:0]  cn10; //storage b[10] & a[15:0]
wire [4:0]  cn11; //storage b[11] & a[15:0]
wire [3:0]  cn12; //storage b[12] & a[15:0]
wire [2:0]  cn13; //storage b[13] & a[15:0]
wire [1:0]  cn14; //storage b[14] & a[15:0]
wire        cn15; //storage b[15] & a[15:0]
wire [15:0]array_a0; //Carrying
wire [15:0]array_a1; //Sum


assign out_d=  array_a1;

always@(posedge clk or negedge reset)
    begin
    if(reset)
        begin
        array_in0 <= 16'b0;
        array_in1 <= 16'b0;
        end
    else if(~cnt && en)
        begin
        array_in0 <= {1'b0,cn0[15:1]}; /////////////////////////cn0[0] = b[0] & a[0] -> product[0]
        array_in1 <= {1'b0,cn1};
        end
    else if(cnt && en)
        begin    
        array_in0 <= in_c;
        array_in1 <= product;
        end
     end
     
     
always@(posedge clk or negedge reset)
    begin
    if(reset)
        begin
        cnt <= 1'b0;
        end
    else if(en)
        begin
        if(cnt)
            cnt <= cnt;
        else 
            cnt <=  1'b1;
        end
    end



//////////////////////////////////////calculate for Partial volume//////
assign cn0  = {16{in_b[0]}} & in_a[15:0] ;  
assign cn1  = {15{in_b[1]}} & in_a[14:0] ;
assign cn2  = {14{in_b[2]}} & in_a[13:0] ;
assign cn3  = {13{in_b[3]}} & in_a[12:0] ;
assign cn4  = {12{in_b[4]}} & in_a[11:0] ;
assign cn5  = {11{in_b[5]}} & in_a[10:0] ;
assign cn6  = {10{in_b[6]}} & in_a[9:0] ;
assign cn7  = {9{in_b[7]}} & in_a[8:0] ;
assign cn8  = {8{in_b[8]}} & in_a[7:0] ;
assign cn9  = {7{in_b[9]}} & in_a[6:0] ;
assign cn10 = {6{in_b[10]}} & in_a[5:0] ;
assign cn11 = {5{in_b[11]}} & in_a[4:0] ;
assign cn12 = {4{in_b[12]}} & in_a[3:0] ;
assign cn13 = {3{in_b[13]}} & in_a[2:0] ;
assign cn14 = {2{in_b[14]}} & in_a[1:0] ;
assign cn15 = {{in_b[15]}} & in_a [0];


//////////// adder array////////////////////////////////
/////////////first row ////////////////////////////////


FULL_ADDER U_FULL_ADDER_A0(
 .a0(array_in0[0]),
 .b0(array_in1[0]),
 .c0(1'b0),
 .s1(array_a1[0]) ,
 .c1(array_a0[0])
                );

genvar  i1;	
generate 
        for(i1=1;i1<16;i1=i1+1)begin:Cn1
			FULL_ADDER U_FULL_ADDER_A(
                    .a0(array_in0[i1]),
                    .b0(array_in1[i1]),
                    .c0(array_a0[i1 - 1'b1]),
                    .s1(array_a1[i1]),
                    .c1(array_a0[i1])
                    );            
		end
endgenerate
/////////////2 row ////////////////////////////////
wire [13:0]array_b0; //Carrying
wire [13:0]array_b1; //Sum

FULL_ADDER U_FULL_ADDER_B0(
 .a0(cn2[0]),
 .b0(array_a1[1]),
 .c0(1'b0),
 .s1(array_b1[0]) ,
 .c1(array_b0[0])
                );

genvar  i2;	
generate 
        for(i2=1;i2<14;i2=i2+1)begin:Cn2
			FULL_ADDER U_FULL_ADDER_B(
                    .a0(cn2[i2]),
                    .b0(array_a1[i2 + 1'b1]),
                    .c0(array_b0[i2 - 1'b1]),
                    .s1(array_b1[i2]),
                    .c1(array_b0[i2])
                    );            
		end
endgenerate


/////////////3 row ////////////////////////////////
wire [12:0]array_c0; //Carrying
wire [12:0]array_c1; //Sum

FULL_ADDER U_FULL_ADDER_C0(
 .a0(cn3[0]),
 .b0(array_b1[1]),
 .c0(1'b0),
 .s1(array_c1[0]) ,
 .c1(array_c0[0])
                );

genvar  i3;	
generate 
        for(i3=1;i3<13;i3=i3+1)begin:Cn3
			FULL_ADDER U_FULL_ADDER_C(
                    .a0(cn2[i3]),
                    .b0(array_b1[i3 + 1'b1]),
                    .c0(array_c0[i3 - 1'b1]),
                    .s1(array_c1[i3]),
                    .c1(array_c0[i3])
                    );            
		end
endgenerate



/////////////4 row ////////////////////////////////

wire [11:0]array_d0; //Carrying
wire [11:0]array_d1; //Sum

FULL_ADDER U_FULL_ADDER_D0(
 .a0(cn4[0]),
 .b0(array_c1[1]),
 .c0(1'b0),
 .s1(array_d1[0]) ,
 .c1(array_d0[0])
                );

genvar  i4;	
generate 
        for(i4=1;i4<12;i4=i4+1)begin:Cn4
			FULL_ADDER U_FULL_ADDER_D(
                    .a0(cn4[i4]),
                    .b0(array_c1[i4 + 1'b1]),
                    .c0(array_d0[i4 - 1'b1]),
                    .s1(array_d1[i4]),
                    .c1(array_d0[i4])
                    );            
		end
endgenerate



/////////////5 row ////////////////////////////////

wire [10:0]array_e0; //Carrying
wire [10:0]array_e1; //Sum

FULL_ADDER U_FULL_ADDER_E0(
 .a0(cn5[0]),
 .b0(array_d1[1]),
 .c0(1'b0),
 .s1(array_e1[0]) ,
 .c1(array_e0[0])
                );

genvar  i5;	
generate 
        for(i5=1;i5<11;i5=i5+1)begin:Cn5
			FULL_ADDER U_FULL_ADDER_E(
                    .a0(cn5[i5]),
                    .b0(array_d1[i5 + 1'b1]),
                    .c0(array_e0[i5 - 1'b1]),
                    .s1(array_e1[i5]),
                    .c1(array_e0[i5])
                    );            
		end
endgenerate


/////////////6 row ////////////////////////////////

wire [9:0]array_f0; //Carrying
wire [9:0]array_f1; //Sum

FULL_ADDER U_FULL_ADDER_F0(
 .a0(cn6[0]),
 .b0(array_e1[1]),
 .c0(1'b0),
 .s1(array_f1[0]) ,
 .c1(array_f0[0])
                );

genvar  i6;	
generate 
        for(i6=1;i6<10;i6=i6+1)begin:Cn6
			FULL_ADDER U_FULL_ADDER_F(
                    .a0(cn6[i6]),
                    .b0(array_e1[i6 + 1'b1]),
                    .c0(array_f0[i6 - 1'b1]),
                    .s1(array_f1[i6]),
                    .c1(array_f0[i6])
                    );            
		end
endgenerate

/////////////7 row ////////////////////////////////

wire [8:0]array_h0; //Carrying
wire [8:0]array_h1; //Sum

FULL_ADDER U_FULL_ADDER_H0(
 .a0(cn7[0]),
 .b0(array_f1[1]),
 .c0(1'b0),
 .s1(array_h1[0]) ,
 .c1(array_h0[0])
                );

genvar  i7;	
generate 
        for(i7=1;i7<9;i7=i7+1)begin:Cn7
			FULL_ADDER U_FULL_ADDER_H(
                    .a0(cn7[i7]),
                    .b0(array_f1[i7 + 1'b1]),
                    .c0(array_h0[i7 - 1'b1]),
                    .s1(array_h1[i7]),
                    .c1(array_h0[i7])
                    );            
		end
endgenerate

/////////////8 row ////////////////////////////////

wire [7:0]array_i0; //Carrying
wire [7:0]array_i1; //Sum

FULL_ADDER U_FULL_ADDER_I0(
 .a0(cn8[0]),
 .b0(array_h1[1]),
 .c0(1'b0),
 .s1(array_i1[0]) ,
 .c1(array_i0[0])
                );

genvar  i8;	
generate 
        for(i8=1;i8<8;i8=i8+1)begin:Cn8
			FULL_ADDER U_FULL_ADDER_I(
                    .a0(cn8[i8]),
                    .b0(array_h1[i8 + 1'b1]),
                    .c0(array_i0[i8 - 1'b1]),
                    .s1(array_i1[i8]),
                    .c1(array_i0[i8])
                    );            
		end
endgenerate

/////////////9 row ////////////////////////////////

wire [6:0]array_j0; //Carrying
wire [6:0]array_j1; //Sum

FULL_ADDER U_FULL_ADDER_J0(
 .a0(cn9[0]),
 .b0(array_i1[1]),
 .c0(1'b0),
 .s1(array_j1[0]) ,
 .c1(array_j0[0])
                );

genvar  i9;	
generate 
        for(i9=1;i9<7;i9=i9+1)begin:Cn9
			FULL_ADDER U_FULL_ADDER_J(
                    .a0(cn9[i9]),
                    .b0(array_i1[i9 + 1'b1]),
                    .c0(array_j0[i9 - 1'b1]),
                    .s1(array_j1[i9]),
                    .c1(array_j0[i9])
                    );            
		end
endgenerate

/////////////10 row ////////////////////////////////

wire [5:0]array_k0; //Carrying
wire [5:0]array_k1; //Sum

FULL_ADDER U_FULL_ADDER_K0(
 .a0(cn10[0]),
 .b0(array_j1[1]),
 .c0(1'b0),
 .s1(array_k1[0]) ,
 .c1(array_k0[0])
                );

genvar  i10;	
generate 
        for(i10=1;i10<6;i10=i10+1)begin:Cn10
			FULL_ADDER U_FULL_ADDER_K(
                    .a0(cn10[i10]),
                    .b0(array_j1[i10 + 1'b1]),
                    .c0(array_k0[i10 - 1'b1]),
                    .s1(array_k1[i10]),
                    .c1(array_k0[i10])
                    );            
		end
endgenerate


/////////////11 row ////////////////////////////////

wire [4:0]array_m0; //Carrying
wire [4:0]array_m1; //Sum

FULL_ADDER U_FULL_ADDER_M0(
 .a0(cn11[0]),
 .b0(array_k1[1]),
 .c0(1'b0),
 .s1(array_m1[0]) ,
 .c1(array_m0[0])
                );

genvar  i11;	
generate 
        for(i11=1;i11<5;i11=i11+1)begin:Cn11
			FULL_ADDER U_FULL_ADDER_M(
                    .a0(cn11[i11]),
                    .b0(array_k1[i11 + 1'b1]),
                    .c0(array_m0[i11 - 1'b1]),
                    .s1(array_m1[i11]),
                    .c1(array_m0[i11])
                    );            
		end
endgenerate

/////////////12 row ////////////////////////////////

wire [3:0]array_n0; //Carrying
wire [3:0]array_n1; //Sum

FULL_ADDER U_FULL_ADDER_N0(
 .a0(cn12[0]),
 .b0(array_m1[1]),
 .c0(1'b0),
 .s1(array_n1[0]) ,
 .c1(array_n0[0])
                );

genvar  i12;	
generate 
        for(i12=1;i12<4;i12=i12+1)begin:Cn12
			FULL_ADDER U_FULL_ADDER_N(
                    .a0(cn12[i12]),
                    .b0(array_m1[i12 + 1'b1]),
                    .c0(array_n0[i12 - 1'b1]),
                    .s1(array_n1[i12]),
                    .c1(array_n0[i12])
                    );            
		end
endgenerate

/////////////13 row ////////////////////////////////

wire [2:0]array_o0; //Carrying
wire [2:0]array_o1; //Sum

FULL_ADDER U_FULL_ADDER_O0(
 .a0(cn13[0]),
 .b0(array_n1[1]),
 .c0(1'b0),
 .s1(array_o1[0]) ,
 .c1(array_o0[0])
                );

genvar  i13;	
generate 
        for(i13=1;i13<3;i13=i13+1)begin:Cn13
			FULL_ADDER U_FULL_ADDER_O(
                    .a0(cn13[i13]),
                    .b0(array_n1[i13 + 1'b1]),
                    .c0(array_o0[i13 - 1'b1]),
                    .s1(array_o1[i13]),
                    .c1(array_o0[i13])
                    );            
		end
endgenerate

/////////////14 row ////////////////////////////////

wire [1:0]array_p0; //Carrying
wire [1:0]array_p1; //Sum

FULL_ADDER U_FULL_ADDER_P0(
 .a0(cn14[0]),
 .b0(array_o1[1]),
 .c0(1'b0),
 .s1(array_p1[0]) ,
 .c1(array_p0[0])
                );

genvar  i14;	
generate 
        for(i14=1;i14<2;i14=i14+1)begin:Cn14
			FULL_ADDER U_FULL_ADDER_P(
                    .a0(cn14[i14]),
                    .b0(array_o1[i14 + 1'b1]),
                    .c0(array_p0[i14 - 1'b1]),
                    .s1(array_p1[i14]),
                    .c1(array_p0[i14])
                    );            
		end
endgenerate

/////////////14 row ////////////////////////////////

wire      array_q1; //Sum

FULL_ADDER U_FULL_ADDER_Q0(
 .a0(cn15),
 .b0(array_p1[1]),
 .c0(1'b0),
 .s1(array_q1) ,
 .c1()
                );



///////////////////////////////////////product a*b /////////////////////

assign product[0]  = cn0[0];
assign product[1]  = array_a1[0];
assign product[2]  = array_b1[0];
assign product[3]  = array_c1[0];
assign product[4]  = array_d1[0];
assign product[5]  = array_e1[0];
assign product[6]  = array_f1[0];
assign product[7]  = array_h1[0];
assign product[8]  = array_i1[0];
assign product[9]  = array_j1[0];
assign product[10] = array_k1[0];
assign product[11] = array_m1[0];
assign product[12] = array_n1[0];
assign product[13] = array_o1[0];
assign product[14] = array_p1[0];
assign product[15] = array_q1;


endmodule
