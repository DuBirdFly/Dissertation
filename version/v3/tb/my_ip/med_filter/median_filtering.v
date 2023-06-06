module median_filtering (
    input  wire         clk,rst_n,
    input  wire [7:0]   iData,
    input  wire         i_de,i_hs,i_vs,
    output wire         med_hs,med_vs,med_de,
    output wire [7:0]   oData      
);

//--------------------------------------------------- 矩阵顺序
//        {matrix_11, matrix_12, matrix_13}
//        {matrix_21, matrix_22, matrix_23}
//        {matrix_31, matrix_32, matrix_33}
//--------------------------------------------------- 模块例化
// 耗费1clk
wire [7:0] matrix_11, matrix_12, matrix_13,matrix_21,matrix_22, matrix_23, matrix_31, matrix_32, matrix_33;

opr_3x3 #(
    .DATA_WIDTH         ( 8         ),
    .ADDR_WIDTH         ( 7         ))
u_opr_3x3(
    //ports
    .clk           (clk              ),
    .rst_n         (rst_n            ),
    .clken         (i_de             ),
    .din           (iData            ),
    .a1            (matrix_11        ),
    .a2            (matrix_12        ),
    .a3            (matrix_13        ),
    .a4            (matrix_21        ),
    .a5            (matrix_22        ),
    .a6            (matrix_23        ),
    .a7            (matrix_31        ),
    .a8            (matrix_32        ),
    .a9            (matrix_33        )
);

//==========================================================================
//==    中值滤波，耗费3clk
/*
　　(1)对窗内的每行像素按降序排序，得到最大值、中间值和最小值。
　　(2)把三行的最小值即第三列相比较，取其中的最大值。
　　(3)把三行的最大值即第- -列相比较，取其中的最小值。
　　(4)把三行的中间值即第二列相比较，再取一次中间值。
　　(5)把前面的到的三个值再做一次排序，获得的中值即该窗口的中值。

　　第1个周期实现（1），第2个周期实现（2）（3）（4），第3个周期实现（5）。
*/
//==========================================================================
//每行像素降序排列，clk1
//---------------------------------------------------
wire [7:0] max_data1,max_data2,max_data3,
           mid_data1,mid_data2,mid_data3,
           min_data1,min_data2,min_data3;
wire [7:0] max_min_data,mid_mid_data,min_max_data;

//第1行
sort u1 (
    .clk                    (clk                    ),
    .data1                  (matrix_11              ), 
    .data2                  (matrix_12              ), 
    .data3                  (matrix_13              ),
    .max_data               (max_data1              ),
    .mid_data               (mid_data1              ),
    .min_data               (min_data1              )
);

//第2行
sort u2 (
    .clk                    (clk                    ),
    .data1                  (matrix_21              ),
    .data2                  (matrix_22              ),
    .data3                  (matrix_23              ),
    .max_data               (max_data2              ),
    .mid_data               (mid_data2              ),
    .min_data               (min_data2              )
);

//第3行
sort u3 (
    .clk                    (clk                    ),
    .data1                  (matrix_31              ),
    .data2                  (matrix_32              ),
    .data3                  (matrix_33              ),
    .max_data               (max_data3              ),
    .mid_data               (mid_data3              ),
    .min_data               (min_data3              )
);

//三行的最小值取最大值
//三行的中间值取中间值
//三行的最大值取最小值，clk2
//---------------------------------------------------
//min-max
sort u4 (
    .clk                    (clk                    ),
    .data1                  (min_data1              ),
    .data2                  (min_data2              ),
    .data3                  (min_data3              ),
    .max_data               (min_max_data           ),
    .mid_data               (                       ),
    .min_data               (                       )
);

//mid-mid
sort u5 (
    .clk                    (clk                    ),
    .data1                  (mid_data1              ),
    .data2                  (mid_data2              ),
    .data3                  (mid_data3              ),
    .max_data               (                       ),
    .mid_data               (mid_mid_data           ),
    .min_data               (                       )
);

//max-min
sort u6 (
    .clk                    (clk                    ),
    .data1                  (max_data1              ), 
    .data2                  (max_data2              ), 
    .data3                  (max_data3              ),
    .max_data               (                       ),
    .mid_data               (                       ),
    .min_data               (max_min_data           )
);

//前面的三个值再取中间值，clk3
//---------------------------------------------------
sort u7 (
    .clk                    (clk                    ),
    .data1                  (max_min_data           ),
    .data2                  (mid_mid_data           ), 
    .data3                  (min_max_data           ),
    .max_data               (                       ),
    .mid_data               (oData                  ),
    .min_data               (                       )
);


//==========================================================================
//==    信号同步，4个拍子
//==========================================================================
reg [3:0]i_de_r,i_hs_r,i_vs_r;

always @(posedge clk) begin
    i_de_r <= {i_de_r[2:0], i_de};
    i_hs_r <= {i_hs_r[2:0], i_hs};
    i_vs_r <= {i_vs_r[2:0], i_vs};
end

assign med_de = i_de_r[3];
assign med_hs = i_hs_r[3];
assign med_vs = i_vs_r[3];

endmodule