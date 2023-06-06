module canny_top (
    // sys input 
    input  wire                         video_clk                  ,
    input  wire                         rst_n                      ,
    // input
    input  wire                         rgb565_hs, rgb565_vs, rgb565_de,
    input  wire        [  15:0]         rgb565                     ,
    // output
    output reg                          canny_hs, canny_vs, canny_de,
    output reg         [  15:0]         canny                      ,
    output wire        [   6:0]         T_otus                     ,
    // input
    // 0: rgb输出; 1: gaus滤波输出; 2: sobel输出; 3: 黄色Canny输出; 4: 彩色Canny输出
    input  wire        [   3:0]         VGA_MODE                   ,
    input  wire        [   7:0]         Sobel_TH                    // Sobel阈值(Sobel Threshold)
);

wire                   [   7:0]         gray_data                  ;
wire                                    gray_hs, gray_vs, gray_de  ;
wire                   [   7:0]         gaus_data                  ;
wire                                    gaus_hs, gaus_vs, gaus_de  ;
wire                   [   7:0]         Gx,Gy,Mxy                  ;
wire                                    sobel_hs, sobel_vs, sobel_de;
wire                   [   7:0]         NMS_data                   ;
wire                                    NMS_hs, NMS_vs, NMS_de     ;
wire                                    DTM_data                   ;
wire                                    DTM_hs, DTM_vs, DTM_de     ;

always@(posedge video_clk) begin
    case (VGA_MODE)
        0:  begin
            canny = rgb565;
            {canny_hs, canny_vs, canny_de} = {rgb565_hs, rgb565_vs, rgb565_de};
        end
        1:  begin
            canny = {gaus_data[7:3], gaus_data[7:2], gaus_data[7:3]};
            {canny_hs, canny_vs, canny_de} = {gaus_hs, gaus_vs, gaus_de};
        end
        2:  begin
            canny = Mxy > Sobel_TH ? 16'b11111_101011_01000 : 16'd0;
            {canny_hs, canny_vs, canny_de} = {sobel_hs, sobel_vs, sobel_de};
        end
        3:  begin
            canny <= DTM_data == 1'b1 ? 16'b11111_101011_01000 : 16'd0;
            {canny_hs, canny_vs, canny_de} <= {DTM_hs, DTM_vs, DTM_de};
        end
        default: begin
            canny = rgb565;
            {canny_hs, canny_vs, canny_de} = {rgb565_hs, rgb565_vs, rgb565_de};
        end
    endcase
end

// 3拍
canny1_YCbCr u_canny1_YCbCr(
    // input
    .clk                               (video_clk                 ),
    .rgb_iData                         (rgb565                    ),
    .rgb565_de                         (rgb565_de                 ),
    .rgb565_hs                         (rgb565_hs                 ),
    .rgb565_vs                         (rgb565_vs                 ),
    // output
    .gray_oData                        (gray_data                 ),
    .gray_de                           (gray_de                   ),
    .gray_hs                           (gray_hs                   ),
    .gray_vs                           (gray_vs                   ) 
);

// 4拍
canny2_gaus u_canny2_gaus(
    // input
    .clk                               (video_clk                 ),
    .gray_data                         (gray_data                 ),
    .gray_de                           (gray_de                   ),
    .gray_hs                           (gray_hs                   ),
    .gray_vs                           (gray_vs                   ),
    // output
    .gaus_hs                           (gaus_hs                   ),
    .gaus_vs                           (gaus_vs                   ),
    .gaus_de                           (gaus_de                   ),
    .gaus_oData                        (gaus_data                 ) 
);

// 4拍
canny3_sobel u1_canny3_sobel(
    // input
    .clk                               (video_clk                 ),
    .gray_data                         (gaus_data                 ),
    .gray_de                           (gaus_de                   ),
    .gray_hs                           (gaus_hs                   ),
    .gray_vs                           (gaus_vs                   ),
    // output
    .Gx                                (Gx                        ),
    .Gy                                (Gy                        ),
    .Mxy                               (Mxy                       ),
    .sobel_hs                          (sobel_hs                  ),
    .sobel_vs                          (sobel_vs                  ),
    .sobel_de                          (sobel_de                  ) 
);

// 2拍
canny4_NMS u_canny4_NMS(
    // input
    .clk                               (video_clk                 ),
    .Gx                                (Gx                        ),
    .Gy                                (Gy                        ),
    .Mxy                               (Mxy                       ),
    .sobel_hs                          (sobel_hs                  ),
    .sobel_vs                          (sobel_vs                  ),
    .sobel_de                          (sobel_de                  ),
    // output
    .NMS_data                          (NMS_data                  ),
    .NMS_hs                            (NMS_hs                    ),
    .NMS_vs                            (NMS_vs                    ),
    .NMS_de                            (NMS_de                    ) 
);

// 非流水线内容，作为参数使用，1帧的延时
otus u_otus(
    // system
    .clock                             (video_clk                 ),
    .rst_n                             (rst_n                     ),
    // input
    .iGray_orig                        (NMS_data                  ),
    .hs                                (NMS_hs                    ),
    .vs                                (NMS_vs                    ),
    .de                                (NMS_de                    ),
    // output
    .T                                 (T_otus                    ) 
);

// 2拍
canny5_DTM u_canny5_DTM(
    // input
    .clk                               (video_clk                 ),
    .NMS_data                          (NMS_data                  ),
    .NMS_hs                            (NMS_hs                    ),
    .NMS_vs                            (NMS_vs                    ),
    .NMS_de                            (NMS_de                    ),
    .Tmax                              (T_otus                    ),
    // output
    .DTM_data                          (DTM_data                  ),
    .DTM_hs                            (DTM_hs                    ),
    .DTM_vs                            (DTM_vs                    ),
    .DTM_de                            (DTM_de                    ) 
);

// Colorful Canny, 将rgb565打15拍后与DTM融合, 使用FIFO打拍


endmodule