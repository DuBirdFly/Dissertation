clc; clear; close all;

img_orig = imread('./img/4.jpg');
img_noise = imnoise(img_orig,'salt & pepper',0.025);

%% 第1步, RGB转灰度
img_gray = rgb2gray(img_noise);      % 0-255 uint8
[ROW,COL] = size(img_gray); % ROW = 480; COL = 640; N = 3(维度)

%% 第1.5步, 自适应中值滤波剔除噪声
img_mid = uint8(zeros(ROW,COL));
VALUE = 7;
for r = 2:ROW-1
    for c = 2:COL-1
        px = get_px2(img_gray,r,c);
        maxx = max(px);
        minn = min(px);
        summ = sum(px);
        midd = median(px);
        z1 = maxx - midd;
        z2 = midd - minn;
        if z1 > z2 && z1 > VALUE
            img_mid(r,c) = (summ - maxx) / 7;
        elseif z1 < z2 && z2 > VALUE
            img_mid(r,c) = (summ - minn) / 7;
        else
            img_mid(r,c) = mean(px);
        end
    end
end

%% 第2步, Gaussian卷积平滑滤波
img_gaos = uint8(img_conv(img_mid,[1 2 1; 2 4 2; 1 2 1]) / 16); % uint8 480x640

%% 第3步 sobel算子(Sobel=S)计算xy梯度，求幅值(Mxy)
Gx = img_conv(img_gaos,[-1 0 1; -2 0 2; -1 0 1]) / 8;   % 采用非标准Sobel算子,45°方向朝右下
Gy = img_conv(img_gaos,[-1 -2 -1; 0 0 0; 1 2 1]) / 8;   % -127 ~ 127
Mxy = uint8((abs(Gx) + abs(Gy)));                            % 0 ~ 255
Mxy(:,2) = 0;Mxy(:,COL - 1) = 0;Mxy(2,:) = 0;Mxy(ROW - 1,:) = 0;    % 清除错误数据

%% 第4步,非极大值抑制FPGA优化版 (Non-Maximum Suppression FPGA Plus)
img_NMS = uint8(zeros(ROW,COL));   % NMS = Non-Maximum Suppression,非极大值抑制
for r = 2:ROW-1
    for c = 2:COL-1
        [z1,z2,z3,z4,z5,z6,z7,z8,z9] = get_px(Mxy,r,c);
        if  (abs(Gx(r,c))*2 > abs(Gy(r,c))*5 && z5 >= z4 && z5 >= z6) ||...
            (abs(Gy(r,c))*2 > abs(Gx(r,c))*5 && z5 >= z2 && z5 >= z8)
            img_NMS(r,c) = z5;
        elseif  (((Gx(r,c)>0 && Gy(r,c)>0) || (Gx(r,c)<0 && Gy(r,c)<0)) && z5 >= z1 && z5 >= z9) ||...
                (((Gx(r,c)>0 && Gy(r,c)<0) || (Gx(r,c)<0 && Gy(r,c)>0)) && z5 >= z3 && z5 >= z7)
            img_NMS(r,c) = z5;
        else
            img_NMS(r,c) = 0;
        end
    end
end

%% 第5步, 最大类间方差法(OTSU算法)取0.5Tmax和0.125Tmax为"双阈值边缘检测"的双阈值
% (注:如果用库函数的自适应阈值OTSU算法: graythresh(img_NMS), 返回0~1的值, 乘以256即可)
Tmax_lib = round(256*graythresh(img_NMS) + 1); % 库函数灰度0-255,而我是1-256
[Tmax_OTUS, sigma_OTUS] = OTUS(img_NMS);
[Tmax_FPGA, sigma_FPGA] = OTUS_FPGA(img_NMS);
T = Tmax_FPGA;

%% 第6步, 双阈值边缘检测(Double threshold monitoring)
img_DTM = false(ROW,COL);   % NMS = Non-Maximum Suppression,非极大值抑制
Th = fix(T / 2);
Tl = fix(T / 8);
for r = 2:ROW-1
    for c = 2:COL-1
        [z1,z2,z3,z4,z5,z6,z7,z8,z9] = get_px(img_NMS,r,c);
        z_min = min([z1 z2 z3 z4 z6 z7 z8 z9]);
        if  (z5 > Th) ||...
            (z5 > Tl && z5 < Th && z_min > Th)
            img_DTM(r,c) = 1;
        else
            img_DTM(r,c) = 0;
        end
    end
