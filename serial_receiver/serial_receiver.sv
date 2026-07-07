module top_module (
    input clk,
    input in,
    input reset,    // Synchronous reset
    output done
);

    typedef enum logic [7:0] {
        ST_IDLE,
        ST_DATA,
        ST_ERROR
    } state_t;

    state_t state_reg;
    state_t state_next;
    logic [7:0] cnt_reg,cnt_next;
    logic done_reg,done_next;

    assign done = done_reg;

    always_comb begin

        state_next = state_reg;
        cnt_next = cnt_reg;

        done_next = 0;

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
                if(cnt_reg == 8) begin
                    if(in == 1) begin
                        state_next = ST_IDLE;
                        done_next = 1;
                    end
                    else begin
                        state_next = ST_ERROR;
                    end
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
        end
        else begin
            state_reg <= state_next;
            cnt_reg <= cnt_next;
            done_reg <= done_next;
        end
    end
endmodule