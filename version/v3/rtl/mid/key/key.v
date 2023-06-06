// 按键排布,输入 (直接绑定引脚,注意!!:按下为0, 比较反常): 
//  RESET     iKEY1     iKEY2     iKEY3 
// PIN_N13   PIN_M15   PIN_M16   PIN_E16
// 经过 key_filtering 按键消抖后,输出: 按下为1, 松开为0 (对输入做了取反, 使之不那么反常)
// 经过 getNegPos 按键信号变成了单时钟周期信号

module key (
    input  wire                         sys_clk                    ,// 50MHz
    input  wire                         iKey1,iKey2,iKey3          ,// 按下为1,松开为0
    output wire                         oKey1,oKey2,oKey3           // 取按下上升沿的1个CLK为1
);

wire                                    fKey1,fKey2,fKey3          ;// filtered key:消抖过的key信号,按下为1,松开为0,单CLK的信号

/* 按键消抖 */
key_filtering u_key1_filtering(
    .clk            ( sys_clk       ),
    .key            ( iKey1         ),
    .key_filter     ( fKey1         ) 
);

key_filtering u_key2_filtering(
    .clk            ( sys_clk       ),
    .key            ( iKey2         ),
    .key_filter     ( fKey2         ) 
);

key_filtering u_key3_filtering(
    .clk            ( sys_clk       ),
    .key            ( iKey3         ),
    .key_filter     ( fKey3         ) 
);

/* 按键上升沿 */
getNegPos u1_getNegPos(
    .clk            ( sys_clk       ),
    .iData          ( fKey1         ),
    .oPos           ( oKey1         )
);

getNegPos u2_getNegPos(
    .clk            ( sys_clk       ),
    .iData          ( fKey2         ),
    .oPos           ( oKey2         )
);

getNegPos u3_getNegPos(
    .clk            ( sys_clk       ),
    .iData          ( fKey3         ),
    .oPos           ( oKey3         )
);

endmodule
