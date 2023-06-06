module otus (
    // system
    input  wire                         clock                      ,
    input  wire                         rst_n                      ,
    // input
    input  wire        [   7:0]         iGray_orig                 ,
    input  wire                         hs,vs,de                   ,
    // output
    output reg         [   6:0]         T                           
);

wire                                    dsp_vld                    ;
wire                   [  19:0]         N1, N2                     ;
wire                   [  22:0]         GrayAll1,GrayAll2          ;
wire                                    finish_clear               ;
wire                   [   6:0]         T_otus                     ;

histo u_histo(
    // system
    .clock                             (clock                     ),
    .rst_n                             (rst_n                     ),
    // input
    .iGray_orig                        (iGray_orig                ),
    .hs                                (                          ),
    .vs                                (vs                        ),
    .de                                (de                        ),
    // output
    .dsp_vld                           (dsp_vld                   ),
    .N1                                (N1                        ),
    .N2                                (N2                        ),
    .GrayAll1                          (GrayAll1                  ),
    .GrayAll2                          (GrayAll2                  ),
    .finish_clear                      (finish_clear              ) 
);

otus_dsp u_otus_dsp(
    // system
    .clock                             (clock                     ),
    .rst_n                             (rst_n                     ),
    // input
    .dsp_vld                           (dsp_vld                   ),
    .N1_u20                            (N1                        ),
    .N2_u20                            (N2                        ),
    .GrayAll1                          (GrayAll1                  ),
    .GrayAll2                          (GrayAll2                  ),
    .finish_clear                      (finish_clear              ),
    // output
    .T_otus                            (T_otus                    ) 
);

// 65M的时钟 = 15.38ns周期
// 65,000,000 clk = 1s
// 65,000clk = 1ms
// 65,000,00 = 100ms = 0.1s
// 19,500,000 = 0.3s
localparam MAX = 11;
localparam MIN = 8;
localparam TIME_MAX = 32'd20_000_000;
reg                    [  31:0]         time_cnt                   ;

always @(posedge clock)
    if (time_cnt > TIME_MAX) time_cnt <= 1'b0;
    else time_cnt <= time_cnt + 1'b1;

always @(posedge clock)
    if (time_cnt == TIME_MAX) begin
        if (T_otus > T && T < MAX) T <= T + 1'b1;
        else if (T_otus < T && T > MIN) T <= T - 1'b1;
    end

endmodule