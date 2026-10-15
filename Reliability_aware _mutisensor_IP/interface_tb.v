`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.10.2026 10:16:20
// Design Name: 
// Module Name: interface_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module tb_sensor_reliability;

reg clk = 0;
reg reset = 1;
reg [7:0] temp_data = 0;
reg [7:0] distance_data = 0;
reg [7:0] gas_data = 0;
reg [2:0] sensor_valid = 0;

wire [7:0] temp_out;
wire [7:0] distance_out;
wire [7:0] gas_out;
wire [2:0] accepted_valid;
wire [2:0] range_error;
wire [2:0] timeout_error;
wire [2:0] healthy;

always #5 clk = ~clk;

sensor_reliability_top dut (
    .clk(clk),
    .reset(reset),
    .temp_data(temp_data),
    .distance_data(distance_data),
    .gas_data(gas_data),
    .sensor_valid(sensor_valid),
    .temp_out(temp_out),
    .distance_out(distance_out),
    .gas_out(gas_out),
    .accepted_valid(accepted_valid),
    .range_error(range_error),
    .timeout_error(timeout_error),
    .healthy(healthy)
);

initial begin
    $monitor("time=%0t valid=%b accepted=%b range=%b timeout=%b healthy=%b temp_out=%d distance_out=%d gas_out=%d",
        $time, sensor_valid, accepted_valid, range_error,
        timeout_error, healthy, temp_out, distance_out, gas_out);

    repeat (2) @(negedge clk);
    reset = 0;

    temp_data = 25;
    distance_data = 100;
    gas_data = 80;
    sensor_valid = 3'b111;
    @(negedge clk);
    sensor_valid = 0;

    repeat (2) @(negedge clk);
    temp_data = 100;
    sensor_valid = 3'b001;
    @(negedge clk);
    sensor_valid = 0;

    repeat (15) @(negedge clk);

    distance_data = 120;
    sensor_valid = 3'b010;
    @(negedge clk);
    sensor_valid = 0;

    repeat (3) @(negedge clk);
    $finish;
end

endmodule
