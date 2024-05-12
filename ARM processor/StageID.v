module StageId(
    input clk, rst,
    // From RegsIfId
    input [31:0] pcIn, inst,
    // From EX
    input [3:0] status,
    // From WB
    input wbWbEn,
    input [31:0] wbValue,
    input [3:0] wbDest,
    // From Hazard
    input hazard,
    // To RegsIdEx
    output [31:0] pcOut,
    output [3:0] aluCmd,
    output memRead, memWriteEn, wbEn, branch, s,
    output [31:0] regRn, regRm,
    output imm,
    output [11:0] shiftOperand,
    output signed [23:0] imm24,
    output [3:0] dest,
    // To Hazard
    output hazardTwoSrc, 
    output [3:0] hazardRn, hazardRdm,
    //sort
    output sort,sort_prev
);

    wire cond, condFinal;
    wire [3:0] aluCmdCU, rn;
    wire [3:0] regfile2Inp;
    wire memReadCU, memWriteCU, wbEnCU, branchCU, sCU,sortCU;

    assign pcOut = pcIn;
    assign imm = inst[25];
    assign shiftOperand = inst[11:0];
    assign imm24 = inst[23:0];
    assign dest = (sort_prev) ? inst[19:16] : inst[15:12];  //sort
    assign rn = inst[19:16];
    assign hazardRn = rn;
    assign hazardRdm = regfile2Inp;
  
    assign hazardTwoSrc = ~imm | memWriteCU;
    assign condFinal = ~cond | hazard;

    ConditionCheck cc(
        .cond(inst[31:28]),
        .status(status),
        .result(cond)
    );

    ControlUnit cu(
        .mode(inst[27:26]),
        .opcode(inst[24:21]),
        .sIn(inst[20]),
        .aluCmd(aluCmdCU),
        .memRead(memReadCU),
        .memWrite(memWriteCU),
        .wbEn(wbEnCU),
        .branch(branchCU),
        .sOut(sCU),
        .sort_previn(sort_prev),
        .sort(sortCU)
    );

    RegisterFile rf(
        .clk(clk),
        .rst(rst),
        .readRegister1(rn),
        .readRegister2(regfile2Inp),
        .writeRegister(wbDest),
        .writeData(wbValue),
        .writeEn(wbWbEn),
        .readData1(regRn),
        .readData2(regRm)
    );

    MUX2to1 #(9) muxCtrlUnit(
        .input1({aluCmdCU, memReadCU, memWriteCU, wbEnCU, branchCU, sCU, sortCU}),
        .input2(10'd0),
        .sel(condFinal),
        .out({aluCmd, memRead, memWriteEn, wbEn, branch, s, sort})
    );

    MUX2to1 #(4) muxRegfile(
        .input1(inst[3:0]),
        .input2(inst[15:12]),
        .sel(memWriteEn | sort),  //sort
        .out(regfile2Inp)
    );

    Register #(1) sort_previous(   //sort
        .clk(clk), .rst(rst),
        .in(sort), .ld(1'b1), .clr(1'b0),
        .out(sort_prev)
    );

endmodule