// w_en，r_en支持同时为1，即边读边写
// full在最后一个空位被填上后输出1，此时count[ADDR_WIDTH-1,0] = 'd0；count[ADDR_WIDTH] = 1'd0
// full=1时如果接着边读边写，则在1个clk后full为0，此时count = {ADDR_WIDTH{1'b1}}
// full=1时如果接着边读边写，则实际读取的延时为1-clk，事实上只要fifo里有数据，读取的延时均为1clk
// empty在全清空时输出1，此时count = 0；
// empty=1时如果接着边读边写，则在1个clk后empty为0，此时count = 1'b1
// empty=1时如果接着边读边写，则实际读取的延时为2-clk，因为需要先实际写入1个数据才能读出数据，所以比一般情况要再加1-clk

module sfifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 7
)(
    // sys
    input  wire                        clk, rst_n,
    // write
    input  wire                        w_en, 
    input  wire [DATA_WIDTH - 1:0]     data_in,
    // read
    input  wire                        r_en,
    output reg  [DATA_WIDTH - 1:0]     data_out,
    // ctrl signal
    output wire                        full, empty,
    output reg  [ADDR_WIDTH : 0]       count
);

    reg [ADDR_WIDTH - 1 : 0] w_addr,r_addr;
    reg [DATA_WIDTH - 1 : 0] mem [{ADDR_WIDTH{1'b1}}:0];

    integer i;
    //memory的初始化以及写操作
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            w_addr<=0;
            for(i=0;i<={ADDR_WIDTH{1'b1}};i=i+1)
                mem[i]<={DATA_WIDTH{1'b0}};
        end
        else if(w_en&(~full)) begin
            mem[w_addr]<=data_in;
            w_addr<=w_addr+1;
        end
    end

    //读操作
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            data_out<={(DATA_WIDTH-1){1'b0}};
            r_addr<=0;
        end
        else if(r_en&(~empty)) begin
            data_out<=mem[r_addr];
            r_addr<=r_addr+1;
        end
    end

    //count产生空满标志符
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n)
            count<=0;
        else if(((w_en)&(~full))&(~((r_en)&(~empty))))
            count<=count+1;
        else if(((r_en)&(~empty))&(~((w_en)&(~full))))
            count<=count-1;
    end

    assign empty=(count==0);
    assign full=(count=={ADDR_WIDTH{1'b1}}+1);

    
endmodule