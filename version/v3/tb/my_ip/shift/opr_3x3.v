// 3x3算子, 需要1clk
module opr_3x3 #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 7
)(
    input  wire                     clk, rst_n,
    input  wire                     clken,
    input  wire [DATA_WIDTH-1:0]    din,
    output reg  [DATA_WIDTH-1:0]    a1, a2, a4, a5, a7, a8,
    output wire [DATA_WIDTH-1:0]    a3, a6, a9
);

wire [DATA_WIDTH-1:0] taps2, taps1, shiftout;

assign {a3, a6, a9} = {taps2, taps1, din};

// 1clk: 打拍形成矩阵, 矩阵顺序归正
always @(posedge clk) begin
    {a1, a2} <= {a2, a3};
    {a4, a5} <= {a5, a6};
    {a7, a8} <= {a8, a9};
end

// 1clk: 输入输出延时
shift_1x3 #(
    .DATA_WIDTH       (8                ),
    .ADDR_WIDTH       (7                ))
u_shift_1x3(
    //ports
    .clk              (clk              ),
    .rst_n            (rst_n            ),
    .shiftin          (din              ),
    .clken            (clken            ),
    .taps2            (taps2            ),
    .taps1            (taps1            ),
    .shiftout         (shiftout         )
);


endmodule