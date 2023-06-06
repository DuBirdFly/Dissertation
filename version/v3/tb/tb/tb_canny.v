`timescale  1ns / 1ps

`include "../devide/my_video_define.v"

module tb_canny;

parameter PERIOD     = 10;

reg         rst_n = 0;
reg         clk = 0;

wire        gen_hs, gen_vs, gen_de;
wire [7:0]  gen_gray;

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

wire [7:0]       NMS_data;
wire             NMS_hs, NMS_vs, NMS_de;

canny_top u_canny_top(
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    // input
    .gray_data      (gen_gray       ),
    .gray_hs        (gen_hs         ),
    .gray_vs        (gen_vs         ),
    .gray_de        (gen_de         ),
    // output
    .NMS_data       (NMS_data       ),
    .NMS_hs         (NMS_hs         ),
    .NMS_vs         (NMS_vs         ),
    .NMS_de         (NMS_de         )
);

initial forever #(PERIOD/2)  clk = ~clk;
initial #(PERIOD*2) rst_n  =  1;

initial begin
    #((PERIOD*`ROW*`COL)*2);
    $stop;
end

endmodule