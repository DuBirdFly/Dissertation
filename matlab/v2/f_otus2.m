%% 函数: FPGA优化后的OTUS算法
% FPGA还剩194,688bits的BRAM可以用
function [Tmax, histogram, GrayArr, MUL, SUBB, SIGMA] = f_otus2(I, L)

    MUL = zeros(L,1);                   % N1*N2, uint16*uint16 = uint32
    DIV1 = zeros(L,1);                  % GrayAll1_u23 / N1_u16 = uint23
    DIV2 = zeros(L,1);                  % GrayAll2_u23 / N2_u16 = uint23
    SUB_u16 = zeros(L,1);               % DIV1 - DIV2 = uint23(取低16位)

    % 直方图统计, histogram(uint20,1024*768), GrayArr(uint20, 2k压力测试938,944)
    [histogram, GrayArr] = f_histogram(I, L);

    for t = 1:L                                     % 统计t阈值下的otus数据
        % N1,N2(uint20,1024*768), GrayAll1,GrayAll2 : uint23(1024*768*8)
        [N1, N2, GrayAll1, GrayAll2] = deal(0);     % 数据清零复位

        for i = 1:L
            if (i <= t)
                N1 = N1 + histogram(i);
                GrayAll1 = GrayAll1 + GrayArr(i);
            elseif (i > t)
                N2 = N2 + histogram(i);
                GrayAll2 = GrayAll2 + GrayArr(i);
            end
        end

        N1_u16 = fix(N1/16);                        % 保留高位,截去低位
        N2_u16 = fix(N2/16);

        % 正式计算
        MUL(t)  = N1_u16 * N2_u16;
        if N1_u16 > 0
            DIV1(t) = fix(GrayAll1 / N1_u16);       % uint23 / uint16 = uint23
        else
            DIV1(t) = 0;
        end
        if N2_u16 > 0
            DIV2(t) = fix(GrayAll2 / N2_u16);
        else
            DIV2(t) = 0;
        end
        SUB  = abs(DIV1(t) - DIV2(t));
        SUB_u16(t) = SUB;                           % 保留低位,截去高位
        SUBB = SUB_u16.^2;
    end
    SIGMA = MUL.*SUBB;
    [~,Tmax] = max(SIGMA);

end