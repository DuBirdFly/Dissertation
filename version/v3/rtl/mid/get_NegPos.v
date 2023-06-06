module getNegPos (
    input  wire                         clk                        ,//50MHz
    input  wire                         iData                      ,
    output wire                         oNeg, oPos                  
);

reg                                     iData_d1                   ;

assign oPos = iData & (~iData_d1);
assign oNeg = (~iData) & iData_d1;

always @(posedge clk) iData_d1 <= iData;

endmodule
