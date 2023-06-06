`include "my_video_define.v"

module gray_gen (
    // sys
    input                               rst_n                      ,
    input                               video_clk                  ,

    // output
    output wire                         hs,vs,de                   ,
    output reg         [  11:0]         x,y                        ,// 注意!!!从1开始
    output wire        [   7:0]         oGray                       
);

reg                    [   7:0]         data_men0 [`ROW*`COL-1:0]  ;// 备份,50*50-1 = 2499,后面是  data_men0 [`ROW*`COL-1:0]
reg                    [  31:0]         cnt                        ;

wire                                    de_neg,vs_neg              ;

// 特别注意, 不要用这种乘法链去找地址, 会有bug......
// assign oGray = (x > `COL || y > `ROW) ? 8'd0 : data_men0[x-1+(y-1)*`COL];

always @(posedge video_clk) begin
    if (!rst_n) cnt <= 1'b0;
    else if (de && cnt < `ROW*`COL - 1) cnt <= cnt + 1'b1;
    else if (vs_neg) cnt <= 1'b0;
end

assign oGray = data_men0[cnt];

my_color_bar u_my_color_bar(
    .clk                               (video_clk                 ),
    .rst                               (~rst_n                    ),
    .hs                                (hs                        ),
    .vs                                (vs                        ),
    .de                                (de                        ),
    .rgb_r                             (                          ),
    .rgb_g                             (                          ),
    .rgb_b                             (                          )
);

getNegPos u_getNegPos_de(
    .clk                               (video_clk                 ),
    .iData                             (de                        ),
    .oPos                              (                          ),
    .oNeg                              (de_neg                    ) 
);

getNegPos u_getNegPos_vs(
    .clk                               (video_clk                 ),
    .iData                             (vs                        ),
    .oPos                              (                          ),
    .oNeg                              (vs_neg                    ) 
);

initial begin
    $readmemh(`PICTURE, data_men0);
end

// 此时的(y,x)是和matlab一致的
// x, 注意!!!从1开始
always @(posedge video_clk or negedge rst_n)
    if (!rst_n) x <= 1'b1;
    else if (de) x <= x + 1'b1;
    else x <= 1'b1;

// y, 注意!!!从1开始
always @(posedge video_clk or negedge rst_n)
    if (!rst_n) y <= 1'b1;
    else if (de_neg) y <= y +1'b1;
    else if (~vs) y <= 1'b1;

endmodule
