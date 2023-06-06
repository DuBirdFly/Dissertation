clc; clear; close all;

% otus算法验证
gray_135p = rgb2gray(imread('./img2/1_135p.jpg'));
gray_270p = rgb2gray(imread('./img2/2_270p.jpg'));
gray_540p = rgb2gray(imread('./img2/3_540p.jpg'));
gray_1080p = rgb2gray(imread('./img2/4_1080p.jpg'));
gray_1620p = rgb2gray(imread('./img2/5_1620p.jpg'));

% 使用元胞矩阵存储不同维度的矩阵，初始化和调用均使用{}
part = {gray_135p, gray_270p, gray_540p, gray_1080p, gray_1620p};
T = zeros(2, 5);
for i = 1:5
    [i_sobel, Gx, Gy] = f_sobel(part{i}); % 计算xy梯度幅值
    i_NMS = f_NMS(i_sobel, Gx, Gy); % 非极大值抑制
    [T(1, i), ~, ~, ~, ~, ~] = f_otus1(i_NMS, 128);
    T(2, i) = 256 * graythresh(i_NMS) + 1;
end

figure(1);
X = categorical({'240 \times 135', '480 \times 270', '960 \times 540', '1920 \times 1080', '2880 \times 1620'}); % 输入标签
X = reordercats(X, {'240 \times 135', '480 \times 270', '960 \times 540', '1920 \times 1080', '2880 \times 1620'}); % 输入标签顺序
bar(X, T);
