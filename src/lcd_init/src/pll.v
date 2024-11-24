`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/03 15:10:07
// Design Name: 
// Module Name: pll
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


module pll(
    input  wire clk_in,
    output reg  clk_out_1,
    output reg  clk_out_2
    );

reg [6:0] clk_cnt_1;// 100Mhz to 10Mhz
reg [6:0] clk_cnt_2;// 100Mhz to 20Mhz
initial begin
    clk_cnt_1   = 7'b0000000;
    clk_cnt_2   = 7'b0000000;
    clk_out_1 = 1'b0;
    clk_out_2 = 1'b0;
end

always @(posedge clk_in) begin
    if(clk_cnt_1 == 7'd5) begin
            clk_out_1 <= ~clk_out_1;
            clk_cnt_1 <=  7'b0000000;
        end
    else begin
            clk_cnt_1 <= clk_cnt_1 + 1'b1;
            clk_out_1 <= clk_out_1;
    end
end

always @(posedge clk_in) begin
    if(clk_cnt_2 == 7'd10) begin
            clk_out_2 <= ~clk_out_2;
            clk_cnt_2 <=  7'b0000000;
        end
    else begin
            clk_cnt_2 <= clk_cnt_2 + 1'b1;
            clk_out_2 <= clk_out_2;
    end
end


endmodule
