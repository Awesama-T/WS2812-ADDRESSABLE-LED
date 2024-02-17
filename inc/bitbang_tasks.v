
`include "led_defines.v"


reg serial_in;
wire [1:0] serial_out;
wire [23:0] data_out [1:0];

task send_bit;
    input bit_val;

begin
    if (bit_val) begin
        serial_in = 1;
        #(`T1H);

        serial_in = 0;
        #(`T1L);

    end else begin
        serial_in = 1;
        #(`T0H);

        serial_in = 0;
        #(`T0L);
    end
end
endtask

task send_bytes;
    integer i;
    input [23:0] bytes_to_send;

begin
    for (i = 23; i >= 0; i = i - 1) begin
        send_bit(bytes_to_send[i]);
    end
end
endtask
