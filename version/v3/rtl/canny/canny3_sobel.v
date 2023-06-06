//============================
//  第3步 sobel算子计算xy幅度
//============================
module canny3_sobel (
    input  wire                         clk                        ,
    input  wire        [   7:0]         gray_data                  ,
    input  wire                         gray_hs, gray_vs,gray_de   ,
    output reg         [   7:0]         Gx,Gy                      ,// -127~127, signed(取反码而不是补码)
    output reg         [   7:0]         Mxy                        ,// 0~255, unsigned, =Gx+Gy,
    output wire                         sobel_hs, sobel_vs, sobel_de 
);

// 矩阵顺序:
// {a1, a2, a3}
// {a4, a5, a6}
// {a7, a8, a9}
wire                   [   7:0]         a1, a2, a3, a4, a5, a6, a7, a8, a9;

reg                    [   9:0]         gx1,gx3                    ;//Gx第1列,Gx第3列,取绝对值
reg                    [   9:0]         gy1,gy3                    ;//Gx第1行,Gx第3行,取绝对值
reg                    [  10:0]         Gx_tmp,Gy_tmp              ;

// clk1, 3x3 算子
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

// clk2
always @(posedge clk) begin
    gx1 <= a1 + {a4,1'b1} + a7;
    gx3 <= a3 + {a6,1'b1} + a9;
    gy1 <= a1 + {a2,1'b1} + a3;
    gy3 <= a7 + {a8,1'b1} + a9;
end

// clk3
always @(posedge clk) begin
    // Gx_tmp
    Gx_tmp[10] <= gx1 > gx3 ? 1'b1 : 1'b0;                          // 定符号, 最高位1为负号
    Gx_tmp[9:0] <= gx1 > gx3 ? gx1 - gx3 : gx3 - gx1;               // 定数值
    // Gy_tmp
    Gy_tmp[10] <= gy1 > gy3 ? 1'b1 : 1'b0;
    Gy_tmp[9:0] <= gy1 > gy3 ? gy1 - gy3 : gy3 - gy1;
end

// clk4
always @(posedge clk) begin
    // Mxy[7:0] = Gx_tmp[9:0] + Gx_tmp[9:0] > 8'd99 ? 8'd0 : 8'd255; // 标准sobel算法取边缘
    Mxy[7:0] = Gx_tmp[9:3] + Gx_tmp[9:3];                           // 右边两个数去除了符号位(第10位),且位宽均为7
    Gx[7:0] = Gx_tmp[10:3];                                         // 最高位为符号位(1为负号)
    Gy[7:0] = Gy_tmp[10:3];                                         // 最高位为符号位(1为负号)
end

// 信号同步: 形成3x3矩阵耗费1clk, 算子耗费3clk, 因此信号要延迟4拍
reg                    [   3:0]         sobel_de_r,sobel_hs_r,sobel_vs_r;

always @(posedge clk) begin
    sobel_de_r <= {sobel_de_r[2:0], gray_de};
    sobel_hs_r <= {sobel_hs_r[2:0], gray_hs};
    sobel_vs_r <= {sobel_vs_r[2:0], gray_vs};
end

assign sobel_de = sobel_de_r[3];
assign sobel_hs = sobel_hs_r[3];
assign sobel_vs = sobel_vs_r[3];

endmodule