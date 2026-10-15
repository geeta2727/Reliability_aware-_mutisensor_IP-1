`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.10.2026 10:15:14
// Design Name: 
// Module Name: interface
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


module sensor_channel #(
    parameter MIN_VALUE = 0,
    parameter MAX_VALUE = 80,
    parameter TIMEOUT_CYCLES = 10
)(
    input clk,
    input reset,
    input [7:0] sensor_data,
    input sensor_valid,
    output reg [7:0] accepted_data,
    output reg accepted_valid,
    output reg range_error,
    output reg timeout_error,
    output reg healthy
);

reg [31:0] timeout_count;

always @(posedge clk) begin
    if (reset) begin
        timeout_count <= 0;
        accepted_data <= 0;
        accepted_valid <= 0;
        range_error <= 0;
        timeout_error <= 0;
        healthy <= 0;
    end else begin
        accepted_valid <= 0;

        if (sensor_valid) begin
            timeout_count <= 0;
            timeout_error <= 0;

            if (sensor_data >= MIN_VALUE &&
                sensor_data <= MAX_VALUE) begin
                accepted_data <= sensor_data;
                accepted_valid <= 1;
                range_error <= 0;
                healthy <= 1;
            end else begin
                range_error <= 1;
                healthy <= 0;
            end
        end else if (timeout_count < TIMEOUT_CYCLES) begin
            timeout_count <= timeout_count + 1;

            if (timeout_count == TIMEOUT_CYCLES - 1) begin
                timeout_error <= 1;
                healthy <= 0;
            end
        end
    end
end

endmodule


module sensor_reliability_top(
    input clk,
    input reset,
    input [7:0] temp_data,
    input [7:0] distance_data,
    input [7:0] gas_data,
    input [2:0] sensor_valid,
    output [7:0] temp_out,
    output [7:0] distance_out,
    output [7:0] gas_out,
    output [2:0] accepted_valid,
    output [2:0] range_error,
    output [2:0] timeout_error,
    output [2:0] healthy
);

sensor_channel #(
    .MIN_VALUE(0),
    .MAX_VALUE(80),
    .TIMEOUT_CYCLES(10)
) temperature_channel (
    .clk(clk),
    .reset(reset),
    .sensor_data(temp_data),
    .sensor_valid(sensor_valid[0]),
    .accepted_data(temp_out),
    .accepted_valid(accepted_valid[0]),
    .range_error(range_error[0]),
    .timeout_error(timeout_error[0]),
    .healthy(healthy[0])
);

sensor_channel #(
    .MIN_VALUE(2),
    .MAX_VALUE(200),
    .TIMEOUT_CYCLES(10)
) distance_channel (
    .clk(clk),
    .reset(reset),
    .sensor_data(distance_data),
    .sensor_valid(sensor_valid[1]),
    .accepted_data(distance_out),
    .accepted_valid(accepted_valid[1]),
    .range_error(range_error[1]),
    .timeout_error(timeout_error[1]),
    .healthy(healthy[1])
);

sensor_channel #(
    .MIN_VALUE(10),
    .MAX_VALUE(240),
    .TIMEOUT_CYCLES(10)
) gas_channel (
    .clk(clk),
    .reset(reset),
    .sensor_data(gas_data),
    .sensor_valid(sensor_valid[2]),
    .accepted_data(gas_out),
    .accepted_valid(accepted_valid[2]),
    .range_error(range_error[2]),
    .timeout_error(timeout_error[2]),
    .healthy(healthy[2])
);

endmodule
