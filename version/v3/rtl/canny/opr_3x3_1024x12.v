// 需要1clk
module opr_3x3_1024x12(
    input                               din_vld                    ,
    input                               clk                        ,
    input              [  12:0]         din                        ,
    output reg         [  12:0]         a1, a2, a3, a4, a5, a6, a7, a8, a9 
);

wire                   [  12:0]         taps0x,taps1x              ;

// 1clk: 打拍形成矩阵, 矩阵顺序归正
always @(posedge clk) begin
    {a1, a2, a3} <= {a2, a3, taps1x};
    {a4, a5, a6} <= {a5, a6, taps0x};
    {a7, a8, a9} <= {a8, a9, din};
end

shift_1024x12 shift_1024x12_m0 (
    .clken                             (din_vld                   ),
    .clock                             (clk                       ),
    .shiftin                           (din                       ),
    .shiftout                          (                          ),
    .taps0x                            (taps0x                    ),
    .taps1x                            (taps1x                    ) 
);

endmodule