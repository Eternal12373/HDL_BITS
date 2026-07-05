module top_module (
    input clk,
    input areset,
    input bump_left,
    input bump_right,
    input ground,
    input dig,
    output walk_left,
    output walk_right,
    output aaah,
    output digging
);
    localparam 
        LEFT = 0,
        RIGHT = 1,
        FALLING = 2,
        ST_DIG = 3;

    reg [7:0] state_reg;
    reg [7:0] state_next;

    reg walk_left_reg,walk_left_next;
    reg walk_right_reg,walk_right_next;
    reg aaah_reg,aaah_next;
    reg walk_preserve_reg,walk_preserve_next;
    reg digging_reg,digging_next;

    assign walk_left = walk_left_reg;
    assign walk_right = walk_right_reg;
    assign aaah = aaah_reg;
    assign digging = digging_reg;
    

    always @(*) begin
        state_next = state_reg;
        walk_left_next = walk_left_reg;
        walk_right_next = walk_right_reg;
        walk_preserve_next = walk_preserve_reg;
        aaah_next = aaah_reg;
        digging_next = 0;

        case (state_reg)
            LEFT: begin
                if(!ground) begin
                    state_next = FALLING;
                    aaah_next = 1;
                    walk_left_next = 0;
                    walk_right_next = 0;
                    walk_preserve_next = walk_left_reg;
                end
                else if(dig) begin
                    state_next = ST_DIG;
                    walk_left_next = 0;
                    walk_right_next = 0;
                    digging_next = 1;
                    walk_preserve_next = walk_left_reg;
                end
                else if(bump_left) begin
                    state_next = RIGHT;
                    walk_left_next = 0;
                    walk_right_next = 1;
                end
                else begin
                    walk_left_next = 1;
                    walk_right_next = 0;
                    state_next = LEFT;
                end
            end
            RIGHT: begin
                if (!ground) begin
                    state_next = FALLING;
                    aaah_next = 1;
                    walk_left_next = 0;
                    walk_right_next = 0;
                    walk_preserve_next = walk_left_reg;
                end
                else if(dig) begin
                    state_next = ST_DIG;
                    walk_left_next = 0;
                    walk_right_next = 0;
                    digging_next = 1;

                end
                else if(bump_right) begin
                    state_next = LEFT;
                    walk_right_next = 0;
                    walk_left_next = 1;
                end
                else begin
                    state_next = RIGHT;
                    walk_right_next = 1;
                    walk_left_next = 0;
                end
            end
            FALLING: begin
                if(ground) begin
                    state_next = walk_preserve_reg?LEFT:RIGHT;
                    
                    walk_left_next = walk_preserve_reg;
                    walk_right_next = ~walk_preserve_reg;
                    aaah_next = 0;
                end
                else begin
                    state_next = FALLING;
                    walk_left_next = 0;
                    walk_right_next = 0;
                    aaah_next = 1;
                end
            end
            ST_DIG: begin
                if(!ground) begin
                    state_next = FALLING;
                    aaah_next = 1;
                end 
                else begin
                    digging_next = 1;
                end
            end
            default: state_next = LEFT;
        endcase
    end

    always @(posedge clk,posedge areset) begin
        if(areset) begin
            state_reg <= LEFT;
            walk_left_reg <= 1;
            walk_right_reg <= 0;
            aaah_reg <= 0;
            walk_preserve_reg <= 0;
            digging_reg <= 0;
        end
        else begin
            state_reg <= state_next;
            walk_left_reg <= walk_left_next;
            walk_right_reg <= walk_right_next;
            aaah_reg <= aaah_next;
            walk_preserve_reg <= walk_preserve_next;
            digging_reg <= digging_next;
        end
    end

endmodule
