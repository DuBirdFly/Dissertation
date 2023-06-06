// 3x3算子, 需要1clk
module opr_3x3_1024x8(
    input                               din_vld                    ,
    input                               clk                        ,
    input              [   7:0]         din                        ,
    output reg         [   7:0]         a1, a2, a3, a4, a5, a6, a7, a8, a9 
);

wire                   [   7:0]         taps0x,taps1x              ;

// 1clk: 打拍形成矩阵, 矩阵顺序归正
always @(posedge clk) begin
    {a1, a2, a3} <= {a2, a3, taps1x};
    {a4, a5, a6} <= {a5, a6, taps0x};
    {a7, a8, a9} <= {a8, a9, din};
end

shift1024x8 shift1024x8_m0 (
    .clken                             (din_vld                   ),
    .clock                             (clk                       ),
    .shiftin                           (din                       ),
    .shiftout                          (                          ),
    .taps0x                            (taps0x                    ),
    .taps1x                            (taps1x                    ) 
);

endmodule