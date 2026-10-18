`timescale 1ns /1ps

module AXI4_LITE_MASTER(

input CLK,
input RESETN,
input START,

input [15:0] CMD_IN,
input [31:0] DATA_IN,

output reg GET_DATA,
output reg GET_CMD,
output reg [31:0] DATA_OUT,

output reg [7:0] AWADDR,
output reg AWVALID,
input AWREADY,

output reg [31:0] WDATA,
output reg [3:0] WSTRB,
output reg WVALID,
input WREADY,

input BVALID,
output reg BREADY,

output reg [7:0] ARADDR,
output reg ARVALID,
input ARREADY,

input [31:0] RDATA,
input RVALID,
output reg RREADY
);

/* START EDGE DETECTOR */

reg start_d;
wire start_edge;

assign start_edge = START & ~start_d;

always @(posedge CLK or negedge RESETN) begin
if(!RESETN)
start_d <= 0;
else
start_d <= START;
end


/* INTERNAL */

reg [7:0] addr;
reg [7:0] size;
reg cmd;

reg aw_done;
reg w_done;


/* FSM */

localparam
IDLE  = 0,
GETCMD= 1,
W_REQ = 2,
W_RESP= 3,
R_REQ = 4,
R_DATA= 5;

reg [2:0] state;


always @(posedge CLK or negedge RESETN) begin

if(!RESETN) begin

state <= IDLE;

GET_CMD <= 0;
GET_DATA <= 0;
DATA_OUT <= 0;

AWVALID <= 0;
WVALID  <= 0;
ARVALID <= 0;

BREADY <= 0;
RREADY <= 0;

AWADDR <= 0;
WDATA  <= 0;
ARADDR <= 0;

WSTRB <= 4'hF;

addr <= 0;
size <= 0;
cmd  <= 0;

aw_done <= 0;
w_done  <= 0;

end

else begin

case(state)

IDLE:
begin
if(start_edge) begin
GET_CMD <= 1;
state <= GETCMD;
end
end


GETCMD:
begin

GET_CMD <= 0;

cmd  <= CMD_IN[15];
size <= CMD_IN[14:8];
addr <= CMD_IN[7:0];

if(CMD_IN[15])
state <= W_REQ;
else
state <= R_REQ;

end


/* WRITE REQUEST */

W_REQ:
begin

AWADDR <= addr;

/* FIXED DATA REQUEST */
if(!w_done)
GET_DATA <= 1;
else
GET_DATA <= 0;

WDATA  <= DATA_IN;

if(!aw_done)
AWVALID <= 1;

if(AWVALID && AWREADY) begin
AWVALID <= 0;
aw_done <= 1;
end

if(!w_done)
WVALID <= 1;

if(WVALID && WREADY) begin
WVALID <= 0;
w_done <= 1;
GET_DATA <= 0;
end

if(aw_done && w_done) begin
BREADY <= 1;
state <= W_RESP;
end

end


/* WRITE RESPONSE */

W_RESP:
begin

if(BVALID) begin

BREADY <= 0;

aw_done <= 0;
w_done  <= 0;

addr <= addr + 1;
size <= size - 1;

if(size == 1) begin
GET_CMD <= 1;
state <= GETCMD;
end
else
state <= W_REQ;

end

end


/* READ REQUEST */

R_REQ:
begin

ARADDR <= addr;
ARVALID <= 1;

if(ARVALID && ARREADY) begin
ARVALID <= 0;
RREADY <= 1;
state <= R_DATA;
end

end


/* READ DATA */

R_DATA:
begin

if(RVALID) begin

DATA_OUT <= RDATA;

RREADY <= 0;

addr <= addr + 1;
size <= size - 1;

if(size == 1) begin
GET_CMD <= 1;
state <= GETCMD;
end
else
state <= R_REQ;

end

end

endcase
end
end

endmodule