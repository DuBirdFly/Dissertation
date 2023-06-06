module shift_1x3 #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 7
)(
    input  wire                     clk, rst_n,
    input  wire [DATA_WIDTH-1:0]    shiftin,
    input  wire                     clken,
    output wire [DATA_WIDTH-1:0]    taps2,
    output wire [DATA_WIDTH-1:0]    taps1,
    output reg  [DATA_WIDTH-1:0]    shiftout
);

wire                        wren1, rden1;
wire                        wren2, rden2;
wire                        full1, full2;
wire [ADDR_WIDTH : 0]       count1;

reg                         fifo_flag;     // 0：仅读入状态；1：边读边写状态

always@(posedge clk or negedge rst_n)
    if (!rst_n) fifo_flag <= 1'b0;
    else if (&count1[ADDR_WIDTH-1:0]) fifo_flag <= 1'b1;

assign wren2 = clken & ((~full2 & ~full1) | fifo_flag);
assign wren1 = clken & (( full2 & ~full1) | fifo_flag);

assign {rden2, rden1} = {fifo_flag, fifo_flag};

always@(posedge clk or negedge rst_n)
    shiftout <= shiftin;

sfifo #(
    .DATA_WIDTH     (DATA_WIDTH     ),
    .ADDR_WIDTH     (ADDR_WIDTH     ))
sfifo_taps2(
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    .w_en           (wren2          ),
    .data_in        (shiftin        ),
    .r_en           (rden2          ),
    .data_out       (taps2          ),
    .full           (full2          ),
    .empty          (               ),
    .count          (               )
);

sfifo #(
    .DATA_WIDTH     (DATA_WIDTH     ),
    .ADDR_WIDTH     (ADDR_WIDTH     ))
sfifo_taps1(
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    .w_en           (wren1          ),
    .data_in        (shiftin        ),
    .r_en           (rden1          ),
    .data_out       (taps1          ),
    .full           (full1          ),
    .empty          (               ),
    .count          (count1         )
);



endmodule