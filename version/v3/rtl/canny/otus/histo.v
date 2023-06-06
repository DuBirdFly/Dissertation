`timescale  1ns / 1ps

module histo (
    // system
    input  wire                         clock                      ,
    input  wire                         rst_n                      ,
    // input
    input  wire        [   7:0]         iGray_orig                 ,
    input  wire                         hs,vs,de                   ,
    // output
    output wire                         dsp_vld                    ,
    output reg         [  19:0]         N1, N2                     ,// 阈值两边灰阶的'直方图'之和
    output reg         [  22:0]         GrayAll1,GrayAll2          ,// 阈值两边灰阶的'直方图*灰阶'之和
    output wire                         finish_clear                // 清空RAM的最后一个clk
);

reg                    [   3:0]         state                      ;
reg                    [   3:0]         next_state                 ;

localparam S_IDLE    = 4'd0;
localparam S_STATS   = 4'd1;                                        // statistics,统计数据
localparam S_RD_OUT  = 4'd2;                                        // read_out, 将ram中的128个数据读出128次
localparam S_CLEAR   = 4'd3;                                        // 打印与清空ram中的数据

// --ram控制器--输入全用组合逻辑,因为RAM自带输入REGISTER
wire                   [  19:0]         histo_rddata, grayArr_rddata;
reg                    [  19:0]         histo_wrdata, grayArr_wrdata;
reg                                     wren                       ;
reg                    [   6:0]         wraddr, rdaddr             ;

// delay
reg                    [   6:0]         iGray_d1                   ;
reg                                     de_d1                      ;
reg                                     flag_add_d1                ;

// reg
reg                    [  11:0]         histo_sum                  ;// 最大为1024*1
reg                    [  16:0]         grayArr_sum                ;// 最大为1024*127=130048=uint17
reg                    [   6:0]         cnt128                     ;// 输出每一个灰阶数据的小循环(matlab里的i)
reg                    [   6:0]         num128                     ;// 每128个灰阶一轮+1的大循环(matlab里的t)
reg                                     flag_deposit_d2, flag_deposit_d1;// 具体看deposit_falg


// wire
wire                                    vs_pos, vs_neg, de_neg     ;
wire                   [   6:0]         iGray                      ;// 7位的iGray,灰度从0-127,大于127的算作127

// wire flag
wire                                    flag_deposit               ;// 寄存_flag, 记录何时写入 N1_u16... 等
wire                                    flag_add                   ;// 1:加到N1上; 0:加到N2上
wire                                    flag_start                 ;

// assign
assign iGray = iGray_orig[7] ? 7'd127 : iGray_orig[6:0];
assign flag_add = (state == S_RD_OUT) & (cnt128 <= num128);
assign flag_start = (state == S_RD_OUT) & (cnt128 == 1'b1);
assign flag_deposit = (state == S_RD_OUT) & (&cnt128);
assign dsp_vld = flag_deposit_d2;
assign finish_clear = (state == S_CLEAR) & (&cnt128);

// N1,N2
always @(posedge clock or negedge rst_n) begin
    if (!rst_n)
        {N1,N2} <= 1'd0;
    else if (flag_start) begin
        N1 <= histo_rddata;
        N2 <= 1'b0;
    end
    else begin
        if (flag_add_d1) N1 <= N1 + histo_rddata;
        else  N2 <= N2 + histo_rddata;
    end
end

// GrayAll1,GrayAll2
always @(posedge clock or negedge rst_n) begin
    if (!rst_n)
        {GrayAll1,GrayAll2} <= 1'd0;
    else if (flag_start) begin
        GrayAll1 <= grayArr_rddata;
        GrayAll2 <= 1'b0;
    end
    else begin
        if (flag_add_d1) GrayAll1 <= GrayAll1 + grayArr_rddata;
        else  GrayAll2 <= GrayAll2 + grayArr_rddata;
    end
end

// 打拍
always @(posedge clock) begin
    iGray_d1 <= iGray;
    de_d1 <= de;
    {flag_deposit_d2, flag_deposit_d1} <= {flag_deposit_d1, flag_deposit};
    flag_add_d1 <= flag_add;
end

// fsm1
always @(posedge clock or negedge rst_n)
    if (!rst_n) state <= S_IDLE;
    else state <= next_state;

// fsm2
always @(*) begin
    next_state = S_IDLE;
    case (state)
        S_IDLE      :
            if (vs_pos) next_state = S_STATS;
            else next_state = S_IDLE;
        S_STATS     :
            if (vs_neg) next_state = S_RD_OUT;
            else next_state = S_STATS;
        S_RD_OUT    :
            if ((&cnt128) & (&num128)) next_state = S_CLEAR;        // 规约运算,判断cnt128是否全为1
            else next_state = S_RD_OUT;
        S_CLEAR     :
            if (&cnt128) next_state = S_IDLE;
            else next_state = S_CLEAR;
        default     :
            next_state = S_IDLE;
    endcase
end

// cnt128
always @(posedge clock or negedge rst_n)
    if (!rst_n) cnt128 <= 1'b0;
    else if ((state == S_RD_OUT) | (state == S_CLEAR))
        cnt128 <= cnt128 + 1'b1;

// num128
always @(posedge clock or negedge rst_n)
    if (!rst_n) num128 <= 1'b0;
    else if ((state == S_RD_OUT) & (&cnt128))
        num128 <= num128 + 1'b1;

// rdaddr
always @(*) begin
    case (state)
        S_STATS: rdaddr = iGray;
        S_RD_OUT: rdaddr = cnt128;
        default: rdaddr = 'b0;
    endcase
end

// wraddr
always @(*) begin
    case (state)
        S_STATS: wraddr = iGray_d1;
        S_CLEAR: wraddr = cnt128;
        default: wraddr = 'b0;
    endcase
end

// wren
always @(*) begin
    case (state)
        S_STATS, S_CLEAR: wren = de_d1 & (iGray != iGray_d1) | de_neg;
        default: wren = 1'b0;
    endcase
end

// histo_sum
always @(posedge clock or negedge rst_n)
    if (!rst_n) histo_sum <= 1'b1;
    else if (de_d1 & (iGray == iGray_d1)) histo_sum <= histo_sum + 1'b1;
    else histo_sum <= 1'b1;

// grayArr_sum
always @(posedge clock or negedge rst_n)
    if (!rst_n) grayArr_sum <= 1'b0;
    else if (de_d1 & (iGray == iGray_d1)) grayArr_sum <= grayArr_sum + iGray;
    else grayArr_sum <= iGray;

// wrdata
always @(*) begin
    case (state)
        S_STATS: begin
            histo_wrdata = histo_rddata + histo_sum;
            grayArr_wrdata = grayArr_rddata + grayArr_sum;
        end
        default: begin
            histo_wrdata = 1'b0;
            grayArr_wrdata = 1'b0;
        end
    endcase
end


ram2p_128x20b histogram(
    .clock                             (clock                     ),
    .rdaddress                         (rdaddr                    ),
    .q                                 (histo_rddata              ),
    .wren                              (wren                      ),
    .data                              (histo_wrdata              ),
    .wraddress                         (wraddr                    ) 
);

ram2p_128x20b grayArr(
    .clock                             (clock                     ),
    .rdaddress                         (rdaddr                    ),
    .q                                 (grayArr_rddata            ),
    .wren                              (wren                      ),
    .data                              (grayArr_wrdata            ),
    .wraddress                         (wraddr                    ) 
);

getNegPos u_getNegPos_vs(
    .clk                               (clock                     ),
    .iData                             (vs                        ),
    .oPos                              (vs_pos                    ),
    .oNeg                              (vs_neg                    ) 
);

getNegPos u_getNegPos_de(
    .clk                               (clock                     ),
    .iData                             (de                        ),
    .oPos                              (                          ),
    .oNeg                              (de_neg                    ) 
);

//////////////////////////////////////////////////////////////////////
/*
reg                                     fwrite_flag                ;// 控制只输出一次
always @(posedge clock or negedge rst_n)
    if (!rst_n) fwrite_flag <= 1'b0;
    else if (finish_clear) fwrite_flag <= 1'b1;

// 打印对比数据 0~(127-1) ; 注意!!!路径需要写全, 用正斜杠'/'
integer file0;
integer file1;
initial file0 = $fopen("D:/PrjWorkspace/Dissertation/version/v2/tb/canny/forTXT/histo.txt");
initial file1 = $fopen("D:/PrjWorkspace/Dissertation/version/v2/tb/canny/forTXT/grayArr.txt");
always @(posedge clock)
    if (~fwrite_flag)
        if (state == S_RD_OUT & (&num128) & rdaddr > 1'd0)begin
            $fdisplay(file0,"%d",histo_rddata);
            $fdisplay(file1,"%d",grayArr_rddata);
            if (rdaddr == 8'd127) begin
                $fdisplay(file0,"%d",histo_rddata);
                $fdisplay(file1,"%d",grayArr_rddata);
                $fclose(file0);
                $fclose(file1);
            end
        end
*/
endmodule