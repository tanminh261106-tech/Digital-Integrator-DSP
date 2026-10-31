
`timescale 1ns/1ps

module tb_digital_integrator;

    parameter WIDTH = 8;
    reg enable;
    reg clk;
    reg rst;
    reg signed [WIDTH-1:0] x_in;
    wire signed [WIDTH-1:0] y_out;

    integer errors;

    digital_integrator #(
        .WIDTH(WIDTH)
    ) dut (
        .clk(clk),
        .rst(rst),
        .x_in(x_in),
        .enable(enable),
        .y_out(y_out)
    );

    // Clock period = 10 ns
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Task: check expected output
    task check_output;
        input signed [WIDTH-1:0] expected;
        begin
            #1;
            if (y_out !== expected) begin
                $display(
                    "FAIL at %0t: expected=%0d, actual=%0d",
                    $time, expected, y_out
                );
                errors = errors + 1;
            end
            else begin
                $display(
                    "PASS at %0t: y_out=%0d",
                    $time, y_out
                );
            end
        end
    endtask

    initial begin
        rst = 1;
        x_in = 0;
        errors = 0;
        enable = 1'b1;
        // Reset
        repeat (2) @(negedge clk);
        @(posedge clk);
        check_output(0);

        // Sample 1: 0 + 2 = 2
        @(negedge clk);
        rst = 0;
        x_in = 8'sd2;
        @(posedge clk);
        check_output(8'sd2);

        // Sample 2: 2 + 3 = 5
        @(negedge clk);
        x_in = 8'sd3;
        @(posedge clk);
        check_output(8'sd5);

        // Sample 3: 5 + (-1) = 4
        @(negedge clk);
        x_in = -8'sd1;
        @(posedge clk);
        check_output(8'sd4);

        // Sample 4: 4 + 4 = 8
        @(negedge clk);
        x_in = 8'sd4;
        @(posedge clk);
        check_output(8'sd8);

        // Zero input: output remains 8
        @(negedge clk);
        x_in = 0;
        @(posedge clk);
        check_output(8'sd8);

        // Negative samples: 8 - 2 - 3 = 3
        @(negedge clk);
        x_in = -8'sd2;
        @(posedge clk);
        check_output(8'sd6);

        @(negedge clk);
        x_in = -8'sd3;
        @(posedge clk);
        check_output(8'sd3);

        // Reset during operation
        @(negedge clk);
        rst = 1;
        @(posedge clk);
        check_output(0);

        // Accumulation starts again after reset
        @(negedge clk);
        rst = 0;
        x_in = 8'sd5;
        @(posedge clk);
        check_output(8'sd5);

        if (errors == 0)
            $display("ALL TESTS PASSED");
        else
            $display("TESTS FAILED: %0d errors", errors);

        $finish;
    end

endmodule
