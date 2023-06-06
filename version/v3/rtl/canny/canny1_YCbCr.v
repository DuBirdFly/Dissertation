module canny1_YCbCr(
    input                               rgb565_de,rgb565_hs,rgb565_vs,
    input                               clk                        ,
    input              [  15:0]         rgb_iData                  ,
    output             [   7:0]         gray_oData                 ,
    output                              gray_de,gray_hs,gray_vs     
);

wire                   [   7:0]         R0,G0,B0                   ;
reg                    [  15:0]         R1,G1,B1,R2,G2,B2,R3,G3,B3 ;
reg                    [  15:0]         Y1,Cb1,Cr1                 ;
reg                    [   7:0]         Y2,Cb2,Cr2                 ;

assign R0 = {rgb_iData[15:11],rgb_iData[13:11]};                    //R8
assign G0 = {rgb_iData[10: 5],rgb_iData[ 6: 5]};                    //G8
assign B0 = {rgb_iData[ 4: 0],rgb_iData[ 2: 0]};                    //B8

assign gray_oData = Y2;

always @(posedge clk) begin
    {R1,G1,B1} <= { {R0 * 16'd77},  {G0 * 16'd150}, {B0 * 16'd29 } };
    {R2,G2,B2} <= { {R0 * 16'd43},  {G0 * 16'd85},  {B0 * 16'd128} };
    {R3,G3,B3} <= { {R0 * 16'd128}, {G0 * 16'd107}, {B0 * 16'd21 } };
end

always @(posedge clk) begin
    Y1  <= R1 + G1 + B1;
    Cb1 <= B2 - R2 - G2 + 16'd32768;                                //128扩大256倍
    Cr1 <= R3 - G3 - B3 + 16'd32768;                                //128扩大256倍
end

always @(posedge clk) begin
    Y2  <= Y1[15:8];
    Cb2 <= Cb1[15:8];
    Cr2 <= Cr1[15:8];
end

//==    信号同步(打三拍)
reg                    [   2:0]         rgb565_de_r,rgb565_hs_r,rgb565_vs_r;

always @(posedge clk) begin
    rgb565_de_r <= {rgb565_de_r[1:0], rgb565_de};
    rgb565_hs_r <= {rgb565_hs_r[1:0], rgb565_hs};
    rgb565_vs_r <= {rgb565_vs_r[1:0], rgb565_vs};
end

assign gray_de = rgb565_de_r[2];
assign gray_hs = rgb565_hs_r[2];
assign gray_vs = rgb565_vs_r[2];


endmodule