module PE (
    input                   clk,
    input                   rstn,
    input       [15:0]      A,
    input       [15:0]      B,
    input       [15:0]      C,
    input                   en,
    output  reg  [15:0]     result,
    output  reg             valid
);

    reg mode;

    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            result <= 0;
            valid <= 0;
            mode <= 0;
        end
        // else if(en) begin
        //     if(!mode)begin
        //         result <= A * B;
        //         valid <= 0;
        //         mode <= 1;
        //     end
        //     else begin
        //         result <= result + C;
        //         valid <= 1;
        //         mode <= 0;
        //     end
        // end

        else if(!mode) begin
            if(en)begin
                result <= A*B;
                valid <= 0;
                mode <= 1;
            end
            else
                valid <= 0;
        end
        else begin
            result <= result + C;
            valid <= 1;
            mode <= 0;
        end


    end
endmodule
