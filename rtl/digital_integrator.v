module digital_integrator #(
    parameter WIDTH = 8
)(
    input wire clk,
    input wire rst,
    input wire enable,
    input wire signed [WIDTH-1:0] x_in,
    output reg signed [WIDTH-1:0] y_out
);

always @(posedge clk) begin
    if (rst)
        y_out <= 0;
    else if (enable)
        y_out <= y_out + x_in;
end

endmodule