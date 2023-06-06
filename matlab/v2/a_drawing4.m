clc; clear; close all;

% 3x3sobel算子与2x2一阶微分对比

i_orig = imread('./img/2.jpg');

i_gray = f_rgb2gray(i_orig);

% sobel梯度幅值
[i_sobel, Gx, Gy] = f_sobel(i_gray);

% 归一化i_sobel
i_sobel = double(i_sobel);
max_num = max(max(i_sobel));
i_sobel = uint8(i_sobel / max_num * 255);

% 非极大值抑制
[ROW,COL] = size(i_sobel);
NMS = uint8(zeros(ROW,COL));
NMS_CUT = uint8(zeros(ROW,COL));    % 被“非极大值抑制”剔除的点

for r = 2:ROW-1
    for c = 2:COL-1
        p = f_get_px9(i_sobel,r,c);
        if  (abs(Gx(r,c))*2 > abs(Gy(r,c))*5 && p(5) >= p(4) && p(5) >= p(6)) ||...
            (abs(Gy(r,c))*2 > abs(Gx(r,c))*5 && p(5) >= p(2) && p(5) >= p(8)) ||...
            (((Gx(r,c)>0 && Gy(r,c)>0) || (Gx(r,c)<0 && Gy(r,c)<0)) && p(5) >= p(1) && p(5) >= p(9)) ||...
            (((Gx(r,c)>0 && Gy(r,c)<0) || (Gx(r,c)<0 && Gy(r,c)>0)) && p(5) >= p(3) && p(5) >= p(7))
            NMS(r,c) = p(5);
            NMS_CUT(r,c) = 0;
        else
            NMS(r,c) = 0;
            NMS_CUT(r,c) = 255;
        end
    end
end

figure(1);
subplot(2, 2, 1); imshow(i_gray); title("灰度原图");
subplot(2, 2, 2); imshow(255-i_sobel*3); title("归一化sobel梯度幅值");
subplot(2, 2, 3); imshow(255-NMS*3); title("归一化NMS梯度幅值");
subplot(2, 2, 4); imshow(NMS_CUT); title("被“非极大值抑制”剔除的点");