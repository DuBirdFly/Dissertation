function [i_sobel, Gx, Gy] = f_sobel(I)

    [ROW,COL] = size(I);

    Gx = f_conv(I,[-1 0 1; -2 0 2; -1 0 1]) / 8;   % 采用非标准Sobel算子,45°方向朝右下
    Gy = f_conv(I,[-1 -2 -1; 0 0 0; 1 2 1]) / 8;   % -127 ~ 127

    i_sobel = uint8((abs(Gx) + abs(Gy)));                       % 0 ~ 255

    i_sobel(1,:)       = 0;
    i_sobel(ROW - 1,:) = 0;
    i_sobel(:,1)       = 0;
    i_sobel(:,COL)     = 0;

end