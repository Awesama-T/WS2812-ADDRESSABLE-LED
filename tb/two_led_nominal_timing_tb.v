`timescale 1ns / 1ns
`include "led_defines.v"

module two_led_nominal_timing_tb;
    `include "bitbang_tasks.v"

    // Instantiate the DUT
    led dut0(.i_serial(serial_in),
             .o_serial(serial_out[0]),
             .o_led(data_out[0]));

    // Instantiate the DUT
    led dut1(.i_serial(serial_out[0]),
             .o_serial(serial_out[1]),
             .o_led(data_out[1]));

    initial begin
        // Set up waveform output
        $dumpfile("two_led_nominal_timing_tb.vcd");
        $dumpvars(0, two_led_nominal_timing_tb);

        $display("Starting the test...");

        // Wait at least 50us to ensure reset completion
        #(`RET);
        $display("Reset LED");
        send_bytes(24'hFF00FF);
        send_bytes(24'h00FF00);
        if (data_out[0] !== 24'hFF00FF) $display("FAIL: LED output incorrect!");
        if (data_out[1] !== 24'h00FF00) $display("FAIL: LED output incorrect!");

        #1000; // Just kill a little time...
        $display("Ending the test...");

        $finish;
    end

endmodule
