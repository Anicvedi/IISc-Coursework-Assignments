(*blackbox*)
module Counter(
    input logic clk,
    input logic [2:0] mode,
    output logic [2:0]count
);

    /*always_ff @(posedge clk) begin
        count  = (count)?0:count + 1;
    end
*/

    always_comb begin
        count = 1; 
        if (mode == 0) count = 0;
        else if(mode == 1) count = 1;
        else count = 2;
    end

endmodule