module top_module (
    input clk,
    input reset,
    input [7:0] in,
    output reg [23:0] out_bytes,
    output  reg done
);
    localparam 
        BYTE0 = 0,
        BYTE1 = 1,
        BYTE2 = 2;

    reg [7:0] state_reg;
    reg [7:0] state_next;
    reg [23:0] out_bytes_next;
    reg done_next;

    always @(*) begin
        state_next = BYTE0;
        done_next = 0;
        out_bytes_next = out_bytes;
        case (state_reg)
            BYTE0: begin
                out_bytes_next[23:16] = in; 
                if(in[3] == 1) begin
                    state_next = BYTE1;
                end
            end
            BYTE1: begin
                out_bytes_next[15:8] = in;
                state_next = BYTE2;
            end
            BYTE2: begin
                out_bytes_next[7:0] = in;
                done_next = 1;
                state_next = BYTE0;

            end
            default: state_next = BYTE0;
        endcase
    end

    always @(posedge clk,posedge reset) begin
        if(reset) begin
            state_reg <= BYTE0;
            out_bytes <= 0;
        end
        else begin
            state_reg <= state_next;
            out_bytes <= out_bytes_next;
            done <= done_next;
        end
    end

endmodule