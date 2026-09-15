/***********************************************************************
*
* LUT-Based S-Box
*
* Ref: Usselmann, OpenCores 2002
*
***********************************************************************/

module AES_SBox_LUT (out, in);

	input	[7:0]	in;

	output	reg	[7:0]	out;

	always @(in)
		case (in)
		   8'h00: out = 8'h63;
		   8'h01: out = 8'h7c;
		   8'h02: out = 8'h77;
		   8'h03: out = 8'h7b;
		   8'h04: out = 8'hf2;
		   8'h05: out = 8'h6b;
		   8'h06: out = 8'h6f;
		   8'h07: out = 8'hc5;
		   8'h08: out = 8'h30;
		   8'h09: out = 8'h01;
		   8'h0a: out = 8'h67;
		   8'h0b: out = 8'h2b;
		   8'h0c: out = 8'hfe;
		   8'h0d: out = 8'hd7;
		   8'h0e: out = 8'hab;
		   8'h0f: out = 8'h76;
		   8'h10: out = 8'hca;
		   8'h11: out = 8'h82;
		   8'h12: out = 8'hc9;
		   8'h13: out = 8'h7d;
		   8'h14: out = 8'hfa;
		   8'h15: out = 8'h59;
		   8'h16: out = 8'h47;
		   8'h17: out = 8'hf0;
		   8'h18: out = 8'had;
		   8'h19: out = 8'hd4;
		   8'h1a: out = 8'ha2;
		   8'h1b: out = 8'haf;
		   8'h1c: out = 8'h9c;
		   8'h1d: out = 8'ha4;
		   8'h1e: out = 8'h72;
		   8'h1f: out = 8'hc0;
		   8'h20: out = 8'hb7;
		   8'h21: out = 8'hfd;
		   8'h22: out = 8'h93;
		   8'h23: out = 8'h26;
		   8'h24: out = 8'h36;
		   8'h25: out = 8'h3f;
		   8'h26: out = 8'hf7;
		   8'h27: out = 8'hcc;
		   8'h28: out = 8'h34;
		   8'h29: out = 8'ha5;
		   8'h2a: out = 8'he5;
		   8'h2b: out = 8'hf1;
		   8'h2c: out = 8'h71;
		   8'h2d: out = 8'hd8;
		   8'h2e: out = 8'h31;
		   8'h2f: out = 8'h15;
		   8'h30: out = 8'h04;
		   8'h31: out = 8'hc7;
		   8'h32: out = 8'h23;
		   8'h33: out = 8'hc3;
		   8'h34: out = 8'h18;
		   8'h35: out = 8'h96;
		   8'h36: out = 8'h05;
		   8'h37: out = 8'h9a;
		   8'h38: out = 8'h07;
		   8'h39: out = 8'h12;
		   8'h3a: out = 8'h80;
		   8'h3b: out = 8'he2;
		   8'h3c: out = 8'heb;
		   8'h3d: out = 8'h27;
		   8'h3e: out = 8'hb2;
		   8'h3f: out = 8'h75;
		   8'h40: out = 8'h09;
		   8'h41: out = 8'h83;
		   8'h42: out = 8'h2c;
		   8'h43: out = 8'h1a;
		   8'h44: out = 8'h1b;
		   8'h45: out = 8'h6e;
		   8'h46: out = 8'h5a;
		   8'h47: out = 8'ha0;
		   8'h48: out = 8'h52;
		   8'h49: out = 8'h3b;
		   8'h4a: out = 8'hd6;
		   8'h4b: out = 8'hb3;
		   8'h4c: out = 8'h29;
		   8'h4d: out = 8'he3;
		   8'h4e: out = 8'h2f;
		   8'h4f: out = 8'h84;
		   8'h50: out = 8'h53;
		   8'h51: out = 8'hd1;
		   8'h52: out = 8'h00;
		   8'h53: out = 8'hed;
		   8'h54: out = 8'h20;
		   8'h55: out = 8'hfc;
		   8'h56: out = 8'hb1;
		   8'h57: out = 8'h5b;
		   8'h58: out = 8'h6a;
		   8'h59: out = 8'hcb;
		   8'h5a: out = 8'hbe;
		   8'h5b: out = 8'h39;
		   8'h5c: out = 8'h4a;
		   8'h5d: out = 8'h4c;
		   8'h5e: out = 8'h58;
		   8'h5f: out = 8'hcf;
		   8'h60: out = 8'hd0;
		   8'h61: out = 8'hef;
		   8'h62: out = 8'haa;
		   8'h63: out = 8'hfb;
		   8'h64: out = 8'h43;
		   8'h65: out = 8'h4d;
		   8'h66: out = 8'h33;
		   8'h67: out = 8'h85;
		   8'h68: out = 8'h45;
		   8'h69: out = 8'hf9;
		   8'h6a: out = 8'h02;
		   8'h6b: out = 8'h7f;
		   8'h6c: out = 8'h50;
		   8'h6d: out = 8'h3c;
		   8'h6e: out = 8'h9f;
		   8'h6f: out = 8'ha8;
		   8'h70: out = 8'h51;
		   8'h71: out = 8'ha3;
		   8'h72: out = 8'h40;
		   8'h73: out = 8'h8f;
		   8'h74: out = 8'h92;
		   8'h75: out = 8'h9d;
		   8'h76: out = 8'h38;
		   8'h77: out = 8'hf5;
		   8'h78: out = 8'hbc;
		   8'h79: out = 8'hb6;
		   8'h7a: out = 8'hda;
		   8'h7b: out = 8'h21;
		   8'h7c: out = 8'h10;
		   8'h7d: out = 8'hff;
		   8'h7e: out = 8'hf3;
		   8'h7f: out = 8'hd2;
		   8'h80: out = 8'hcd;
		   8'h81: out = 8'h0c;
		   8'h82: out = 8'h13;
		   8'h83: out = 8'hec;
		   8'h84: out = 8'h5f;
		   8'h85: out = 8'h97;
		   8'h86: out = 8'h44;
		   8'h87: out = 8'h17;
		   8'h88: out = 8'hc4;
		   8'h89: out = 8'ha7;
		   8'h8a: out = 8'h7e;
		   8'h8b: out = 8'h3d;
		   8'h8c: out = 8'h64;
		   8'h8d: out = 8'h5d;
		   8'h8e: out = 8'h19;
		   8'h8f: out = 8'h73;
		   8'h90: out = 8'h60;
		   8'h91: out = 8'h81;
		   8'h92: out = 8'h4f;
		   8'h93: out = 8'hdc;
		   8'h94: out = 8'h22;
		   8'h95: out = 8'h2a;
		   8'h96: out = 8'h90;
		   8'h97: out = 8'h88;
		   8'h98: out = 8'h46;
		   8'h99: out = 8'hee;
		   8'h9a: out = 8'hb8;
		   8'h9b: out = 8'h14;
		   8'h9c: out = 8'hde;
		   8'h9d: out = 8'h5e;
		   8'h9e: out = 8'h0b;
		   8'h9f: out = 8'hdb;
		   8'ha0: out = 8'he0;
		   8'ha1: out = 8'h32;
		   8'ha2: out = 8'h3a;
		   8'ha3: out = 8'h0a;
		   8'ha4: out = 8'h49;
		   8'ha5: out = 8'h06;
		   8'ha6: out = 8'h24;
		   8'ha7: out = 8'h5c;
		   8'ha8: out = 8'hc2;
		   8'ha9: out = 8'hd3;
		   8'haa: out = 8'hac;
		   8'hab: out = 8'h62;
		   8'hac: out = 8'h91;
		   8'had: out = 8'h95;
		   8'hae: out = 8'he4;
		   8'haf: out = 8'h79;
		   8'hb0: out = 8'he7;
		   8'hb1: out = 8'hc8;
		   8'hb2: out = 8'h37;
		   8'hb3: out = 8'h6d;
		   8'hb4: out = 8'h8d;
		   8'hb5: out = 8'hd5;
		   8'hb6: out = 8'h4e;
		   8'hb7: out = 8'ha9;
		   8'hb8: out = 8'h6c;
		   8'hb9: out = 8'h56;
		   8'hba: out = 8'hf4;
		   8'hbb: out = 8'hea;
		   8'hbc: out = 8'h65;
		   8'hbd: out = 8'h7a;
		   8'hbe: out = 8'hae;
		   8'hbf: out = 8'h08;
		   8'hc0: out = 8'hba;
		   8'hc1: out = 8'h78;
		   8'hc2: out = 8'h25;
		   8'hc3: out = 8'h2e;
		   8'hc4: out = 8'h1c;
		   8'hc5: out = 8'ha6;
		   8'hc6: out = 8'hb4;
		   8'hc7: out = 8'hc6;
		   8'hc8: out = 8'he8;
		   8'hc9: out = 8'hdd;
		   8'hca: out = 8'h74;
		   8'hcb: out = 8'h1f;
		   8'hcc: out = 8'h4b;
		   8'hcd: out = 8'hbd;
		   8'hce: out = 8'h8b;
		   8'hcf: out = 8'h8a;
		   8'hd0: out = 8'h70;
		   8'hd1: out = 8'h3e;
		   8'hd2: out = 8'hb5;
		   8'hd3: out = 8'h66;
		   8'hd4: out = 8'h48;
		   8'hd5: out = 8'h03;
		   8'hd6: out = 8'hf6;
		   8'hd7: out = 8'h0e;
		   8'hd8: out = 8'h61;
		   8'hd9: out = 8'h35;
		   8'hda: out = 8'h57;
		   8'hdb: out = 8'hb9;
		   8'hdc: out = 8'h86;
		   8'hdd: out = 8'hc1;
		   8'hde: out = 8'h1d;
		   8'hdf: out = 8'h9e;
		   8'he0: out = 8'he1;
		   8'he1: out = 8'hf8;
		   8'he2: out = 8'h98;
		   8'he3: out = 8'h11;
		   8'he4: out = 8'h69;
		   8'he5: out = 8'hd9;
		   8'he6: out = 8'h8e;
		   8'he7: out = 8'h94;
		   8'he8: out = 8'h9b;
		   8'he9: out = 8'h1e;
		   8'hea: out = 8'h87;
		   8'heb: out = 8'he9;
		   8'hec: out = 8'hce;
		   8'hed: out = 8'h55;
		   8'hee: out = 8'h28;
		   8'hef: out = 8'hdf;
		   8'hf0: out = 8'h8c;
		   8'hf1: out = 8'ha1;
		   8'hf2: out = 8'h89;
		   8'hf3: out = 8'h0d;
		   8'hf4: out = 8'hbf;
		   8'hf5: out = 8'he6;
		   8'hf6: out = 8'h42;
		   8'hf7: out = 8'h68;
		   8'hf8: out = 8'h41;
		   8'hf9: out = 8'h99;
		   8'hfa: out = 8'h2d;
		   8'hfb: out = 8'h0f;
		   8'hfc: out = 8'hb0;
		   8'hfd: out = 8'h54;
		   8'hfe: out = 8'hbb;
		   8'hff: out = 8'h16;
		endcase
	
