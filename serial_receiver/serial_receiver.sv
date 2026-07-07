module top_module (
    input clk,
    input in,
    input reset,    // Synchronous reset
    output [7:0] out_byte,
    output done
);

    typedef enum logic [7:0] {
        ST_IDLE,
        ST_DATA,
        ST_JUDGE,
        ST_ERROR
    } state_t;

    state_t state_reg;
    state_t state_next;
    logic [7:0] cnt_reg,cnt_next;
    logic done_reg,done_next;
    reg [7:0] out_byte_reg,out_byte_next;

    assign done = done_reg;
    assign out_byte = out_byte_reg;
    always_comb begin

        state_next = state_reg;
        cnt_next = cnt_reg;

        done_next = 0;
        out_byte_next = out_byte_reg;

        case (state_reg)
            ST_IDLE: 
            begin
                cnt_next = 0;
                if(!in) begin
                    state_next = ST_DATA;
                end
            end
            ST_DATA: 
            begin
                cnt_next = cnt_reg + 1'b1;
                out_byte_next[cnt_reg] = in;
                
                if(cnt_reg == 7) begin
                    state_next = ST_JUDGE;
                end
            end
            ST_JUDGE:begin
                if (in) begin
                    state_next = ST_IDLE;
                    done_next = 1;
                end
                else begin
                    state_next = ST_ERROR;
                end
            end
            ST_ERROR: begin
                if(in == 1) begin
                    state_next = ST_IDLE;
                end
            end
            default: state_next = ST_IDLE;
        endcase
    end    

    always_ff @(posedge clk) begin
        if(reset) begin
            state_reg <= ST_IDLE;
            done_reg <= 0;
            cnt_reg <= 0;
            out_byte_reg <= 0;
        end
        else begin
            state_reg <= state_next;
            cnt_reg <= cnt_next;
            done_reg <= done_next;
            out_byte_reg <= out_byte_next;
        end
    end
endmodule