module otus (
    // system
    input  wire                         clock                      ,
    input  wire                         rst_n                      ,
    // input
    input  wire        [   7:0]         iGray_orig                 ,
    input  wire                         hs,vs,de                    
);

wire                                    dsp_vld                    ;
wire                   [  19:0]         N1, N2                     ;
wire                   [  22:0]         GrayAll1,GrayAll2          ;
wire                                    finish_clear               ;

histo u_histo(
    // system
    .clock                             (clock                     ),
    .rst_n                             (rst_n                     ),
    // input
    .iGray_orig                        (iGray_orig                ),
    .hs                                (hs                        ),
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
    .finish_clear                      (finish_clear              ) 
);

endmodule