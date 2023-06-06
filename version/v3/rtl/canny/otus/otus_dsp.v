module otus_dsp (
    // system
    input  wire                         clock                      ,
    input  wire                         rst_n                      ,
    // input
    input  wire                         dsp_vld                    ,// 只有1个clk的时候数据是有效的
    input  wire        [  19:0]         N1_u20, N2_u20             ,// 阈值两边灰阶的'直方图'之和
    input  wire        [  22:0]         GrayAll1,GrayAll2          ,// 阈值两边灰阶的'直方图*灰阶'之和
    // 清空RAM的最后一个clk, 若本文件下 assign finish_clear = &num128 & cnt128==125 可有同样效果
    input  wire                         finish_clear               ,
    output reg         [   6:0]         T_otus                     
);

// IP:乘法器与除法器, 输入全用组合逻辑, 0-clk延时的组合输出
reg                    [  31:0]         mul_a,mul_b                ;
wire                   [  63:0]         mul_q                      ;
reg                    [  22:0]         div_a                      ;// 分子
reg                    [  15:0]         div_b                      ;// 分母
wire                   [  22:0]         div_q                      ;

// reg
reg                    [  15:0]         N1,N2                      ;// 取高16位
reg                    [  22:0]         GA1,GA2                    ;
reg                    [   6:0]         cnt128, num128, Tmax       ;
reg                                     busy                       ;
reg                    [  22:0]         DIV1,DIV2, SUB_u23         ;
reg                    [  31:0]         MUL,SUBB                   ;
wire                   [  15:0]         SUB                        ;// 取低16位
reg                    [  63:0]         SIGMA, SIGMA_max           ;

assign SUB = SUB_u23[15:0];

// N1,N2,GA1,GA2
always @(posedge clock)
    if (dsp_vld) begin
        {N1, N2} <= {N1_u20[19:4], N2_u20[19:4]};
        {GA1, GA2} <= {GrayAll1, GrayAll2};
    end

// cnt128
always @(posedge clock or negedge rst_n)
    if (!rst_n) cnt128 <= 1'b0;
    else if (finish_clear) cnt128 <= 1'b0;
    else if (busy) cnt128 <= cnt128 + 1'b1;

// num128
always @(posedge clock or negedge rst_n)
    if (!rst_n) num128 <= 7'd127;
    else if (finish_clear) num128 <= 7'd127;
    else if (dsp_vld) num128 <= num128 + 1'b1;

// busy
always @(posedge clock or negedge rst_n)
    if (!rst_n) busy <= 1'b0;
    else if (finish_clear) busy <= 1'b0;
    else if (dsp_vld) busy <= 1'b1;

// mul_a, mul_b
always @(*) begin
    case (cnt128)
        0,1,2   :begin
            mul_a = N1;
            mul_b = N2;
        end
        3       :begin
            mul_a = SUB;
            mul_b = SUB;
        end
        4       :begin
            mul_a = SUBB;
            mul_b = MUL;
        end
        default: begin
            mul_a = 0;
            mul_b = 0;
        end
    endcase
end

// div_a, div_b
always @(*) begin
    case (cnt128)
        0       :begin
            div_a = GA1;
            div_b = N1;
        end
        1       :begin
            div_a = GA2;
            div_b = N2;
        end
        default: begin
            div_a = 0;
            div_b = 1'b1;
        end
    endcase
end

// MUL, DIV1, DIV2, SUB_u23, SUBB, SIGMA
always @(posedge clock) begin
    if (busy)
        case (cnt128)
            0:  begin
                DIV1 <= ~|N1 ? 1'd0 : div_q;
                MUL <= mul_q[31:0];
            end
            1:  DIV2 <= ~|N2 ? 1'd0 : div_q;
            2:  SUB_u23 <= (DIV1 > DIV2) ? DIV1 - DIV2 : DIV2 - DIV1;
            3:  SUBB <= mul_q[31:0];
            4:  SIGMA <= mul_q;
            default:;
        endcase
end

// Tmax, SIGMA_max
always @(posedge clock or negedge rst_n) begin
    if (!rst_n) begin
        Tmax <= 1'b0;
        SIGMA_max <= 1'b0;
    end
    else if (finish_clear) begin
        Tmax <= 1'b0;
        SIGMA_max <= 1'b0;
    end
    else if (busy & cnt128 == 7'd5 & SIGMA > SIGMA_max) begin
        Tmax <= num128;
        SIGMA_max <= SIGMA;
    end
end

// T_otus
always @(posedge clock)
    if (finish_clear) T_otus <= Tmax;

// 乘法器,需要8个9-bits的DPS和80个LUT,0-clk延时
mul_32_32 u_mul_32_32(
    .dataa                             (mul_a[31:0]               ),
    .datab                             (mul_b[31:0]               ),
    .result                            (mul_q[63:0]               ) 
);

// 除法器,0-clk延时,当分母为0时输出未知数
div_23_16 u_div_23_16(
    .numer                             (div_a[22:0]               ),// 分子(被除数)
    .denom                             (div_b[15:0]               ),// 分母(除数)
    .quotient                          (div_q[22:0]               ) // 商
);

//////////////////////////////////////////////////////////////////////
/*
reg                    [   3:0]         frame_flag                 ;// 控制只输出一次
always @(posedge clock or negedge rst_n)
    if (!rst_n) frame_flag <= 1'b0;
    else if (finish_clear) frame_flag <= frame_flag + 1'b1;


integer file0;
integer file1;
integer file2;
initial file0 = $fopen("D:/PrjWorkspace/Dissertation/version/v2/tb/canny/forTXT/MUL.txt");
initial file1 = $fopen("D:/PrjWorkspace/Dissertation/version/v2/tb/canny/forTXT/SUBB.txt");
initial file2 = $fopen("D:/PrjWorkspace/Dissertation/version/v2/tb/canny/forTXT/SIGMA.txt");
always @(posedge clock)
    if (frame_flag == 4'd0 & busy) begin
        if (cnt128 == 7'd1) $fdisplay(file0,"%d",MUL);
        else if (cnt128 == 7'd4) $fdisplay(file1,"%d",SUBB);
        else if (cnt128 == 7'd5) $fdisplay(file2,"%d",SIGMA);
    end

always @(posedge clock)
    if (finish_clear) $display("T_otus = %d", T_otus);
*/
endmodule