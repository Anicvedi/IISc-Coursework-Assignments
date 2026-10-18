module top_question2b (
    input  wire        clk,
    input  wire        btn,
    input  wire        dir,
    input  wire        rst_n,
    input  wire [3:0]  N,
    input  wire        load,
    input  wire [3:0]  load_val,

    output wire [3:0]  count
);

wire pulse;

// Debouncer
debouncer #(
    .MAX_COUNT(2_000_000)
) u_db (
    .clk(clk),
    .btn_async(btn),
    .btn_pulse(pulse)
);

// Mode selection
wire [1:0] mode;
assign mode = (dir) ? 2'b01 : 2'b10;

// Counter
modN_updown_counter u_counter (
    .clk(clk),
    .clk_en(pulse),
    .rst_n(rst_n),
    .N(N),                
    .mode(mode),
    .load(load),           
    .load_val(load_val),   
    .count(count)
);

endmodule