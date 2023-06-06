//~ `New testbench
`timescale  1ns / 1ps

`include "../devide/my_video_define.v"

// 注意！！：vga_device应该输出 NyaRu_128x96，也就经过极大值抑制的图片

module tb_otus;

    parameter                           PERIOD            = 10     ;

reg                                     rst_n             = 0      ;
reg                                     video_clk         = 0      ;

wire                                    hs                         ;
wire                                    vs                         ;
wire                                    de                         ;
wire                   [  11:0]         x,y                        ;
wire                   [   7:0]         oGray                      ;

initial begin
    forever #(PERIOD/2)  video_clk = ~video_clk;
end

initial begin
    #(PERIOD*2) rst_n  =  1;
end

gray_gen u_gray_gen (
    // input
    .rst_n                             (rst_n                     ),
    .video_clk                         (video_clk                 ),
    // output
    .hs                                (hs                        ),
    .vs                                (vs                        ),
    .de                                (de                        ),
    .x                                 (x                         ),
    .y                                 (y                         ),
    .oGray                             (oGray                     ) 
);

otus u_otus(
    .clock                             (video_clk                 ),
    .rst_n                             (rst_n                     ),
    .iGray_orig                        (oGray                     ),
    .hs                                (hs                        ),
    .vs                                (vs                        ),
    .de                                (de                        ) 
);

initial begin
    #((PERIOD*`ROW*`COL)*9);
    $stop;
end


endmodule