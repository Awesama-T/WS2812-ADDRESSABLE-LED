`timescale 1ns / 1ns
`include "led.v"
`define T0H     350.0   // 0.35 us
`define T0L     800.0   // 0.8 us
`define T1H     700.0   // 0.7 us
`define T1L     600.0   // 0.6 us
`define MARGIN  150.0   // +/- 150 ns
`define RET     50000.0 // 50 us

module sams_tb;

localparam SKEWED = 1;
localparam NORMAL = 0;

reg serial_in =0;
wire [1:0] serial_out;
wire [23:0] data_out [1:0];
//***********************************************************************
//  Task to send bits normaly
//***********************************************************************
task send_bit;
    input bit_val;

begin
    if (bit_val) 
    begin
        serial_in = 1;
        #(`T1H);

        serial_in = 0;
        #(`T1L);
    end else 
    begin
        serial_in = 1;
        #(`T0H);

        serial_in = 0;
        #(`T0L);
        serial_in = 1;
    end
end
endtask
//***********************************************************************
//  Task to send bits with skew
//***********************************************************************
task send_bit_skewed;
    input bit_val;

begin
    if (bit_val) 
    begin
        serial_in = 1;
        #(`T1H - `MARGIN);

        serial_in = 0;
        #(`T1L - `MARGIN);
    end else 
    begin
        serial_in = 1;
        #(`T0H + `MARGIN);

        serial_in = 0;
        #(`T0L + `MARGIN);
        serial_in = 1;
    end
end
endtask
//***********************************************************************
// Task to send 24-bits; either normally or skewed
// if sel==1 send bytes in a skewed sequence
// if sel==0 send bytes in a normal sequence
//***********************************************************************
task send_bytes;
    integer i;
    input [23:0] bytes_to_send;
    input sel;

begin
    for (i = 23; i >= 0; i = i - 1) 
    begin
        if(~sel)
        send_bit(bytes_to_send[i]);
        else 
        send_bit_skewed(bytes_to_send[i]);
    end
end
endtask
//***********************************************************************
//  Task to display a special message
//***********************************************************************
task show_sacred_msg;
    integer j;
    reg [95:0] str1;
    begin
        str1 = "Xnt&qd^ghqdc";//coded message
    for (j = 0; j < 12; j = j+1) begin
        str1[8*j +: 8] = str1[8*j +: 8]+8'd1;
    end
    $display("%s", str1);
end
endtask


    // Instantiate the DUT
    led dut0(.i_serial(serial_in),
             .o_serial(serial_out[0]),
             .o_led(data_out[0]));

    // Instantiate the DUT
    led dut1(.i_serial(serial_out[0]),
             .o_serial(serial_out[1]),
             .o_led(data_out[1]));


    initial 
    begin 
        // Set up waveform output
        $dumpfile("sams_tb.vcd");
        $dumpvars(0, sams_tb);

        $display("Starting the test...");

        // Wait at least 50us to ensure reset completion
        #(`RET);
        $display("Reset LEDs");
        send_bytes(24'hF0F0FF, NORMAL);
        send_bytes(24'hF0F0FF, NORMAL);
        if (data_out[0] !== 24'hF0F0FF) $display("FAIL: LED1 output incorrect!");else show_sacred_msg();
        if (data_out[1] !== 24'hF0F0FF) $display("FAIL: LED2 output incorrect!");else show_sacred_msg();
        #(`RET);
        $display("Reset LEDs again");
        send_bytes(24'hF0F0FF, SKEWED);
        send_bytes(24'hF0F0FF, SKEWED);
        if (data_out[0] !== 24'hF0F0FF) $display("FAIL: LED1 output incorrect!"); else show_sacred_msg();
        if (data_out[1] !== 24'hF0F0FF) $display("FAIL: LED2 output incorrect!"); else show_sacred_msg();
        #1500; // Just kill a little time...
        $display("Ending the test...");

        $finish;
    end

endmodule

