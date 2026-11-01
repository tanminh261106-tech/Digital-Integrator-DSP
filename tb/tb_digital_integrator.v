
`timescale 1ns/1ps

module tb_digital_integrator;

    parameter WIDTH = 8;

    // Testbench signals
    reg enable;
    reg clk;
    reg rst;
    reg signed [WIDTH-1:0] x_in;
    wire signed [WIDTH-1:0] y_out;

    // Test counters
    integer errors;
    integer tests;

    // Instantiate DUT
    digital_integrator #(
        .WIDTH(WIDTH)
    ) dut (
        .clk(clk),
        .rst(rst),
        .x_in(x_in),
        .enable(enable),
        .y_out(y_out)
    );

    // Clock generation: period = 10ns
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Task: check expected output
    task check_output;
        input signed [WIDTH-1:0] expected;
        begin
            #1;
            tests = tests + 1;

            if (y_out !== expected) begin
                $display(
                    "FAIL at %0t: expected=%0d, actual=%0d",
                    $time, expected, y_out
                );
                errors = errors + 1;
            end
            else begin
                $display(
                    "PASS at %0t: expected=%0d, actual=%0d",
                    $time, expected, y_out
                );
            end
        end
    endtask

    // Main test sequence
    initial begin

        // Initialize signals
        rst = 1;
        x_in = 0;
        enable = 1;
        errors = 0;
        tests = 0;

        $display("====================================");
        $display(" DIGITAL INTEGRATOR TEST START");
        $display("====================================");

        // TEST 1: Initial reset
        $display("\nTEST 1: INITIAL RESET");

        repeat (2) @(negedge clk);
        @(posedge clk);
        check_output(0);

        // TEST 2: Positive inputs
        $display("\nTEST 2: POSITIVE INPUTS");

        @(negedge clk);
        rst = 0;
        x_in = 8'sd2;

        @(posedge clk);
        check_output(8'sd2);

        @(negedge clk);
        x_in = 8'sd3;

        @(posedge clk);
        check_output(8'sd5);

        // TEST 3: Negative inputs
        $display("\nTEST 3: NEGATIVE INPUTS");

        @(negedge clk);
        x_in = -8'sd1;

        @(posedge clk);
        check_output(8'sd4);

        @(negedge clk);
        x_in = -8'sd2;

        @(posedge clk);
        check_output(8'sd2);

        // TEST 4: Zero input
        $display("\nTEST 4: ZERO INPUT");

        @(negedge clk);
        x_in = 0;

        @(posedge clk);
        check_output(8'sd2);

        // TEST 5: Enable disabled
        $display("\nTEST 5: ENABLE DISABLED");

        @(negedge clk);
        enable = 0;
        x_in = 8'sd20;

        @(posedge clk);
        check_output(8'sd2);

        // TEST 6: Enable enabled again
        $display("\nTEST 6: ENABLE ENABLED AGAIN");

        @(negedge clk);
        enable = 1;
        x_in = 8'sd5;

        @(posedge clk);
        check_output(8'sd7);

        // TEST 7: Reset during operation
        $display("\nTEST 7: RESET DURING OPERATION");

        @(negedge clk);
        rst = 1;

        @(posedge clk);
        check_output(0);

        // TEST 8: Accumulation after reset
        $display("\nTEST 8: ACCUMULATION AFTER RESET");

        @(negedge clk);
        rst = 0;
        x_in = 8'sd5;

        @(posedge clk);
        check_output(8'sd5);

        // TEST 9: Positive overflow
        $display("\nTEST 9: POSITIVE OVERFLOW");

        @(negedge clk);
        rst = 1;

        @(posedge clk);
        check_output(0);

        @(negedge clk);
        rst = 0;
        x_in = 8'sd120;

        @(posedge clk);
        check_output(8'sd120);

        @(negedge clk);
        x_in = 8'sd10;

        @(posedge clk);
        check_output(-8'sd126);

        // TEST 10: Negative overflow
        $display("\nTEST 10: NEGATIVE OVERFLOW");

        @(negedge clk);
        rst = 1;

        @(posedge clk);
        check_output(0);

        @(negedge clk);
        rst = 0;
        x_in = -8'sd120;

        @(posedge clk);
        check_output(-8'sd120);

        @(negedge clk);
        x_in = -8'sd20;

        @(posedge clk);
        check_output(8'sd116);

        // FINAL SUMMARY
        $display("\n====================================");
        $display(" SIMULATION SUMMARY");
        $display("====================================");

        $display("Total tests : %0d", tests);
        $display("Total errors: %0d", errors);

        if (errors == 0)
            $display("RESULT: ALL TESTS PASSED!");
        else
            $display("RESULT: TEST FAILED!");

        $display("====================================");

        $finish;
    end

endmodule
