clc; clear; close all;

% 读取图片（i_orig = img_original）
i_orig = imread('./img/2.jpg');

% RGB转灰度
i_gray = f_rgb2gray(i_orig);

% sobel算子计算xy梯度幅值
[i_sobel, ~, ~] = f_sobel(i_gray);

% 不同阈值的Sobel
a = [5, 9, 13, 17, 21];
sobel = cat(5, i_sobel, i_sobel, i_sobel, i_sobel, i_sobel);

subplot(2,3,1); imshow(i_gray);

a = 3;
step = 4;

for x = 1 : 5
    A = sobel(:,:,x);
    A(A >= a) = 255;
    A(A < a) = 0;
    sobel(:,:,x) = A;
    subplot(2,3,x+1); imshow(255-sobel(:,:,x));
    a = a + step;
end