endmodule

/***********************************************************************
*
* Composite-Field-Based S-Box
*
* Ref: Canright, CHES 2005
*
***********************************************************************/

/* S-box using all normal bases */
/*   case # 4 : [d^16, d], [alpha^8, alpha^2], [Omega^2, Omega] */
/*   beta^8 = N^2*alpha^2, N = w^2 */
/*   optimized using OR gates and NAND gates */

/* square in GF(2^2), using normal basis [Omega^2,Omega]
 * inverse is the same as square in GF(2^2), using any normal basis
 */
module GF_SQ_2 ( A, Q );
	input [1:0] A;
	output [1:0] Q;
  
	assign Q = { A[0], A[1] };
endmodule

/* scale by w = Omega in GF(2^2), using normal basis [Omega^2,Omega] */
module GF_SCLW_2 ( A, Q );
	input [1:0] A;
	output [1:0] Q;
	assign Q = { (A[1] ^ A[0]), A[1] };
endmodule

/* scale by w^2 = Omega^2 in GF(2^2), using normal basis [Omega^2,Omega] */
module GF_SCLW2_2 ( A, Q );
	input [1:0] A;
	output [1:0] Q;
	assign Q = { A[0], (A[1] ^ A[0]) };
endmodule

/* multiply in GF(2^2), shared factors, module GF_MULS_2 ( A, ab, B, cd, Q );
using normal basis [Omega^2,Omega] */
module GF_MULS_2 ( A, ab, B, cd, Q );
	input [1:0] A;
	input ab;
	input [1:0] B;
	input cd;
	output [1:0] Q;
	wire abcd, p, q;
	assign abcd = ~(ab & cd);  /* note:~& syntax for NAND won’t compile */
	assign p = (~(A[1] & B[1])) ^ abcd;
	assign q = (~(A[0] & B[0])) ^ abcd;
	assign Q = { p, q }; 