end

%% 第7步,绘图
figure(1);
subplot(2,3,1);imshow(img_noise);title('img\_noise');
subplot(2,3,2);imshow(img_gray);title('img\_noise\_gray');
subplot(2,3,3);imshow(255-4*Mxy);title('Mxy');
subplot(2,3,4);imshow(255-6*img_NMS);title('NMS');
subplot(2,3,5);imshow(~img_DTM);title('DTM');
subplot(2,3,6);imshow(~edge(img_gaos,'canny'));title('Canny_{lib}');

figure(3);
imshow(~img_DTM);

%% 第8步,绘图
% 输出非极大值抑制的灰度图给testbench使用
% 文件读写是非常耗时间的, 不用时记得注释掉
% fid = fopen('gray_NMS.txt','w+');
% for r = 1:ROW
%     for c = 1:COL
%         % img_NMS(5)是竖着的第5个而不是横着的,所以使用双参数img_NMS(1,5)
%         fprintf(fid,'%02X ',img_NMS(r,c));
%     end
% end
% fclose(fid);



%% 函数: 获取8-邻域
function [px1,px2,px3,px4,px5,px6,px7,px8,px9] = get_px(img,r,c)
    %GET_PX 输入(图像,坐标r,坐标c),输出(3x3领域的9个数据)
    px1 = img(r-1,c-1); px2 = img(r-1,c); px3 = img(r-1,c+1);
    px4 = img(r  ,c-1); px5 = img(r  ,c); px6 = img(r  ,c+1);
    px7 = img(r+1,c-1); px8 = img(r+1,c); px9 = img(r+1,c+1);
end

function p = get_px2(img,r,c)
    %GET_PX 输入(图像,坐标r,坐标c),输出(3x3领域的9个数据)
    p = zeros(9,1);
    p(1) = img(r-1,c-1); p(2) = img(r-1,c); p(3) = img(r-1,c+1);
    p(4) = img(r  ,c-1); p(5) = img(r  ,c); p(6) = img(r  ,c+1);
    p(7) = img(r+1,c-1); p(8) = img(r+1,c); p(9) = img(r+1,c+1);
end

%% 函数: 图像卷积
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

%% 函数: OTUS算法
function [Tmax, SIGMA] = OTUS(I)
    [ROW,COL] = size(I);
    L = 256;
    histogram = zeros(L,1);             % 直方图
    for r = 1:ROW                       % 直方图统计 = 矩阵
        for c = 1:COL
            index = I(r,c) + 1;   % img_NMS(r,c)的值是从0开始的, 而index是从1开始的
            histogram(index) = histogram(index) + 1; 
        end
    end
    GrayArr = histogram .* (0:L-1)';     % 直方图 .* 灰度 = 矩阵, uint24 , 小撇表示转置矩阵
    N1 = zeros(L,1); N2 = zeros(L,1); GrayAll1 = zeros(L,1); GrayAll2 = zeros(L,1);
    for t = 1:L
        N1(t) = sum(histogram(1:t));
        N2(t) = sum(histogram(t+1:L));
        GrayAll1(t) = sum(GrayArr(1:t));
        GrayAll2(t) = sum(GrayArr(t+1:L));
    end
    % sigma = sqrt(N1.*N2.*(GrayAll1./N1-GrayAll2./N2).^2 / (ROW*COL)^2);
    MUL = N1.*N2;
    DIV1 = GrayAll1./N1;
    DIV2 = GrayAll2./N2;
    SUB = DIV1 - DIV2;
    SUBB = SUB.^2;
    SIGMA = MUL.*SUBB;
    [~,Tmax] = max(SIGMA);

    figure(2);
    subplot(3,5,1);bar(histogram);title('MATLAB\_HISTOGRAM');ylim([0 max(histogram(2:128))*1.1]);xlim([0 128]);
    subplot(3,5,2);bar(GrayArr);title('MATLAB\_GrayArr');xlim([0 128]);
    subplot(3,5,3);bar(MUL);title('MATLAB\_MUL');xlim([0 128]);
    subplot(3,5,4);bar(SUBB);title('MATLAB\_SUBB');xlim([0 128]);
    subplot(3,5,5);bar(SIGMA);title('MATLAB\_SIGMA');xlim([0 128]);
end

