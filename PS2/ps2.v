module top_module (
    input clk,
    input reset,
    input [7:0] in,
    output  reg done
);
    localparam 
        IDLE = 0,
        BYTE0 = 1,
        BYTE1 = 2,
        BYTE2 = 3;

    reg [7:0] state_reg;
    reg [7:0] state_next;

    always @(*) begin
        state_next = IDLE;
        done = 0;
        case (state_reg)
            IDLE: begin
                if(in[3] == 1) begin
                    state_next = BYTE0;
                end
            end
            BYTE0: begin
                state_next = BYTE1;
            end
            BYTE1: begin
                state_next = BYTE2;
            end
            BYTE2: begin
                done = 1;

                if(in[3] == 1) begin
                    state_next = BYTE0;
                end
                else begin
                    state_next = IDLE;
                end
            end
            default: state_next = IDLE;
        endcase
    end

    always @(posedge clk,posedge reset) begin
        if(reset) begin
            state_reg <= IDLE;
        end
        else begin
            state_reg <= state_next;
        end
    end

endmodule