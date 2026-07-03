`timescale 1ns/1ps

module tb_ps2;
    reg clk;
    reg reset;
    reg [7:0] in;
    reg [8*5-1:0] state_name;
    wire done;

    top_module dut (
        .clk(clk),
        .reset(reset),
        .in(in),
        .done(done)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    always @(*) begin
        case (dut.state_reg)
            0: state_name = "IDLE ";
            1: state_name = "BYTE0";
            2: state_name = "BYTE1";
            3: state_name = "BYTE2";
            default: state_name = "UNKN ";
        endcase
    end

    task send_byte;
        input [7:0] value;
        begin
            @(negedge clk);
            in = value;
            @(posedge clk);
            #1;
            $display("%0t in=%02h in[3]=%0b state=%0d done=%0b",
                     $time, in, in[3], dut.state_reg, done);
        end
    endtask

    initial begin
        $dumpfile("tb_ps2.vcd");
        $dumpvars(0, tb_ps2);

        reset = 1'b1;
        in = 8'h00;

        repeat (2) @(posedge clk);
        @(negedge clk);
        reset = 1'b0;

        send_byte(8'h6b);
        send_byte(8'h1d);
        send_byte(8'hca);

        repeat (4) begin
            @(posedge clk);
            #1;
            $display("%0t in=%02h in[3]=%0b state=%0d done=%0b",
                     $time, in, in[3], dut.state_reg, done);
        end

        $finish;
    end
endmodule
