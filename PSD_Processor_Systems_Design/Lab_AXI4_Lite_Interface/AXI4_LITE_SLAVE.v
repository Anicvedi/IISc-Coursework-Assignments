`timescale 1ns /1ps

module AXI4_LITE_SLAVE(

input CLK,
input RESETN,

input [7:0] AWADDR,
input AWVALID,
output reg AWREADY,

input [31:0] WDATA,
input [3:0] WSTRB,
input WVALID,
output reg WREADY,

output reg BVALID,
input BREADY,

input [7:0] ARADDR,
input ARVALID,
output reg ARREADY,

output reg [31:0] RDATA,
output reg RVALID,
input RREADY
);

/* BRAM */

reg ena;
reg [0:0]wea;
reg [7:0] addra;
reg [31:0] dina;
wire [31:0] douta;

blk_mem_gen_0 bram(
.clka(CLK),
.ena(ena),
.wea(wea),
.addra(addra),
.dina(dina),
.douta(douta)
);


/* INTERNAL */

reg [7:0] waddr;

reg write_addr_done;
reg write_data_done;

/* BRAM latency pipeline */
reg [2:0] read_delay;


/* LOGIC */

always @(posedge CLK or negedge RESETN) begin

if(!RESETN) begin

AWREADY <= 0;
WREADY  <= 0;
BVALID  <= 0;

ARREADY <= 0;
RVALID  <= 0;
RDATA   <= 0;

ena <= 0;
wea <= 0;
addra <= 0;
dina  <= 0;

write_addr_done <= 0;
write_data_done <= 0;

read_delay <= 0;

end

else begin

AWREADY <= 0;
WREADY  <= 0;
ARREADY <= 0;

ena <= 0;
wea <= 0;


/******** WRITE ADDRESS ********/

if(AWVALID && !write_addr_done) begin
AWREADY <= 1;
waddr <= AWADDR;
write_addr_done <= 1;
end


/******** WRITE DATA ********/

if(WVALID && !write_data_done) begin

WREADY <= 1;

ena   <= 1;
wea   <= 1;
addra <= waddr;
dina  <= WDATA;

write_data_done <= 1;

end


/******** WRITE RESPONSE ********/

if(write_addr_done && write_data_done)
BVALID <= 1;

if(BVALID && BREADY) begin
BVALID <= 0;
write_addr_done <= 0;
write_data_done <= 0;
end



/******** READ ADDRESS ********/

if(ARVALID && read_delay == 0) begin

ARREADY <= 1;

ena   <= 1;
wea   <= 0;
addra <= ARADDR;

/* BRAM latency = 2 cycles + 1 FSM cycle */
read_delay <= 3;

end


/******** LATENCY PIPELINE ********/

if(read_delay != 0)
read_delay <= read_delay - 1;


/******** DATA READY ********/

if(read_delay == 1) begin
RDATA  <= douta;
RVALID <= 1;
end


/******** READ HANDSHAKE ********/

if(RVALID && RREADY)
RVALID <= 0;

end
end

endmodule