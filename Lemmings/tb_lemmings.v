`timescale 1ns/1ps

module tb_lemmings;
    reg clk;
    reg areset;
    reg bump_left;
    reg bump_right;
    reg ground;
    reg [8*5-1:0] state_name;
    wire walk_left;
    wire walk_right;
    wire aaah;

    integer errors;

    top_module dut (
        .clk(clk),
        .areset(areset),
        .bump_left(bump_left),
        .bump_right(bump_right),
        .ground(ground),
        .walk_left(walk_left),
        .walk_right(walk_right),
        .aaah(aaah)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    always @(*) begin
        case (dut.state_reg)
            0: state_name = "LEFT ";
            1: state_name = "RIGHT";
            2: state_name = "FALL ";
            default: state_name = "UNKN ";
        endcase
    end

    task check_outputs;
        input [8*32-1:0] tag;
        input exp_left;
        input exp_right;
        input exp_aaah;
        begin
            if (walk_left !== exp_left || walk_right !== exp_right || aaah !== exp_aaah) begin
                errors = errors + 1;
                $display("FAIL %-32s time=%0t state=%0s left=%0b right=%0b aaah=%0b expected=%0b%0b%0b",
                         tag, $time, state_name, walk_left, walk_right, aaah,
                         exp_left, exp_right, exp_aaah);
            end else begin
                $display("PASS %-32s time=%0t state=%0s left=%0b right=%0b aaah=%0b",
                         tag, $time, state_name, walk_left, walk_right, aaah);
            end
        end
    endtask

    task step_and_check;
        input [8*32-1:0] tag;
        input next_bump_left;
        input next_bump_right;
        input next_ground;
        input exp_left;
        input exp_right;
        input exp_aaah;
        begin
            @(negedge clk);
            bump_left = next_bump_left;
            bump_right = next_bump_right;
            ground = next_ground;
            @(posedge clk);
            #1;
            check_outputs(tag, exp_left, exp_right, exp_aaah);
        end
    endtask

    initial begin
        $dumpfile("tb_lemmings.vcd");
        $dumpvars(0, tb_lemmings);

        errors = 0;
        areset = 1'b1;
        bump_left = 1'b0;
        bump_right = 1'b0;
        ground = 1'b1;

        repeat (2) @(posedge clk);
        #1;
        check_outputs("async reset starts walking left", 1'b1, 1'b0, 1'b0);

        @(negedge clk);
        areset = 1'b0;

        step_and_check("keep walking left",       1'b0, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0);
        step_and_check("bump left turns right",   1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0);
        step_and_check("keep walking right",      1'b0, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0);
        step_and_check("bump right turns left",   1'b0, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0);

        step_and_check("falling from left",       1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1);
        step_and_check("still falling left",      1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1);
        step_and_check("land walking left",       1'b0, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0);

        step_and_check("turn right again",        1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0);
        step_and_check("falling from right",      1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1);
        step_and_check("still falling right",     1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1);
        step_and_check("land walking right",      1'b0, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0);

        if (errors == 0) begin
            $display("PASS all lemmings checks");
            $finish;
        end

        $display("FAIL %0d lemmings checks failed", errors);
        $fatal(1);
    end
endmodule
