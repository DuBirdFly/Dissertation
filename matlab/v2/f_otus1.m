%% 函数: OTUS算法
function [Tmax, histogram, GrayArr, MUL, SUBB, SIGMA] = f_otus1(I, L)

    [histogram, GrayArr] = f_histogram(I, L);

    [N1,N2,GrayAll1,GrayAll2] = deal(zeros(L,1));    % 数据清空

    for t = 1:L
        N1(t) = sum(histogram(1:t));
        N2(t) = sum(histogram(t+1:L));
        GrayAll1(t) = sum(GrayArr(1:t));
        GrayAll2(t) = sum(GrayArr(t+1:L));
    end

    % 计算
    MUL = N1.*N2;
    SUBB = (GrayAll1./N1 - GrayAll2./N2).^2;
    SIGMA = MUL.*SUBB;
    [~,Tmax] = max(SIGMA);
end
