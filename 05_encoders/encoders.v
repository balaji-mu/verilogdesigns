module encoder (
    input wire [15:0] datain,
    output reg [3:0] dataout
);

    // priority encoder
    integer i;
    always @(*) begin
        dataout = 0;
        for (i = 0; i < 16; i = i + 1) begin
            if (datain[i]) dataout = i;
        end
    end
    
endmodule