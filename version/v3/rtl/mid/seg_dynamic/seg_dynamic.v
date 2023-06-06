`timescale  1ns/1ns

module  seg_dynamic
(
    input  wire                         clk                        ,//系统时钟，频率50MHz
    input  wire                         rstn                       ,//复位信号，低有效
    input  wire        [  19:0]         data                       ,//数码管要显示的值
    input  wire        [   5:0]         point                      ,//小数点显示,高电平有效
    input  wire                         seg_en                     ,//数码管使能信号，高电平有效
    input  wire                         sign                       ,//符号位，高电平显示负号

    output wire        [   5:0]         SEL                        ,//数码管位选信号
    output wire        [   7:0]         SEG                         //数码管段选信号
);

    parameter                           CNT_MAX = 16'd49_999       ;//数码管刷新时间计数最大值(1ms)
    parameter                           SEL_NUM_MAX = 3'd5         ;//数码管个数

wire                   [   3:0]         unit                       ;//个位数
wire                   [   3:0]         ten                        ;//十位数
wire                   [   3:0]         hun                        ;//百位数
wire                   [   3:0]         tho                        ;//千位数
wire                   [   3:0]         t_tho                      ;//万位数
wire                   [   3:0]         h_hun                      ;//十万位数
reg                    [   3:0]         DIG_NUM                    ;//当前SEL下显示的DIG数字(0-9)
reg                    [   2:0]         SEL_NUM                    ;//当前显示的数码管(0-5)
reg                    [   2:0]         SEL_NUM_d1                 ;//仅用于为sel_d0打拍
reg                    [   7:0]         seg_d0                     ;
reg                    [   5:0]         sel_d0                     ;
reg                                     dot_disp                   ;//当前显示的数码管(0-5)是否有小数点

reg                    [  15:0]         cnt_1ms                    ;//1ms 计数器
reg                                     flag_1ms                   ;//1ms 标志信号

assign SEL = sel_d0;
assign SEG = seg_d0;

//cnt_1ms
always@(posedge clk or negedge rstn)begin
    if(rstn == 1'b0)
        cnt_1ms <= 16'd0;
    else if(cnt_1ms == CNT_MAX)
        cnt_1ms <= 16'd0;
    else
        cnt_1ms <= cnt_1ms + 1'b1;
end

//flag_1ms
always@(posedge clk or negedge rstn)begin
    if(rstn == 1'b0)
        flag_1ms <= 1'b0;
    else if(cnt_1ms == CNT_MAX - 1'b1)
        flag_1ms <= 1'b1;
    else
        flag_1ms <= 1'b0;
end

//SEL_NUM
always @(posedge clk or negedge rstn) begin
    if(rstn == 1'b0)
        SEL_NUM <= 3'b0;
    else begin
        if (flag_1ms == 1'b1) begin
            if(SEL_NUM == SEL_NUM_MAX)
                SEL_NUM <= 3'b0;
            else
                SEL_NUM <= SEL_NUM + 1'b1;
        end
    end
end

//SEL_NUM_d1
always @(posedge clk or negedge rstn) begin
    if(rstn == 1'b0)
        SEL_NUM_d1 <= 3'b0;
    else begin
        SEL_NUM_d1 <= SEL_NUM;
    end
end

//sel_d0
always @(posedge clk or negedge rstn) begin
    if(rstn == 1'b0)
        sel_d0 <= 6'b0;
    else begin
        case (SEL_NUM_d1)
            3'd0:   sel_d0 <= 6'b111_110;
            3'd1:   sel_d0 <= 6'b111_101;
            3'd2:   sel_d0 <= 6'b111_011;
            3'd3:   sel_d0 <= 6'b110_111;
            3'd4:   sel_d0 <= 6'b101_111;
            3'd5:   sel_d0 <= 6'b011_111;
            default: sel_d0 <= 6'b111_110;
        endcase
    end
end


//dot_disp
always @(posedge clk or negedge rstn) begin
    if(rstn == 1'b0)
        dot_disp <= 1'b0;
    else begin
        dot_disp <= ~point[SEL_NUM];                                //point是1有效的，而seg是0有效的
    end
end

//DIG_NUM:随着SEL_NUM变化而变化
always@(posedge clk or negedge rstn)begin
    if(rstn == 1'b0)
        DIG_NUM <= 1'b0;                                            //显示数字 0
    else begin
        case (SEL_NUM)
            3'd0:   DIG_NUM <= unit;                                //显示数字 0-9
            3'd1:   DIG_NUM <= ten;                                 //显示数字 0-9
            3'd2:   DIG_NUM <= hun;                                 //显示数字 0-9
            3'd3:   DIG_NUM <= tho;                                 //显示数字 0-9
            3'd4:   DIG_NUM <= t_tho;                               //显示数字 0-9
            3'd5:
                    if (sign == 1'b0)
                        DIG_NUM <= h_hun;                           //显示数字 0-9
                    else
                        DIG_NUM <= 4'd10;                           //显示负号
            default: DIG_NUM <= 4'b0;                               //显示数字 0
        endcase
    end
end

//seg_d0:控制数码管段选信号，显示数字
always@(posedge clk or negedge rstn)begin
    if(rstn == 1'b0)
        seg_d0 <= 8'b1111_1111;                                     //不显示任何字符
    else
        case(DIG_NUM)
            4'd0 : seg_d0 <= {dot_disp,7'b100_0000};                //显示数字 0
            4'd1 : seg_d0 <= {dot_disp,7'b111_1001};                //显示数字 1
            4'd2 : seg_d0 <= {dot_disp,7'b010_0100};                //显示数字 2
            4'd3 : seg_d0 <= {dot_disp,7'b011_0000};                //显示数字 3
            4'd4 : seg_d0 <= {dot_disp,7'b001_1001};                //显示数字 4
            4'd5 : seg_d0 <= {dot_disp,7'b001_0010};                //显示数字 5
            4'd6 : seg_d0 <= {dot_disp,7'b000_0010};                //显示数字 6
            4'd7 : seg_d0 <= {dot_disp,7'b111_1000};                //显示数字 7
            4'd8 : seg_d0 <= {dot_disp,7'b000_0000};                //显示数字 8
            4'd9 : seg_d0 <= {dot_disp,7'b001_0000};                //显示数字 9
            4'd10 : seg_d0 <= 8'b1011_1111 ;                        //显示负号
            4'd11 : seg_d0 <= 8'b1111_1111 ;                        //不显示任何字符
            default:seg_d0 <= 8'b1100_0000;
    endcase
end

binary_8421    binary_8421_inst
(
    .clk                               (clk                       ),//系统时钟，频率50MHz
    .rstn                              (rstn                      ),//复位信号，低电平有效
    .data                              (data                      ),//输入需要转换的数据

    .unit                              (unit                      ),//个位BCD码
    .ten                               (ten                       ),//十位BCD码
    .hun                               (hun                       ),//百位BCD码
    .tho                               (tho                       ),//千位BCD码
    .t_tho                             (t_tho                     ),//万位BCD码
    .h_hun                             (h_hun                     ) //十万位BCD码
);

endmodule




