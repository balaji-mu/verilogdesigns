module rrarb (
    input wire [3:0] req,
    input wire clk,
    input wire rst,
    output wire [1:0] gnt
);
    reg [1:0] ptr;
    reg [1:0] gntreg;
    wire [7:0] reqreq;
    wire [3:0] window;
    wire [1:0] win;

    assign reqreq = {req,req}; // [r3,r2,r1,r0,r3,r2,r1,r0]
    assign gnt = gntreg;

    assign window = reqreq[ptr +: 4]; // window = reqreq[ptr+3:ptr]
    assign win = window[0] ? ptr :
                 window[1] ? ptr+1 :
                 window[2] ? ptr+2 :
                 window[3] ? ptr+3 :
                 0;

    always @(posedge clk or negedge rst) begin
        if (!rst) gntreg <= 2'b0;
        else if (req != 4'b0) gntreg <= win;
    end

    always @(posedge clk or negedge rst) begin
        if (!rst) ptr <= 2'b0;
        else if (req != 4'b0) ptr <= (win + 1);
    end

endmodule