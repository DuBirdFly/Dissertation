clc; clear; close all;

% 读取图片（i_orig = img_original）
i_orig = imread('./img/2.jpg');

% 添加椒盐噪声
i_noise = imnoise(i_orig,'salt & pepper',0.00);

% RGB转灰度
i_gray = f_rgb2gray(i_noise);

% 自适应中值滤波剔除噪声
i_med = f_med_filter(i_gray);

% Gaussian滤波卷积平滑噪声
i_gaos = f_gauss(i_med);

% sobel算子计算xy梯度幅值
[i_sobel, Gx, Gy] = f_sobel(i_gaos);

% 非极大值抑制FPGA优化版 (Non-Maximum Suppression FPGA Plus)
i_NMS = f_NMS(i_sobel, Gx, Gy);

% 最大类间方差法(OTSU算法)取0.5Tmax和0.125Tmax为"双阈值边缘检测"的双阈值
T_lib = round(256*graythresh(i_NMS) + 1);
[T1, HST1, GAr1, MUL1, SUBB1, SIG1] = f_otus1(i_NMS, 256);
[T2, HST2, GAr2, MUL2, SUBB2, SIG2] = f_otus2(i_NMS, 128);

% Modelsim比对数据导入
[HST3, GAr3, MUL3, SUBB3, SIG3] = f_modelsim();

% 双阈值边缘检测(Double threshold monitoring)
i_DTM = f_DTM(i_NMS, T1/2, T1/8);

% 制表
figure(1);
subplot(2,3,1); imshow(i_orig); title('原图');
subplot(2,3,2); imshow(i_gray); title('灰度图');
subplot(2,3,3); imshow(255 - 4*i_sobel); title('梯度幅值结果');
subplot(2,3,4); imshow(255 - 8*i_NMS); title('非极大抑制结果');
subplot(2,3,5); imshow(~i_DTM); title('双阈值边缘检测结果');
subplot(2,3,6); imshow(~edge(i_gray,'canny')); title('Matlab库-Canny函数');

figure(2);
subplot(3,5,1);area(HST1);title('Matlab\_HISTOGRAM');ylim([0 max(HST1(2:128))*1.1]);xlim([0 80]);
subplot(3,5,2);area(GAr1);title('Matlab\_GrayArr');xlim([0 80]);
subplot(3,5,3);area(MUL1);title('Matlab\_MUL');xlim([0 80]);
subplot(3,5,4);area(SUBB1);title('Matlab\_SUBB');xlim([0 80]);
subplot(3,5,5);area(SIG1);title('Matlab\_SIGMA');xlim([0 80]);

subplot(3,5,6);area(HST2);title('UINT\_HISTOGRAM');ylim([0 max(HST2(2:128))*1.1]);xlim([0 80]);
subplot(3,5,7);area(GAr2);title('UINT\_GrayArr');xlim([0 80]);
subplot(3,5,8);area(MUL2);title('UINT\_MUL');xlim([0 80]);
subplot(3,5,9);area(SUBB2);title('UINT\_SUBB');xlim([0 80]);
subplot(3,5,10);area(SIG2);title('UINT\_SIGMA');xlim([0 80]);

subplot(3,5,11);area(HST3);title('Modelsim\_HISTO');ylim([0 max(HST3(2:128))*1.1]);xlim([0 80]);
subplot(3,5,12);area(GAr3);title('Modelsim\_GrayArr');xlim([0 80]);
subplot(3,5,13);area(MUL3);title('Modelsim\_MUL');xlim([0 80]);
subplot(3,5,14);area(SUBB3);title('Modelsim\_SUBB');xlim([0 80]);
subplot(3,5,15);area(SIG3);title('Modelsim\_SIGMA');xlim([0 80]);

figure(3);
HSTT = [HST1(1:80);HST2(1:80)];
bar(HSTT);ylim([0 max(HST1(2:128))*1.1]);