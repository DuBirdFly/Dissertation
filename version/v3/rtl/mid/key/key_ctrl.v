// -----------------------------------------------------------------
//  RESET     iKEY1     iKEY2     iKEY3     (按下为0,未消抖,接到管脚)
// PIN_N13   PIN_M15   PIN_M16   PIN_E16    (管脚约束)
//  None     oKey[2]   oKey[1]   oKey[0]    (按下为1,已消抖,key_busy期间无效)
//  None     3'b100    3'b010    3'b001     (非组合按键下的oKey数值)
//  RESET       -       MODE        +       (按键功能)

// -----------------------------------------------------------------
// mode[reg]模式说明:
// mode = 0 : VGA输出显示切换模式
// mode = 1 : Sobel阈值设置模式
// mode = 2 : Otus数值显示模式

module key_ctrl (
    // sys
    input  wire                         sys_clk                    ,// 50MHz
    input  wire                         rst_n                      ,
    // input key
    input  wire                         iKey1                      ,
    input  wire                         iKey2                      ,
    input  wire                         iKey3                      ,
    input  wire        [   6:0]         T_otus                     ,// 废案，因为T_otus的值和仿真不一样，就不放到数码管上丢脸了
    // output
    output reg         [  19:0]         seg_value                  ,// 数码管显示的数字
    // 0: rgb输出; 1: gaus滤波输出; 2: sobel输出; 3: 黄色Canny输出;
    output reg         [   3:0]         VGA_MODE                   ,// VGA输出模式, (canny_top 的输入)
    output reg         [   7:0]         Sobel_TH                    // Sobel阈值, (canny_top 的输入)
);

localparam                              MODE_MAX = 3               ;// key2控制的模式共有 MODE_MAX 个
localparam                              VGA_MODE_MAX = 4           ;// VGA_MODE 共有 VGA_MODE_MAX 个

// 0 : VGA输出显示切换模式; mode = 1 : Sobel阈值设置模式; mode = 2 : Otus数值显示模式
reg                    [   3:0]         mode                       ;

wire                                    key1, key2, key3           ;

// mode
always @(posedge sys_clk or negedge rst_n) begin
    if (!rst_n)
        mode = 1'b0;
    else if (key2) begin
        if (mode == MODE_MAX - 1'b1) mode <= 1'b0;
        else mode = mode + 1'b1;
    end
end

// VGA_MODE
always @(posedge sys_clk or negedge rst_n) begin
    if (!rst_n)
        VGA_MODE <= 4'd0;
    else if (mode == 1'b0) begin
        if (key3) begin
            if (VGA_MODE == VGA_MODE_MAX - 1'd1) VGA_MODE <= 4'd0;
            else VGA_MODE <= VGA_MODE + 4'd1;
        end
        else if (key1) begin
            if (VGA_MODE == 4'd0) VGA_MODE <= VGA_MODE_MAX - 1'd1;
            else VGA_MODE <= VGA_MODE - 4'd1;
        end
    end
end

// Sobel_TH
always @(posedge sys_clk or negedge rst_n) begin
    if (!rst_n)
        Sobel_TH <= 8'd20;
    else if (mode == 1'b1) begin
        if (key3 && Sobel_TH < 8'd255 - 8'd2) begin
            Sobel_TH <= Sobel_TH + 8'd2;
        end
        else if (key1 && Sobel_TH > 8'd2) begin
            Sobel_TH <= Sobel_TH - 8'd2;
        end
    end
end

// seg_value
always @(posedge sys_clk) begin
    case (mode)
        'd0: seg_value <= VGA_MODE;
        'd1: seg_value <= Sobel_TH + 20'd10_000;
        'd2: seg_value <= T_otus + 20'd20_000;
        default: seg_value <= 20'd12345;
    endcase
end

// key
key u_key(
    .sys_clk    ( sys_clk   ),
    .iKey1      ( iKey1     ),
    .iKey2      ( iKey2     ),
    .iKey3      ( iKey3     ),
    .oKey1      ( key1      ),
    .oKey2      ( key2      ),
    .oKey3      ( key3      )
);

endmodule