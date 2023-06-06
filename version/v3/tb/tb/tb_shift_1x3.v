`timescale  1ns / 1ps
module tb_shift_1x3;

parameter PERIOD     = 10;
parameter DATA_WIDTH = 8;
parameter ADDR_WIDTH = 7;

reg                   rst_n = 0;
reg                   clk = 0;

wire [DATA_WIDTH-1:0]   shiftin;
wire [DATA_WIDTH-1:0]   taps2, taps1, shiftout;

reg  [6:0]              cnt = 0;
reg                     clken = 0;
reg  [7:0]              num = 0;

always@(posedge clk or negedge rst_n)
    if (!rst_n) cnt <= 1'b0;
    else cnt <= cnt + 1'b1;

always@(posedge clk or negedge rst_n)
    if (!rst_n) num <= 1'b0;
    else if (&cnt & ~&num) num <= num + 1'b1;

always@(posedge clk or negedge rst_n) 
    if (!rst_n) clken <= 0;
    else if (&cnt) clken <= 1;

assign shiftin = {1'b0,cnt};

shift_1x3 #(
    .DATA_WIDTH       (8                ),
    .ADDR_WIDTH       (7                ))
u_shift_1x3(
    //ports
    .clk              (clk              ),
    .rst_n            (rst_n            ),
    .shiftin          (shiftin          ),
    .clken            (clken            ),
    .taps2            (taps2            ),
    .taps1            (taps1            ),
    .shiftout         (shiftout         )
);

initial forever #(PERIOD/2)  clk = ~clk;
initial #(PERIOD*2) rst_n  =  1;

initial begin
    #(PERIOD*{ADDR_WIDTH{1'b1}}*5);
    $stop;
end


endmodule