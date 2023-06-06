clc; clear; close all;

% 中值滤波效果对比

% 读取图片（i_orig = img_original）
i_orig = imread('./img/2.jpg');

% 添加椒盐噪声
i_noise = imnoise(i_orig, 'salt & pepper', 0.05);

% RGB转灰度
i_gray = f_rgb2gray(i_noise);

% 自适应中值滤波剔除噪声
i_med = f_med_filter(i_gray);

figure(1);
subplot(1, 3, 1); imshow(i_noise); title("加入椒盐噪声的原图");
subplot(1, 3, 2); imshow(~edge(i_med, 'canny')); title("有中值滤波Canny边缘检测");
subplot(1, 3, 3); imshow(~edge(i_gray, 'canny')); title("无中值滤波Canny边缘检测");
