module top(
    input                               clk                        ,
    input                               rst_n                      ,
    inout                               cmos_scl                   ,//cmos i2c clock
    inout                               cmos_sda                   ,//cmos i2c data
    input                               cmos_vsync                 ,//cmos vsync
    input                               cmos_href                  ,//cmos hsync refrence,data valid
    input                               cmos_pclk                  ,//cmos pxiel clock
    output                              cmos_xclk                  ,//cmos externl clock
    input              [   7:0]         cmos_db                    ,//cmos data
    output                              cmos_rst_n                 ,//cmos reset
    output                              cmos_pwdn                  ,//cmos power down
    output                              vga_out_hs                 ,//vga horizontal synchronization
    output                              vga_out_vs                 ,//vga vertical synchronization
    output             [   4:0]         vga_out_r                  ,//vga red
    output             [   5:0]         vga_out_g                  ,//vga green
    output             [   4:0]         vga_out_b                  ,//vga blue
    output                              sdram_clk                  ,//sdram clock
    output                              sdram_cke                  ,//sdram clock enable
    output                              sdram_cs_n                 ,//sdram chip select
    output                              sdram_we_n                 ,//sdram write enable
    output                              sdram_cas_n                ,//sdram column address strobe
    output                              sdram_ras_n                ,//sdram row address strobe
    output             [   1:0]         sdram_dqm                  ,//sdram data enable
    output             [   1:0]         sdram_ba                   ,//sdram bank address
    output             [  12:0]         sdram_addr                 ,//sdram address
    inout              [  15:0]         sdram_dq                   ,//sdram data
    // key
    input  wire                         key1                       ,// Pin_M15
    input  wire                         key2                       ,// Pin_M16
    input  wire                         key3                       ,// PIN_E16
    // seg
    output wire        [   7:0]         DIG                        ,// DP,G,……,A
    output wire        [   5:0]         SEL                         
);

    parameter                           MEM_DATA_BITS          = 16;//external memory user interface data width
    parameter                           ADDR_BITS              = 24;//external memory user interface address width
    parameter                           BUSRT_BITS             = 10;//external memory user interface burst width

wire                                    wr_burst_data_req          ;
wire                                    wr_burst_finish            ;
wire                                    rd_burst_finish            ;
wire                                    rd_burst_req               ;
wire                                    wr_burst_req               ;
wire                   [BUSRT_BITS - 1:0]rd_burst_len               ;
wire                   [BUSRT_BITS - 1:0]wr_burst_len               ;
wire                   [ADDR_BITS - 1:0]rd_burst_addr              ;
wire                   [ADDR_BITS - 1:0]wr_burst_addr              ;
wire                                    rd_burst_data_valid        ;
wire                   [MEM_DATA_BITS - 1 : 0]rd_burst_data              ;
wire                   [MEM_DATA_BITS - 1 : 0]wr_burst_data              ;
wire                                    read_req                   ;
wire                                    read_req_ack               ;
wire                                    read_en                    ;
wire                   [  15:0]         read_data                  ;
wire                                    write_en                   ;
wire                   [  15:0]         write_data                 ;
wire                                    write_req                  ;
wire                                    write_req_ack              ;
wire                                    ext_mem_clk                ;//external memory clock
wire                                    video_clk                  ;//video pixel clock
wire                   [  15:0]         cmos_16bit_data            ;
wire                                    cmos_16bit_wr              ;
wire                   [   1:0]         write_addr_index           ;
wire                   [   1:0]         read_addr_index            ;
wire                   [   9:0]         lut_index                  ;
wire                   [  31:0]         lut_data                   ;

wire                   [   6:0]         T_otus                     ;
wire                   [  19:0]         seg_value                  ;
wire                   [   3:0]         VGA_MODE                   ;
wire                   [   7:0]         Sobel_TH                   ;

assign sdram_clk = ext_mem_clk;
assign cmos_rst_n = 1'b1;
assign cmos_pwdn = 1'b0;
assign write_en = cmos_16bit_wr;
assign write_data = {cmos_16bit_data[4:0],cmos_16bit_data[10:5],cmos_16bit_data[15:11]};


