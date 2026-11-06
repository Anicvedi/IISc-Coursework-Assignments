`timescale 1ns/1ps

module tbHA;

    logic a;
    logic b;
    logic s;
    logic cout;

    logic clk;

    HA dut(.*);

    initial begin
        a = 0;
        b = 0;
        clk = 0;
    end

    always #5 clk = ~clk;

    initial begin
        $dumpfile("tbHA.vcd");
        $dumpvars(0,tbHA);
    end

    initial begin
        repeat(2) @(negedge clk);
        b = 1;
        @(negedge clk);
         a = 1; b = 0;
        @(negedge clk);
        b = 1; a = 1;
        #50;
        $finish;
    end

endmodule