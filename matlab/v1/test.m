clc; clear; close all;

img_orig = imread('./img/4.jpg');

img_noise = imnoise(img_orig, 'salt & pepper', 0.05);

%% 第1步, RGB转灰度
img_gray = rgb2gray(img_noise); % 0-255 uint8
[ROW, COL] = size(img_gray); % ROW = 480; COL = 640; N = 3(维度)

%% 第0.5步, 自适应中值滤波剔除噪声
img_mid = uint8(zeros(ROW, COL));
theta1 = 15; theta2 = 20;
for r = 2:ROW - 1
    for c = 2:COL - 1
        p = get_px9(img_gray, r, c); % c=200,r=201 噪点
        z = zeros(9, 1);
        for i = 1:9
            z(i) = abs(p(i) - p(5)); % 9方向（包括自己）的差分数据
        end
        Zavg = mean(z);
        Zmin = min(z);
        if Zavg < theta1 % 极大可能不是噪点
            img_mid(r, c) = p(5); % 取本值
        else
            if (Zavg + Zmin >= theta2) % 一定是噪点
                img_mid(r, c) = median(p); % 取中值
            else % 可能是噪点
                img_mid(r, c) = (sum(p) - p(5)) / 8; % 取除去中心点的均值
            end
        end
    end
end

figure(1); imshow(img_gray);
figure(2); imshow(img_mid);

function p = get_px9(I, r, c)
    p = zeros(9, 1);
    p(1) = I(r - 1, c - 1); p(2) = I(r - 1, c); p(3) = I(r - 1, c + 1);
    p(4) = I(r, c - 1); p(5) = I(r, c); p(6) = I(r, c + 1);
    p(7) = I(r + 1, c - 1); p(8) = I(r + 1, c); p(9) = I(r + 1, c + 1);
end
