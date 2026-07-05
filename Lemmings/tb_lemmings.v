`timescale 1ns/1ps

module tb_lemmings;
    reg clk;
    reg areset;
    reg bump_left;
    reg bump_right;
    reg ground;
    reg dig;
    reg [8*7-1:0] state_name;
    wire walk_left;
    wire walk_right;
    wire aaah;
    wire digging;

    integer errors;
    integer i;

    top_module dut (
        .clk(clk),
        .areset(areset),
        .bump_left(bump_left),
        .bump_right(bump_right),
        .ground(ground),
        .dig(dig),
        .walk_left(walk_left),
        .walk_right(walk_right),
        .aaah(aaah),
        .digging(digging)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    always @(*) begin
        case (dut.state_reg)
            0: state_name = "LEFT   ";
            1: state_name = "RIGHT  ";
            2: state_name = "FALLING";
            3: state_name = "DIGGING";
            4: state_name = "DIE    ";
            default: state_name = "UNKN   ";
        endcase
    end

    task check_outputs;
        input [8*40-1:0] tag;
        input exp_left;
        input exp_right;
        input exp_aaah;
        input exp_digging;
        begin
            if (walk_left !== exp_left ||
                walk_right !== exp_right ||
                aaah !== exp_aaah ||
                digging !== exp_digging) begin
                errors = errors + 1;
                $display("FAIL %-40s time=%0t state=%0s cnt=%0d out=%0b%0b%0b%0b expected=%0b%0b%0b%0b",
                         tag, $time, state_name, dut.cnt_reg,
                         walk_left, walk_right, aaah, digging,
                         exp_left, exp_right, exp_aaah, exp_digging);
            end else begin
                $display("PASS %-40s time=%0t state=%0s cnt=%0d out=%0b%0b%0b%0b",
                         tag, $time, state_name, dut.cnt_reg,
                         walk_left, walk_right, aaah, digging);
            end
        end
    endtask

    task step_and_check;
        input [8*40-1:0] tag;
        input next_bump_left;
        input next_bump_right;
        input next_ground;
        input next_dig;
        input exp_left;
        input exp_right;
        input exp_aaah;
        input exp_digging;
        begin
            @(negedge clk);
            bump_left = next_bump_left;
            bump_right = next_bump_right;
            ground = next_ground;
            dig = next_dig;
            @(posedge clk);
            #1;
            check_outputs(tag, exp_left, exp_right, exp_aaah, exp_digging);
        end
    endtask

    task reset_dut;
        begin
            @(negedge clk);
            areset = 1'b1;
            bump_left = 1'b0;
            bump_right = 1'b0;
            ground = 1'b1;
            dig = 1'b0;
            repeat (2) @(posedge clk);
            #1;
            check_outputs("async reset starts walking left", 1'b1, 1'b0, 1'b0, 1'b0);
            @(negedge clk);
            areset = 1'b0;
        end
    endtask

    task short_fall_and_land_left;
        begin
            step_and_check("short fall starts from left", 1'b0, 1'b0, 1'b0, 1'b0,
                           1'b0, 1'b0, 1'b1, 1'b0);
            repeat (5) begin
                step_and_check("short fall stays alive", 1'b0, 1'b0, 1'b0, 1'b0,
                               1'b0, 1'b0, 1'b1, 1'b0);
            end
            step_and_check("short fall lands walking left", 1'b0, 1'b0, 1'b1, 1'b0,
                           1'b1, 1'b0, 1'b0, 1'b0);
        end
    endtask

    task long_fall_and_die;
        begin
            step_and_check("long fall starts", 1'b0, 1'b0, 1'b0, 1'b0,
                           1'b0, 1'b0, 1'b1, 1'b0);
            for (i = 0; i < 22; i = i + 1) begin
                step_and_check("long fall keeps falling", 1'b1, 1'b1, 1'b0, 1'b1,
                               1'b0, 1'b0, 1'b1, 1'b0);
            end
            step_and_check("long fall lands dead", 1'b0, 1'b0, 1'b1, 1'b0,
                           1'b0, 1'b0, 1'b0, 1'b0);
            step_and_check("dead state holds outputs low", 1'b1, 1'b1, 1'b1, 1'b1,
                           1'b0, 1'b0, 1'b0, 1'b0);
        end
    endtask

    task repeated_short_falls_stay_alive;
        begin
            for (i = 0; i < 5; i = i + 1) begin
                short_fall_and_land_left();
                step_and_check("walk after short landing", 1'b0, 1'b0, 1'b1, 1'b0,
                               1'b1, 1'b0, 1'b0, 1'b0);
            end
        end
    endtask

    initial begin
        $dumpfile("tb_lemmings.vcd");
        $dumpvars(0, tb_lemmings);

        errors = 0;
        areset = 1'b0;
        bump_left = 1'b0;
        bump_right = 1'b0;
        ground = 1'b1;
        dig = 1'b0;

        reset_dut();

        step_and_check("keep walking left", 1'b0, 1'b0, 1'b1, 1'b0,
                       1'b1, 1'b0, 1'b0, 1'b0);
        step_and_check("bump left turns right", 1'b1, 1'b0, 1'b1, 1'b0,
                       1'b0, 1'b1, 1'b0, 1'b0);
        step_and_check("keep walking right", 1'b0, 1'b0, 1'b1, 1'b0,
                       1'b0, 1'b1, 1'b0, 1'b0);
        step_and_check("bump right turns left", 1'b0, 1'b1, 1'b1, 1'b0,
                       1'b1, 1'b0, 1'b0, 1'b0);
        short_fall_and_land_left();

        reset_dut();
        step_and_check("dig from left", 1'b0, 1'b0, 1'b1, 1'b1,
                       1'b0, 1'b0, 1'b0, 1'b1);
        step_and_check("keep digging ignores bumps", 1'b1, 1'b1, 1'b1, 1'b0,
                       1'b0, 1'b0, 1'b0, 1'b1);
        step_and_check("dig hole opens and starts fall", 1'b0, 1'b0, 1'b0, 1'b0,
                       1'b0, 1'b0, 1'b1, 1'b0);
        repeat (3) begin
            step_and_check("fall after digging", 1'b0, 1'b0, 1'b0, 1'b1,
                           1'b0, 1'b0, 1'b1, 1'b0);
        end
        step_and_check("land after short dig fall", 1'b0, 1'b0, 1'b1, 1'b0,
                       1'b1, 1'b0, 1'b0, 1'b0);

        reset_dut();
        step_and_check("turn right before digging", 1'b1, 1'b0, 1'b1, 1'b0,
                       1'b0, 1'b1, 1'b0, 1'b0);
        step_and_check("dig from right", 1'b0, 1'b0, 1'b1, 1'b1,
                       1'b0, 1'b0, 1'b0, 1'b1);
        step_and_check("right dig starts falling", 1'b0, 1'b0, 1'b0, 1'b0,
                       1'b0, 1'b0, 1'b1, 1'b0);
        step_and_check("right dig short fall", 1'b0, 1'b0, 1'b0, 1'b0,
                       1'b0, 1'b0, 1'b1, 1'b0);
        step_and_check("right dig lands right", 1'b0, 1'b0, 1'b1, 1'b0,
                       1'b0, 1'b1, 1'b0, 1'b0);

        reset_dut();
        repeated_short_falls_stay_alive();

        reset_dut();
        short_fall_and_land_left();
        step_and_check("turn right after left fall", 1'b1, 1'b0, 1'b1, 1'b0,
                       1'b0, 1'b1, 1'b0, 1'b0);
        step_and_check("dig right after old left direction", 1'b0, 1'b0, 1'b1, 1'b1,
                       1'b0, 1'b0, 1'b0, 1'b1);
        step_and_check("right dig old direction falls", 1'b0, 1'b0, 1'b0, 1'b0,
                       1'b0, 1'b0, 1'b1, 1'b0);
        step_and_check("right dig old direction lands right", 1'b0, 1'b0, 1'b1, 1'b0,
                       1'b0, 1'b1, 1'b0, 1'b0);

        reset_dut();
        long_fall_and_die();

        if (errors == 0) begin
            $display("PASS all lemmings checks");
            $finish;
        end

        $display("FAIL %0d lemmings checks failed", errors);
        $fatal(1);
    end
endmodule
