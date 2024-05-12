module HazardUnit(
    input [3:0] rn, rdm,
    input twoSrc,
    input sort,
    input [3:0] destEx, destMem,
    input wbEnEx, wbEnMem,
    output reg hazard,
    output reg sorthazard
);
    always @(rn, rdm, destEx, destMem, wbEnEx, wbEnMem, twoSrc) begin
        hazard = 1'b0;
        sorthazard = 1'b0;
        if(sort) begin //sort
            sorthazard = 1'b1;
        end
        else begin
            if (wbEnEx) begin
                if (rn == destEx || (twoSrc && rdm == destEx)) begin
                    hazard = 1'b1;
                end
            end
            if (wbEnMem) begin
                if (rn == destMem || (twoSrc && rdm == destMem)) begin
                    hazard = 1'b1;
                end
            end
        end
    end
endmodule
