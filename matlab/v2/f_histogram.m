function [histogram, GrayArr] = f_histogram(I, L)

    [ROW,COL] = size(I);
    histogram = zeros(L,1);             % 直方图

    for r = 1:ROW                       % 直方图统计 = 矩阵
        for c = 1:COL
            index = I(r,c) + 1;         % img_NMS(r,c)的值是从0开始的, 而index是从1开始的
            if (index > L)              % 避免溢出
                index = L;
            end
            histogram(index) = histogram(index) + 1; 
        end
    end

    GrayArr = histogram .* (0:L-1)';


end