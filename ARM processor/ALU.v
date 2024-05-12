
module ALU #(
    parameter N = 32
)(
    input [N-1:0] a, b,
    input carryIn,
    input [3:0] EXE_CMD,
    output reg [N-1:0] out,
    output [3:0] status
);
    reg c, v;
    wire z, n;
    wire [31:0] sub1,sub2;
    assign status = {n, z, c, v};
    assign z = ~|out;
    assign n = out[N-1];

    //sort
    assign {c,sub1} = a - b;
    assign {c,sub2} = b - a;

    wire [N-1:0] carryExt, nCarryExt;
    assign carryExt = {{(N-1){1'b0}}, carryIn};
    assign nCarryExt = {{(N-1){1'b0}}, ~carryIn};

    always @(EXE_CMD or a or b or carryExt or nCarryExt) begin
        out = {N{1'b0}};
        c = 1'b0;

        case (EXE_CMD)
            4'b0001: out = b;                      // MOV
            4'b1001: out = ~b;                     // MVN
            4'b0010: {c, out} = a + b;             // ADD
            4'b0011: {c, out} = a + b + carryExt;  // ADC
            4'b0100: {c, out} = a - b;             // SUB
            4'b0101: {c, out} = a - b - nCarryExt; // SBC
            4'b0110: out = a & b;                  // AND
            4'b0111: out = a | b;                  // ORR
            4'b1000: out = a ^ b;                  // EOR
            4'b1010: out = (sub1[31]) ? b : a;      //sort1
            4'b1011: out = (sub2[31]) ? b : a;      //sort2
            default: out = {N{1'b0}};
        endcase
        
        //overflow
        v = 1'b0;
        if (EXE_CMD[3:1] == 3'b001) begin      // ADD, ADC
            v = (a[N-1] == b[N-1]) && (a[N-1] != out[N-1]);
        end
        else if (EXE_CMD[3:1] == 3'b010) begin // SUB, SBC
            v = (a[N-1] != b[N-1]) && (a[N-1] != out[N-1]);
        end
    end
endmodule