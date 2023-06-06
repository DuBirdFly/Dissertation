module canny_top (
    input  wire       clk, rst_n,
    input  wire [7:0] gray_data,
    input  wire       gray_hs, gray_vs, gray_de,
    output wire [7:0] NMS_data,
    output wire       NMS_hs, NMS_vs, NMS_de

);

wire [7:0] Gx, Gy, Mxy;
wire       sobel_hs, sobel_vs, sobel_de;

sobel u_sobel(
    .clk               ( clk               ),
    .rst_n             ( rst_n             ),
    // input
    .gray_data         ( gray_data         ),
    .gray_hs           ( gray_hs           ),
    .gray_vs           ( gray_vs           ),
    .gray_de           ( gray_de           ),
    // output
    .Gx                ( Gx                ),
    .Gy                ( Gy                ),
    .Mxy               ( Mxy               ),
    .sobel_hs          ( sobel_hs          ),
    .sobel_vs          ( sobel_vs          ),
    .sobel_de          ( sobel_de          )
);

nms u_nms(
    .clk              ( clk              ),
    .rst_n            ( rst_n            ),
    // input
    .Gx               ( Gx               ),
    .Gy               ( Gy               ),
    .Mxy              ( Mxy              ),
    .sobel_hs         ( sobel_hs         ),
    .sobel_vs         ( sobel_vs         ),
    .sobel_de         ( sobel_de         ),
    // output
    .NMS_data         ( NMS_data         ),
    .NMS_hs           ( NMS_hs           ),
    .NMS_vs           ( NMS_vs           ),
    .NMS_de           ( NMS_de           )
);

endmodule