// 处理输出
wire                                    rgb565_hs, rgb565_vs, rgb565_de;
wire                   [  15:0]         rgb565                     ;
wire                                    canny_hs, canny_vs, canny_de;
wire                   [  15:0]         canny                      ;
assign vga_out_hs = canny_hs;
assign vga_out_vs = canny_vs;
assign vga_out_r  = canny[15:11];
assign vga_out_g  = canny[10:5];
assign vga_out_b  = canny[4:0];

//generate the CMOS sensor clock and the SDRAM controller clock
sys_pll sys_pll_m0(
    .inclk0                            (clk                       ),
    .c0                                (cmos_xclk                 ),
    .c1                                (ext_mem_clk               ) 
    );
//generate video pixel clock
video_pll video_pll_m0(
    .inclk0                            (clk                       ),
    .c0                                (video_clk                 ) 
    );
//I2C master controller
i2c_config i2c_config_m0(
    .rst                               (~rst_n                    ),
    .clk                               (clk                       ),
    .clk_div_cnt                       (16'd500                   ),
    .i2c_addr_2byte                    (1'b1                      ),
    .lut_index                         (lut_index                 ),
    .lut_dev_addr                      (lut_data[31:24]           ),
    .lut_reg_addr                      (lut_data[23:8]            ),
    .lut_reg_data                      (lut_data[7:0]             ),
    .error                             (                          ),
    .done                              (                          ),
    .i2c_scl                           (cmos_scl                  ),
    .i2c_sda                           (cmos_sda                  ) 
);
//configure look-up table
lut_ov5640_rgb565_1024_768 lut_ov5640_rgb565_1024_768_m0(
    .lut_index                         (lut_index                 ),
    .lut_data                          (lut_data                  ) 
);
//CMOS sensor 8bit data is converted to 16bit data
cmos_8_16bit cmos_8_16bit_m0(
    .rst                               (~rst_n                    ),
    .pclk                              (cmos_pclk                 ),
    .pdata_i                           (cmos_db                   ),
    .de_i                              (cmos_href                 ),
    .pdata_o                           (cmos_16bit_data           ),
    .hblank                            (                          ),
    .de_o                              (cmos_16bit_wr             ) 
);
//CMOS sensor writes the request and generates the read and write address index
cmos_write_req_gen cmos_write_req_gen_m0(
    .rst                               (~rst_n                    ),
    .pclk                              (cmos_pclk                 ),
    .cmos_vsync                        (cmos_vsync                ),
    .write_req                         (write_req                 ),
    .write_addr_index                  (write_addr_index          ),
    .read_addr_index                   (read_addr_index           ),
    .write_req_ack                     (write_req_ack             ) 
);
//The video output timing generator and generate a frame read data request
rgb565_gen rgb565_gen_m0
(
    .video_clk                         (video_clk                 ),
    .rst                               (~rst_n                    ),
    .read_req                          (read_req                  ),
    .read_req_ack                      (read_req_ack              ),
    .read_en                           (read_en                   ),
    .read_data                         (read_data                 ),
    .hs                                (rgb565_hs                 ),
    .vs                                (rgb565_vs                 ),
    .de                                (rgb565_de                 ),
    .vout_data                         (rgb565                    ) 
);

//video frame data read-write control
frame_read_write frame_read_write_m0
(
    .rst                               (~rst_n                    ),
    .mem_clk                           (ext_mem_clk               ),
    .rd_burst_req                      (rd_burst_req              ),
    .rd_burst_len                      (rd_burst_len              ),
    .rd_burst_addr                     (rd_burst_addr             ),
    .rd_burst_data_valid               (rd_burst_data_valid       ),
    .rd_burst_data                     (rd_burst_data             ),
    .rd_burst_finish                   (rd_burst_finish           ),
    .read_clk                          (video_clk                 ),
    .read_req                          (read_req                  ),
    .read_req_ack                      (read_req_ack              ),
    .read_finish                       (                          ),
    .read_addr_0                       (24'd0                     ),//The first frame address is 0
    .read_addr_1                       (24'd2073600               ),//The second frame address is 24'd2073600 ,large enough address space for one frame of video
    .read_addr_2                       (24'd4147200               ),
    .read_addr_3                       (24'd6220800               ),
    .read_addr_index                   (read_addr_index           ),
    .read_len                          (24'd786432                ),//frame size
    .read_en                           (read_en                   ),
    .read_data                         (read_data                 ),

    .wr_burst_req                      (wr_burst_req              ),
    .wr_burst_len                      (wr_burst_len              ),
    .wr_burst_addr                     (wr_burst_addr             ),
    .wr_burst_data_req                 (wr_burst_data_req         ),
    .wr_burst_data                     (wr_burst_data             ),
    .wr_burst_finish                   (wr_burst_finish           ),
    .write_clk                         (cmos_pclk                 ),
    .write_req                         (write_req                 ),
    .write_req_ack                     (write_req_ack             ),
    .write_finish                      (                          ),
    .write_addr_0                      (24'd0                     ),
    .write_addr_1                      (24'd2073600               ),
    .write_addr_2                      (24'd4147200               ),
    .write_addr_3                      (24'd6220800               ),
    .write_addr_index                  (write_addr_index          ),
    .write_len                         (24'd786432                ),//frame size
    .write_en                          (write_en                  ),
    .write_data                        (write_data                ) 
);
//sdram controller
sdram_core sdram_core_m0
(
    .rst                               (~rst_n                    ),
    .clk                               (ext_mem_clk               ),
    .rd_burst_req                      (rd_burst_req              ),
    .rd_burst_len                      (rd_burst_len              ),
    .rd_burst_addr                     (rd_burst_addr             ),
    .rd_burst_data_valid               (rd_burst_data_valid       ),
    .rd_burst_data                     (rd_burst_data             ),
    .rd_burst_finish                   (rd_burst_finish           ),
    .wr_burst_req                      (wr_burst_req              ),
    .wr_burst_len                      (wr_burst_len              ),
    .wr_burst_addr                     (wr_burst_addr             ),
    .wr_burst_data_req                 (wr_burst_data_req         ),
    .wr_burst_data                     (wr_burst_data             ),
    .wr_burst_finish                   (wr_burst_finish           ),
    .sdram_cke                         (sdram_cke                 ),
    .sdram_cs_n                        (sdram_cs_n                ),
    .sdram_ras_n                       (sdram_ras_n               ),
    .sdram_cas_n                       (sdram_cas_n               ),
    .sdram_we_n                        (sdram_we_n                ),
    .sdram_dqm                         (sdram_dqm                 ),
    .sdram_ba                          (sdram_ba                  ),
    .sdram_addr                        (sdram_addr                ),
    .sdram_dq                          (sdram_dq                  ) 
);

// canny算法
canny_top u_canny_top(
    .video_clk                         (video_clk                 ),
    .rst_n                             (rst_n                     ),
    .rgb565_hs                         (rgb565_hs                 ),
    .rgb565_vs                         (rgb565_vs                 ),
    .rgb565_de                         (rgb565_de                 ),
    .rgb565                            (rgb565                    ),
    .canny_hs                          (canny_hs                  ),
    .canny_vs                          (canny_vs                  ),
    .canny_de                          (canny_de                  ),
    .canny                             (canny                     ),
    .T_otus                            (T_otus                    ),
    .VGA_MODE                          (VGA_MODE                  ),
    .Sobel_TH                          (Sobel_TH                  )
);

seg_dynamic #(
    .CNT_MAX                           (16'd49_999                ) //数码管刷新时间计数最大值, 1ms
)
u_seg_dynamic(
    // sys input
    .clk                               (clk                       ),
    .rstn                              (rst_n                     ),
    // input
    .data                              (seg_value                  ),
    .point                             (6'b000_000                ),
    .sign                              (1'b0                      ),
    .seg_en                            (1'b1                      ),
    // output
    .SEL                               (SEL                       ),
    .SEG                               (DIG                       ) 
);

key_ctrl u_key_ctrl(
    .sys_clk                           (clk                       ),
    .rst_n                             (rst_n                     ),
    // input
    .iKey1                             (key1                      ),
    .iKey2                             (key2                      ),
    .iKey3                             (key3                      ),
    .T_otus                            (T_otus                    ),
    // output
    .seg_value                         (seg_value                 ),
    .VGA_MODE                          (VGA_MODE                  ),
    .Sobel_TH                          (Sobel_TH                  )
);

endmodule