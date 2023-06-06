`timescale  1ns / 1ps

`include "../devide/my_video_define.v"

module tb_median_filtering;

parameter PERIOD     = 10;

reg         rst_n = 0;
reg         clk = 0;

wire        gen_hs, gen_vs, gen_de;
wire [7:0]  gen_gray;
wire        med_hs, med_vs, med_de;
wire [7:0]  med_data;

median_filtering u_median_filtering(
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    .iData          (gen_gray       ),
    .i_de           (gen_de         ),
    .i_hs           (gen_hs         ),
    .i_vs           (gen_vs         ),
    .med_hs         (med_hs         ),
    .med_vs         (med_vs         ),
    .med_de         (med_de         ),
    .oData          (med_data       )
);

gray_gen u_gray_gen (
    // input
    .video_clk      (clk            ),
    .rst_n          (rst_n          ),
    // output
    .hs             (gen_hs         ),
    .vs             (gen_vs         ),
    .de             (gen_de         ),
    .x              (               ),
    .y              (               ),
    .oGray          (gen_gray       ) 
);

initial forever #(PERIOD/2)  clk = ~clk;
initial #(PERIOD*2) rst_n  =  1;

initial begin
    #((PERIOD*`ROW*`COL)*3);
    $stop;
end

endmodule