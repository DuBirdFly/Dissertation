/**
 * 输入的key     信号--按下为低电平(0)，松开为高电平(1)
 * 输出的key_filter信号--【自定义】: 按下为(1)，松开为(0)
 */

module key_filtering (
    input  wire                         clk                        ,
    input  wire                         key                        ,// 按下为(0)，松开为(1)
    output reg                          key_filter                  // 按下为(1)，松开为(0)
);
    parameter                           cnt_max = 19'd50_0000      ;

reg                                     key_reg                    ;
reg                    [  18:0]         timer                      ;

always@(posedge clk) begin
    key_reg <= key;
    if(key != key_reg)
        timer <= cnt_max;
    else begin
        if(timer > 1'd0)
            timer <= timer - 1'd1;
        else
            timer <= 1'd0;
    end
end

//输出的key_filter信号--自定义
always@(posedge clk)
    if(timer == 1'd0 && key_reg == 1'b0)
        key_filter <= 1'b1;                                         //按下按键(的所有时间)
    else
        key_filter <= 1'b0;                                         //松开按键

endmodule