endmodule

/* multiply & scale by N in GF(2^2), shared factors, basis [Omega^2,Omega] */
module GF_MULS_SCL_2 ( A, ab, B, cd, Q );
	input [1:0] A;
	input ab;
	input [1:0] B;
	input cd;
	output [1:0] Q;
	wire t, p, q;

	assign t = ~(A[0] & B[0]); /* note: ~& syntax for NAND won’t compile */
	assign p = (~(ab & cd)) ^ t;
	assign q = (~(A[1] & B[1])) ^ t;
	assign Q = { p, q };
endmodule

module GF_INV_4 ( A, Q );
	input [3:0] A; output [3:0] Q;
	wire [1:0] a, b, d, p, q, ab, ab2, ab2N;
	wire sa, sb, sd; /* for shared factors in multipliers */
  
	assign a = A[3:2]; assign b = A[1:0];
	assign sa = a[1] ^ a[0];
	assign sb = b[1] ^ b[0];
	/* optimize this section as shown below
		assign d = { 
		~(a[1] | b[1]) ^ (~(sa &  sb)) ,
		~(sa | sb) ^ (~(a[0] & b[0])) };
	 end of optimization */

    GF_MULS_2 abmul(a, sa, b, sb, ab);
	GF_SQ_2 absq( (a ^ b), ab2);
	GF_SCLW2_2 absclN( ab2, ab2N);
	GF_SQ_2 dinv( (ab ^ ab2N), d);

	assign sd = d[1] ^ d[0];
	GF_MULS_2 pmul(d, sd, b, sb, p);
	GF_MULS_2 qmul(d, sd, a, sa, q);
	assign Q = { p, q };
