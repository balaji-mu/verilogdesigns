module decoder4_16(
    input wire[3:0] datain,
    input wire enable,
    output wire [15:0] dataout
);
    assign dataout = (enable) ? 16'd1 << datain : 16'd0;
endmodule
