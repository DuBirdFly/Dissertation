module sort
//========================< 端口 >==========================================
(
//system --------------------------------------------
input   wire                clk                     ,
//input ---------------------------------------------
input   wire    [7:0]       data1                   ,
input   wire    [7:0]       data2                   ,
input   wire    [7:0]       data3                   ,
//output --------------------------------------------
output  reg     [7:0]       max_data                , //最大值
output  reg     [7:0]       mid_data                , //中间值
output  reg     [7:0]       min_data                  //最小值
);
//==========================================================================
//==    最大值
//==========================================================================
always @(posedge clk) begin
    if(data1 >= data2 && data1 >= data3)
        max_data <= data1;
    else if(data2 >= data1 && data2 >= data3)
        max_data <= data2;
    else if(data3 >= data1 && data3 >= data2)
        max_data <= data3;
end
//==========================================================================
//==    中间值
//==========================================================================
always @(posedge clk) begin
    if((data2 >= data1 && data1 >= data3) || (data3 >= data1 && data1 >= data2))
        mid_data <= data1;
    else if((data1 >= data2 && data2 >= data3) || (data3 >= data2 && data2 >= data1))
        mid_data <= data2;
    else if((data1 >= data3 && data3 >= data2) || (data1 >= data3 && data3 >= data2))
        mid_data <= data3;
end
//==========================================================================
//==    最小值
//==========================================================================
always @(posedge clk) begin
     if(data3 >= data2 && data2 >= data1)
        min_data <= data1;
    else if(data3 >= data1 && data1 >= data2)
        min_data <= data2;
    else if(data1 >= data2 && data2 >= data3)
        min_data <= data3;
end

endmodule