endmodule

/* square & scale by nu in GF(2^4)/GF(2^2),
 * in the normal basis [alpha^8, alpha^2]:
 *
 * nu = beta^8 = N^2*alpha^2, N = w^2
 */
module GF_SQ_SCL_4 ( A, Q );
	input [3:0] A;
	output [3:0] Q;
	wire [1:0] a, b, ab2, b2, b2N2;
	assign a = A[3:2];
	assign b = A[1:0];
	GF_SQ_2 absq(a ^ b, ab2);
	GF_SQ_2 bsq(b, b2);
	GF_SCLW_2 bmulN2(b2, b2N2);

	assign Q = { ab2, b2N2 };
endmodule

/* multiply in GF(2^4)/GF(2^2), shared factors, basis [alpha^8, alpha^2] */
module GF_MULS_4 ( A, a, Al, Ah, aa, B, b, Bl, Bh, bb, Q );
	input [3:0] A;
	input [1:0] a;
	input Al;
	input Ah;
	input aa;
	input [3:0] B;
	input [1:0] b;
	input Bl;
	input Bh;
	input bb;
	output [3:0] Q;
	wire [1:0] ph, pl, ps, p;
	wire t;

	GF_MULS_2 himul(A[3:2], Ah, B[3:2], Bh, ph);
	GF_MULS_2 lomul(A[1:0], Al, B[1:0], Bl, pl);
	GF_MULS_SCL_2 summul( a, aa, b, bb, p);
	assign Q = { (ph ^ p), (pl ^ p) };
endmodule

