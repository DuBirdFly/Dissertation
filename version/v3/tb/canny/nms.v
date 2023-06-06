//============================
//  第4步 非极大值抑制FPGA优化版
//  NMS = Non-Maximum Suppression
//============================
module nms (
    input  wire                         clk, rst_n                 ,
    input  wire        [   7:0]         Gx,Gy                      ,// -127~127, signed(取反码而不是补码)
    input  wire        [   7:0]         Mxy                        ,// 0~255, unsigned, =Gx+Gy(已在sobel里同步过)
    input  wire                         sobel_hs,sobel_vs,sobel_de ,
    output reg         [   7:0]         NMS_data                   ,
    output wire                         NMS_hs, NMS_vs, NMS_de      
);

// 矩阵顺序:
// {a1, a2, a3}
// {a4, a5, a6}
// {a7, a8, a9}
wire                   [   7:0]         a1, a2, a3, a4, a5, a6, a7, a8, a9;

reg                    [   9:0]         Gx_x2,Gx_x5,Gy_x2,Gy_x5    ;// Gx_x2 = Gx*2, 其他同理, unsigned

// clk1
opr_3x3 #(
    .DATA_WIDTH         ( 8         ),
    .ADDR_WIDTH         ( 7         ))
u_opr_3x3(
    //ports
    .clk           (clk              ),
    .rst_n         (rst_n            ),
    .clken         (sobel_de         ),
    .din           (Mxy              ),
    .a1            (a1               ),
    .a2            (a2               ),
    .a3            (a3               ),
    .a4            (a4               ),
    .a5            (a5               ),
    .a6            (a6               ),
    .a7            (a7               ),
    .a8            (a8               ),
    .a9            (a9               )
);

// clk1 -- 与3x3矩阵生成是同步的
always @(posedge clk) begin
    Gx_x2 = Gx[6:0] * 4'd2;
    Gx_x5 = Gx[6:0] * 4'd5;
    Gy_x2 = Gy[6:0] * 4'd2;
    Gy_x5 = Gy[6:0] * 4'd5;
end

// clk2
always @(posedge clk) begin
    if ((Gx_x2 > Gy_x5 && a5 >= a4 && a5 >= a6) ||
        (Gy_x2 > Gx_x5 && a5 >= a2 && a5 >= a8))
        NMS_data <= a5;
    else if (((Gx[7] ^ Gy[7]) == 1'b0 && a5 >= a1 && a5 >= a9) ||
            ((Gx[7] ^ Gy[7]) == 1'b1 && a5 >= a3 && a5 >= a7))
        NMS_data <= a5;
    else
        NMS_data <= 1'b0;
end

// 信号同步: 形成3x3矩阵耗费1clk, 非极大值抑制耗费2clk, 因此信号要延迟2拍
reg                    [   1:0]         NMS_de_r,NMS_hs_r,NMS_vs_r ;

always @(posedge clk) begin
    NMS_de_r <= {NMS_de_r[0], sobel_de};
    NMS_hs_r <= {NMS_hs_r[0], sobel_hs};
    NMS_vs_r <= {NMS_vs_r[0], sobel_vs};
end

assign NMS_de = NMS_de_r[1];
assign NMS_hs = NMS_hs_r[1];
assign NMS_vs = NMS_vs_r[1];

endmodule