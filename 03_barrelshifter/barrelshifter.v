module barrelshifter (
    input wire [31:0] datain,
    input wire [4:0] shiftamt, // shift amount
    input wire [2:0] operation, 
    /* operation type:
        0 - rotate right
        1 - rotate left
        2 - logical left shift
        3 - logical right shift
        rest - out = 0
    */
    output wire [31:0] dataout
);

    wire [63:0] temp1;

    assign temp1 =      {datain,datain} << shiftamt;
    assign dataout =    (operation == 3'd0) ? {datain,datain} >> shiftamt : 
                        (operation == 3'd1) ? temp1[63:32] :
                        (operation == 3'd2) ? datain << shiftamt:
                        (operation == 3'd3) ? datain >> shiftamt:
                        32'd0;
    
endmodule