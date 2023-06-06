`timescale  1ns / 1ps

module tb_sfifo;

parameter PERIOD     = 10;
parameter DATA_WIDTH = 8;
parameter ADDR_WIDTH = 7;

reg                   rst_n = 0;
reg                   clk = 0;
reg  [7:0]            cnt = 0;
reg  [7:0]            num = 0;
reg                   w_en = 0;
reg                   r_en = 1;

wire [DATA_WIDTH-1:0] data_out;
wire                  full;
wire                  empty;
wire [ADDR_WIDTH:0]   count;

always@(posedge clk or negedge rst_n)
    if (!rst_n) cnt <= 1'b0;
    else cnt <= cnt + 1'b1;

always@(posedge clk or negedge rst_n)
    if (!rst_n) num <= 1'b0;
    else if (&cnt & ~&num) num <= num + 1'b1;

always@(posedge clk or negedge rst_n) 
    if (!rst_n) {w_en, r_en} <= 2'b01;
    else if (&cnt)
        case (num)
            0,1,2   :{w_en, r_en} <= {~w_en, ~r_en};
            3,4     :{w_en, r_en} <= 2'b11;
            5       :{w_en, r_en} <= 2'b01;
            6       :{w_en, r_en} <= 2'b11;
            default :{w_en, r_en} <= 2'b00;
        endcase

sfifo #(
    .DATA_WIDTH     (DATA_WIDTH     ),
    .ADDR_WIDTH     (ADDR_WIDTH     ))
u_sfifo(
    //ports
    .clk              (clk          ),
    .rst_n            (rst_n        ),
    .w_en             (w_en         ),
    .data_in          (cnt          ),
    .r_en             (r_en         ),
    .data_out         (data_out     ),
    .full             (full         ),
    .empty            (empty        ),
    .count            (count        )
);

initial forever #(PERIOD/2)  clk = ~clk;
initial #(PERIOD*2) rst_n  =  1;

initial begin
    #(PERIOD*{ADDR_WIDTH{1'b1}}*17);
    $stop;
end

endmodule