%% 函数: FPGA优化后的OTUS算法
% FPGA还剩194,688bits的BRAM可以用
function [Tmax, sigma] = OTUS_FPGA(I)
    [ROW,COL] = size(I);
    L = 128; 
    % N = ROW*COL;
    histogram = zeros(L,1);             % 直方图, uint20(1024*768)
    GrayArr = zeros(L,1);               % 直方图*灰阶, uint20(2k压力测试938,944)
    % N1,N2 : uint20(1024*768)
    % GrayAll1,GrayAll2 : uint23(1024*768*8)
    MUL = zeros(L,1);                   % N1*N2, uint16*uint16 = uint32
    DIV1 = zeros(L,1);                  % GrayAll1_u23 / N1_u16 = uint23
    DIV2 = zeros(L,1);                  % GrayAll2_u23 / N2_u16 = uint23
    SUB_u16 = zeros(L,1);               % DIV1 - DIV2 = uint23(取低16位)

    % 直方图统计
    for r = 1:ROW
        for c = 1:COL
            index = I(r,c) + 1;         % I(r,c)的值是从0开始的, 而index是从1开始的
            if (index > L) 
                index = L;
            end
            histogram(index) = histogram(index) + 1; 
            GrayArr(index) = GrayArr(index) + double(I(r,c)); % 实际上-避免溢出:(uint20)57344 = (1110 0000 0000 0000)b
        end
    end

    for t = 1:L
        N1 = 0; N2 = 0; GrayAll1 = 0; GrayAll2 = 0;     % 数据清零复位
        % 统计t阈值下的otus数据: N1,N2,GrayAll1,GrayAll2
        for i = 1:L
            if (i <= t)
                N1 = N1 + histogram(i);
                GrayAll1 = GrayAll1 + GrayArr(i);
            elseif (i > t)
                N2 = N2 + histogram(i);
                GrayAll2 = GrayAll2 + GrayArr(i);
            end
        end
        N1_u16 = fix(N1/16); % 保留高位,截去低位
        N2_u16 = fix(N2/16); % uint20/(2^4)=u16
        % 正式计算
        MUL(t)  = N1_u16 * N2_u16;
        if N1_u16 > 0
            DIV1(t) = fix(GrayAll1 / N1_u16); % uint23 / uint16 = uint23
        else
            DIV1(t) = 0;
        end
        if N2_u16 > 0
            DIV2(t) = fix(GrayAll2 / N2_u16);
        else
            DIV2(t) = 0;
        end
        SUB  = abs(DIV1(t) - DIV2(t));
        SUB_u16(t) = SUB; % 保留低位,截去高位
        SUBB = SUB_u16.^2;
    end
    sigma = uint64(MUL.*SUBB);
    [~,Tmax] = max(sigma);

    figure(2);
    subplot(3,5,6);bar(histogram);title('MATLAB\_FPGA\_HISTO');ylim([0 max(histogram(2:128))*1.1]);
    subplot(3,5,7);bar(GrayArr);title('MATLAB\_FPGA\_GrayArr');
    subplot(3,5,8);bar(MUL);title('MATLAB\_FPGA\_MUL');
    subplot(3,5,9);bar(SUBB);title('MATLAB\_FPGA\_SUBB');
    subplot(3,5,10);bar(sigma);title('MATLAB\_FPGA\_SIGMA');


    modelsim_histogram = load('D:/PrjWorkspace/Dissertation/version/v2/tb/canny/forTXT/histo.txt');
    modelsim_GrayArr = load('D:/PrjWorkspace/Dissertation/version/v2/tb/canny/forTXT/grayArr.txt');
    modelsim_MUL = load('D:/PrjWorkspace/Dissertation/version/v2/tb/canny/forTXT/MUL.txt');
    modelsim_SUBB = load('D:/PrjWorkspace/Dissertation/version/v2/tb/canny/forTXT/SUBB.txt');
    modelsim_SIGMA = load('D:/PrjWorkspace/Dissertation/version/v2/tb/canny/forTXT/SIGMA.txt');

    subplot(3,5,11);bar(modelsim_histogram);title('Modelsim\_HISTO');ylim([0 max(modelsim_histogram(2:128))*1.1]);
    subplot(3,5,12);bar(modelsim_GrayArr);title('Modelsim\_GrayArr');
    subplot(3,5,13);bar(modelsim_MUL);title('Modelsim\_MUL');
    subplot(3,5,14);bar(modelsim_SUBB);title('Modelsim\_SUBB');
    subplot(3,5,15);bar(modelsim_SIGMA);title('Modelsim\_SIGMA');


end