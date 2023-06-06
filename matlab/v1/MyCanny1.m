clc;
clear;
close all;

img_orig = imread('./img/4.png');
img_gray = rgb2gray(img_orig);      % 0-255 uint8

[ROW,COL] = size(img_gray); % ROW = 480; COL = 640

%  第一步、Gaussian卷积平滑滤波
img_gaos = uint8(img_conv(img_gray,[1 2 1; 2 4 2; 1 2 1])./16); % uint8 480x640

% 第二步 sobel算子(Sobel=S)计算xy梯度，求幅值(M)与方向(theta)
Gx = img_conv(img_gaos,[-1 0 1; -2 0 2; -1 0 1]);   %
Gy = img_conv(img_gaos,[1 2 1; 0 0 0; -1 -2 -1]);   % 采用标准Sobel算子,45°方向朝右上
M = abs(Gx) + abs(Gy);  % double 480x640
theta = atan(Gx./Gy);

% 第三步,非极大值抑制 (Non-Maximum Suppression)
img_NMS = zeros(ROW,COL);   % NMS = Non-Maximum Suppression,非极大值抑制
for r = 2:ROW-1
    for c = 2:COL-1
        [px1,px2,px3,px4,px5,px6,px7,px8,px9] = get_px(M,r,c);
        dirc = theta(r,c);
        dirc_abs = abs(dirc);
        if (   dirc_abs < pi/8 && px5 >= px4 && px5 >= px6 ...
            || dirc_abs > 3*pi/8 && px5 >= px2 && px5 >= px8 ...
            || dirc > pi/8 && dirc < 3*pi/8 && px5 >= px3 && px5 >= px7 ...
            || dirc > -3*pi && dirc < -pi/8 && px5 >= px1 && px5 >= px9 ) 
            img_NMS(r,c) = px5;
        else 
            img_NMS(r,c) = 0;
        end
    end
end

% 第四步,双阈值边缘检测(Double threshold monitoring)
img_DTM = zeros(ROW,COL);   % NMS = Non-Maximum Suppression,非极大值抑制
lowTh  = 0.01 *max(max(img_NMS));  %低阈值
higtTh = 0.06 *max(max(img_NMS));  %高阈值
for r = 2:ROW-1
    for c = 2:COL-1
        if img_NMS(r,c) > higtTh
            img_DTM(r,c) = 255;
        elseif img_NMS(r,c) < lowTh
            img_DTM(r,c) = 0;
        else
            [px1,px2,px3,px4,px5,px6,px7,px8,px9] = get_px(img_NMS,r,c);
            if (px2 > higtTh || px4 > higtTh || px6 > higtTh || px8 > higtTh ||...
                px1 > higtTh  || px3 > higtTh  || px7 > higtTh  || px9 > higtTh )
                img_DTM(r,c) = 255;
            end
        end
    end
end

% 库函数canny对比
BW2 = edge(img_gaos,'canny');

figure(1);
subplot(2,4,1);imshow(img_orig);title('原图');
subplot(2,4,2);imshow(img_gray);title('灰度图');
subplot(2,4,3);imshow(img_gaos);title('高斯滤波');
subplot(2,4,4);imshow(255-uint8(M));title('sobel计算幅值');
subplot(2,4,5);imshow(255-uint8(img_NMS));title('非极大值抑制');
subplot(2,4,6);imshow(255-uint8(img_DTM));title('双阈值边缘检测Canny结果');
subplot(2,4,7);imshow(~BW2);title('Canny库函数');

% 绘制"剔除边界无效像素"且"压缩幅值"的Sobel梯度幅值的3D图像
M_3D = zeros(ROW,COL);
for r = 4:ROW-2
    for c = 4:COL-2
        if (M(r,c) > 160) 
            M_3D(r,c) = M(r,c) / 12;
        else
            M_3D(r,c) = M(r,c);
        end
    end
end
figure(2);
mesh(M_3D);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
function [px1,px2,px3,px4,px5,px6,px7,px8,px9] = get_px(img,r,c)
    %GET_PX 输入(图像,坐标r,坐标c),输出(3x3领域的9个数据)
    px1 = img(r-1,c-1); px2 = img(r-1,c); px3 = img(r-1,c+1);
    px4 = img(r  ,c-1); px5 = img(r  ,c); px6 = img(r  ,c+1);
    px7 = img(r+1,c-1); px8 = img(r+1,c); px9 = img(r+1,c+1);
end

function img = img_conv(img_in,convCore)
    %IMG_CONV 输入(图像,卷积核(3x3)),输出(卷积后结果)
    I = double(img_in);     % 简化缩写,输入图像
    cv = convCore;          % 简化缩写,卷积核
    [ROW,COL] = size(I);
    img = zeros(ROW,COL);
    for r = 2:ROW-1
        for c = 2:COL-1
            img(r,c) =  I(r-1,c-1)*cv(1,1) + I(r-1,c)*cv(1,2) + I(r-1,c+1)*cv(1,3) +...
                        I(r  ,c-1)*cv(2,1) + I(r  ,c)*cv(2,2) + I(r  ,c+1)*cv(2,3) +...
                        I(r+1,c-1)*cv(3,1) + I(r+1,c)*cv(3,2) + I(r+1,c+1)*cv(3,3);
        end
    end
end
