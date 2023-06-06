clc; clear; close all;

% 3x3sobel算子与2x2一阶微分对比

i_orig = imread('./img/2.jpg');

i_gray = f_rgb2gray(i_orig);

% sobel梯度幅值
[i_sobel, ~, ~] = f_sobel(i_gray);

% 归一化i_sobel
i_sobel = double(i_sobel);
max = max(max(i_sobel));
i_sobel = uint8(i_sobel / max * 255);

% 2x2一阶导的梯度幅值
[ROW,COL] = size(i_gray);
[Gx, Gy] = deal(zeros(ROW, COL));

for r = 2:ROW
    for c = 2:COL
        a = double(i_gray([r-1 r],[c-1 c]));
        Gx(r, c) = sum(sum(a.*[-1 -1;1 1]));
        Gy(r, c) = sum(sum(a.*[1 -1;1 -1]));
    end
end

i_2x2 = uint8(abs(Gx) + abs(Gy));

figure(1);
subplot(1, 2, 1); imshow(i_gray); title("灰度原图");
subplot(1, 2, 2); imshow(255-i_sobel); title("归一化sobel梯度幅值");

figure(2);
subplot(1, 2, 1); imshow(255-i_sobel); title("归一化sobel梯度幅值");
subplot(1, 2, 2); imshow(255-i_2x2); title("2x2一阶导的梯度幅值");