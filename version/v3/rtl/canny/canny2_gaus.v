//============================
// 步骤2:高斯滤波高斯滤波,耗费3clk,
//============================
module canny2_gaus(
    input  wire                         clk                        ,
    input  wire        [   7:0]         gray_data                  ,
    input  wire                         gray_de, gray_hs, gray_vs  ,
    output wire                         gaus_hs, gaus_vs, gaus_de  ,
    output reg         [   7:0]         gaus_oData                  
);

reg                    [   9:0]         gs1, gs3                   ;
reg                    [  10:0]         gs2                        ;
reg                    [  11:0]         gs                         ;

// 矩阵顺序
// {a1, a2, a3}
// {a4, a5, a6}
// {a7, a8, a9}
wire                   [   7:0]         a1, a2, a3, a4, a5, a6, a7, a8, a9;

// 1clk, 3x3 算子
opr_3x3_1024x8 opr_3x3_1024x8_m0 (
    .clk                               (clk                       ),
    .din_vld                           (gray_de                   ),
    .din                               (gray_data                 ),
    .a1                                (a1                        ),
    .a2                                (a2                        ),
    .a3                                (a3                        ),
    .a4                                (a4                        ),
    .a5                                (a5                        ),
    .a6                                (a6                        ),
    .a7                                (a7                        ),
    .a8                                (a8                        ),
    .a9                                (a9                        ) 
);

// clk2, 上中下的一行值
//---------------------------------------------------
always @ (posedge clk)begin
    gs1 <=  a1       + {a2, 1'b0}  +  a3;                           // * [1,2,1]
    gs2 <= {a4,1'b0} + {a5, 2'b00} + {a6,1'b1};                     // * [2,4,2]
    gs3 <=  a7       + {a8, 1'b0}  +  a9;                           // * [1,2,1]
end

// clk3, 相加
//---------------------------------------------------
always @(posedge clk)begin
    gs <= gs1 + gs2 + gs3;
end

// clk4，除以16 -> 右移4位 -> 取高8位
//---------------------------------------------------
always @(posedge clk) begin
    gaus_oData <= gs[11:4];
end

// 信号同步:形成3x3矩阵耗费1clk, 算子耗费3clk, 因此要延迟4拍
reg                    [   3:0]         gaus_de_r,gaus_hs_r,gaus_vs_r       ;

always @(posedge clk) begin
    gaus_de_r <= {gaus_de_r[2:0], gray_de};
    gaus_hs_r <= {gaus_hs_r[2:0], gray_hs};
    gaus_vs_r <= {gaus_vs_r[2:0], gray_vs};
end

assign gaus_de = gaus_de_r[3];
assign gaus_hs = gaus_hs_r[3];
assign gaus_vs = gaus_vs_r[3];

endmodule