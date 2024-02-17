`timescale 1ns / 1ns
`include "led_defines.v"

module one_led_nominal_timing_tb;
    `include "bitbang_tasks.v"

    // Instantiate the DUT
    led dut(.i_serial(serial_in),
            .o_serial(serial_out[0]),
            .o_led(data_out[0]));

    initial begin
        // Set up waveform output
        $dumpfile("one_led_nominal_timing_tb.vcd");
        $dumpvars(0, one_led_nominal_timing_tb);

        $display("Starting the test...");

        // Wait at least 50us to ensure reset completion
        #(`RET);

        $display("Reset LED");
        send_bytes(24'hFF00FF);

        if (data_out[0] !== 24'hFF00FF) $display("FAIL: LED output incorrect!");

        #1000; // Just kill a little time...
        $display("Ending the test...");

        $finish;
    end

endmodule
