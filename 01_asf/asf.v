module asf(
	input wire wren,
	input wire [7:0] wrdata,
	input wire clkA,
	output wire isfull,

	input wire rden,
	input wire clkB,
	output wire [7:0] rddata,
	output wire isempty,

	input wire rstA,
	input wire rstB
);

	// pointers
	reg [2:0] n_wrptr;
	reg [2:0] n_rdptr;
    wire [2:0] g_wrptr;
	wire [2:0] g_rdptr;

	// array
	reg [7:0] mem [4];

	// 2FF synchronizer flops
	reg [2:0] ff1_f,ff2_f;
	reg [2:0] ff1_b,ff2_b;


    assign isfull = (g_wrptr[2] != ff2_b[2]) &&
                    (g_wrptr[1] != ff2_b[1]) &&
                    (g_wrptr[0] == ff2_b[0]);
    assign isempty = (ff2_f == g_rdptr);

    // n_wrptr
    always @(posedge clkA or negedge rstA) begin
        if (!rstA) n_wrptr <= 3'b0;
        else if (wren && !isfull) n_wrptr <= n_wrptr + 1;
    end

    // n_rdptr
    always @(posedge clkB or negedge rstB) begin
        if (!rstB) n_rdptr <= 3'b0;
        else if (rden && !isempty) n_rdptr <= n_rdptr + 1;
    end

    assign g_wrptr = (n_wrptr >> 1) ^ n_wrptr;
    assign g_rdptr = (n_rdptr >> 1) ^ n_rdptr;

    // 2FF sync
    always @(posedge clkB or negedge rstB) begin
        if (!rstB) begin
            ff1_f <= 3'b0;
            ff2_f <= 3'b0;
        end else begin
            ff1_f <= g_wrptr;
            ff2_f <= ff1_f;
        end
    end

    always @(posedge clkA or negedge rstA) begin
        if (!rstA) begin
            ff1_b <= 3'b0;
            ff2_b <= 3'b0;
        end else begin
            ff1_b <= g_rdptr;
            ff2_b <= ff1_b;
        end
    end

    always @(posedge clkA) begin
        if (wren && !isfull) mem[n_wrptr[1:0]] <= wrdata;
    end

    assign rddata = mem[n_rdptr[1:0]];

endmodule