/* inverse in GF(2^8)/GF(2^4), using normal basis [d^16, d] */
module GF_INV_8 ( A, Q );
	input [7:0] A;
	output [7:0] Q;
	wire [3:0] a, b, c, d, p, q;
	wire [1:0] sa, sb, sd, t; /* for shared factors in multipliers */ 
	wire al, ah, aa, bl, bh, bb, dl, dh, dd; /* for shared factors */
	wire c1, c2, c3; /* for temp var */

	assign a = A[7:4];
	assign b = A[3:0];
	assign sa = a[3:2] ^ a[1:0];
	assign sb = b[3:2] ^ b[1:0];
	assign al = a[1] ^ a[0];
	assign ah = a[3] ^ a[2];
	assign aa = sa[1] ^ sa[0];
	assign bl = b[1] ^ b[0];
	assign bh = b[3] ^ b[2];
	assign bb = sb[1] ^ sb[0];
  
	/* optimize this section as shown below
	GF_MULS_4 abmul(a, sa, al, ah, aa, b, sb, bl, bh, bb, ab);
	GF_SQ_SCL_4 absq( (a ^ b), ab2);
	GF_INV_4 dinv( (ab ^ ab2), d);
	*/
	assign c1 = ~(ah & bh);
	assign c2 = ~(sa[0] & sb[0]);
	assign c3 = ~(aa & bb);
	assign c = {
		(~(sa[0] | sb[0]) ^ (~(a[3] & b[3]))) ^ c1 ^ c3 ,
		(~(sa[1] | sb[1]) ^ (~(a[2] & b[2]))) ^ c1 ^ c2 ,
		(~(al | bl) ^ (~(a[1] & b[1]))) ^ c2 ^ c3 ,
		(~(a[0] | b[0]) ^ (~(al & bl))) ^ (~(sa[1] & sb[1])) ^ c2
		};
	GF_INV_4 dinv( c, d);
	/* end of optimization */
	assign sd = d[3:2] ^ d[1:0];
	assign dl = d[1] ^ d[0];
	assign dh = d[3] ^ d[2];
	assign dd = sd[1] ^ sd[0];
	GF_MULS_4 pmul(d, sd, dl, dh, dd, b, sb, bl, bh, bb, p);
	GF_MULS_4 qmul(d, sd, dl, dh, dd, a, sa, al, ah, aa, q);
	assign Q = { p, q };
endmodule

/* MUX21I is an inverting 2:1 multiplexor */
module MUX21I ( A, B, s, Q );
	input A;
	input B;
	input s;
	output Q;

	assign Q = ~( s ? A : B );
endmodule

/* find Sbox in GF(2^8), by Canright Algorithm */
module AES_SBox_Canright (out, in);

	input   [7:0]   in;

	output  [7:0]   out;

	wire [7:0] A;
	wire [7:0] Q;
	wire [7:0] B, C;
	wire R1, R2, R3, R4, R5, R6, R7, R8, R9;
	wire T1, T2, T3, T4, T5, T6, T7, T8, T9, T10;

	assign A = in;
	assign out = Q;

	/* change basis from GF(2^8) */
	assign R1 = A[7] ^ A[5] ;
	assign R2 = A[7] ~^ A[4] ;
	assign R3 = A[6] ^ A[0] ;
	assign R4 = A[5] ~^ R3 ;
	assign R5 = A[4] ^ R4 ;
	assign R6 = A[3] ^ A[0] ;
	assign R7 = A[2] ^ R1 ;
	assign R8 = A[1] ^ R3 ;
	assign R9 = A[3] ^ R8 ;
	assign B[7] = ~(R7 ~^ R8) ;
	assign B[6] = ~R5 ;
	assign B[5] = ~(A[1] ^ R4) ;
	assign B[4] = ~(R1 ~^ R3) ;
	assign B[3] = ~(A[1]^ R2 ^ R6) ;
	assign B[2] = A[0] ;
	assign B[1] = ~R4 ;
	assign B[0] = ~(A[2] ~^ R9) ;
  
	GF_INV_8 gf_2_8_inverter( B, C );

	/* change basis back from GF(2^8)/GF(2^4)/GF(2^2) to GF(2^8) */
	assign T1 = C[7] ^ C[3];
	assign T2 = C[6] ^ C[4];
	assign T3 = C[6] ^ C[0];
	assign T4 = C[5] ~^ C[3] ; 
	assign T5 = C[5] ~^ T1 ; 
	assign T6 = C[5] ~^ C[1] ; 
	assign T7 = C[4] ~^ T6 ; 
	assign T8 = C[2] ^ T4 ; 
	assign T9 = C[1] ^ T2 ; 
	assign T10 = T3 ^ T5 ; 
	assign Q[7] = ~T4 ;
	assign Q[6] = ~T1 ;
	assign Q[5] = ~T3 ;
	assign Q[4] = ~T5 ;
	assign Q[3] = ~(T2 ^ T5);
	assign Q[2] = ~(T3 ^ T8);
	assign Q[1] = ~T7 ;
	assign Q[0] = ~T9 ;
endmodule